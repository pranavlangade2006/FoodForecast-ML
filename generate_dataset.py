import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os

# ==========================================
# FOODFORECAST ML - DATASET GENERATOR
# ==========================================

np.random.seed(42)

# Number of records
num_records = 1000

start_date = datetime(2025, 1, 1)

records = []

for i in range(num_records):

    date = start_date + timedelta(days=i)

    day_of_week = date.strftime("%A")

    # Weekend
    is_weekend = 1 if day_of_week in ["Saturday", "Sunday"] else 0

    # Random holiday
    is_holiday = np.random.choice([0, 1], p=[0.92, 0.08])

    # Expected customers
    base_customers = np.random.randint(80, 350)

    if is_weekend:
        base_customers += np.random.randint(30, 100)

    if is_holiday:
        base_customers += np.random.randint(50, 150)

    expected_customers = base_customers

    # Reservations
    reservations = int(
        expected_customers * np.random.uniform(0.15, 0.40)
    )

    # Special event
    special_event = np.random.choice(
        [0, 1],
        p=[0.85, 0.15]
    )

    if special_event:
        expected_customers += np.random.randint(30, 100)

    # Previous day customers
    previous_day_customers = max(
        50,
        int(
            expected_customers *
            np.random.uniform(0.80, 1.20)
        )
    )

    # ==========================================
    # RAW MATERIAL REQUIREMENTS
    # ==========================================

    # Rice
    rice_required = (
        expected_customers * 0.18
        + np.random.normal(0, 2)
    )

    # Potato
    potato_required = (
        expected_customers * 0.12
        + np.random.normal(0, 1.5)
    )

    # Onion
    onion_required = (
        expected_customers * 0.06
        + np.random.normal(0, 0.8)
    )

    # Tomato
    tomato_required = (
        expected_customers * 0.08
        + np.random.normal(0, 1)
    )

    # Cooking oil
    oil_required = (
        expected_customers * 0.025
        + np.random.normal(0, 0.3)
    )

    # Flour
    flour_required = (
        expected_customers * 0.10
        + np.random.normal(0, 1.2)
    )

    # Prevent negative values
    rice_required = max(0, rice_required)
    potato_required = max(0, potato_required)
    onion_required = max(0, onion_required)
    tomato_required = max(0, tomato_required)
    oil_required = max(0, oil_required)
    flour_required = max(0, flour_required)

    records.append({

        "date": date.strftime("%Y-%m-%d"),

        "day_of_week": day_of_week,

        "is_weekend": is_weekend,

        "is_holiday": is_holiday,

        "expected_customers": expected_customers,

        "reservations": reservations,

        "special_event": special_event,

        "previous_day_customers": previous_day_customers,

        "rice_required_kg": round(rice_required, 2),

        "potato_required_kg": round(potato_required, 2),

        "onion_required_kg": round(onion_required, 2),

        "tomato_required_kg": round(tomato_required, 2),

        "oil_required_litre": round(oil_required, 2),

        "flour_required_kg": round(flour_required, 2)
    })


# ==========================================
# CREATE DATAFRAME
# ==========================================

df = pd.DataFrame(records)


# ==========================================
# CREATE DATASET FOLDER
# ==========================================

os.makedirs("dataset", exist_ok=True)


# ==========================================
# SAVE DATASET
# ==========================================

file_path = "dataset/hotel_food_demand.csv"

df.to_csv(file_path, index=False)


# ==========================================
# DISPLAY INFORMATION
# ==========================================

print("=" * 60)
print("FOODFORECAST ML DATASET CREATED")
print("=" * 60)

print(f"\nDataset location: {file_path}")

print(f"Total records: {len(df)}")

print(f"Total columns: {len(df.columns)}")

print("\nColumns:")

for column in df.columns:
    print("-", column)

print("\nFirst 5 records:")

print(df.head())

print("\nDataset created successfully! 🚀")