extends Node

var items: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var item_container = preload("res://items/GeneralItems/ItemContainer.tscn").instantiate()
	for item in item_container.get_children():
		register(item)
		print("%s %d" % [item.name, item.item_id])


func register(item: Item):
	items[item.item_id] = item

func get_item(id):
	return items[id]

func get_item_data(item_id: int) -> Dictionary:
	if item_id not in items:
		return {"name": "Unknown", "texture": null, "description": "", "max_stack_size": 5}
	
	var item_scene = items[item_id]
	var name = item_scene.item_name 
	var description = ""
	var max_stack_size = item_scene.max_stack_size
	
	if item_scene is Weapon:
		max_stack_size = 1
	
	if item_scene.get("item_description") != null:
		description = item_scene.item_description
	
	var texture: Texture2D = null
	for child in item_scene.get_children():
		if child is Sprite2D:
			texture = child.texture
			break
	
	return {"name": name, "texture": texture, "description": description, "max_stack_size": max_stack_size}
