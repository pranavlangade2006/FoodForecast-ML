import sqlite3
import os


# ==========================================
# FOODFORECAST DATABASE
# ==========================================

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

DATABASE_DIR = os.path.join(
    BASE_DIR,
    "database"
)

DATABASE_PATH = os.path.join(
    DATABASE_DIR,
    "inventory.db"
)


# ==========================================
# CONNECT TO DATABASE
# ==========================================

def get_connection():

    return sqlite3.connect(DATABASE_PATH)


# ==========================================
# CREATE TABLE
# ==========================================

def create_tables():

    os.makedirs(
        DATABASE_DIR,
        exist_ok=True
    )

    connection = get_connection()

    cursor = connection.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            material_name TEXT NOT NULL UNIQUE,
            current_stock REAL NOT NULL,
            unit TEXT NOT NULL,
            minimum_stock REAL DEFAULT 0
        )
    """)

    connection.commit()

    connection.close()

    print("Database tables created successfully!")


# ==========================================
# INSERT INITIAL STOCK
# ==========================================

def insert_initial_stock():

    connection = get_connection()

    cursor = connection.cursor()

    materials = [
        ("Rice", 25, "kg", 10),
        ("Potato", 20, "kg", 8),
        ("Onion", 10, "kg", 5),
        ("Tomato", 15, "kg", 5),
        ("Cooking Oil", 8, "litre", 3),
        ("Flour", 20, "kg", 8)
    ]

    for material in materials:

        cursor.execute("""
            INSERT OR IGNORE INTO inventory
            (material_name, current_stock, unit, minimum_stock)
            VALUES (?, ?, ?, ?)
        """, material)

    connection.commit()

    connection.close()

    print("Initial inventory added successfully!")


# ==========================================
# RUN DATABASE SETUP
# ==========================================

if __name__ == "__main__":

    create_tables()

    insert_initial_stock()

    print("\nFoodForecast inventory database is ready!")