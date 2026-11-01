from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel
import pandas as pd
import joblib
import os

from database.inventory import get_stock


app = FastAPI(title="FoodForecast ML API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Model Directory
# -----------------------------

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "ml_model", "models")


# -----------------------------
# Load ML Models
# -----------------------------

models = {
    "rice": joblib.load(os.path.join(MODEL_DIR, "rice_model.pkl")),
    "potato": joblib.load(os.path.join(MODEL_DIR, "potato_model.pkl")),
    "onion": joblib.load(os.path.join(MODEL_DIR, "onion_model.pkl")),
    "tomato": joblib.load(os.path.join(MODEL_DIR, "tomato_model.pkl")),
    "oil": joblib.load(os.path.join(MODEL_DIR, "oil_model.pkl")),
    "flour": joblib.load(os.path.join(MODEL_DIR, "flour_model.pkl"))
}


# -----------------------------
# Input Data
# -----------------------------

class PredictionRequest(BaseModel):
    is_weekend: int
    is_holiday: int
    expected_customers: int
    reservations: int
    special_event: int
    previous_day_customers: int


# -----------------------------
# Home API
# -----------------------------

@app.get("/")
def home():
    return {
        "message": "FoodForecast ML API is running!",
        "status": "success"
    }


# -----------------------------
# Model Information
# -----------------------------

@app.get("/model-info")
def model_info():
    return {
        "models": list(models.keys()),
        "model_type": "Random Forest Regressor"
    }


# -----------------------------
# Prediction + Inventory
# -----------------------------

@app.post("/predict-all")
def predict_all(data: PredictionRequest):

    # -----------------------------
    # Prepare Input Data
    # -----------------------------

    input_data = pd.DataFrame([{
        "is_weekend": data.is_weekend,
        "is_holiday": data.is_holiday,
        "expected_customers": data.expected_customers,
        "reservations": data.reservations,
        "special_event": data.special_event,
        "previous_day_customers": data.previous_day_customers
    }])

    # -----------------------------
    # ML Predictions
    # -----------------------------

    predictions = {}

    for material, model in models.items():

        prediction = model.predict(input_data)[0]

        predictions[material] = round(float(prediction), 2)

    # -----------------------------
    # Inventory Mapping
    # -----------------------------

    inventory_materials = {
        "rice": "Rice",
        "potato": "Potato",
        "onion": "Onion",
        "tomato": "Tomato",
        "oil": "Cooking Oil",
        "flour": "Flour"
    }

    # -----------------------------
    # Compare Prediction with Stock
    # -----------------------------

    result = {}

    for material, prediction in predictions.items():

        material_name = inventory_materials[material]

        stock_data = get_stock(material_name)

        if stock_data:

            current_stock, unit, minimum_stock = stock_data

            # Calculate purchase requirement
            purchase_required = max(
                0,
                prediction - current_stock
            )

            # -----------------------------
            # Recommendation Logic
            # -----------------------------

            if current_stock >= prediction:

                recommendation = "Stock Sufficient"

            elif current_stock >= minimum_stock:

                recommendation = "Purchase Required"

            else:

                recommendation = "Urgent Purchase"

            # -----------------------------
            # Final Material Result
            # -----------------------------

            result[material] = {

                "predicted_requirement": prediction,

                "current_stock": current_stock,

                "purchase_required": round(
                    purchase_required,
                    2
                ),

                "minimum_stock": minimum_stock,

                "unit": unit,

                "recommendation": recommendation
            }

    # -----------------------------
    # Final API Response
    # -----------------------------

    return {

        "status": "success",

        "expected_customers": data.expected_customers,

        "results": result

    }