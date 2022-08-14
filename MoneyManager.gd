extends Node2D


var player_money: int = 0;
var number_of_player_bases: int = 0

func handle_bases_changed(bases):
	number_of_player_bases = 0
	for base in bases:
		if base.team.team == Team.TeamName.PLAYER:
			number_of_player_bases += 1


func _on_Timer_timeout():
	player_money += number_of_player_bases
	print("Player money: " + str(player_money) + "\nNumber of player bases: " + str(number_of_player_bases))
