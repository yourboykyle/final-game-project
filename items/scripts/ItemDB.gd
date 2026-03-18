extends Node

var items: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var item_container = preload("res://items/GeneralItems/ItemContainer.tscn").instantiate()
	for  item in item_container.get_children():
		register(item)


func register(item: Item):
	items[item.item_id] = item

func get_item(id):
	return items[id]
