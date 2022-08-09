extends Node2D

var capturable_bases: Array = []

func _ready():
	capturable_bases = get_children()

func get_capturable_bases() -> Array:
	return capturable_bases
