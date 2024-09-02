extends Node

@export var player_scene: PackedScene  = preload('res://player.tscn')
@export var enemy_scene: PackedScene = preload('res://enemy.tscn')
@export var boss_scene: PackedScene = preload('res://boss.tscn')
var score: int


# Starts a new game by resetting score and spawning new player
func new_game():
	score = 0
	$HUD.update_score(score)
	$HUD.show_message('Get Ready')
	var player = player_scene.instantiate()
	player.position = $StartPosition.position
	player.connect('update_health', _on_update_health)
	player.connect('update_item_timer', _on_update_item_timer)
	player.connect('death', _on_player_death)
	add_child(player)
	$StartTimer.start()
	$Music.play()

func _on_start_timer_timeout():
	$EnemyTimer.start()

# Spawn enemies randomly
func _on_enemy_timer_timeout():
	var enemy = enemy_scene.instantiate()
	# Random point on Path2D and set spawn
	var enemy_spawn_location = get_node('/root/Main/EnemyPath/EnemySpawn')
	enemy_spawn_location.progress_ratio = randf()
	enemy.position = enemy_spawn_location.position

	# Random speed and zig-zag
	enemy.speed = randf_range(enemy.min_speed, enemy.max_speed)
	enemy.zig_zag = bool(randi_range(-1, 1))
	enemy.has_mine = bool(randi_range(-1, 1))

	enemy.connect('death', _on_update_score)
	add_child(enemy)

func _on_update_score(new_score: int):
	score = score + new_score
	$HUD.update_score(score)

	# Initiate boss every 30 levels
	if score % 30 == 0:
		initiate_boss()

func _on_update_health(new_health: int):
	$HUD.update_health(new_health)

func _on_update_item_timer(item_time: float):
	$HUD.update_item_timer(item_time)

func _on_player_death():
	game_over()

# Spawn the big bad
func initiate_boss():
	var boss = boss_scene.instantiate()
	# Spawn it in the middle of the screen
	var boss_spawn_location = get_node('EnemyPath/EnemySpawn')
	boss_spawn_location.progress_ratio = .5
	boss.position = boss_spawn_location.position
	boss.position.y = -200

	boss.connect('death', _on_update_score)
	boss.connect('update_health', _on_boss_update_health)
	call_deferred('add_child', boss)

func _on_boss_update_health(new_health: int):
	$HUD.update_boss_health(new_health)

func game_over():
	$EnemyTimer.stop()
	get_tree().call_group('enemies', 'queue_free')
	get_tree().call_group('items', 'queue_free')
	$HUD.show_game_over()
	$Music.stop()
