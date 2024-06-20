extends Node2D


var start = Vector2i(-2,-2)
var end = Vector2i(17,20)
#var start = Vector2i(0,0)
#var end = Vector2i(4,4)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p = ($map_test/antagonist.global_position - $map_test/exit3.global_position) / ($map_test/exit.global_position - $map_test/exit3.global_position)
	#print(p)
	p *= Vector2(end)
	$view/SubViewport/isometric_test2.move_to_(p)

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
			if td:
				tiles.append(coords)
	$view/SubViewport/isometric_test2.create_map(tiles)
			
	
	
	
	
