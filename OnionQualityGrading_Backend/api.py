# # from fastapi import FastAPI, UploadFile, File, HTTPException
# # import os
# # import shutil
# # import tempfile
# # from fastapi.responses import FileResponse
# # from pdf_generator import generate_pdf
# # from final import (
# #     grade_onion_heap,
# #     fetch_mandi_prices,
# #     process_mandi_records
# # )


# # # ============================================================
# # # FASTAPI APPLICATION
# # # ============================================================

# # app = FastAPI(
# #     title="Onion Quality Grading API",
# #     description=(
# #         "YOLO + ResNet-18 + Mandi Price "
# #         "based Onion Quality Grading API"
# #     ),
# #     version="1.0.0"
# # )


# # # ============================================================
# # # HOME
# # # ============================================================

# # @app.get("/")
# # def home():
# #     return {
# #         "status": "success",
# #         "message": "Onion Quality Grading API is running"
# #     }


# # # ============================================================
# # # ANALYZE ONION HEAP IMAGE
# # # ============================================================

# # @app.post("/analyze")
# # def analyze(file: UploadFile = File(...)):

# #     temp_path = None

# #     try:

# #         # --------------------------------------------------------
# #         # DEBUG - SHOW WHAT PHONE SENT
# #         # --------------------------------------------------------

# #         print("\n")
# #         print("=" * 70)
# #         print("IMAGE UPLOAD RECEIVED")
# #         print("=" * 70)

# #         print("Filename:", file.filename)
# #         print("Content-Type:", file.content_type)


# #         # --------------------------------------------------------
# #         # DETERMINE IMAGE EXTENSION
# #         # --------------------------------------------------------

# #         filename = file.filename or ""
# #         extension = os.path.splitext(filename)[1].lower()

# #         mime_to_extension = {
# #             "image/jpeg": ".jpg",
# #             "image/jpg": ".jpg",
# #             "image/png": ".png",
# #             "image/webp": ".webp",
# #         }


# #         # --------------------------------------------------------
# #         # CASE 1: MIME TYPE IS VALID
# #         # --------------------------------------------------------

# #         if file.content_type in mime_to_extension:

# #             extension = mime_to_extension[file.content_type]


# #         # --------------------------------------------------------
# #         # CASE 2: MIME TYPE IS UNKNOWN BUT FILENAME IS VALID
# #         # --------------------------------------------------------

# #         elif extension in [".jpg", ".jpeg", ".png", ".webp"]:

# #             # Keep the filename extension.
# #             # Normalize JPEG to .jpg.
# #             if extension == ".jpeg":
# #                 extension = ".jpg"


# #         # --------------------------------------------------------
# #         # INVALID FORMAT
# #         # --------------------------------------------------------

# #         else:

# #             raise HTTPException(
# #                 status_code=400,
# #                 detail=(
# #                     "Invalid image format. "
# #                     "Please upload JPG, JPEG, PNG or WEBP."
# #                 )
# #             )


# #         # --------------------------------------------------------
# #         # CREATE TEMPORARY FILE
# #         # --------------------------------------------------------

# #         with tempfile.NamedTemporaryFile(
# #             delete=False,
# #             suffix=extension
# #         ) as temp_file:

# #             temp_path = temp_file.name

# #             shutil.copyfileobj(
# #                 file.file,
# #                 temp_file
# #             )


# #         print("Detected extension:", extension)
# #         print("Temporary path:", temp_path)


# #         # --------------------------------------------------------
# #         # VERIFY FILE EXISTS
# #         # --------------------------------------------------------

# #         if not os.path.exists(temp_path):

# #             raise HTTPException(
# #                 status_code=500,
# #                 detail="Failed to save uploaded image."
# #             )


# #         # --------------------------------------------------------
# #         # CHECK FILE SIZE
# #         # --------------------------------------------------------

# #         file_size = os.path.getsize(temp_path)

# #         print("File size:", file_size, "bytes")


# #         if file_size == 0:

# #             raise HTTPException(
# #                 status_code=400,
# #                 detail="Uploaded image is empty."
# #             )


# #         # --------------------------------------------------------
# #         # RUN ONION QUALITY GRADING
# #         # --------------------------------------------------------

# #         print("\n")
# #         print("=" * 70)
# #         print("STARTING ONION QUALITY ANALYSIS")
# #         print("=" * 70)

# #         result = grade_onion_heap(temp_path)


# #         # --------------------------------------------------------
# #         # NO RESULT
# #         # --------------------------------------------------------

# #         if result is None:

# #             raise HTTPException(
# #                 status_code=422,
# #                 detail=(
# #                     "No onions could be analyzed "
# #                     "from this image."
# #                 )
# #             )


# #         # --------------------------------------------------------
# #         # SUCCESS
# #         # --------------------------------------------------------

# #         print("\n")
# #         print("=" * 70)
# #         print("ANALYSIS COMPLETED")
# #         print("=" * 70)

# #         return {
# #             "status": "success",
# #             "filename": file.filename,
# #             "result": result
# #         }


# #     # ============================================================
# #     # FASTAPI ERROR
# #     # ============================================================

# #     except HTTPException:
# #         raise


# #     # ============================================================
# #     # OTHER ERROR
# #     # ============================================================

# #     except Exception as e:

# #         print("\n")
# #         print("=" * 70)
# #         print("API ERROR")
# #         print("=" * 70)

# #         print("Error:", str(e))

# #         raise HTTPException(
# #             status_code=500,
# #             detail=f"Analysis failed: {str(e)}"
# #         )


# #     # ============================================================
# #     # DELETE TEMPORARY FILE
# #     # ============================================================

# #     finally:

# #         if temp_path and os.path.exists(temp_path):

# #             try:
# #                 os.remove(temp_path)

# #                 print("Temporary image deleted.")

# #             except OSError:
# #                 pass

# #     # ============================================================
# # # MARKET PRICES
# # # ============================================================

# # @app.get("/market-prices")
# # def get_market_prices():

# #     try:

# #         print("\n")
# #         print("=" * 70)
# #         print("FETCHING MARKET PRICES")
# #         print("=" * 70)

# #         # ----------------------------------------------------
# #         # FETCH DATA FROM DATA.GOV.IN
# #         # ----------------------------------------------------

# #         records = fetch_mandi_prices()

# #         if not records:

# #             raise HTTPException(
# #                 status_code=404,
# #                 detail="No onion market price data found."
# #             )


# #         # ----------------------------------------------------
# #         # PROCESS / FILTER RECORDS
# #         # ----------------------------------------------------

# #         processed_records = process_mandi_records(records)

# #         if not processed_records:

# #             raise HTTPException(
# #                 status_code=404,
# #                 detail="No valid onion market prices found."
# #             )


# #         # ----------------------------------------------------
# #         # PREPARE MARKET PRICE LIST
# #         # ----------------------------------------------------

# #         prices = []

# #         for record in processed_records:

# #             prices.append({
# #                 "state": record.get("state", ""),
# #                 "district": record.get("district", ""),
# #                 "market": record.get("market", ""),
# #                 "variety": record.get("variety", ""),
# #                 "min_price": record.get("min_price", 0),
# #                 "modal_price": record.get("modal_price", 0),
# #                 "max_price": record.get("max_price", 0),
# #                 "arrival_date": record.get("arrival_date", "")
# #             })


# #         print(
# #             "Valid market records:",
# #             len(prices)
# #         )


# #         # ----------------------------------------------------
# #         # RETURN TO MOBILE APP
# #         # ----------------------------------------------------

# #         return {
# #             "status": "success",
# #             "count": len(prices),
# #             "prices": prices
# #         }


# #     # ========================================================
# #     # FASTAPI ERROR
# #     # ========================================================

# #     except HTTPException:
# #         raise


# #     # ========================================================
# #     # OTHER ERROR
# #     # ========================================================

# #     except Exception as e:

# #         print("\nMARKET PRICE API ERROR:")
# #         print(str(e))

# #         raise HTTPException(
# #             status_code=500,
# #             detail=f"Failed to fetch market prices: {str(e)}"
# #         )


    
# # @app.post("/generate-pdf")
# # def generate_analysis_pdf(data: dict):
# #     try:
# #         result = data.get("result")

# #         if not result:
# #             raise HTTPException(
# #                 status_code=400,
# #                 detail="Analysis result is required."
# #             )

# #         temp_dir = tempfile.gettempdir()

# #         pdf_path = os.path.join(
# #             temp_dir,
# #             "onion_quality_report.pdf"
# #         )

# #         generate_pdf(
# #             result,
# #             pdf_path
# #         )

# #         if not os.path.exists(pdf_path):
# #             raise HTTPException(
# #                 status_code=500,
# #                 detail="Failed to generate PDF."
# #             )

# #         return FileResponse(
# #             path=pdf_path,
# #             media_type="application/pdf",
# #             filename="onion_quality_report.pdf"
# #         )

# #     except HTTPException:
# #         raise

# #     except Exception as e:
# #         print("PDF GENERATION ERROR:")
# #         print(str(e))

# #         raise HTTPException(
# #             status_code=500,
# #             detail=f"PDF generation failed: {str(e)}"
# #         )



# #     
# from fastapi import FastAPI, UploadFile, File, HTTPException
# from fastapi.responses import FileResponse
# from typing import List
# import os
# import tempfile
# import shutil

# from final_multi_image import grade_onion_heap
# from pdf_generator import generate_pdf


# app = FastAPI(title="Onion Quality Grading API",description="Local YOLO11s + EfficientNet-B0 Onion Quality Grading API")


# # ============================================================
# # HEALTH CHECK
# # ============================================================

# @app.get("/")
# def root():
#     return {
#         "status": "success",
#         "message": "Onion Quality Grading API is running"
#     }


# # ============================================================
# # MULTI-IMAGE ANALYSIS
# # ============================================================

# @app.post("/analyze")
# async def analyze_images(
#     files: List[UploadFile] = File(...)
# ):
#     """
#     Accept multiple photos of the SAME onion heap.

#     Flutter sends:
#         files: image1
#         files: image2
#         files: image3
#         ...

#     Supported formats:
#         JPG / JPEG / PNG / WEBP
#     """

#     if not files:
#         raise HTTPException(
#             status_code=400,
#             detail="No images were uploaded."
#         )

#     allowed_extensions = {
#         ".jpg", ".jpeg", ".png", ".webp"
#     }

#     mime_to_extension = {
#         "image/jpeg": ".jpg",
#         "image/jpg": ".jpg",
#         "image/png": ".png",
#         "image/webp": ".webp",
#     }

#     temp_paths = []

#     try:
#         for index, file in enumerate(files, start=1):

#             original_name = file.filename or f"image_{index}.jpg"

#             extension = os.path.splitext(
#                 original_name
#             )[1].lower()

#             if file.content_type in mime_to_extension:
#                 extension = mime_to_extension[file.content_type]

#             elif extension == ".jpeg":
#                 extension = ".jpg"

#             elif extension not in allowed_extensions:
#                 raise HTTPException(
#                     status_code=400,
#                     detail=(
#                         f"Invalid image format for "
#                         f"'{original_name}'. "
#                         f"Use JPG, JPEG, PNG or WEBP."
#                     )
#                 )

#             temp_file = tempfile.NamedTemporaryFile(
#                 delete=False,
#                 suffix=extension
#             )

#             temp_path = temp_file.name

#             try:
#                 shutil.copyfileobj(
#                     file.file,
#                     temp_file
#                 )
#             finally:
#                 temp_file.close()

#             temp_paths.append(temp_path)

#         print("\n" + "=" * 70)
#         print("MULTI-IMAGE ANALYSIS REQUEST")
#         print("=" * 70)
#         print("Images received:", len(temp_paths))

#         # final.py accepts a list of image paths and combines
#         # the results into one heap analysis.
#         result = grade_onion_heap(temp_paths)

#         if result is None:
#             raise HTTPException(
#                 status_code=422,
#                 detail=(
#                     "No onions could be detected in the "
#                     "uploaded images."
#                 )
#             )

#         return {
#             "status": "success",
#             "photos_processed": len(temp_paths),
#             "result": result
#         }

#     except HTTPException:
#         raise

#     except Exception as e:
#         print("Analysis error:", repr(e))
#         raise HTTPException(
#             status_code=500,
#             detail=f"Analysis failed: {str(e)}"
#         )

#     finally:
#         # Always remove temporary uploaded images.
#         for path in temp_paths:
#             try:
#                 if os.path.exists(path):
#                     os.remove(path)
#             except Exception as cleanup_error:
#                 print(
#                     "Could not remove temp file:",
#                     cleanup_error
#                 )


# # ============================================================
# # MARKET PRICES
# # ============================================================

# @app.get("/market-prices")
# def get_market_prices():
#     try:
#         # Import here so API startup does not unnecessarily
#         # perform a market-price request.
#         from final_multi_image import (
#             fetch_mandi_prices,
#             process_mandi_records
#         )

#         records = fetch_mandi_prices()

#         if not records:
#             raise HTTPException(
#                 status_code=404,
#                 detail="No onion market price data found."
#             )

#         processed_records = process_mandi_records(records)

#         if not processed_records:
#             raise HTTPException(
#                 status_code=404,
#                 detail="No valid onion market prices found."
#             )

#         prices = []

#         for record in processed_records:
#             prices.append({
#                 "state": record.get("state", ""),
#                 "district": record.get("district", ""),
#                 "market": record.get("market", ""),
#                 "variety": record.get("variety", ""),
#                 "min_price": record.get("min_price", 0),
#                 "modal_price": record.get("modal_price", 0),
#                 "max_price": record.get("max_price", 0),
#                 "arrival_date": record.get("arrival_date", "")
#             })

#         return {
#             "status": "success",
#             "count": len(prices),
#             "prices": prices
#         }

#     except HTTPException:
#         raise

#     except Exception as e:
#         raise HTTPException(
#             status_code=500,
#             detail=f"Failed to fetch market prices: {str(e)}"
#         )


# # ============================================================
# # PDF REPORT
# # ============================================================

# @app.post("/generate-pdf")
# async def generate_pdf_report(payload: dict):

#     pdf_path = None

#     try:

#         # --------------------------------------------------------
#         # GET ANALYSIS RESULT
#         # --------------------------------------------------------

#         result = payload.get("result")

#         if not result:
#             raise HTTPException(
#                 status_code=400,
#                 detail="Missing analysis result."
#             )

#         # --------------------------------------------------------
#         # CREATE TEMPORARY PDF PATH
#         # --------------------------------------------------------

#         temp_dir = tempfile.gettempdir()

#         pdf_path = os.path.join(
#             temp_dir,
#             "onion_quality_report.pdf"
#         )

#         print("\n" + "=" * 70)
#         print("PDF GENERATION REQUEST")
#         print("=" * 70)

#         print("PDF path:", pdf_path)

#         # --------------------------------------------------------
#         # GENERATE PDF
#         # --------------------------------------------------------
#         # IMPORTANT:
#         # generate_pdf() requires TWO arguments:
#         #
#         # generate_pdf(result, output_path)
#         #
#         # It writes the PDF to output_path.
#         # --------------------------------------------------------

#         generate_pdf(
#             result,
#             pdf_path
#         )

#         # --------------------------------------------------------
#         # VERIFY PDF WAS CREATED
#         # --------------------------------------------------------

#         if not os.path.exists(pdf_path):

#             raise HTTPException(
#                 status_code=500,
#                 detail="PDF file was not created."
#             )

#         file_size = os.path.getsize(pdf_path)

#         print("PDF generated successfully.")
#         print("PDF size:", file_size, "bytes")

#         if file_size == 0:

#             raise HTTPException(
#                 status_code=500,
#                 detail="Generated PDF is empty."
#             )

#         # --------------------------------------------------------
#         # RETURN PDF TO FLUTTER
#         # --------------------------------------------------------

#         return FileResponse(
#             path=pdf_path,
#             media_type="application/pdf",
#             filename="onion_quality_report.pdf"
#         )

#     except HTTPException:
#         raise

#     except Exception as e:

#         print("\n" + "=" * 70)
#         print("PDF GENERATION ERROR")
#         print("=" * 70)

#         print("Error:", repr(e))

#         raise HTTPException(
#             status_code=500,
#             detail=f"PDF generation failed: {str(e)}"
#         )

#     #uvicorn api_updated:app --host 0.0.0.0 --port 8000
#     #uvicorn api:app --host 0.0.0.0 --port 8000


from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from typing import List
import os
import tempfile
import shutil

from final_multi_image import grade_onion_heap
from pdf_generator import generate_pdf


app = FastAPI(title="Onion Quality Grading API")


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/")
def root():
    return {
        "status": "success",
        "message": "Onion Quality Grading API is running"
    }


# ============================================================
# MULTI-IMAGE ANALYSIS
# ============================================================

@app.post("/analyze")
async def analyze_images(
    files: List[UploadFile] = File(...)
):
    """
    Accept multiple photos of the SAME onion heap.

    Flutter sends:
        files: image1
        files: image2
        files: image3
        ...

    Supported formats:
        JPG / JPEG / PNG / WEBP
    """

    if not files:
        raise HTTPException(
            status_code=400,
            detail="No images were uploaded."
        )

    allowed_extensions = {
        ".jpg", ".jpeg", ".png", ".webp"
    }

    mime_to_extension = {
        "image/jpeg": ".jpg",
        "image/jpg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }

    temp_paths = []

    try:
        for index, file in enumerate(files, start=1):

            original_name = file.filename or f"image_{index}.jpg"

            extension = os.path.splitext(
                original_name
            )[1].lower()

            if file.content_type in mime_to_extension:
                extension = mime_to_extension[file.content_type]

            elif extension == ".jpeg":
                extension = ".jpg"

            elif extension not in allowed_extensions:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Invalid image format for "
                        f"'{original_name}'. "
                        f"Use JPG, JPEG, PNG or WEBP."
                    )
                )

            temp_file = tempfile.NamedTemporaryFile(
                delete=False,
                suffix=extension
            )

            temp_path = temp_file.name

            try:
                shutil.copyfileobj(
                    file.file,
                    temp_file
                )
            finally:
                temp_file.close()

            temp_paths.append(temp_path)

        print("\n" + "=" * 70)
        print("MULTI-IMAGE ANALYSIS REQUEST")
        print("=" * 70)
        print("Images received:", len(temp_paths))

        # final.py accepts a list of image paths and combines
        # the results into one heap analysis.
        result = grade_onion_heap(temp_paths)

        if result is None:
            raise HTTPException(
                status_code=422,
                detail=(
                    "No onions could be detected in the "
                    "uploaded images."
                )
            )

        return {
            "status": "success",
            "photos_processed": len(temp_paths),
            "result": result
        }

    except HTTPException:
        raise

    except Exception as e:
        print("Analysis error:", repr(e))
        raise HTTPException(
            status_code=500,
            detail=f"Analysis failed: {str(e)}"
        )

    finally:
        # Always remove temporary uploaded images.
        for path in temp_paths:
            try:
                if os.path.exists(path):
                    os.remove(path)
            except Exception as cleanup_error:
                print(
                    "Could not remove temp file:",
                    cleanup_error
                )


# ============================================================
# MARKET PRICES
# ============================================================

# @app.get("/market-prices")
# def get_market_prices():
#     try:
#         # Import here so API startup does not unnecessarily
#         # perform a market-price request.
#         from final_multi_image import (
#             fetch_mandi_prices,
#             process_mandi_records
#         )

#         records = fetch_mandi_prices()

#         if not records:
#             raise HTTPException(
#                 status_code=404,
#                 detail="No onion market price data found."
#             )

#         processed_records = process_mandi_records(records)

#         if not processed_records:
#             raise HTTPException(
#                 status_code=404,
#                 detail="No valid onion market prices found."
#             )

#         prices = []

#         for record in processed_records:
#             prices.append({
#                 "state": record.get("state", ""),
#                 "district": record.get("district", ""),
#                 "market": record.get("market", ""),
#                 "variety": record.get("variety", ""),
#                 "min_price": record.get("min_price", 0),
#                 "modal_price": record.get("modal_price", 0),
#                 "max_price": record.get("max_price", 0),
#                 "arrival_date": record.get("arrival_date", "")
#             })

#         return {
#             "status": "success",
#             "count": len(prices),
#             "prices": prices
#         }

#     except HTTPException:
#         raise

#     except Exception as e:
#         raise HTTPException(
#             status_code=500,
#             detail=f"Failed to fetch market prices: {str(e)}"
#         )


@app.get("/market-prices")
def get_market_prices():
    try:
        from final_multi_image import (
            fetch_mandi_prices,
            process_mandi_records
        )

        records = fetch_mandi_prices()

        if not records:
            return {
                "status": "unavailable",
                "count": 0,
                "prices": [],
                "message": "Mandi market data is temporarily unavailable. Please try again later."
            }

        processed_records = process_mandi_records(records)

        if not processed_records:
            return {
                "status": "unavailable",
                "count": 0,
                "prices": [],
                "message": "No valid onion market prices were returned."
            }

        prices = []

        for record in processed_records:
            prices.append({
                "state": record.get("state", ""),
                "district": record.get("district", ""),
                "market": record.get("market", ""),
                "variety": record.get("variety", ""),
                "min_price": record.get("min_price", 0),
                "modal_price": record.get("modal_price", 0),
                "max_price": record.get("max_price", 0),
                "arrival_date": record.get("arrival_date", "")
            })

        return {
            "status": "success",
            "count": len(prices),
            "prices": prices
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch market prices: {str(e)}"
        )


# ============================================================
# PDF REPORT
# ============================================================

@app.post("/generate-pdf")
async def generate_pdf_report(payload: dict):

    pdf_path = None

    try:

        # --------------------------------------------------------
        # GET ANALYSIS RESULT
        # --------------------------------------------------------

        result = payload.get("result")

        if not result:
            raise HTTPException(
                status_code=400,
                detail="Missing analysis result."
            )

        # --------------------------------------------------------
        # CREATE TEMPORARY PDF PATH
        # --------------------------------------------------------

        temp_dir = tempfile.gettempdir()

        pdf_path = os.path.join(
            temp_dir,
            "onion_quality_report.pdf"
        )

        print("\n" + "=" * 70)
        print("PDF GENERATION REQUEST")
        print("=" * 70)

        print("PDF path:", pdf_path)

        # --------------------------------------------------------
        # GENERATE PDF
        # --------------------------------------------------------
        # IMPORTANT:
        # generate_pdf() requires TWO arguments:
        #
        # generate_pdf(result, output_path)
        #
        # It writes the PDF to output_path.
        # --------------------------------------------------------

        generate_pdf(
            result,
            pdf_path
        )

        # --------------------------------------------------------
        # VERIFY PDF WAS CREATED
        # --------------------------------------------------------

        if not os.path.exists(pdf_path):

            raise HTTPException(
                status_code=500,
                detail="PDF file was not created."
            )

        file_size = os.path.getsize(pdf_path)

        print("PDF generated successfully.")
        print("PDF size:", file_size, "bytes")

        if file_size == 0:

            raise HTTPException(
                status_code=500,
                detail="Generated PDF is empty."
            )

        # --------------------------------------------------------
        # RETURN PDF TO FLUTTER
        # --------------------------------------------------------

        return FileResponse(
            path=pdf_path,
            media_type="application/pdf",
            filename="onion_quality_report.pdf"
        )

    except HTTPException:
        raise

    except Exception as e:

        print("\n" + "=" * 70)
        print("PDF GENERATION ERROR")
        print("=" * 70)

        print("Error:", repr(e))

        raise HTTPException(
            status_code=500,
            detail=f"PDF generation failed: {str(e)}"
        )

    #uvicorn api:app --host 0.0.0.0 --port 8000