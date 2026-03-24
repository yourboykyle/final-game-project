class_name Melee extends Weapon

@onready var melee = self
@export var angle : float = 80.0
@export var attack_radius: float = 150.0

func _ready() -> void:
	pass


func attack():
	var dir = (get_global_mouse_position() - melee.global_position).normalized()
	var origin = Vector2(melee.global_position.x, melee.global_position.y)
	if attack_type == Globals.ATTACK_TYPE.CONE:
		cone_attack(origin, dir, angle, attack_radius)
	elif attack_type == Globals.ATTACK_TYPE.RECTANGLE:
		rectangle_attack(origin, dir)
