extends RigidBody2D

signal death

@export var min_speed: float = 150
@export var max_speed: float = 350
@export var health: int = 25
@export var damage_delt: int = 25
@export var points: int = 1
@export var mine_scene: PackedScene = preload('res://mine.tscn')
@export var item_scene: PackedScene = preload('res://item.tscn')
@export var explosion_scene: PackedScene = preload('res://explosion.tscn')
var speed: float
var zig_zag: bool
var has_mine: bool


func _ready():
	linear_velocity = Vector2(0, speed)
	if zig_zag: # Implimentation of zig-zagging enemies
		linear_velocity.x = min_speed * randi_range(-1, 1)
		$ZigZagTimer.wait_time = randf_range(0.5, 2)
		$ZigZagTimer.start()
	elif has_mine: # Non-zig-zagging enemies can lay mines
		$MineTimer.wait_time = randf_range(0.2, 2)
		$MineTimer.start()
	add_to_group('enemies')

# Switch to the zig of the zag
func _on_zig_zag_timer_timeout():
	linear_velocity = Vector2(-linear_velocity.x, speed)

func _on_mine_timer_timeout():
	lay_mine()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func damage(damage_amount: int):
	health = clamp(health - damage_amount, 0, INF)
	if health == 0:
		death.emit(points)
		explode()
	return health

func lay_mine():
	var mine = mine_scene.instantiate()
	get_tree().current_scene.add_child(mine)
	mine.transform = self.global_transform
	$MineSound.play()

func explode():
	# Randomly drop items
	if !bool(randi_range(0, 5)):
		var item = item_scene.instantiate()
		get_tree().current_scene.call_deferred('add_child', item)  # idk why this needs to be deferred but it errors if not
		item.transform = self.global_transform

	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.transform = self.global_transform
	queue_free()
