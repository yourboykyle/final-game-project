extends Item

func _ready():
	pass

func use_item(user):
	user.change_oxygen(5)
	var hotbar_index = InventoryManager.hotbar_selected_index
	var slot = InventoryManager.hotbar.slots[hotbar_index]

	if slot["quantity"] == 1:
		InventoryManager.hotbar.slots[hotbar_index] = null
	else:
		slot["quantity"] -= 1
		
	InventoryManager.inventory_changed.emit()
