extends Node2D

signal buying_ai_choose_option(option)

# Should have priorities like: 
# 	if the player has more actors -> prioritize more actors
# 	if only the home base is left -> prioritize turrets
# 	else -> buy weapons
# Maybe priority should be an int that can be changed depending on factors?

var available_options: Array = []
var money: int = 0

func choose_next_purchase():
	pass

# TODO: Make moneymanager call this when removed_options has been updated
# Returns all options that aren't removed
func set_available_options(all_options: Array, removed_options: Array) -> Array:
	available_options = []
	for option in all_options:
		# -1 means that the option is not in the list
		if removed_options.find(option) == -1:
			available_options.append(option)
	return available_options

func set_money(money: int):
	self.money = money 