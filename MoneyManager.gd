extends Node2D

signal bought_weapon(weapon)

onready var team = $Team
# TODO: Should probably have an array of all scenes that can be bought
onready var shotgun = preload("res://weapons/Shotgun.tscn")

var money: int = 0;
var number_of_team_bases: int = 1

func initialize(team_name: int):
	team.team = team_name

func handle_bases_changed(bases):
	number_of_team_bases = 1
	for base in bases:
		if base.team.team == team.team:
			number_of_team_bases += 1

func _on_Timer_timeout():
	# TODO: Add constant to multiply? 
	money += number_of_team_bases
	# TODO: Add money to GUI
	print(str(team.team) + " money: " + str(money) + "\nNumber of bases: " + str(number_of_team_bases))

func _unhandled_input(event):
	# Both sides share this scene but controls should only work for the player side
	if team.team == Team.TeamName.PLAYER and event.is_action_released("buy"):
		try_buy()

func try_buy():
	# This function is just a test function
	var cost: int = 20
	if money >= cost:
		print("Bought " + str(shotgun))
		money -= cost
		emit_signal("bought_weapon", shotgun)
	else:
		print("not enough")
