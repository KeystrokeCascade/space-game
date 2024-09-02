extends Area2D

@export var speed: float = 300
@export var velocity: Vector2 = Vector2.ZERO
@export var damage_delt: int = 50
@export var explosion_scene: PackedScene = preload('res://explosion.tscn')


func _ready():
	add_to_group('enemies')

func _physics_process(delta):
	velocity = velocity.normalized() * speed
	position += velocity * delta

func _on_area_entered(area):
	if area.is_in_group('players'):
		area.damage(damage_delt)
		explode()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func explode():
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.transform = self.global_transform
	queue_free()
