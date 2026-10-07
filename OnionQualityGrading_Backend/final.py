import os
import json
import subprocess

from PIL import Image

import torch
import torch.nn as nn

from torchvision import models, transforms

from inference_sdk import InferenceHTTPClient


# ============================================================
# CONFIGURATION
# ============================================================

# Set these in PowerShell:
#
# $env:ROBOFLOW_API_KEY="YOUR_NEW_ROBOFLOW_KEY"
# $env:DATA_GOV_API_KEY="YOUR_NEW_DATA_GOV_KEY"

ROBOFLOW_API_KEY = "lms0LlKQfzm39SwBouMs"
DATA_GOV_API_KEY = "579b464db66ec23bdd000001f09f0db0330d49c84d28feefd141e284"


if not ROBOFLOW_API_KEY:
    raise RuntimeError(
        "ROBOFLOW_API_KEY is not set!"
    )

if not DATA_GOV_API_KEY:
    raise RuntimeError(
        "DATA_GOV_API_KEY is not set!"
    )


# ============================================================
# MODEL / API SETTINGS
# ============================================================

YOLO_MODEL_ID = "onion-detection-team/1"

DATA_GOV_RESOURCE_ID = (
    "9ef84268-d588-465a-a308-a864a43d0070"
)

CONFIDENCE_THRESHOLD = 0.80


# ============================================================
# SIZE THRESHOLDS
# ============================================================

# Reference image height used when the thresholds were calibrated.
# Normalizing to this reference prevents high-resolution phone
# images from making every onion appear Large.
REFERENCE_IMAGE_HEIGHT = 720.0

# Stricter thresholds: more onions will fall into Small.
SMALL_THRESHOLD = 170
LARGE_THRESHOLD = 230


# ============================================================
# QUALITY WEIGHTS
# ============================================================

HEALTH_WEIGHT = 0.60
SIZE_WEIGHT = 0.40


# ============================================================
# HEALTH MODEL
# ============================================================

MODEL_PATH = (
    r"D:\SIH\OnionQualityGrading\onion_health_model.pth"
)


# ============================================================
# DEVICE
# ============================================================

DEVICE = torch.device(
    "cuda"
    if torch.cuda.is_available()
    else "cpu"
)

print("=" * 70)
print("              ONION QUALITY GRADING SYSTEM")
print("=" * 70)

print("\nDevice:", DEVICE)

if torch.cuda.is_available():
    print(
        "GPU:",
        torch.cuda.get_device_name(0)
    )


# ============================================================
# LOAD EFFICIENTNET-B0
# ============================================================

print("\nLoading health model...")

checkpoint = torch.load(
    MODEL_PATH,
    map_location=DEVICE
)

CLASS_NAMES = checkpoint.get(
    "classes",
    ["Healthy", "Unhealthy"]
)

model = models.efficientnet_b0(
    weights=None
)

num_features = (
    model.classifier[1].in_features
)

model.classifier[1] = nn.Linear(
    num_features,
    len(CLASS_NAMES)
)

model.load_state_dict(
    checkpoint["model_state_dict"]
)

model.to(DEVICE)
model.eval()

IMAGE_SIZE = checkpoint.get(
    "image_size",
    224
)


# ============================================================
# IMAGE TRANSFORM
# ============================================================

transform = transforms.Compose([

    transforms.Resize(
        (IMAGE_SIZE, IMAGE_SIZE)
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[
            0.485,
            0.456,
            0.406
        ],
        std=[
            0.229,
            0.224,
            0.225
        ]
    )
])

print("Health model loaded.")
print("Classes:", CLASS_NAMES)


# ============================================================
# INITIALIZE ROBOFLOW
# ============================================================

print("\nInitializing YOLO...")

client = InferenceHTTPClient(
    api_url="https://serverless.roboflow.com",
    api_key=ROBOFLOW_API_KEY
)

print("YOLO initialized.")


# ============================================================
# HEALTH PREDICTION
# ============================================================

def predict_health(crop):

    image = crop.convert("RGB")

    tensor = transform(image)

    tensor = tensor.unsqueeze(0)

    tensor = tensor.to(DEVICE)

    with torch.no_grad():

        output = model(tensor)

        probabilities = torch.softmax(
            output,
            dim=1
        )

        confidence, predicted = torch.max(
            probabilities,
            dim=1
        )

    class_name = CLASS_NAMES[
        predicted.item()
    ]

    return (
        class_name,
        confidence.item() * 100
    )


# ============================================================
# SIZE CLASSIFICATION
# ============================================================

def classify_size(width, height, image_height=None):

    # Raw YOLO bounding-box diameter.
    raw_diameter = (
        float(width) + float(height)
    ) / 2.0

    # Normalize to the 720px reference height.
    # Example: a 1440px image gets scale=0.5, so its
    # bounding boxes are compared fairly with the calibration.
    if image_height and image_height > 0:

        scale = (
            REFERENCE_IMAGE_HEIGHT
            / float(image_height)
        )

        diameter = raw_diameter * scale

    else:

        diameter = raw_diameter

    if diameter < SMALL_THRESHOLD:

        size = "Small"
        score = 50

    elif diameter <= LARGE_THRESHOLD:

        size = "Medium"
        score = 75

    else:

        size = "Large"
        score = 100

    return (
        size,
        score,
        diameter
    )


# ============================================================
# FETCH MANDI PRICES
# ============================================================

def fetch_mandi_prices():

    print("\n")
    print("=" * 70)
    print("FETCHING INDIA-WIDE ONION MANDI PRICES")
    print("=" * 70)

    url = (
        "https://api.data.gov.in/resource/"
        + DATA_GOV_RESOURCE_ID
    )

    command = [

        "curl.exe",

        "--get",

        "--max-time",
        "120",

        url,

        "--data-urlencode",
        f"api-key={DATA_GOV_API_KEY}",

        "--data-urlencode",
        "format=json",

        "--data-urlencode",
        "limit=1000",

        "--data-urlencode",
        "filters[commodity]=Onion"
    ]

    try:

        result = subprocess.run(

            command,

            capture_output=True,

            text=True,

            encoding="utf-8",

            errors="replace"
        )

    except FileNotFoundError:

        print("ERROR: curl.exe was not found.")
        return []

    if result.returncode != 0:

        print("Mandi API error:")
        print(result.stderr)

        return []

    response = result.stdout.strip()

    if not response:

        print("Empty response received.")
        return []

    try:

        data = json.loads(
            response
        )

    except json.JSONDecodeError:

        print(
            "Could not read mandi API response."
        )

        print(response[:1000])

        return []

    records = data.get(
        "records",
        []
    )

    print(
        "Mandi records received:",
        len(records)
    )

    return records


# ============================================================
# PROCESS MANDI RECORDS
# ============================================================

def process_mandi_records(records):

    valid_records = []

    for record in records:

        state = str(
            record.get(
                "state",
                ""
            )
        ).strip()

        commodity = str(
            record.get(
                "commodity",
                ""
            )
        ).strip()

        variety = str(
            record.get(
                "variety",
                ""
            )
        ).strip()


        # Only Onion
        if commodity.lower() != "onion":
            continue


        # Exclude green onion
        if (
            "green" in commodity.lower()
            or
            "green" in variety.lower()
        ):
            continue


        # Tamil Nadu:
        # Only Bellary
        if state.lower() == "tamil nadu":

            if variety.lower() != "bellary":
                continue


        try:

            min_price = float(
                record.get(
                    "min_price",
                    0
                ) or 0
            )

            max_price = float(
                record.get(
                    "max_price",
                    0
                ) or 0
            )

            modal_price = float(
                record.get(
                    "modal_price",
                    0
                ) or 0
            )

        except (
            ValueError,
            TypeError
        ):

            continue


        if (
            min_price <= 0
            or
            modal_price <= 0
            or
            max_price <= 0
        ):
            continue


        valid_records.append({

            "state": state,

            "district": str(
                record.get(
                    "district",
                    ""
                )
            ).strip(),

            "market": str(
                record.get(
                    "market",
                    ""
                )
            ).strip(),

            "commodity": commodity,

            "variety": variety,

            "grade": str(
                record.get(
                    "grade",
                    ""
                )
            ).strip(),

            "arrival_date": str(
                record.get(
                    "arrival_date",
                    ""
                )
            ).strip(),

            "min_price": min_price,

            "max_price": max_price,

            "modal_price": modal_price
        })

    return valid_records


# ============================================================
# MARKET SUMMARY
# ============================================================

def calculate_market_summary(records):

    if not records:
        return None


    min_prices = [
        r["min_price"]
        for r in records
        if r["min_price"] > 0
    ]

    modal_prices = [
        r["modal_price"]
        for r in records
        if r["modal_price"] > 0
    ]

    max_prices = [
        r["max_price"]
        for r in records
        if r["max_price"] > 0
    ]


    if not modal_prices:
        return None


    average_min = (
        sum(min_prices) / len(min_prices)
        if min_prices
        else 0
    )

    average_modal = (
        sum(modal_prices)
        /
        len(modal_prices)
    )

    average_max = (
        sum(max_prices) / len(max_prices)
        if max_prices
        else 0
    )


    states = set(
        r["state"]
        for r in records
    )

    markets = set(
        r["market"]
        for r in records
    )


    lowest = min(
        records,
        key=lambda x: x["modal_price"]
    )

    highest = max(
        records,
        key=lambda x: x["modal_price"]
    )


    top_expensive = sorted(
        records,
        key=lambda x: x["modal_price"],
        reverse=True
    )[:5]


    top_cheapest = sorted(
        records,
        key=lambda x: x["modal_price"]
    )[:5]


    return {

        "states": len(states),

        "markets": len(markets),

        "records": len(records),

        "average_min": average_min,

        "average_modal": average_modal,

        "average_max": average_max,

        "lowest": lowest,

        "highest": highest,

        "top_expensive": top_expensive,

        "top_cheapest": top_cheapest
    }


# ============================================================
# ESTIMATED PRICE
# ============================================================

def calculate_estimated_price(
    grade,
    average_min_price,
    average_modal_price,
    average_max_price
):

    if grade == "A":

        estimated_price = (
            average_modal_price
            +
            average_max_price
        ) / 2

        price_basis = (
            "Between Modal and Maximum"
        )


    elif grade == "B":

        estimated_price = (
            average_modal_price
            *
            0.90
        )

        price_basis = (
            "10% below Modal"
        )


    elif grade == "C":

        estimated_price = (
            average_min_price
            +
            average_modal_price
        ) / 2

        price_basis = (
            "Between Minimum and Modal"
        )


    else:

        estimated_price = 0

        price_basis = "Rejected"


    return (
        estimated_price,
        price_basis
    )


# ============================================================
# MAIN GRADING FUNCTION
# ============================================================

def grade_onion_heap(image_path):

    print("\n")
    print("=" * 70)
    print("                 ONION QUALITY GRADING")
    print("=" * 70)

    print("\nImage:", image_path)


    # ========================================================
    # LOAD IMAGE
    # ========================================================

    try:

        image = Image.open(
            image_path
        ).convert("RGB")

    except Exception as e:

        print(
            "ERROR loading image:",
            e
        )

        return None


    image_width, image_height = (
        image.size
    )


    print(
        f"Image size: "
        f"{image_width} x {image_height}"
    )

    print(
        f"Size calibration: {REFERENCE_IMAGE_HEIGHT:.0f}px reference height"
    )

    print(
        f"Size thresholds: "
        f"Small < {SMALL_THRESHOLD:.1f}px | "
        f"Medium {SMALL_THRESHOLD:.1f}-{LARGE_THRESHOLD:.1f}px | "
        f"Large > {LARGE_THRESHOLD:.1f}px"
    )


    # ========================================================
    # YOLO DETECTION
    # ========================================================

    print("\nRunning YOLO detection...")


    try:

        result = client.infer(
            image_path,
            model_id=YOLO_MODEL_ID
        )

    except Exception as e:

        print(
            "YOLO error:",
            e
        )

        return None


    # ========================================================
    # CONFIDENCE FILTER
    # ========================================================

    predictions = [

        p

        for p in result.get(
            "predictions",
            []
        )

        if p.get(
            "confidence",
            0
        ) >= CONFIDENCE_THRESHOLD
    ]


    print(
        f"Detected onions: "
        f"{len(predictions)}"
    )


    if not predictions:

        print(
            "No onions detected."
        )

        return None


    # ========================================================
    # COUNTERS
    # ========================================================

    healthy_count = 0
    unhealthy_count = 0

    small_count = 0
    medium_count = 0
    large_count = 0

    onion_results = []


    # ========================================================
    # INDIVIDUAL ONION ANALYSIS
    # ========================================================

    for index, prediction in enumerate(
        predictions,
        start=1
    ):

        x = float(
            prediction["x"]
        )

        y = float(
            prediction["y"]
        )

        width = float(
            prediction["width"]
        )

        height = float(
            prediction["height"]
        )

        confidence = float(
            prediction["confidence"]
        )


        # ----------------------------------------------------
        # Bounding box
        # ----------------------------------------------------

        left = max(
            0,
            int(x - width / 2)
        )

        top = max(
            0,
            int(y - height / 2)
        )

        right = min(
            image_width,
            int(x + width / 2)
        )

        bottom = min(
            image_height,
            int(y + height / 2)
        )


        if (
            right <= left
            or
            bottom <= top
        ):
            continue


        # ----------------------------------------------------
        # Crop
        # ----------------------------------------------------

        crop = image.crop(
            (
                left,
                top,
                right,
                bottom
            )
        )


        # ----------------------------------------------------
        # HEALTH
        # ----------------------------------------------------

        try:

            health, health_confidence = (
                predict_health(crop)
            )

        except Exception as e:

            print(
                f"Onion {index} "
                f"health error: {e}"
            )

            continue


        if health.lower() == "healthy":
            healthy_count += 1
        else:
            unhealthy_count += 1


        # ----------------------------------------------------
        # SIZE
        # ----------------------------------------------------

        size, size_score, diameter = (
            classify_size(
                width,
                height,
                image_height
            )
        )

        raw_diameter = (
            width + height
        ) / 2.0

        print(
            f"Onion {index}: "
            f"raw={raw_diameter:.1f}px, "
            f"normalized={diameter:.1f}px, "
            f"size={size}"
        )


        if size == "Small":
            small_count += 1

        elif size == "Medium":
            medium_count += 1

        else:
            large_count += 1


        # ----------------------------------------------------
        # STORE INDIVIDUAL RESULT
        # ----------------------------------------------------

        onion_results.append({

            "number": index,

            "yolo_confidence":
                round(
                    confidence * 100,
                    2
                ),

            "health":
                health,

            "health_confidence":
                round(
                    health_confidence,
                    2
                ),

            "size":
                size,

            "diameter_px":
                round(
                    diameter,
                    2
                ),

            "raw_diameter_px":
                round(
                    raw_diameter,
                    2
                ),

            "size_score":
                size_score
        })


    # ========================================================
    # TOTAL
    # ========================================================

    total = len(
        onion_results
    )


    if total == 0:

        return None


    # ========================================================
    # HEALTH SCORE
    # ========================================================

    health_score = (
        healthy_count
        /
        total
    ) * 100


    # ========================================================
    # SIZE SCORE
    # ========================================================

    size_score = (

        large_count * 100

        +

        medium_count * 75

        +

        small_count * 50

    ) / total


    # ========================================================
    # FINAL SCORE
    # ========================================================

    final_score = (

        HEALTH_WEIGHT
        *
        health_score

        +

        SIZE_WEIGHT
        *
        size_score
    )


    # ========================================================
    # GRADE
    # ========================================================

    if final_score >= 90:

        grade = "A"
        description = "Excellent"

    elif final_score >= 75:

        grade = "B"
        description = "Good"

    elif final_score >= 50:

        grade = "C"
        description = "Average"

    else:

        grade = "Reject"
        description = "Poor"


    # ========================================================
    # MANDI DATA
    # ========================================================

    records = fetch_mandi_prices()

    records = process_mandi_records(
        records
    )

    summary = calculate_market_summary(
        records
    )


    # ========================================================
    # ESTIMATED PRICE
    # ========================================================

    estimated_price = None
    price_basis = None


    if summary:

        estimated_price, price_basis = (
            calculate_estimated_price(

                grade,

                summary["average_min"],

                summary["average_modal"],

                summary["average_max"]
            )
        )


    # ========================================================
    # PRINT RESULT
    # ========================================================

    print("\n")
    print("=" * 70)
    print("                    FINAL SUMMARY")
    print("=" * 70)

    print(
        f"\nTotal onions: {total}"
    )

    print(
        f"Healthy: {healthy_count}"
    )

    print(
        f"Unhealthy: {unhealthy_count}"
    )

    print(
        f"Small: {small_count}"
    )

    print(
        f"Medium: {medium_count}"
    )

    print(
        f"Large: {large_count}"
    )

    print(
        f"\nHealth Score: "
        f"{health_score:.2f}/100"
    )

    print(
        f"Size Score: "
        f"{size_score:.2f}/100"
    )

    print(
        f"Final Score: "
        f"{final_score:.2f}/100"
    )

    print(
        f"Grade: "
        f"{grade} - {description}"
    )


    if estimated_price is not None:

        print(
            f"Estimated Price: "
            f"₹{estimated_price:.2f} / quintal"
        )

    else:

        print(
            "Estimated Price: Unavailable"
        )


    # ========================================================
    # RETURN RESULT TO FASTAPI
    # ========================================================

    return {

        "total_onions": int(total),

        "healthy": int(healthy_count),

        "unhealthy": int(
            unhealthy_count
        ),

        "small": int(small_count),

        "medium": int(medium_count),

        "large": int(large_count),

        "health_score": round(
            float(health_score),
            2
        ),

        "size_score": round(
            float(size_score),
            2
        ),

        "final_score": round(
            float(final_score),
            2
        ),

        "grade": grade,

        "description": description,

        "market": (

            {

                "states":
                    int(summary["states"]),

                "markets":
                    int(summary["markets"]),

                "records":
                    int(summary["records"]),

                "average_min_price":
                    round(
                        float(
                            summary["average_min"]
                        ),
                        2
                    ),

                "average_modal_price":
                    round(
                        float(
                            summary["average_modal"]
                        ),
                        2
                    ),

                "average_max_price":
                    round(
                        float(
                            summary["average_max"]
                        ),
                        2
                    )
            }

            if summary

            else None
        ),

        "estimated_price": (

            round(
                float(
                    estimated_price
                ),
                2
            )

            if estimated_price is not None

            else None
        ),

        "price_basis":
            price_basis,

        "onions":
            onion_results
    }


# ============================================================
# RUN DIRECTLY
# ============================================================

if __name__ == "__main__":

    image_path = input(
        "\nEnter heap image path: "
    ).strip().strip('"')


    if not os.path.exists(
        image_path
    ):

        print(
            "ERROR: Image file not found."
        )

        raise SystemExit(1)


    grade_onion_heap(
        image_path
    )