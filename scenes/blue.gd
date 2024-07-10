extends Node2D
class_name ProtagonistBody
var elapsed = 0.0

@onready var blue = $blue

func _process(delta):
	elapsed += delta
	blue.position = Vector2(0,cos(elapsed)*16.0-100.0) 


func add_radar_target(target: Node2D):
	var radar = preload("res://scenes/radar.tscn").instantiate() as Radar
	radar.radar_target = target
	$blue.add_child(radar)
	
func hide_footsteps():
	$footstep_revealing_light.texture_scale = 0.1
	
func grow_footsteps(delta):
	$footstep_revealing_light.texture_scale = clamp($footstep_revealing_light.texture_scale + delta, 1, 100)
