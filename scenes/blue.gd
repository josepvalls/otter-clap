extends Node2D

var elapsed = 0.0

func _process(delta):
	elapsed += delta
	if position.distance_squared_to($"../red".position) > 2000000:
		$radar.show()
		$radar.look_at($"../red".global_position)
		$radar.modulate = Color(1.0,1.0,1.0,abs(cos(elapsed)))
	else:
		$radar.hide()
