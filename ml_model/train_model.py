import pandas as pd
import joblib

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# ==========================================
# 1. LOAD DATASET
# ==========================================

df = pd.read_csv("dataset/hotel_food_demand.csv")

print("=" * 60)
print("FOODFORECAST ML - RANDOM FOREST MODEL")
print("=" * 60)


# ==========================================
# 2. SELECT FEATURES
# ==========================================

features = [
    "is_weekend",
    "is_holiday",
    "expected_customers",
    "reservations",
    "special_event",
    "previous_day_customers",
    "previous_day_rice_kg"
]

X = df[features]

# Target
y = df["rice_required_kg"]


# ==========================================
# 3. TRAIN / TEST SPLIT
# ==========================================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42
)

print("\nTraining records:", len(X_train))
print("Testing records:", len(X_test))


# ==========================================
# 4. CREATE MODEL
# ==========================================

model = RandomForestRegressor(
    n_estimators=200,
    random_state=42
)


# ==========================================
# 5. TRAIN MODEL
# ==========================================

print("\nTraining Random Forest model...")

model.fit(X_train, y_train)

print("Model training completed!")


# ==========================================
# 6. MAKE PREDICTIONS
# ==========================================

y_pred = model.predict(X_test)


# ==========================================
# 7. MODEL EVALUATION
# ==========================================

mae = mean_absolute_error(y_test, y_pred)

rmse = mean_squared_error(
    y_test,
    y_pred
) ** 0.5

r2 = r2_score(y_test, y_pred)


print("\n" + "=" * 60)
print("MODEL PERFORMANCE")
print("=" * 60)

print(f"MAE  : {mae:.2f} kg")
print(f"RMSE : {rmse:.2f} kg")
print(f"R²   : {r2:.4f}")


# ==========================================
# 8. SAMPLE PREDICTIONS
# ==========================================

results = pd.DataFrame({
    "Actual Rice (kg)": y_test.values,
    "Predicted Rice (kg)": y_pred.round(2)
})

print("\nSample Predictions:")
print(results.head(10))


# ==========================================
# 9. SAVE MODEL
# ==========================================

model_path = "ml_model/rice_prediction_model.pkl"

joblib.dump(model, model_path)

print("\nModel saved successfully!")
print(f"Location: {model_path}")


print("\nFoodForecast ML model completed successfully! 🚀")