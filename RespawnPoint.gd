extends Position2D

class_name RespawnPoint

onready var area = $Area2D

func area_is_empty() -> bool:
	# All actors are physics bodies 
	if area.get_overlapping_bodies().size() == 0:
		return true
	else:
		return false
