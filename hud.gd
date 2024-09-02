extends CanvasLayer

signal start_game


func _on_start_button_pressed():
	$StartButton.hide()
	$TitleLabel.hide()
	$CreditLabel.hide()
	$PauseButton.show()
	$HealthBar.show()
	start_game.emit()

# Using Godot's built-in pause stuff
func _on_pause_button_pressed():
	get_tree().paused = true
	$Pause.show()

func show_message(text: String):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func _on_message_timer_timeout():
	$MessageLabel.hide()

func update_score(score: int):
	$ScoreLabel.text = str(score)

func update_health(health: int):
	$HealthBar.value = health

# Timer showing how long an item has left, hidden when empty
func update_item_timer(item_time: float):
	$ItemBar.value = item_time
	if $ItemBar.value == 0:
		$ItemBar.hide()
	else:
		$ItemBar.show()

# Boss health bar, hidden when empty
func update_boss_health(health: int):
	$BossHealthBar.value = health
	if $BossHealthBar.value == 0:
		$BossHealthBar.hide()
	else:
		$BossHealthBar.show()

func show_game_over():
	show_message('Game Over')
	$HealthBar.hide()
	$ItemBar.hide()
	$BossHealthBar.hide()
	$PauseButton.hide()
	# Wait for MessageTimer
	await $MessageTimer.timeout

	$StartButton.show()
	$TitleLabel.show()
	$CreditLabel.show()
