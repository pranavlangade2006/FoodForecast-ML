
import pandas as pd
from pathlib import Path

# Project paths
BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "dataset" / "kaggle_food_demand"
OUTPUT_DIR = BASE_DIR / "dataset" / "processed"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Load CSV files
train = pd.read_csv(DATA_DIR / "train.csv")
test = pd.read_csv(DATA_DIR / "test.csv")

meal = pd.read_csv(DATA_DIR / "meal_info.csv")
center = pd.read_csv(DATA_DIR / "fulfilment_center_info.csv")

print("Files loaded successfully!")

# Merge meal information
train = train.merge(
    meal,
    on="meal_id",
    how="left",
    validate="many_to_one"
)

test = test.merge(
    meal,
    on="meal_id",
    how="left",
    validate="many_to_one"
)

# Merge center information
train = train.merge(
    center,
    on="center_id",
    how="left",
    validate="many_to_one"
)

test = test.merge(
    center,
    on="center_id",
    how="left",
    validate="many_to_one"
)

# Check missing values
print("\nTrain shape:", train.shape)
print("Test shape:", test.shape)

print("\nMissing values in train:")
print(train.isnull().sum())

print("\nMissing values in test:")
print(test.isnull().sum())

# Save processed datasets
train.to_csv(OUTPUT_DIR / "train_merged.csv", index=False)
test.to_csv(OUTPUT_DIR / "test_merged.csv", index=False)

print("\nDataset merging completed!")
print("Processed files saved successfully.")
