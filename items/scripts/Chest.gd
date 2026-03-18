extends Area2D

var contained_item : Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var item_ids = []
	
	for item in ItemDb.items:
		item_ids.append(item)
	
	var random_item = randi_range(0, len(item_ids) - 1)
	
	contained_item = ItemDb.items[item_ids[random_item]]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_body_entered(body: Node2D) -> void:
	print(contained_item)
