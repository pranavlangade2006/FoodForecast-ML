import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
DATABASE_PATH = os.path.join(BASE_DIR, "database", "inventory.db")


def get_inventory():
    connection = sqlite3.connect(DATABASE_PATH)
    connection.row_factory = sqlite3.Row

    cursor = connection.cursor()

    cursor.execute("""
        SELECT material_name, current_stock, unit, minimum_stock
        FROM inventory
    """)

    inventory = [dict(row) for row in cursor.fetchall()]

    connection.close()

    return inventory


def get_stock(material_name):
    connection = sqlite3.connect(DATABASE_PATH)

    cursor = connection.cursor()

    cursor.execute("""
        SELECT current_stock, unit, minimum_stock
        FROM inventory
        WHERE material_name = ?
    """, (material_name,))

    result = cursor.fetchone()

    connection.close()

    return result