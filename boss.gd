extends RigidBody2D

signal death
signal update_health

@export var health: int = 1000
@export var damage_delt: int = 50
@export var points: int = 10
@export var missile_volley: int = 4
@export var frenzy_thresholds: Array = [750, 500, 250, 0]
@export var missile_scene: PackedScene = preload('res://missile.tscn')
@export var explosion_scene: PackedScene = preload('res://explosion.tscn')
var speed: float


func _ready():
	add_to_group('enemies')

# Random boss movement along the top of the screen
func _on_move_timer_timeout():
	var boss_move_location = get_node('/root/Main/EnemyPath/EnemySpawn')
	boss_move_location.progress_ratio = randf()
	move_to_postition(boss_move_location.position)

# Moving to where the boss isn't because it knows where it is
func move_to_postition(where_it_isnt: Vector2):
	var where_it_is = self.position
	self.linear_velocity =  where_it_isnt - where_it_is
	await get_tree().create_timer(1).timeout
	self.linear_velocity = Vector2.ZERO

# Fire a missile volley out at random
func _on_missile_timer_timeout():
	for i in missile_volley:
		shoot(randf_range(-35, 35))
		await get_tree().create_timer(.3).timeout

# Crazy frenzy at certain health thresholds
func frenzy():
	# Save these for later
	var move_timer = $MoveTimer.wait_time
	var missile_timer = $MissileTimer.wait_time

	$MoveTimer.wait_time = .5
	$MissileTimer.wait_time = 1.5
	await get_tree().create_timer(6).timeout

	$MoveTimer.wait_time = move_timer
	$MissileTimer.wait_time = missile_timer

# Simplified version of player shoot controller that only cares about angle
func shoot(angle: float = 0):
	var missile = missile_scene.instantiate()
	var radians = deg_to_rad(angle)

	missile.velocity = Vector2(-sin(radians), cos(radians))
	get_tree().current_scene.add_child(missile)

	missile.transform = $MissileSpawn.global_transform
	missile.rotation = radians
	missile.transform.origin -= Vector2(angle * 4, 0)
	$MissileSound.play()

func damage(damage_amount: int):
	health = clamp(health - damage_amount, 0, INF)
	update_health.emit(health)
	if health == 0:
		death.emit(points)
		explode()
	# Activate frenzy
	if health < frenzy_thresholds[0]:
		frenzy_thresholds.pop_front()
		frenzy()
	return health

func explode():
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.transform = self.global_transform
	explosion.scale = Vector2(4, 4)
	queue_free()
