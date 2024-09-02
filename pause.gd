extends CanvasLayer


# Unpause using Godot's fancy pause stuff because the pause stops all other nodes from running
func _on_resume_button_pressed():
	self.hide()
	get_tree().paused = false
