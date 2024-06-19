extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 10000

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity.x = move_toward(velocity.x, SPEED * direction.x, ACCELERATION*delta)
		velocity.y = move_toward(velocity.y, SPEED * direction.y, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		var tilemap: TileMap = $"../map/NavigationRegion2D/TileMap"
		var coords = tilemap.local_to_map(tilemap.to_local(global_position))
		var td: TileData = tilemap.get_cell_tile_data(0, coords + Vector2i(0,-1))
		print("accept ", coords, td)
		tilemap.set_cell(0, coords, 2, Vector2i(5, 4))
		var next = Vector2i.ZERO
		if randf()<0.5:
			next = Vector2i(-1, 0)
		else:
			next = Vector2i(1, 0)
		tilemap.set_cell(0, coords+next, -1, Vector2i(5, 4))
			
		#tilemap.set_cells_terrain_connect
		var region: NavigationRegion2D = $"../map/NavigationRegion2D"
		region.bake_navigation_polygon()
		
		
