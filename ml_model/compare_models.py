
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score


# ==========================================
# 1. LOAD DATASET
# ==========================================

df = pd.read_csv("dataset/hotel_food_demand.csv")

print("=" * 65)
print("FOODFORECAST ML - MODEL COMPARISON")
print("=" * 65)


# ==========================================
# 2. FEATURES AND TARGET
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


# ==========================================
# 4. CREATE MODELS
# ==========================================

models = {
    "Linear Regression": LinearRegression(),

    "Decision Tree": DecisionTreeRegressor(
        random_state=42
    ),

    "Random Forest": RandomForestRegressor(
        n_estimators=200,
        random_state=42
    ),

    "Gradient Boosting": GradientBoostingRegressor(
        n_estimators=100,
        random_state=42
    )
}


# ==========================================
# 5. TRAIN AND EVALUATE
# ==========================================

results = []

for name, model in models.items():

    print(f"\nTraining {name}...")

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

    results.append({
        "Model": name,
        "MAE": mae,
        "RMSE": rmse,
        "R2": r2
    })


# ==========================================
# 6. DISPLAY RESULTS
# ==========================================

results_df = pd.DataFrame(results)

print("\n")
print("=" * 65)
print("MODEL PERFORMANCE COMPARISON")
print("=" * 65)

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


# ==========================================
# 7. FIND BEST MODEL
# ==========================================

best_model_name = results_df.loc[
    results_df["R2"].idxmax(),
    "Model"
]

print("\n" + "=" * 65)
print("BEST MODEL")
print("=" * 65)

print(f"Best Model: {best_model_name}")

print("\nComparison completed successfully! 🚀")