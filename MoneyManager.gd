extends Node2D

onready var team = $Team

var money: int = 0;
var number_of_team_bases: int = 0

func initialize(team_name: int):
	team.team = team_name

func handle_bases_changed(bases):
	number_of_team_bases = 0
	for base in bases:
		if base.team.team == team.team:
			number_of_team_bases += 1

func _on_Timer_timeout():
	money += number_of_team_bases
	print(str(team.team) + " money: " + str(money) + "\nNumber of bases: " + str(number_of_team_bases))

func _unhandled_input(event):
	if team.team == Team.TeamName.PLAYER and event.is_action_released("buy"):
		try_buy()

func try_buy():
	if money >= 20:
		money -= 20
		print("Bought")
