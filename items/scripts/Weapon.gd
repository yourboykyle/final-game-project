class_name Weapon extends Equippable

const BULLET = preload("res://entities/Bullet.tscn")
@onready var player = get_node("/root/Main/Player")
# Weapon attributes
@export var fire_rate : float = 0.15
@export var range : float = 1500
@export var aoe : float = 10
@export var damage : float = 5
@export var linger_time : float = 0.0
@export var projectile_speed: int = 1000
@export var collision_mask : int = 1
@export var hitscan : bool
var fire_timer = 0.0

func try_attack():
	if !Globals.shooting_enabled:
		return
	
	if fire_timer <= 0:
		fire_timer = fire_rate
		# Call attack function
		attack()
		queue_redraw() 

# abstract attack class, ill make class abstract later
func attack():
	pass

# Logic for weapons that create a hitbox
func hitbox(origin, direction):
	var space_state = get_world_2d().direct_space_state
	var shape = RectangleShape2D.new()
	shape.size = Vector2(range, aoe)
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(direction.angle(), origin + direction * range / 2)
	query.exclude = [player, self]
	#query.collision_mask = collision_mask
	
	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider.has_method("take_damage"):
			collider.take_damage(damage)
	
	if linger_time > 0:
		var hitbox_area = Area2D.new()
		var col_shape = CollisionShape2D.new()
		col_shape.shape = shape
		hitbox_area.add_child(col_shape)
		hitbox_area.position = origin + direction * range / 2
		hitbox_area.rotation = direction.angle()
		get_tree().current_scene.add_child(hitbox_area)
		hitbox_area.body_entered.connect(func(body):
			if body.has_method("take_damage"):
				body.take_damage(damage)
		)
		var tween = create_tween()
		tween.tween_interval(linger_time)
		tween.tween_callback(hitbox_area.queue_free)
	
	# Drawing the line for debug
	var rect = ColorRect.new()
	rect.color = Color(1, 0.8, 0, 0.5)
	rect.size = Vector2(range, aoe)
	rect.pivot_offset = Vector2(0, rect.size.y / 2)
	rect.position = origin
	rect.rotation = direction.angle()
	get_tree().current_scene.add_child(rect)
	
	var tween2 = create_tween()
	tween2.tween_interval(max(linger_time, 0.05))
	tween2.tween_callback(rect.queue_free)

# Function that shoots a projectile in the direction of a crosshair
# Can probably reuse this for enemy logic 
func shoot_projectile(weapon):
	#create a bullet
	var bullet = BULLET.instantiate()
	
	# calculate the direction from the crosshair to the gun, and set the bullets direction to that
	var dir = (Globals.crosshair_instance.global_position - weapon.global_position).normalized()
	bullet.direction = dir
	bullet.damage = damage
	bullet.speed = projectile_speed
	
	# set the bullets starting point to the guns position
	bullet.global_position = weapon.global_position
	#Add the child to the scene tree
	get_tree().current_scene.add_child(bullet)
