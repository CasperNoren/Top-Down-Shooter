extends CanvasLayer

# Otherwise it closes down instantly
var has_been_released: bool = false

func _ready():
	print("I'm new")
	get_tree().paused = true

func _on_ContinueButton_pressed():
	handle_continue()


func _on_MainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://ui/MainMenuScreen.tscn")

func _unhandled_input(event):
	# Is necessary to have the bool and use released instead of pressed ...
	# ... otherwise issues arise with the menu reopening or closing instantly
	if event.is_action_released("pause"):
		if not has_been_released:
			has_been_released = true
		else:
			handle_continue()

func handle_continue():
	get_tree().paused = false
	queue_free()
