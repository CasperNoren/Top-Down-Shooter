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
# TODO: Should probably have an array or enum of all scenes that can be bought
onready var shotgun = preload("res://weapons/Shotgun.tscn")
onready var submachinegun = preload("res://weapons/SubmachineGun.tscn")
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
	for buy_option in BuyOptions:
		try_buy_option(BuyOptions[buy_option])
	
	# TODO: Remove return
	return
	# This function is just a test function
	var cost: int = 2
	if money >= cost:
		money -= cost
		
		# TODO: Change to menu option
		match times_bought:
			0:
				print_bought_packed_scene(submachinegun)
				emit_signal("bought_weapon", submachinegun)
			1:
				print_bought_packed_scene(shotgun)
				emit_signal("bought_weapon", shotgun)
			2:
				print_bought_packed_scene(turret)
				emit_signal("bought_turret", turret)
			3:
				print_bought_packed_scene(turret)
				emit_signal("bought_turret", turret)
			_:
				var team_members_to_buy = 1
				print("Bought: ", team_members_to_buy, " team member(s)")
				emit_signal("bought_team_members", team_members_to_buy)
		times_bought += 1
	else:
		print("Not enough")

func try_buy_option(option: int):
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
				return
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

func print_bought_packed_scene(scene: PackedScene):
	# Can't use get_filename on packed scene
	var scene_instance = scene.instance()
	print("Bought: ", scene_instance.get_filename())
	scene_instance.queue_free()
