extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var t = 2.0
	$i1.modulate = Color(1,1,1,1)
	$i2.modulate = Color(1,1,1,0)
	$i3.modulate = Color(1,1,1,0)
	$i4.hide()
	$i4/Button.pressed.connect(main_menu_play)
	$i5.hide()
	var tween = create_tween()
	#tween.tween_property($i1, "modulate", Color(1,1,1,1), t)
	tween.tween_property($i2, "modulate", Color(1,1,1,1), t)
	tween.tween_property($i3, "modulate", Color(1,1,1,1), t)
	tween.tween_callback(main_menu)
	tween.play()

func main_menu():
	$i4.show()
	
func main_menu_play():
	$i5.modulate = Color(1,1,1,0)
	$i5.show()
	var tween = create_tween()
	tween.tween_property($i5, "modulate", Color(1,1,1,1), 0.5)
	tween.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/transfer_test.tscn")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
