extends Node2D

class_name BuyableOption

export (PackedScene) var item_scene = null
export (String) var signal_to_emit = ""
export (String) var shop_name = ""
export (int) var cost = 0
export (bool) var should_not_be_removed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
