extends Node

@export var stash_capacity: int = 40
@export var hotbar_capacity: int = 5
var run_loot_capacity: int = 20

var stash: InventoryContainer
var hotbar: InventoryContainer
var run_loot: InventoryContainer

var hotbar_snapshot: InventoryContainer
var hotbar_selected_index: int = 0

signal inventory_changed
signal run_loot_changed
signal hotbar_slot_selected(slot_index: int)

func _ready():
	stash = InventoryContainer.new(stash_capacity)
	hotbar = InventoryContainer.new(hotbar_capacity)
	run_loot = InventoryContainer.new(run_loot_capacity)
	
	_init_debug_items()

func add_to_stash(item_id: int, quantity: int = 1, metadata: Dictionary = {}) -> bool:
	var result = stash.add_item(item_id, quantity, metadata)
	if result:
		inventory_changed.emit()
	return result

func move_stash_to_hotbar(stash_index: int) -> bool:
	var item = stash.get_item(stash_index)
	if item.is_empty():
		return false
	
	if hotbar.is_full():
		return false
	
	stash.remove_item(stash_index)
	hotbar.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}))

	inventory_changed.emit()
	return true

func move_hotbar_to_stash(hotbar_index: int) -> bool:
	var item = hotbar.get_item(hotbar_index)
	if item.is_empty():
		return false
	
	if stash.is_full():
		return false
	
	hotbar.remove_item(hotbar_index)
	stash.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}))

	inventory_changed.emit()
	return true

func start_run():
	hotbar_snapshot = InventoryContainer.new(hotbar_capacity)
	hotbar_snapshot.from_dict(hotbar.to_dict())
	run_loot.clear()

# On death?
func clear_run_state():
	run_loot.clear()
	hotbar.clear()
	run_loot_changed.emit()
	inventory_changed.emit()

# On Extract?
func extract_run_rewards():
	for i in range(run_loot.capacity):
		var item = run_loot.get_item(i)
		if not item.is_empty():
			stash.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}))
			run_loot.remove_item(i)
	
	run_loot_changed.emit()
	inventory_changed.emit()

func get_hotbar_items() -> Array:
	var items = []
	for i in range(hotbar.capacity):
		var item = hotbar.get_item(i)
		if not item.is_empty():
			items.append(item)
	
	return items

func to_dict() -> Dictionary:
	return {
		"stash": stash.to_dict(),
		"hotbar": hotbar.to_dict(),
		"run_loot": run_loot.to_dict()
	}

func from_dict(data: Dictionary):
	stash.from_dict(data.get("stash", {}))
	hotbar.from_dict(data.get("hotbar", {}))
	run_loot.from_dict(data.get("run_loot", {}))
	inventory_changed.emit()

func select_hotbar_slot(index: int) -> void:
	if index >= 0 and index < hotbar.capacity:
		hotbar_selected_index = index
		hotbar_slot_selected.emit(index)

#Testing Only
func _init_debug_items():
	stash.add_item(3001, 1, {})
	stash.add_item(3002, 1, {})
	stash.add_item(3003, 1, {})
	stash.add_item(1001, 5, {})
	inventory_changed.emit()
