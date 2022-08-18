extends Node2D

const Player = preload("res://actors/Player.tscn")
const GameOverScreen = preload("res://ui/GameOverScreen.tscn")
const PauseScreen = preload("res://ui/PauseScreen.tscn")
const BuyScreen = preload("res://ui/BuyScreen.tscn")

onready var player_respawn_timer = $PlayerRespawnTimer
onready var capturable_base_manager = $CapturableBaseManager
onready var ally_ai = $AllyMapAI
onready var enemy_ai = $EnemyMapAI
onready var ally_turret_spots = $AllyTurretSpots
onready var enemy_turret_spots = $EnemyTurretSpots
onready var bullet_manager = $BulletManager
onready var money_manager = $MoneyManager
onready var player: Player = $Player
onready var camera = $Camera2D
onready var gui = $GUI
onready var ground = $Ground
onready var pathfinding = $PathFinding

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")
	GlobalSignals.connect("buy_option_pressed", ally_ai.money_manager, "handle_buy_button_pressed")
	
	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints
	
	pathfinding.create_navigation_map(ground)
	
	var bases = capturable_base_manager.get_capturable_bases()
	ally_ai.initialize(bases, ally_respawns.get_children(), pathfinding, ally_turret_spots.get_children())
	enemy_ai.initialize(bases, enemy_respawns.get_children(), pathfinding, enemy_turret_spots.get_children())
	capturable_base_manager.connect("player_captured_all_bases", self, "handle_player_win")
	capturable_base_manager.connect("player_lost_all_bases", self, "handle_player_lost")
	capturable_base_manager.connect("bases_changed", self, "handle_bases_changed")
	
	spawn_player()

func spawn_player():
	# Create player
	print("Spawned player")
	var player = Player.instance()
	add_child(player)
	
	# Set up camera, death signal and gui connection
	player.set_camera_transform(camera.get_path())
	player.connect("died", self, "handle_player_died")
	gui.set_player(player)
	
	# Get the Player-Team's weapons and give them to the player
	for weapon in ally_ai.bought_weapons_array:
		player.weapon_manager.add_weapon(weapon.instance())

func handle_player_died():
	# Signal could be emitted multiple times which would otherwise cause multiple players to spawn
	if player_respawn_timer.is_stopped():
		player_respawn_timer.start()

func handle_player_win():
	var game_over = GameOverScreen.instance()
	add_child(game_over)
	# GameOverScreen has pause mode set to process instead of inherit so it won't be paused
	game_over.set_title(true)
	get_tree().paused = true

func handle_player_lost():
	var game_over = GameOverScreen.instance()
	add_child(game_over)
	# GameOverScreen has pause mode set to process instead of inherit so it won't be paused
	game_over.set_title(false)
	get_tree().paused = true

func handle_bases_changed(bases: Array):
	gui.set_bases(bases)
	ally_ai.money_manager.handle_bases_changed(bases)
	enemy_ai.money_manager.handle_bases_changed(bases)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		var pause_menu = PauseScreen.instance()
		add_child(pause_menu)
	elif event.is_action_pressed("buy"):
		var buy_screen = BuyScreen.instance()
		GlobalSignals.connect("purchase_was_success", buy_screen, "handle_purchase_was_success")
		add_child(buy_screen)
		# Needs to be after it's added as a scene otherwise _ready() and onready vars won't already have run
		buy_screen.set_options_to_not_remove(ally_ai.money_manager.options_to_not_remove)
		buy_screen.remove_multiple_options(ally_ai.money_manager.removed_options)


func _on_PlayerRespawnTimer_timeout():
	# TODO: Add count down?
	spawn_player()
