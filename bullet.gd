extends Area2D

@export var speed: float = 750
@export var velocity: Vector2 = Vector2.ZERO
@export var damage_delt: int = 25


func _physics_process(delta):
	velocity = velocity.normalized() * speed
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group('enemies'):
		body.damage(damage_delt)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
