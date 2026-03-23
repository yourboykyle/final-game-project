class_name Melee extends Weapon

@onready var melee = self
@export var shape: Globals.MELEE_HITBOXES
@export var angle : float = 80.0
@export var attack_radius: float = 150.0

func _ready() -> void:
	pass


func _process(delta):
	fire_timer -= delta

func attack():
	var dir = (get_global_mouse_position() - melee.global_position).normalized()
	var origin = Vector2(global_position.x, global_position.y)
	cone_attack(origin, dir, angle, attack_radius)
