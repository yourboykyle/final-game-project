class_name Weapon extends Equippable

const BULLET = preload("res://entities/Bullet.tscn")
const PLAYERBULLETTEXTURE = preload("res://assets/sprites/playerbullet.png")
const ENEMYBULLETTEXTURE = preload("res://assets/sprites/enemybullet.png")
# Weapon attributes
@export var attack_type: Globals.ATTACK_TYPE
#How fast the weapon shoots
@export var fire_rate : float = 1.0
#How far the raycast goes
@export var rectangle_range : float = 1500
#Size of the raycast
@export var aoe : float = 10
# main gun damage (hitscan gun uses this)
@export var damage : float = 15
#Linger is only visual
@export var linger_time : float = 0.05
#What layer it collides with
@export var collision_mask : int = 2
var fire_timer = 0.0
var weapon_owner = null

func _ready() -> void:
	max_stack_size = 1

func try_attack():
	if !Globals.shooting_enabled:
		return
	
	if fire_timer <= 0:
		fire_timer = fire_rate
		# Call attack function
		attack()

func _process(delta):
	fire_timer -= delta

# abstract attack method, ill make class abstract later
func attack():
	pass



# Logic for weapons use hitscan
func rectangle_attack(origin, direction):
	play_sound_effect()
	
	var space_state = get_world_2d().direct_space_state
	var shape = RectangleShape2D.new()
	shape.size = Vector2(rectangle_range, aoe)
	var query = PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(direction.angle(), origin + direction * rectangle_range / 2)
	query.shape = shape
	query.exclude = [weapon_owner, self]
	query.collision_mask = collision_mask

	var results = space_state.intersect_shape(query)
	draw_rectangle_debug(origin, direction)

	for result in results:
		var collider = result.collider
		if !collider.has_method("take_damage"):
			continue
		
		# Raycast from origin to this enemy to check for walls in between
		var ray = PhysicsRayQueryParameters2D.create(origin, collider.global_position)
		ray.exclude = [weapon_owner, self]
		ray.collision_mask = collision_mask
		var ray_result = space_state.intersect_ray(ray)
		
		# If nothing blocked the ray, or the ray hit this enemy directly, damage it
		if ray_result.is_empty() or ray_result.collider == collider:
			collider.take_damage(damage)




# Function that shoots a projectile in the direction of a crosshair
# Can probably reuse this for enemy logic 
func shoot_projectile(weapon, dir, projectile_speed):
	play_sound_effect()

	var bullet = BULLET.instantiate()
	
	bullet.direction = dir
	bullet.damage = damage
	bullet.speed = projectile_speed 
	if weapon_owner.is_in_group("boss"): 
		collision_mask = 1
	bullet.collision_mask = collision_mask
	
	# set the bullets starting point to the guns position
	bullet.global_position = weapon.global_position + (dir*50) 
	bullet.shooter = weapon_owner
	#Add the child to the scene tree
	get_tree().current_scene.add_child(bullet)
	
	if !weapon_owner || weapon_owner.is_in_group("player"):
		bullet.sprite_2d.texture = PLAYERBULLETTEXTURE
	
	if weapon_owner && (weapon_owner.is_in_group("enemy") || weapon_owner.is_in_group("boss")):
		bullet.sprite_2d.texture = ENEMYBULLETTEXTURE


func cone_attack(origin, direction, angle, radius):
	play_sound_effect()
	
	var space_state = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, origin) 
	print(weapon_owner)
	if weapon_owner:
		if weapon_owner.is_in_group("boss"):
				collision_mask = 1
				print("check")
		query.collision_mask = collision_mask
		query.exclude = [weapon_owner]
	
	var results = space_state.intersect_shape(query)
	
	var cone_angle = deg_to_rad(angle)
	var threshold = cos(cone_angle / 2.0)
	
	for result in results:
		var collider = result.collider
		if !collider:
			continue
		
		if !collider.has_method("take_damage"):
			continue
		
		var to_target = (collider.global_position - origin).normalized()
		var dot = direction.dot(to_target)
		
		if dot >= threshold:
			# Raycast to check for walls between origin and enemy
			var ray = PhysicsRayQueryParameters2D.create(origin, collider.global_position)
			ray.exclude = [weapon_owner, self]
			ray.collision_mask = collision_mask
			var ray_result = space_state.intersect_ray(ray)
			
			if ray_result.is_empty() or ray_result.collider == collider:
				collider.take_damage(damage)
	
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

func draw_rectangle_debug(origin, direction):
	# Drawing the line for debug
	var rect = ColorRect.new()
	rect.color = Color(1, 0.8, 0, 0.5)
	rect.size = Vector2(rectangle_range, aoe)
	rect.pivot_offset = Vector2(0, rect.size.y / 2)
	rect.position = origin + Vector2(0, -aoe/2)
	rect.rotation = direction.angle()
	get_tree().current_scene.add_child(rect)
	
	var tween = create_tween()
	tween.tween_interval(max(linger_time, 0.05))
	tween.tween_callback(rect.queue_free)
	
