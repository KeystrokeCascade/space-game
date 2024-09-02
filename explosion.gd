extends AnimatedSprite2D


# Explode with a different pitch so it doesn't get too repetitive
func _ready():
	$ExplosionSound.pitch_scale = randf_range(0.5, 1.5)
	$ExplosionSound.play()

func _on_animation_finished():
	queue_free()
