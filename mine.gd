extends RigidBody2D

@export var speed: float = 150
@export var health: int = 25
@export var damage_delt: int = 50
@export var explosion_scene: PackedScene = preload('res://explosion.tscn')
var in_range: bool
var target: Area2D


func _ready():
	add_to_group('enemies')

# Lerp towards a player in range
func _physics_process(delta):
	if in_range:
		self.position = self.position.lerp(target.position, delta * (speed / 60))

# Lock onto a player to lerp to
func _on_detection_radius_area_entered(area):
	if area.is_in_group('players'):
		in_range = true
		target = area

# Un-lock player out of range so not infinite
func _on_detection_radius_area_exited(area):
	if area.is_in_group('players'):
		in_range = false

func damage(damage_amount: int):
	health = clamp(health - damage_amount, 0, INF)
	if health == 0:
		explode()
	return health

func explode():
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.transform = self.global_transform
	explosion.scale = Vector2(0.6, 0.6)
	queue_free()
