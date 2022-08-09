extends CanvasLayer


onready var title = $PanelContainer/MarginContainer/Rows/Title
onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("Fade")

func set_title(win: bool):
	if win:
		title.text = "YOU WIN!"
		title.modulate = Color.green
	else:
		title.text = "YOU LOSE!"
		title.modulate = Color.red

func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Main.tscn")

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://ui/MainMenuScreen.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
