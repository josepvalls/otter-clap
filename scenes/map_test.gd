extends Node2D



@onready var level: MyIsometricMap = $view/SubViewport/isometric_test2
@onready var map: MyTileMap = $map_test/map/NavigationRegion2D/TileMap
@onready var region: NavigationRegion2D = $map_test/map/NavigationRegion2D
@onready var antagonist: Antagonist = $map_test/antagonist
var antagonist_path_failures = 0
var tween: Tween
var stolen = 0
var neutralized = 0
var default_paths_to_clear = []
var memory = []
var warning_kind = -1
var antagonist_speed = 0.3
#@onready var snd_environment = [preload("res://sound/Otterclap_SD_Environment Changing.1of3.2.wav"), preload("res://sound/Otterclap_SD_Environment Changing.2of3.2.wav"), preload("res://sound/Otterclap_SD_Environment Changing.3of3.2.wav")]
@onready var snd_environment = [preload("res://sound/Otterclap_SD_Environment Changing.1of3 (short).wav"), preload("res://sound/Otterclap_SD_Environment Changing.2of3 (short).wav"), preload("res://sound/Otterclap_SD_Environment Changing.3of3 (short).wav")]
@onready var snd_antagonist = preload("res://sound/Otterclap_SD_Hero Injured.wav")
@onready var snd_glyph = preload("res://sound/Otterclap_SD_Magic Glyph Create.4.wav")
@onready var snd_stolen = preload("res://sound/Otterclap_SD_Treasure-Core retrieved.wav")
@onready var snd: AudioStreamPlayer = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	get_map()
	$warning.hide()
	$map_test/protagonist.terrain_altered.connect(terrain_altered)
	$map_test/protagonist.terrain_possessed.connect(terrain_possessed)
	$map_test/protagonist.movement.connect(movement)
	level.move_to_($map_test/protagonist.coords, "blue", null)
	map.build_graph(antagonist.goal)
	move_antagonist()
	default_paths_to_clear += map.find_path(antagonist.coords, antagonist.exits[0])[1]
	#default_paths_to_clear += map.find_path(antagonist.coords, antagonist.exits[1])[1]
	
func move_antagonist():
	# where is the antagonist?
	var current_tile = map.get_tile_kind_at(antagonist.coords)
	#print(antagonist.coords, antagonist.goal, current_tile)
	if current_tile==5:
		# disable the antagonist
		snd.stop()
		snd.stream = snd_antagonist
		snd.play()
		neutralized +=1
		$antagonists.text = "Antagonists neutralized: " + str(neutralized)
		$warning.text = "\n\nWarning, an antagonist fell into a trap, they will remember it, make sure you move it somewhere else when they are not looking."
		$warning.show()
		warning_kind = 2
		memory.append(antagonist.coords)
		# how many traps do we keep in memory?
		if len(memory) > 8:
			memory.pop_front()

		# TODO die animation and delay before spawning next one
		var spanw_location = antagonist.exits[randi()%antagonist.exits.size()]
		antagonist.coords = spanw_location
		antagonist.path = []
	elif current_tile == 3 and antagonist.coords == antagonist.goal:
		$warning.hide()
		# got stolen
		snd.stop()
		snd.stream = snd_stolen
		snd.play()
		stolen +=1
		$essence.text = "Stolen essence: " + str(stolen)
		
	if not antagonist.path:
		if antagonist.coords != antagonist.goal:
			antagonist.target = antagonist.goal
		else:
			antagonist.target = antagonist.exits[randi()%antagonist.exits.size()]
		var path_data = map.find_path(antagonist.coords, antagonist.target, memory)
		antagonist.path = path_data[1]
		print("antagonist target", antagonist.target, path_data)
		if path_data[0]==false:
			antagonist_path_failures +=1
			print("path failure ", antagonist_path_failures)
			$warning.text = "\n\nWarning, an antagonist cannot find its way in the forest, you must open a path or neutralize it with a trap as soon as possible, otherwise, they will open their own path and destroy your forest permanently."
			$warning.show()
			warning_kind = 1
			if antagonist_path_failures >= 3:
				reset_paths()
		else:
			if warning_kind==1:
				$warning.hide()
					
	if antagonist.path:
		if tween:
			tween.kill()
		tween = create_tween()
		antagonist.coords = antagonist.path.pop_front()
		var antagonist_sprite = level.get_node("ysorter/red")
		tween.tween_property(antagonist_sprite, "position", level.map_reference[antagonist.coords].position, antagonist_speed)
		tween.tween_callback(move_antagonist)

func reset_paths():
	$warning.hide()
	antagonist_path_failures = 0
	for coords in default_paths_to_clear:
		map.set_cell(0, coords, 2, Vector2i(0, 1))
		level.update_tile(coords, 0)
	map.graph = {}
	map.build_graph(antagonist.goal)

func terrain_altered(coords, kind):
	if kind!=0:
		snd.stream = snd_environment[randi()%snd_environment.size()]
		snd.play()
	if kind == 1:
		map.set_cell(0, coords, 2, Vector2i(5, 4))
	elif kind == 5:
		map.set_cell(0, coords, 2, Vector2i(3, 0))
	elif kind == 0:
		map.set_cell(0, coords, 2, Vector2i(0, 1))
	
	level.update_tile(coords, kind)
	# rebuild the pathfinding graph and recompute antagonist path when needed
	map.graph = {}
	map.build_graph(antagonist.goal)
	var path_data = map.find_path(antagonist.coords, antagonist.target)
	antagonist.path = path_data[1]

var is_possessed = false
func terrain_possessed(coords, kind):
	if kind == 0:
		level.hide_hint()
		is_possessed = false
	else:
		is_possessed = true
		snd.stop()
		snd.stream = snd_glyph
		snd.play()
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
			var scaled = clamp($view/SubViewport/isometric_test2.scale.x*1.1, 0.4, 1.0)
			$view/SubViewport/isometric_test2.scale = Vector2(scaled, scaled)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var scaled = clamp($view/SubViewport/isometric_test2.scale.x*0.9, 0.4, 1.0)
			$view/SubViewport/isometric_test2.scale = Vector2(scaled, scaled)


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
			
	
	
	
	
