extends Interactable

@onready var player = get_node("/root/Main/DungeonContainer/Player")
var in_extraction_zone = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func extract():
	InventoryManager.extract_run_rewards()
	
	get_tree().current_scene.clear_dungeon()
	get_tree().current_scene.load_main_menu()

func interact():
	if !in_extraction_zone:
		return
	
	extract()

func _on_body_entered(body: Node2D) -> void:
	in_extraction_zone = true


func _on_body_exited(body: Node2D) -> void:
	in_extraction_zone = false
