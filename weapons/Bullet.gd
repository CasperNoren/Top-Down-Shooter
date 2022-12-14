extends Area2D
class_name Bullet

export (int) var speed = 15
export (int) var damage = 20

onready var KillTimer = $KillTimer

var direction := Vector2.ZERO
var team: int = -1 

func _ready():
	KillTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()


func _on_KillTimer_timeout():
	queue_free()


func _on_Bullet_body_entered(body):
	if body.has_method("handle_hit"):
		GlobalSignals.emit_signal("bullet_impact", body.global_position, direction)
		if body.has_method("get_team") and body.get_team() != team:
			body.handle_hit(damage)
	queue_free()
