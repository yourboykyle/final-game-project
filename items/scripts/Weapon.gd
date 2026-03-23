class_name Weapon extends Equippable

const BULLET = preload("res://entities/Bullet.tscn")
@onready var player = get_node("/root/Main/DungeonContainer/Player")
# Weapon attributes
#How fast the weapon shoots
@export var fire_rate : float = 1.0
#How far the raycast goes
@export var hitscan_range : float = 1500
#Size of the raycast
@export var aoe : float = 10
@export var damage : float = 34
#Linger is only visual
@export var linger_time : float = 0.05
#How fast projectile goes
@export var projectile_speed: int = 1000
#What layer it collides with
@export var collision_mask : int = 2
@export var hitscan : bool
var fire_timer = 0.0

func _ready() -> void:
	add_to_group("weapons")

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

# Logic for weapons use hitscan
func hitscan_attack(origin, direction):
	var space_state = get_world_2d().direct_space_state
	var shape = RectangleShape2D.new()
	shape.size = Vector2(hitscan_range, aoe)
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(direction.angle(), origin + direction * hitscan_range / 2)
	query.exclude = [player, self]
	query.collision_mask = collision_mask
	
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
		hitbox_area.position = origin + direction * hitscan_range / 2
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
	rect.size = Vector2(hitscan_range, aoe)
	rect.pivot_offset = Vector2(0, rect.size.y / 2)
	rect.position = origin
	rect.rotation = direction.angle()
	get_tree().current_scene.add_child(rect)
	
	var tween2 = create_tween()
	tween2.tween_interval(max(linger_time, 0.05))
	tween2.tween_callback(rect.queue_free)

# Function that shoots a projectile in the direction of a crosshair
# Can probably reuse this for enemy logic 
func shoot_projectile(weapon, dir):
	#create a bullet
	var bullet = BULLET.instantiate()
	
	bullet.direction = dir
	bullet.damage = damage
	bullet.speed = projectile_speed
	
	# set the bullets starting point to the guns position
	bullet.global_position = weapon.global_position
	#Add the child to the scene tree
	get_tree().current_scene.add_child(bullet)


func cone_attack(origin, direction, angle, radius):
	var space_state = get_world_2d().direct_space_state
	
	# Step 1: detect everything in a circle
	var shape = CircleShape2D.new()
	shape.radius = radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, origin)
	query.collision_mask = collision_mask
	query.exclude = [player]
	
	var results = space_state.intersect_shape(query)
	
	# Step 2: filter into a cone
	var cone_angle = deg_to_rad(angle)
	var threshold = cos(cone_angle / 2.0)
	
	for result in results:
		var collider = result.collider
		
		if !collider:
			continue
		
		var to_target = (collider.global_position - origin).normalized()
		var dot = direction.dot(to_target)
		
		if dot >= threshold:
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
	
	# Debug cone
	draw_cone_debug(origin, direction, cone_angle, radius)

func draw_cone_debug(origin, direction, angle, length):
	var line = Line2D.new()
	line.width = 2
	
	var points = [origin]
	var steps = 20
	
	for i in range(steps + 1):
		var t = -angle/2 + angle * (i / float(steps))
		var dir = direction.rotated(t)
		points.append(origin + dir * length)
	
	points.append(origin)
	line.points = points
	
	get_tree().current_scene.add_child(line)
	
	var tween = create_tween()
	tween.tween_interval(linger_time)
	tween.tween_callback(line.queue_free)
