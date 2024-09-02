extends Area2D

signal death
signal update_health
signal update_item_timer

@export var speed: float = 400  # (pixels/sec)
@export var health: int = 100
@export var max_health: int = 100
@export var damage_delt: int = 25
@export var bullet_scene : PackedScene = preload('res://bullet.tscn')
@export var explosion_scene: PackedScene = preload('res://explosion.tscn')
var items: Array = ['health', 'shotgun', 'sniper', 'triple-shot']  # Would love to have a proper powerup system using objects but I lack time and brainpower, so strings and if-elses it is
var item_bag: Array
var item: String
var screen_size: Vector2  # Size of the game window.


func _ready():
	screen_size = get_viewport_rect().size
	update_health.emit(health)
	add_to_group('players')

func _process(delta):
	# Movement controller
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.normalized() * speed

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# Shooting controller
	if (Input.is_action_just_pressed('shoot') ||  # Shoot on hold
		Input.is_action_pressed('shoot') &&  # Shoot on press
		$BulletTimer.is_stopped()):
		gun()

	# Tell HUD what da timer at
	update_item_timer.emit($ItemTimer.time_left)

# Pick up items
func _on_area_entered(area):
	if area.is_in_group('items'):
		collect_item()
		area.queue_free()

# Get hit by enemies
func _on_body_entered(body):
	if body.is_in_group('enemies'):
		body.damage(damage_delt)
		damage(body.damage_delt)

func damage(damage_amount: int):
	health = clamp(health - damage_amount, 0, max_health)
	if health == 0:
		death.emit()
		explode()
	update_health.emit(health)

func gun():
	# Spread out shots in all directions
	if item == 'shotgun':
		shoot(-30)
		shoot(0)
		shoot(30)

	# High velocity and damage
	if item == 'sniper':
		shoot(0, 0, 2, 2000, 100)  # Yes it's an ugly unreadable function but GDScript doesn't have kwargs :(

	# Clear a corridor in front of you
	if item == 'triple-shot':
		shoot(0, -50)
		shoot()
		shoot(0, 50)

	# Boring normal bullet
	if item == '':
		shoot()

	$BulletTimer.start()

# Cursed bullet-making fuction to reduce code repititon around powerups
func shoot(angle: float = 0, offset: float = 0, bullet_scale: float = 1, bullet_speed: float = 0, bullet_damage_delt: float = 0):
	var bullet = bullet_scene.instantiate()
	var radians = deg_to_rad(angle)

	bullet.velocity = Vector2(sin(radians), -cos(radians))
	get_tree().current_scene.add_child(bullet)

	bullet.transform = $BulletSpawn.global_transform
	bullet.rotation = radians
	bullet.transform.origin += Vector2(offset, 0)
	bullet.scale = Vector2(bullet_scale, bullet_scale)
	if bullet_speed != 0:
		bullet.speed = bullet_speed
	if bullet_damage_delt != 0:
		bullet.damage_delt = bullet_damage_delt

	$BulletSound.play()

func collect_item():
	$ItemSound.play()

	# Bag method of randomness so you can't get same thing 100 times in a row
	if item_bag.size() == 0:
		item_bag.assign(items)
	item_bag.shuffle()
	item = item_bag.pop_back()

	if item == 'health':  # Special handling of health
		$/root/Main/HUD.show_message('Health!')
		health = clamp(health + 25, 0, max_health)
		update_health.emit(health)
		$ItemTimer.stop()
		item = ''  # Stop health from messing with other item stuff

	# Item effects listed in shoot function
	if item == 'shotgun':
		$/root/Main/HUD.show_message('Shotgun!')
		$ItemTimer.start()

	if item == 'sniper':
		$/root/Main/HUD.show_message('Sniper!')
		$ItemTimer.start()

	if item == 'triple-shot':
		$/root/Main/HUD.show_message('Triple Shot!')
		$ItemTimer.start()

# Clear item when time runs out
func _on_item_timer_timeout():
	item = ''

func explode():
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.transform = self.global_transform
	queue_free()
