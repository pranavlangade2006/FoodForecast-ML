
import pandas as pd
import numpy as np
import joblib

from pathlib import Path
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# Project paths
BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "dataset" / "processed"
MODEL_DIR = BASE_DIR / "ml_model" / "models"

MODEL_DIR.mkdir(parents=True, exist_ok=True)

# Load merged dataset
df = pd.read_csv(DATA_DIR / "train_merged.csv")

print("Dataset loaded:", df.shape)

# Input features
numeric_features = [
    "week",
    "checkout_price",
    "base_price",
    "emailer_for_promotion",
    "homepage_featured",
    "op_area"
]

categorical_features = [
    "center_id",
    "meal_id",
    "category",
    "cuisine",
    "city_code",
    "region_code",
    "center_type"
]

features = numeric_features + categorical_features
target = "num_orders"

# Time-based train-validation split
cutoff_week = df["week"].max() - 10

train_df = df[df["week"] <= cutoff_week].copy()
valid_df = df[df["week"] > cutoff_week].copy()

X_train = train_df[features]
y_train = train_df[target]

X_valid = valid_df[features]
y_valid = valid_df[target]

print("Training records:", len(X_train))
print("Validation records:", len(X_valid))
print("Validation starts after week:", cutoff_week)

# Preprocessing
preprocessor = ColumnTransformer(
    transformers=[
        ("numeric", "passthrough", numeric_features),
        ("categorical", OneHotEncoder(handle_unknown="ignore"),
         categorical_features)
    ]
)

# Random Forest model
rf_model = RandomForestRegressor(
    n_estimators=80,
    max_depth=18,
    min_samples_leaf=5,
    max_samples=0.8,
    n_jobs=-1,
    random_state=42,
    verbose=1
)

# Complete pipeline
pipeline = Pipeline([
    ("preprocessor", preprocessor),
    ("model", rf_model)
])

# Train model
print("\nStarting Random Forest training...")
pipeline.fit(X_train, y_train)

print("\nTraining completed!")

# Evaluate model
predictions = pipeline.predict(X_valid)

mae = mean_absolute_error(y_valid, predictions)
rmse = np.sqrt(mean_squared_error(y_valid, predictions))
r2 = r2_score(y_valid, predictions)
wape = (
    np.abs(y_valid - predictions).sum()
    / max(y_valid.sum(), 1)
) * 100

print("\n===== MODEL PERFORMANCE =====")
print(f"MAE  : {mae:.2f}")
print(f"RMSE : {rmse:.2f}")
print(f"R2   : {r2:.4f}")
print(f"WAPE : {wape:.2f}%")

# Save trained model
model_path = MODEL_DIR / "kaggle_meal_demand_model.pkl"
joblib.dump(pipeline, model_path)

print("\nModel saved successfully!")
print("Location:", model_path)
