class_name Gun extends Weapon

# Shooting stuff
@onready var gun = self
# Gun attributes
#If it shoots a raycast or projectile (true for raycast)

# Add every gun to the gun group (NOT CURRENTLY USED, MAY BE USEFUL LATER)
func _ready() -> void:
	pass

func _process(delta):
	fire_timer -= delta

# Guns attack function
func attack():
	var dir = (get_global_mouse_position() - gun.global_position).normalized()
	if self.hitscan:
		hitscan_attack(global_position, dir)
	else:
		shoot_projectile(gun, dir)
	
