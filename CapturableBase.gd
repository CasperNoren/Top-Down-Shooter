extends Area2D
class_name CapturableBase

signal base_captured(new_team)

export (Color) var neutral_color = Color(1, 1, 1)
export (Color) var player_color = Color(0.235294, 0.431373, 0.129412)
export (Color) var enemy_color = Color(0.156863, 0.364706, 0.603922)
export (bool) var debug_show_capture_prints = false

onready var collision_shape = $CollisionShape2D
onready var team = $Team
onready var capture_timer = $CaptureTimer
onready var sprite = $Sprite
onready var player_label = $PlayerLabel
onready var enemy_label = $EnemyLabel

var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL

func _ready():
	player_label.text = "0"
	enemy_label.text = "0"

func get_random_position_within_capture_radius() -> Vector2:
	var extents = collision_shape.shape.extents
	var top_left = collision_shape.global_position - (extents / 2)
	
	var x = rand_range(top_left.x, top_left.x + extents.x)
	var y = rand_range(top_left.y, top_left.y + extents.y)
	
	return Vector2(x, y)

func _on_CapturableBase_body_entered(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.PLAYER:
			player_unit_count += 1
			change_player_label()
		elif body_team == Team.TeamName.ENEMY:
			enemy_unit_count += 1
			change_enemy_label()
		check_wheter_base_can_be_captured()


func _on_CapturableBase_body_exited(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.PLAYER:
			player_unit_count -= 1
			change_player_label()
		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count -= 1
			change_enemy_label()
		check_wheter_base_can_be_captured()

func change_player_label():
	player_label.text = str(player_unit_count)

func change_enemy_label():
	enemy_label.text = str(enemy_unit_count)

func check_wheter_base_can_be_captured():
	if debug_show_capture_prints:
		print(player_unit_count, " | ", enemy_unit_count)
	var majority_team = get_team_with_majority()
	if majority_team == Team.TeamName.NEUTRAL:
		if debug_show_capture_prints:
			print("Teams evened out, stopping capture clock. Current owner:", team.team)
		team_to_capture = Team.TeamName.NEUTRAL
		capture_timer.stop()
	if majority_team == team.team:
		if debug_show_capture_prints:
			print("Owning team regained majority, stopping clock: ", team.team)
		team_to_capture = team.TeamName.NEUTRAL
		capture_timer.stop()
	else:
		# If it's the same team as last time the function was called ...
		# ... and if the timer isn't stopped
		if majority_team == team_to_capture and capture_timer.time_left > 0:
			# If it's the same team as last time we don't want the timer to start over
			if debug_show_capture_prints:
				print("Team to capture number changed. Doing nothing to the clock")
			return
		if debug_show_capture_prints:
			print("New team has majority, starting clock. New team: ", majority_team)
		team_to_capture = majority_team
		capture_timer.start()

func get_team_with_majority() -> int:
	if enemy_unit_count == player_unit_count:
		return Team.TeamName.NEUTRAL
	if enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY
	else:
		return Team.TeamName.PLAYER

func set_team(new_team):
	team.team = new_team
	emit_signal("base_captured", new_team)
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite.modulate = neutral_color
			return
		Team.TeamName.ENEMY:
			sprite.modulate = enemy_color
			return
		Team.TeamName.PLAYER:
			sprite.modulate = player_color
			return

func _on_CaptureTimer_timeout():
	if team_to_capture != Team.TeamName.NEUTRAL:
		set_team(team_to_capture)
