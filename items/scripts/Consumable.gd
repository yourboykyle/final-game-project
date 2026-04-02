class_name Consumable extends Item



func decrease_quantity():
	
	var hotbar_index = InventoryManager.hotbar_selected_index
	var slot = InventoryManager.hotbar.slots[hotbar_index]
	
	if slot["quantity"] == 1:
		InventoryManager.hotbar.slots[hotbar_index] = null
	else:
		slot["quantity"] -= 1
		
	InventoryManager.inventory_changed.emit()
