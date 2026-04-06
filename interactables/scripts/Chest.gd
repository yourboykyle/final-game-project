extends Interactable

var contained_item : Item
var in_chest_zone : bool
signal opened
var is_looted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var items = []
	
	for item in ItemDb.items:
		var weight = ItemDb.items[item].weight
		for i in weight:
			items.append(item)
	
	var random_item = randi_range(0, len(items) - 1)
	
	contained_item = ItemDb.items[items[random_item]]

func loot():
	if is_looted:
		return
	
	is_looted = true
	Globals.play_sfx(sfx_stream)
	var quantity = 1
	if contained_item.item_id == 1001:
		quantity = 2
	InventoryManager.add_to_run_loot(contained_item.item_id, quantity)
	InventoryManager.run_loot_changed.emit()
	opened.emit()
	Globals.add_xp(10)
	call_deferred("queue_free")

func interact():
	if !in_chest_zone:
		return
	
	loot()


func _on_body_entered(body: Node2D) -> void:
	if is_looted: return
	in_chest_zone = true


func _on_body_exited(body: Node2D) -> void:
	if is_looted: return
	in_chest_zone = false
