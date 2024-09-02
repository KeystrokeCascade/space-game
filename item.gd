extends Area2D

@export var speed: float = 75
@export var spinny_speed: float = 4  # Radians per second


func _ready():
	add_to_group('items')

func _process(delta):
	self.rotate(spinny_speed * delta)

func _physics_process(delta):
	var velocity = Vector2.ZERO
	velocity.y = +1  # Move down
	velocity = velocity.normalized() * speed
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
