extends Node2D

class_name MoneyManager

signal bought_weapon(weapon)
signal bought_team_members(amount)
signal bought_turret(turret)
signal money_changed(value)

enum BuyOptions {
	SUBMACHINEGUN,
	SHOTGUN,
	TURRET1,
	TURRET2,
	TEAMMEMBER
}

onready var team = $Team 
onready var buyable_options_container = $BuyableOptionsContainer
onready var buying_ai = $BuyingAI
# TODO: Remove these, first check so they aren't used anymore
onready var submachinegun = preload("res://weapons/SubmachineGun.tscn")
onready var shotgun = preload("res://weapons/Shotgun.tscn")
onready var turret = preload("res://actors/Turret.tscn")

export (bool) var debug_buy_all = false
export (bool) var debug_zero_cost = false

var money: int = 0 setget set_money
var number_of_team_bases: int = 1
# TODO: Remove, this is a test variable to use before a menu can be used to choose what to buy
var times_bought: int = 0
var options: Array = []
var removed_options: Array = []
var options_to_not_remove: Array = []

func initialize(team_name: int):
	team.team = team_name
	for buyable_option in buyable_options_container.get_children():
		options.append(buyable_option)
		if buyable_option.should_not_be_removed:
			options_to_not_remove.append(buyable_option)

func handle_bases_changed(bases):
	number_of_team_bases = 1
	for base in bases:
		if base.team.team == team.team:
			number_of_team_bases += 1

func _on_Timer_timeout():
	# TODO: Add constant to multiply? 
	money += number_of_team_bases
	# TODO: Add money to GUI
	print(str(team.team) + " money: " + str(money) + "| Number of bases: " + str(number_of_team_bases))
	# It's for the GUI
	if team.team == Team.TeamName.PLAYER:
		emit_signal("money_changed", money)

func _unhandled_input(event):
	# Both sides share this scene but controls should only work for the player side
	# TODO: Remove, testing
	return
	if team.team == Team.TeamName.PLAYER and event.is_action_released("buy"):
		try_buy()

func handle_buy_button_pressed(option: BuyableOption):
	#print(BuyOptions.keys()[option], " buy button reached money manager")
	var purchase_successful = false
	# TODO: this shouldn't be done:
	if option.shop_name == "Team Member(s)":
		purchase_successful = try_buy_option(option, 2)
	else:
		purchase_successful = try_buy_option(option)
	
	if purchase_successful:
		GlobalSignals.emit_signal("purchase_was_success", option)
		# -1 means that the option is not in the list
		if options_to_not_remove.find(option) == -1:
			add_removed_option(option)

func try_buy():
	# This function is just a test function
	# Debug: also sets costs to zero
	if debug_buy_all:
		for option in options:
			try_buy_option(option)
		return
	
	var purchase_successful = false
	# TODO these are not updated:
	return
	match times_bought:
		0:
			pass
			#purchase_successful = try_buy_option(BuyOptions.SUBMACHINEGUN)
		1:
			pass
			#purchase_successful = try_buy_option(BuyOptions.SHOTGUN)
		2:
			pass
			#purchase_successful = try_buy_option(BuyOptions.TURRET1)
		3:
			pass
			#purchase_successful = try_buy_option(BuyOptions.TURRET2)
		_:
			pass
			#purchase_successful = try_buy_option(BuyOptions.TEAMMEMBER, 2)
	if purchase_successful:
		times_bought += 1

func try_buy_option(option: BuyableOption, amount: int = -1) -> bool:
	# amount: int -1 functions as null here
	var cost: int = option.cost
	var signal_to_emit: String = option.signal_to_emit
	var packed_scene: PackedScene = option.item_scene
	
	# debug_buy_all needs the cost to be zero to purchase everything sucessfully
	if debug_zero_cost or debug_buy_all:
		cost = 0
		
	if money >= cost:
		set_money(money - cost)
		if team.team == Team.TeamName.PLAYER:
			emit_signal("money_changed", money)
		
		if packed_scene == null:
			# Should always show the amount, null (-1) will count as 1
			if amount == -1:
				amount = 1
			emit_signal(signal_to_emit, amount)
		elif packed_scene != null and amount != -1:
			# TODO: Currently not used for any option, no signal exists currrently
			print("Error: MoneyManager tried to buy packed scene with amount (does not exist)")
			emit_signal(signal_to_emit, packed_scene, amount)
		elif packed_scene != null:
			emit_signal(signal_to_emit, packed_scene)
		else:
			printerr("Invalid buy option reached signal emitting stage")
			return false
		print_bought_option(option, amount)
		return true
	else:
		print_bought_option(option, amount, false)
		return false

func print_bought_option(option: BuyableOption, amount: int, purchase_successful: bool = true):
	# -1 counts as null here
	var purchasing_message: String = "Bought: "
	if not purchase_successful:
		purchasing_message = "Not enought money to buy: "
	if amount == -1:
		print(purchasing_message, option.shop_name)
	else:
		print(purchasing_message, amount, " ", option.shop_name)

func set_money(new_value: int):
	money = new_value
	# Player doesn't need AI
	if team.team != Team.TeamName.PLAYER:
		buying_ai.set_money(money)

# This is more or less a setter 
func add_removed_option(option: BuyableOption):
	removed_options.append(option)
	# Player doesn't need AI
	if team.team != Team.TeamName.PLAYER:
		buying_ai.set_available_options(options, removed_options)
