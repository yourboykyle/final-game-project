extends Interactable

var contained_item : Item
var in_chest_zone : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var items = []
	
	for item in ItemDb.items:
		items.append(item)
	
	var random_item = randi_range(0, len(items) - 1)
	
	contained_item = ItemDb.items[items[random_item]]

func loot():
	InventoryManager.add_to_stash(contained_item.get_id(), 1)
	queue_free()

func interact():
	if !in_chest_zone:
		return
	
	loot()


func _on_body_entered(body: Node2D) -> void:
	in_chest_zone = true


func _on_body_exited(body: Node2D) -> void:
	in_chest_zone = false
