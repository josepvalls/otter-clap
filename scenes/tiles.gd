extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_kind(kind):
	$"0".hide()
	$"1".hide()
	$"2".hide()
	$"3".hide()
	$"4".hide()
	$"5".hide()
	$"3/GPUParticles2D".emitting = false
	$"5/GPUParticles2D".emitting = false
	if kind==0:
		$"0".show()
		for child in $"0".get_children():
			child.visible = false
		$"0".get_children()[randi()%$"0".get_child_count()].visible=true
		z_index = -1
	elif kind==1:
		$"1".show()
		for child in $"1".get_children():
			if child.name == "Base":
				continue
			child.visible = bool(randf()<0.3)
		z_index = 0
	elif kind==2:
		$"2".show()
		for child in $"2".get_children():
			child.visible = false
		$"2".get_children()[randi()%$"2".get_child_count()].visible=true
		z_index = 0
	elif kind==3:
		$"3".show()
		$"3/GPUParticles2D".emitting = true
	elif kind==4:
		$"4".show()
		for child in $"4".get_children():
			if child.name == "Base":
				continue
			child.visible = bool(randf()<0.5)
		z_index = 0
	elif kind==5:
		$"5".show()
		$"5/GPUParticles2D".emitting = true

