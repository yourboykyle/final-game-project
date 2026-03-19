class_name Melee extends Weapon

@onready var melee = self
@export var shape: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called when the node enters the scene tree for the first time.
func _process(delta):
	fire_timer -= delta

func attack():
	var dir = (get_global_mouse_position() - melee.global_position).normalized()
	var origin = Vector2(global_position.x, global_position.y - 32)
	cast_hitbox(origin, dir, melee.shape)
