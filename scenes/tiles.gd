extends Node2D

func make_visible(q: Array, s=1, n=3):
	for idx in q.size()-s:
		q[idx+s].visible = false
	for i in n:
		var idx = randi()%(q.size() - s)
		q[idx+s].visible = true
		q.remove_at(idx+s)

func set_kind(kind):
	if kind==0:
		# paths
		for child in get_children():
			child.visible = false
		get_children()[randi()%get_child_count()].visible=true
		z_index = -1
	elif kind==1:
		# trees
		make_visible(get_children())
		z_index = 0
	elif kind==2:
		# walls
		for child in get_children():
			child.visible = false
		get_children()[randi()%get_child_count()].visible=true
		z_index = 0
	elif kind==3:
		# goal
		$"GPUParticles2D".emitting = true
	elif kind==4:
		# grass
		make_visible(get_children(), 1, 6)
		z_index = 0
	elif kind==5:
		make_visible(get_children())
		$"GPUParticles2D".show()
		$"GPUParticles2D".emitting = true
	elif kind==6:
		pass
	elif kind==100:
		make_visible(get_children(), 1, 1)

