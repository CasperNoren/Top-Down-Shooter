extends Node2D

signal bought_weapon(weapon)
signal bought_team_members(amount)
signal bought_turret(turret)

# TODO: Add use
enum BuyOptions {
	SUBMACHINEGUN,
	SHOTGUN,
	TURRET1,
	TURRET2,
	TEAMMEMBER
}

onready var team = $Team 
onready var submachinegun = preload("res://weapons/SubmachineGun.tscn")
onready var shotgun = preload("res://weapons/Shotgun.tscn")
onready var turret = preload("res://actors/Turret.tscn")

var money: int = 0;
var number_of_team_bases: int = 1
# TODO: Remove, this is a test variable to use before a menu can choose what to buy
var times_bought: int = 0

func initialize(team_name: int):
	team.team = team_name
	#for weapon in $WeaponContainer.get_children():
		#weapon.hide()

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

func _unhandled_input(event):
	# Both sides share this scene but controls should only work for the player side
	if team.team == Team.TeamName.PLAYER and event.is_action_released("buy"):
		try_buy()

func try_buy():
	var debug_buy_all = false
	if debug_buy_all:
		for buy_option in BuyOptions:
			try_buy_option(BuyOptions[buy_option])
		# TODO: Remove return
		return
	
	# This function is just a test function

	var purchase_sucessful = false
	# TODO: Change to menu option
	match times_bought:
		0:
			purchase_sucessful = try_buy_option(BuyOptions.SUBMACHINEGUN)
		1:
			purchase_sucessful = try_buy_option(BuyOptions.SHOTGUN)
		2:
			purchase_sucessful = try_buy_option(BuyOptions.TURRET1)
		3:
			purchase_sucessful = try_buy_option(BuyOptions.TURRET2)
		_:
			purchase_sucessful = try_buy_option(BuyOptions.TEAMMEMBER)
	if purchase_sucessful:
		times_bought += 1

func try_buy_option(option: int) -> bool:
	var cost: int = 20
	var signal_to_emit: String = ""
	# TODO: Don't like using a non-typed variable
	var packed_scene: PackedScene = null
	var amount: int = -1
	
	match option:
			BuyOptions.SUBMACHINEGUN:
				cost = 1
				signal_to_emit = "bought_weapon"
				packed_scene = submachinegun
			BuyOptions.SHOTGUN:
				cost = 2
				signal_to_emit = "bought_weapon"
				packed_scene = shotgun
			BuyOptions.TURRET1:
				cost = 3
				signal_to_emit = "bought_turret"
				packed_scene = turret
			BuyOptions.TURRET2:
				cost = 3
				signal_to_emit = "bought_turret"
				packed_scene = turret
			BuyOptions.TEAMMEMBER:
				cost = 1
				signal_to_emit = "bought_team_members"
				amount = 1
			_:
				print("Invalid buy option")
				return false
	# TODO: Remove test cost = 0
	cost = 0
	if money >= cost:
		money -= cost
		
		if packed_scene != null and amount != -1:
			# TODO: Currently not used for any option, no signal exists currrently
			emit_signal(signal_to_emit, packed_scene, amount)
			# TODO: Add print for amount
			print_bought_packed_scene(packed_scene)
		elif packed_scene != null:
			emit_signal(signal_to_emit, packed_scene)
			print_bought_packed_scene(packed_scene)
		elif amount != -1:
			emit_signal(signal_to_emit, amount)
			print("Bought: ", amount, " ", signal_to_emit)
		else:
			printerr("Invalid buy option reached signal emitting stage")
			return false
		return true
	else:
		print("Not enough money to purchase: ", BuyOptions.keys()[option])
		return false

func print_bought_packed_scene(scene: PackedScene):
	# Can't use get_filename on packed scene
	var scene_instance = scene.instance()
	print("Bought: ", scene_instance.get_filename())
	scene_instance.queue_free()
