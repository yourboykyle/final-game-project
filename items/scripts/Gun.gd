class_name Gun extends Weapon

# Shooting stuff
@onready var gun = self
# Gun attributes (empty for now)

# Add every gun to the gun group (NOT CURRENTLY USED, MAY BE USEFUL LATER)
func _ready() -> void:
	add_to_group("guns")

# Called when the node enters the scene tree for the first time.
func _process(delta):
	fire_timer -= delta

# Guns attack function
func attack():
	if hitscan:
		var dir = (get_global_mouse_position() - gun.global_position).normalized()
		hitbox(global_position, dir)
	else:
		shoot_projectile(gun)
	
