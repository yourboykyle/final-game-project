class_name Gun extends Weapon

# Shooting stuff
const BULLET = preload("res://entities/Bullet.tscn")
@onready var crosshair = get_node("/root/Main/Crosshair")
@onready var gun = get_node("/root/Main/Player/BaseGun")

var fire_rate = 0.15
var fire_timer = 0.0
# End shooting stuff

# Called when the node enters the scene tree for the first time.
func _process(delta):
	# Shooting stuff
	if Globals.shooting_enabled:
		fire_timer -= delta
		
		if Input.is_action_pressed("shoot") and fire_timer <= 0:
			fire_timer = fire_rate
			shoot()

func shoot():
	
	var bullet = BULLET.instantiate()
	
	print(crosshair)
	var dir = (crosshair.global_position - gun.global_position).normalized()
	bullet.direction = dir

	bullet.global_position = gun.global_position

	get_tree().current_scene.add_child(bullet)
