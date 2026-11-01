
import joblib
import pandas as pd

# Load trained model
model = joblib.load("ml_model/rice_prediction_model.pkl")

print("=" * 50)
print("FOODFORECAST ML - RICE PREDICTION")
print("=" * 50)

# Get input from user
is_weekend = int(input("\nIs it a weekend? (0 = No, 1 = Yes): "))
is_holiday = int(input("Is it a holiday? (0 = No, 1 = Yes): "))
expected_customers = int(input("Expected customers: "))
reservations = int(input("Number of reservations: "))
special_event = int(input("Special event? (0 = No, 1 = Yes): "))
previous_day_customers = int(input("Previous day customers: "))
previous_day_rice_kg = float(input("Previous day rice consumption (kg): "))

# Create input DataFrame
input_data = pd.DataFrame([{
    "is_weekend": is_weekend,
    "is_holiday": is_holiday,
    "expected_customers": expected_customers,
    "reservations": reservations,
    "special_event": special_event,
    "previous_day_customers": previous_day_customers,
    "previous_day_rice_kg": previous_day_rice_kg
}])

# Make prediction
prediction = model.predict(input_data)

rice_required = prediction[0]

print("\n" + "=" * 50)
print("PREDICTION RESULT")
print("=" * 50)

print(f"\nExpected Customers : {expected_customers}")
print(f"Predicted Rice     : {rice_required:.2f} kg")

print("\nRecommended Rice Stock:")
print(f"👉 {rice_required:.2f} kg")

print("\nPrediction completed successfully! 🚀")