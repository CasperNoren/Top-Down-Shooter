extends CanvasLayer

onready var option_columns = $PauseMenuContainer/PanelContainer/MarginContainer/Rows/OptionColumns
onready var button_buy_option = preload("res://ui/ButtonBuyOption.tscn")

# Otherwise it closes down instantly
var has_been_released: bool = false
var options: Array = []

func _ready():
	get_tree().paused = true
	
	for buy_option in MoneyManager.BuyOptions:
		var option = button_buy_option.instance()
		option_columns.add_child(option)
		print(buy_option)
		option.initialize(MoneyManager.BuyOptions[buy_option])
		options.append(option)

func _on_ContinueButton_pressed():
	handle_continue()

func _unhandled_input(event):
	# Is necessary to have the bool and use released instead of pressed ...
	# ... otherwise issues arise with the menu reopening or closing instantly
	if event.is_action_released("buy"):
		if not has_been_released:
			has_been_released = true
		else:
			handle_continue()

func handle_continue():
	get_tree().paused = false
	queue_free()
