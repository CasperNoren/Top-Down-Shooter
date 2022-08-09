extends Node2D


const BLINK_PARTICLE = preload("res://weapons/BlinkParticles.tscn")


func _ready():
	GlobalSignals.connect("blink_used", self, "handle_blink_used")


func handle_blink_used(position: Vector2, rotation):
	var blink = BLINK_PARTICLE.instance()
	add_child(blink)
	blink.global_position = position
	blink.global_rotation =  rotation
	blink.start_emitting()
