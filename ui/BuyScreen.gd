extends CanvasLayer

onready var option_columns_container = $PauseMenuContainer/PanelContainer/MarginContainer/Rows/OptionColumnsContainer
onready var current_option_column = $PauseMenuContainer/PanelContainer/MarginContainer/Rows/OptionColumnsContainer/OptionColumns
onready var button_buy_option = preload("res://ui/ButtonBuyOption.tscn")
onready var option_column_scene = preload("res://ui/OptionColumns.tscn")

export (bool) var debug_show_prints = false

# Otherwise it closes down instantly
var has_been_released: bool = false
var options: Array = []
var options_to_not_remove: Array = []
var max_options_per_row = 3

func _ready():
	get_tree().paused = true

func add_options(options_to_add: Array):
	# TODO: Make it so options start a new row if there are too many
	for buy_option in options_to_add:
		var option = button_buy_option.instance()
		
		if current_option_column.get_children().size() >= max_options_per_row:
			var new_column = option_column_scene.instance()
			option_columns_container.add_child(new_column)
			current_option_column = new_column
		current_option_column.add_child(option)
		
		option.initialize(buy_option)
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

func remove_option(option: BuyableOption):
	if debug_show_prints:
		print("Remove option: ", option.shop_name)
	# Can't use find() because we look for the variable it has, not the button itself
	for option_button in options:
		# The for loop could go over a freed button
		if is_instance_valid(option_button):
			if option_button.option == option:
				if debug_show_prints:
					print(option.shop_name, " option removed")
				option_button.queue_free()
				# No reason to keep going after option has been found
				return
	# Should never happened therefore shown even without debug_show_prints 
	print("BuyScreen tried to remove option that does not exist")

func remove_multiple_options(options_to_remove: Array):
	for option in options_to_remove:
		remove_option(option)

func handle_purchase_was_success(option: BuyableOption):
	# Not being -1 means that it is in the list of things not to remove
	if options_to_not_remove.find(option) != -1:
		# Some options shouldn't disappear so they just return out right away
		return
	remove_option(option)

func set_options_to_not_remove(options_to_not_remove: Array):
	# Shouldn't be done in initialize because the list might change dynamically in the future ...
	# ... like setting a limit for how many times something can be bought
	self.options_to_not_remove = options_to_not_remove
	if debug_show_prints:
		print("Options to not remove: ", options_to_not_remove)
