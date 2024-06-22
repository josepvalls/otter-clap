extends Node2D



@onready var level: MyIsometricMap = $view/SubViewport/isometric_test2
@onready var map: MyTileMap = $map_test/map/NavigationRegion2D/TileMap
@onready var region: NavigationRegion2D = $map_test/map/NavigationRegion2D
@onready var antagonist: Antagonist = $map_test/antagonist
var antagonist_path_failures = 0
var tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready():
	get_map()
	$map_test/protagonist.terrain_altered.connect(terrain_altered)
	$map_test/protagonist.terrain_possessed.connect(terrain_possessed)
	$map_test/protagonist.movement.connect(movement)
	level.move_to_($map_test/protagonist.coords, "blue", null)
	map.build_graph(antagonist.goal)
	move_antagonist()
	
func move_antagonist():
	if not antagonist.path:
		var path_data = []
		if antagonist.coords != antagonist.goal:
			path_data = map.find_path(antagonist.coords, antagonist.goal)
		else:
			path_data = map.find_path(antagonist.coords, antagonist.exits[randi()%antagonist.exits.size()])
		antagonist.path = path_data[1]
		print("path", antagonist.path)
		if path_data[0]==false:
			antagonist_path_failures +=1
			print("path failure ", antagonist_path_failures)
	if antagonist.path:
		if tween:
			tween.kill()
		tween = create_tween()
		antagonist.coords = antagonist.path.pop_front()
		var antagonist_sprite = level.get_node("ysorter/red")
		tween.tween_property(antagonist_sprite, "position", level.map_reference[antagonist.coords].position, 0.3)
		tween.tween_callback(move_antagonist)

func terrain_altered(coords, kind):
	if kind == 1:
		map.set_cell(0, coords, 2, Vector2i(5, 4))
	elif kind == 5:
		map.set_cell(0, coords, 2, Vector2i(3, 0))
	elif kind == 0:
		map.set_cell(0, coords, 2, Vector2i(0, 1))
	
	#region.bake_navigation_polygon()
	level.update_tile(coords, kind)
	# rebuild the pathfinding graph
	map.graph = {}
	map.build_graph(antagonist.goal)

func terrain_possessed(coords, kind):
	if kind == 0:
		level.hide_hint()
	else:
		level.show_hint()

func movement(from, to, t):
	level.move_to_(to, "blue", t)
	level.map_reference[from].modulate = Color(1.0,1.0,1.0,1.0)
	if map.get_tile_kind_at(to)==1:
		level.map_reference[to].modulate = Color(0.5,0.5,1.0,1.0)
		# it's a tree
		
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$view/SubViewport/isometric_test2.scale *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$view/SubViewport/isometric_test2.scale *= 0.9


func get_map():
	var tilemap = $map_test/map/NavigationRegion2D/TileMap
	var tiles = []
	for x in range(map.start.x, map.end.x):
		for y in range(map.start.y, map.end.y):
			var coords = Vector2i(x,y)
			var kind = tilemap.get_tile_kind_at(coords)
			tiles.append([coords, kind])
	print("tiles", tiles)
	$view/SubViewport/isometric_test2.create_map(tiles)
			
	
	
	
	
