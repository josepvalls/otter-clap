extends Node2D

var elapsed = 0.0

@onready var blue = $blue
@onready var radar = $blue/radar

func _process(delta):
	elapsed += delta
	blue.position = Vector2(0,cos(elapsed)*16.0-100.0) 
	if position.distance_squared_to($"../red".position) > 1600000:
		radar.show()
		radar.look_at($"../red".global_position)
		radar.modulate = Color(1.0,1.0,1.0,clamp(abs(cos(elapsed)), 0.1, 1.0))
	else:
		radar.hide()
