import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset
df = pd.read_csv("dataset/hotel_food_demand.csv")

print("=" * 50)
print("FOODFORECAST ML - DATA ANALYSIS")
print("=" * 50)

# Dataset information
print("\n1. Dataset Shape:")
print(df.shape)

print("\n2. Dataset Columns:")
print(df.columns.tolist())

print("\n3. First 5 Records:")
print(df.head())

print("\n4. Missing Values:")
print(df.isnull().sum())

print("\n5. Statistical Summary:")
print(df.describe())

# Average customers
print("\n6. Average Expected Customers:")
print(round(df["expected_customers"].mean(), 2))

# Average rice requirement
print("\n7. Average Rice Requirement:")
print(round(df["rice_required_kg"].mean(), 2), "kg")

# Maximum rice requirement
print("\n8. Maximum Rice Requirement:")
print(round(df["rice_required_kg"].max(), 2), "kg")

# Minimum rice requirement
print("\n9. Minimum Rice Requirement:")
print(round(df["rice_required_kg"].min(), 2), "kg")


# -----------------------------
# GRAPH 1: Customers vs Rice
# -----------------------------

plt.figure(figsize=(8, 5))

sns.scatterplot(
    data=df,
    x="expected_customers",
    y="rice_required_kg"
)

plt.title("Expected Customers vs Rice Requirement")
plt.xlabel("Expected Customers")
plt.ylabel("Rice Required (kg)")

plt.tight_layout()
plt.show()


# -----------------------------
# GRAPH 2: Rice Requirement
# -----------------------------

plt.figure(figsize=(8, 5))

sns.histplot(
    df["rice_required_kg"],
    bins=30,
    kde=True
)

plt.title("Distribution of Rice Requirement")
plt.xlabel("Rice Required (kg)")
plt.ylabel("Frequency")

plt.tight_layout()
plt.show()


# -----------------------------
# GRAPH 3: Weekend vs Weekday
# -----------------------------

plt.figure(figsize=(7, 5))

sns.boxplot(
    data=df,
    x="is_weekend",
    y="rice_required_kg"
)

plt.title("Rice Requirement: Weekday vs Weekend")
plt.xlabel("Weekend (0 = No, 1 = Yes)")
plt.ylabel("Rice Required (kg)")

plt.tight_layout()
plt.show()


print("\nAnalysis completed successfully!")