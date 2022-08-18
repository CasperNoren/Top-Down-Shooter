extends CanvasLayer

onready var option_columns = $PauseMenuContainer/PanelContainer/MarginContainer/Rows/OptionColumns
onready var button_buy_option = preload("res://ui/ButtonBuyOption.tscn")

# Otherwise it closes down instantly
var has_been_released: bool = false
var options: Array = []
var removed_options: Array = []

func _ready():
	get_tree().paused = true
	
	for buy_option in MoneyManager.BuyOptions:
		print(removed_options.find(buy_option))
		if removed_options.find(buy_option) == -1:
			var option = button_buy_option.instance()
			option_columns.add_child(option)
			print(buy_option)
			option.initialize(MoneyManager.BuyOptions[buy_option])
			options.append(option)

func initialize(removed_options: Array):
	self.removed_options = removed_options

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

func remove_option(option: int):
	#print("Remove option: ", option, " | also known as: ", MoneyManager.BuyOptions.keys()[option])
	# Can't use find() because we look for the variable it has, not the button itself
	for option_button in options:
		# The for loop could go over a freed button
		if is_instance_valid(option_button):
			if option_button.option == option:
				#print(MoneyManager.BuyOptions.keys()[option], " option removed")
				option_button.queue_free()
				# No reason to keep going after option has been found
				return
	print("BuyScreen tried to remove option that does not exist")

func remove_multiple_options(options_to_remove: Array):
	for option in options_to_remove:
		remove_option(option)

func handle_purchase_was_success(option: int):
	# Team member option shouldn't disappear
	if option == MoneyManager.BuyOptions.TEAMMEMBER:
		return
	remove_option(option)
