extends Node2D


var start = Vector2i(-3,-3)
var end = Vector2i(18,21)
#var start = Vector2i(0,0)
#var end = Vector2i(4,4)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_map()
	$map_test/protagonist.terrain_altered.connect(terrain_altered)

func terrain_altered(coords, kind):
	$view/SubViewport/isometric_test2.update_tile(coords, kind)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p 
	p = ($map_test/antagonist.global_position - $map_test/exit3.global_position) / ($map_test/exit.global_position - $map_test/exit3.global_position)
	p *= Vector2(end)
	$view/SubViewport/isometric_test2.move_to_(p, "red")
	p = ($map_test/protagonist.global_position - $map_test/exit3.global_position) / ($map_test/exit.global_position - $map_test/exit3.global_position)
	p *= Vector2(end)
	$view/SubViewport/isometric_test2.move_to_(p, "blue")

	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$view/SubViewport/isometric_test2.scale *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$view/SubViewport/isometric_test2.scale *= 0.9


func get_map():
	var tilemap = $map_test/map/NavigationRegion2D/TileMap
	var tiles = []
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			var coords = Vector2i(x,y)
			var td: TileData = tilemap.get_cell_tile_data(0, coords)
			var kind = 0
			if td:
				if td.terrain==1:
					kind=2
				elif td.terrain==2:
					kind=3
				else:
					kind=1
			tiles.append([coords, kind])
	$view/SubViewport/isometric_test2.create_map(tiles)
			
	
	
	
	
