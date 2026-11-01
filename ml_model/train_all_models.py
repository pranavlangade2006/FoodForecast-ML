import pandas as pd
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score


# ==========================================
# FOODFORECAST ML
# MULTI RAW MATERIAL MODEL TRAINING
# ==========================================

print("=" * 70)
print("FOODFORECAST ML - MULTI MATERIAL TRAINING")
print("=" * 70)


# ==========================================
# 1. LOAD DATASET
# ==========================================

df = pd.read_csv("dataset/hotel_food_demand.csv")

print(f"\nDataset records: {len(df)}")


# ==========================================
# 2. FEATURES
# ==========================================

features = [
    "is_weekend",
    "is_holiday",
    "expected_customers",
    "reservations",
    "special_event",
    "previous_day_customers"
]

X = df[features]


# ==========================================
# 3. MATERIALS
# ==========================================

materials = {
    "rice": "rice_required_kg",
    "potato": "potato_required_kg",
    "onion": "onion_required_kg",
    "tomato": "tomato_required_kg",
    "oil": "oil_required_litre",
    "flour": "flour_required_kg"
}


# ==========================================
# 4. CREATE MODEL DIRECTORY
# ==========================================

os.makedirs("ml_model/models", exist_ok=True)


# ==========================================
# 5. TRAIN EACH MODEL
# ==========================================

results = []

for material, target_column in materials.items():

    print("\n" + "-" * 70)
    print(f"Training model for: {material.upper()}")
    print("-" * 70)

    y = df[target_column]

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.20,
        random_state=42
    )

    model = RandomForestRegressor(
        n_estimators=200,
        random_state=42
    )

    model.fit(X_train, y_train)

    predictions = model.predict(X_test)

    mae = mean_absolute_error(
        y_test,
        predictions
    )

    rmse = mean_squared_error(
        y_test,
        predictions
    ) ** 0.5

    r2 = r2_score(
        y_test,
        predictions
    )

    # Save model

    model_path = f"ml_model/models/{material}_model.pkl"

    joblib.dump(
        model,
        model_path
    )

    results.append({
        "Material": material,
        "MAE": mae,
        "RMSE": rmse,
        "R2": r2
    })

    print(f"MAE  : {mae:.2f}")
    print(f"RMSE : {rmse:.2f}")
    print(f"R2   : {r2:.4f}")

    print(f"Model saved: {model_path}")


# ==========================================
# 6. DISPLAY FINAL RESULTS
# ==========================================

results_df = pd.DataFrame(results)

print("\n")
print("=" * 70)
print("FINAL MODEL PERFORMANCE")
print("=" * 70)

print(
    results_df.to_string(
        index=False,
        formatters={
            "MAE": "{:.2f}".format,
            "RMSE": "{:.2f}".format,
            "R2": "{:.4f}".format
        }
    )
)


print("\n" + "=" * 70)
print("ALL MODELS TRAINED SUCCESSFULLY!")
print("=" * 70)

print("\nSaved models:")

for material in materials:
    print(
        f"✓ {material}_model.pkl"
    )

print("\nFoodForecast multi-material ML system ready! 🚀")