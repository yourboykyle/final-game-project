extends Interactable

var player = Globals.player
var in_bubble_zone = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact():
	if !in_bubble_zone:
		return
	use_bubble()

func use_bubble():
	player.oxygen = player.oxygen + 20
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	in_bubble_zone = true


func _on_body_exited(body: Node2D) -> void:
	in_bubble_zone = false
