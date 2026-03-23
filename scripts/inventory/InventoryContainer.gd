class_name InventoryContainer
extends RefCounted

var slots: Array
var capacity: int

func _init(p_capacity: int):
	capacity = p_capacity
	slots = []
	for i in range(capacity):
		slots.append(null)

func add_item(item_id: int, quantity: int = 1, metadata: Dictionary = {}) -> bool:
	var item_data = {"id": item_id, "quantity": quantity, "metadata": metadata}
	
	#Stack on slot
	for slot in slots:
		if slot != null and slot.id == item_id:
			slot.quantity += quantity
			return true
	#insert new
	for i in range(capacity):
		if slots[i] == null:
			slots[i] = item_data
			return true
	
	return false

func remove_item(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= capacity:
		return {}
	var item = slots[slot_index]
	slots[slot_index] = null
	if item:
		return item
	else:
		return {}

func get_item(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= capacity:
		return {}
	if slots[slot_index]:
		return slots[slot_index]
	else:
		return {}

func move_item(from_index: int, to_index: int) -> bool:
	if from_index < 0 or from_index >= capacity or to_index < 0 or to_index >= capacity:
		return false
	if slots[from_index] == null:
		return false
	
	#move
	if slots[to_index] == null:
		slots[to_index] = slots[from_index]
		slots[from_index] = null
		return true
	
	#stack
	if slots[from_index].id == slots[to_index].id:
		slots[to_index].quantity += slots[from_index].quantity
		slots[from_index] = null
		return true
	
	return false

func is_full() -> bool:
	for slot in slots:
		if slot == null:
			return false
	return true

func get_free_slots() -> int:
	var count = 0
	for slot in slots:
		if slot == null:
			count+= 1
	return count

func clear():
	for i in range(capacity):
		slots[i] = null

func to_dict() -> Dictionary:
	var data = []
	for slot in slots:
		data.append(slot.duplicate() if slot else null)
	return {"slots":data, "capacity": capacity}

func from_dict(data:Dictionary):
	capacity = data.get("capacity", capacity)
	slots = data.get("slots", []).duplicate()

	while slots.size() < capacity:
		slots.append(null)
	slots.resize(capacity)
