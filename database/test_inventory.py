from database.inventory import get_inventory, get_stock

print("ALL INVENTORY:")
print(get_inventory())

print("\nRICE STOCK:")
print(get_stock("Rice"))