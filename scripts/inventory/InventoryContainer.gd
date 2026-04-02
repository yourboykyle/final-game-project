class_name InventoryContainer
extends RefCounted

var slots: Array
var capacity: int

func _init(p_capacity: int):
	capacity = p_capacity
	slots = []
	for i in range(capacity):
		slots.append(null)

func add_item(item_id: int, quantity: int = 1, metadata: Dictionary = {}, max_stack_size: int = 5) -> bool:
	var item_data = {"id": item_id, "quantity": quantity, "metadata": metadata}
	
	#Stack on slot if there's room
	for slot in slots:
		if slot != null and slot.id == item_id:
			var space_available = max_stack_size - slot.quantity
			if space_available > 0:
				var amount_to_add = min(quantity, space_available)
				slot.quantity += amount_to_add
				quantity -= amount_to_add
				if quantity <= 0:
					return true
	
	#insert new stacks if quantity remaining
	while quantity > 0:
		var amount_for_this_slot = min(quantity, max_stack_size)
		item_data = {"id": item_id, "quantity": amount_for_this_slot, "metadata": metadata}
		
		for i in range(capacity):
			if slots[i] == null:
				slots[i] = item_data
				quantity -= amount_for_this_slot
				if quantity <= 0:
					return true
				break
		
		# If we get here and still have quantity, inventory is full
		if quantity > 0:
			return false
	
	return true

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

func move_item(from_index: int, to_index: int, max_stack_size: int = 5) -> bool:
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
		var space_available = max_stack_size - slots[to_index].quantity
		if space_available > 0:
			var amount_to_move = min(slots[from_index].quantity, space_available)
			slots[to_index].quantity += amount_to_move
			slots[from_index].quantity -= amount_to_move
			
			if slots[from_index].quantity <= 0:
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
