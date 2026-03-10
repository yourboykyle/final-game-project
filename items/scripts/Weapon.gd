class_name Weapon extends Equippable

const BULLET = preload("res://entities/Bullet.tscn")
@onready var crosshair = get_node("/root/Main/Crosshair")
@onready var player_collision_shape = get_node("/root/Main/Player/CollsionShape")
# Weapon attributes
@export var weapon_name : String
@export var fire_rate : float = 0.15
@export var range : float = 1500
var fire_timer = 0.0

func try_attack():
	if !Globals.shooting_enabled:
		return
	
	if fire_timer <= 0:
		fire_timer = fire_rate
		# Call attack function
		attack()

# abstract attack class, ill make class abstract later
func attack():
	pass

# Logic for shooting a hitscan gun
func shoot_hitscan(origin, direction):
	# Get the current space state
	var space_state = get_world_2d().direct_space_state
	
	var end_pos = origin + direction * range
	print("Origin: " + str(origin))
	print("Direction: " + str(direction))
	print("End pos: " + str(end_pos))
	var query = PhysicsRayQueryParameters2D.create(origin, end_pos)
	query.exclude = [player_collision_shape, self]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		
		#Doesn't do anything yet because it has nothing to collide with
		
		#if collider.has_method("take_damage"):
		#	collider.take_damage(damage)
	
	# Create the line
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color(1, 0.8, 0)  # yellow
	line.points = [origin, end_pos]

	# Optional: use anti-aliasing for smooth lines
	line.antialiased = true

	# Add it to the scene
	get_tree().current_scene.add_child(line)

	# Make it visible for a short time (e.g., 0.05 seconds)
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = fire_rate/100
	timer.connect("timeout", Callable(line, "queue_free"))
	get_tree().current_scene.add_child(timer)
	timer.start()


# Function that shoots a projectile in the direction of a crosshair
# Can probably reuse this for enemy logic 
func shoot_projectile(weapon):
	#create a bullet
	var bullet = BULLET.instantiate()
	
	# calculate the direction from the crosshair to the gun, and set the bullets direction to that
	var dir = (crosshair.global_position - weapon.global_position).normalized()
	bullet.direction = dir
	
	# set the bullets starting point to the guns position
	bullet.global_position = weapon.global_position
	#Add the child to the scene tree
	get_tree().current_scene.add_child(bullet)
