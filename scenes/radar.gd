extends Node2D
class_name Radar

var radar_target: Node2D 
var elapsed = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	if radar_target:
		if position.distance_squared_to(radar_target.position) > 1600000:
			show()
			look_at(radar_target.global_position)
			modulate = Color(1.0,1.0,1.0,clamp(abs(cos(elapsed)), 0.1, 1.0))
		else:
			hide()

