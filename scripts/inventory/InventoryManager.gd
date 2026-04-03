extends Node

@export var stash_capacity: int = 40
@export var hotbar_capacity: int = 5
var run_loot_capacity: int = 20
var max_upgrades_capacity: int = 5  # Max upgrades at level 5

var stash: InventoryContainer
var hotbar: InventoryContainer
var run_loot: InventoryContainer
var upgrades: InventoryContainer

var hotbar_snapshot: InventoryContainer
var hotbar_selected_index: int = 0

signal inventory_changed
signal run_loot_changed
signal upgrades_changed
signal hotbar_slot_selected(slot_index: int)

func _ready():
	stash = InventoryContainer.new(stash_capacity)
	hotbar = InventoryContainer.new(hotbar_capacity)
	run_loot = InventoryContainer.new(run_loot_capacity)
	upgrades = InventoryContainer.new(max_upgrades_capacity)
	
	_init_debug_items()

func add_to_stash(item_id: int, quantity: int = 1, metadata: Dictionary = {}) -> bool:
	var max_stack = _get_max_stack_size(item_id)
	var result = stash.add_item(item_id, quantity, metadata, max_stack)
	if result:
		inventory_changed.emit()
	return result

func add_to_run_loot(item_id: int, quantity: int = 1, metadata: Dictionary = {}) -> bool:
	var max_stack = _get_max_stack_size(item_id)
	var result = run_loot.add_item(item_id, quantity, metadata, max_stack)
	if result:
		Globals.items_collected += quantity
		run_loot_changed.emit()
	return result

func move_stash_to_hotbar(stash_index: int) -> bool:
	var item = stash.get_item(stash_index)
	if item.is_empty():
		return false
	
	if hotbar.is_full():
		return false
	
	var max_stack = _get_max_stack_size(item.id)
	stash.remove_item(stash_index)
	hotbar.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}), max_stack)

	inventory_changed.emit()
	return true

func move_hotbar_to_stash(hotbar_index: int) -> bool:
	var item = hotbar.get_item(hotbar_index)
	if item.is_empty():
		return false
	
	if stash.is_full():
		return false
	
	var max_stack = _get_max_stack_size(item.id)
	hotbar.remove_item(hotbar_index)
	stash.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}), max_stack)

	inventory_changed.emit()
	return true

func _is_upgrade_item(item_id: int) -> bool:
	#restrict to upgrades?
	var item_scene = ItemDb.get_item(item_id)
	return item_scene is Upgrade

func move_stash_to_upgrades(stash_index: int, upgrade_index: int) -> bool:
	if upgrade_index >= get_unlocked_upgrade_slots():
		return false
	
	var item = stash.get_item(stash_index)
	if item.is_empty():
		return false
	
	if not _is_upgrade_item(item.id):
		return false
	
	var upgrade_slot = upgrades.get_item(upgrade_index)
	if not upgrade_slot.is_empty():
		return false
	
	var max_stack = _get_max_stack_size(item.id)
	stash.remove_item(stash_index)
	upgrades.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}), max_stack)
	
	inventory_changed.emit()
	upgrades_changed.emit()
	return true

func move_upgrades_to_stash(upgrade_index: int) -> bool:
	if upgrade_index >= get_unlocked_upgrade_slots():
		return false
	
	var item = upgrades.get_item(upgrade_index)
	if item.is_empty():
		return false
	
	if stash.is_full():
		return false
	
	var max_stack = _get_max_stack_size(item.id)
	upgrades.remove_item(upgrade_index)
	stash.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}), max_stack)
	
	inventory_changed.emit()
	upgrades_changed.emit()
	return true

func get_unlocked_upgrade_slots() -> int:
	return mini(Globals.level, max_upgrades_capacity)

func start_run():
	hotbar_snapshot = InventoryContainer.new(hotbar_capacity)
	hotbar_snapshot.from_dict(hotbar.to_dict())
	run_loot.clear()

# On death?
func clear_run_state():
	run_loot.clear()
	hotbar.clear()
	upgrades.clear()
	run_loot_changed.emit()
	inventory_changed.emit()
	upgrades_changed.emit()

func clear_upgrades():
	upgrades.clear()
	upgrades_changed.emit()

# On Extract?
func extract_run_rewards():
	for i in range(run_loot.capacity):
		var item = run_loot.get_item(i)
		if not item.is_empty():
			var max_stack = _get_max_stack_size(item.id)
			stash.add_item(item.id, item.get("quantity", 1), item.get("metadata", {}), max_stack)
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
		"run_loot": run_loot.to_dict(),
		"upgrades": upgrades.to_dict()
	}

func from_dict(data: Dictionary):
	stash.from_dict(data.get("stash", {}))
	hotbar.from_dict(data.get("hotbar", {}))
	run_loot.from_dict(data.get("run_loot", {}))
	upgrades.from_dict(data.get("upgrades", {}))
	inventory_changed.emit()

func select_hotbar_slot(index: int) -> void:
	if index >= 0 and index < hotbar.capacity:
		hotbar_selected_index = index
		hotbar_slot_selected.emit(index)

func _get_max_stack_size(item_id: int) -> int:
	var item_data = ItemDb.get_item_data(item_id)
	return item_data.get("max_stack_size")

#Testing Only
func _init_debug_items():
	var max_stack_3001 = _get_max_stack_size(3001)
	var max_stack_3003 = _get_max_stack_size(3003)
	var max_stack_1001 = _get_max_stack_size(1001)
	var max_stack_3005 = _get_max_stack_size(3005)

	stash.add_item(3001, 1, {}, max_stack_3001)
	stash.add_item(3005, 1, {}, max_stack_3005)
	hotbar.add_item(3003, 1, {}, max_stack_3003)
	stash.add_item(1001, 5, {}, max_stack_1001)

	#Upgrade Testing
	#var max_stack_4002 = _get_max_stack_size(4002)
	#var max_stack_4003 = _get_max_stack_size(4002)
	#stash.add_item(4001, 1, {}, max_stack_4001)
	#stash.add_item(4001, 1, {}, max_stack_4002)
	#stash.add_item(4002, 1, {}, max_stack_4002)
	#stash.add_item(4003, 1, {}, max_stack_4003)

	inventory_changed.emit()
