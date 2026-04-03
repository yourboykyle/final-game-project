class_name Gun extends Weapon

# Shooting stuff
@onready var gun = self
#How fast projectile goes
@export var projectile_speed: int = 1000
# Gun attributes
#If it shoots a raycast or projectile (true for raycast)


# Add every gun to the gun group (NOT CURRENTLY USED, MAY BE USEFUL LATER)
func _ready() -> void:
	pass

# Guns attack function
func attack():
	var dir = (get_global_mouse_position() - gun.global_position).normalized()
	var origin = Vector2(gun.global_position.x, gun.global_position.y)
	if attack_type == Globals.ATTACK_TYPE.RECTANGLE:
		
		rectangle_attack(origin, dir)
	elif attack_type == Globals.ATTACK_TYPE.PROJECTILE:
		
		shoot_projectile(gun, dir, projectile_speed)
	
