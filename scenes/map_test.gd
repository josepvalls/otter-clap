extends Node2D


var exits = [Vector2i(30,14), Vector2i(30,5), Vector2i(23,0), Vector2i(23,19)]
#var exits = [Vector2i(30,14)]#, Vector2i(30,5), Vector2i(23,-1), Vector2i(23,20)]
var goal1 = Vector2i(5,8)
var goals = [goal1]
var more_goals = [Vector2i(13,8), Vector2i(9,0)]
class MyAntagonist:
	var id: int
	var coords: Vector2i
	var target: Vector2i
	var sprite: Node2D
	var path: Array
	var tween: Tween
	var moved: bool
	func _init(id_, coords_, target_, sprite_):
		id = id_
		coords = coords_
		target = target_
		sprite = sprite_
		path = []
		tween = null
		moved = false
		

var antagonists = []

@onready var level: MyIsometricMap = $view/SubViewport/isometric_test2
@onready var map: MyTileMap = $map_test/map/NavigationRegion2D/TileMap
@onready var region: NavigationRegion2D = $map_test/map/NavigationRegion2D
var antagonist_path_failures = 0
var stolen = 0
var neutralized = 0
var default_paths_to_clear = {}
var memory = []
var antagonist_speed = 0.1
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
	map.build_graph(goal1)
	for exit in exits:
		for coords in map.find_path(exit, goal1)[1]:
			default_paths_to_clear[coords] = true
		default_paths_to_clear.erase(exit)
	default_paths_to_clear.erase(goal1)
	add_antagonist()
	move_antagonists()

func add_antagonist():
	var antagonist_body = preload("res://scenes/red.tscn").instantiate()
	level.get_node("ysorter").add_child(antagonist_body)
	antagonists.append(MyAntagonist.new(1, map.end-Vector2i.ONE*2, Vector2i.ZERO, antagonist_body))
	var protagonist_body = $view/SubViewport/isometric_test2/ysorter/blue as ProtagonistBody
	protagonist_body.add_radar_target(antagonist_body)

func add_goal():
	if more_goals:
		var goal2 = more_goals.pop_front()
		map.set_cell(0, goal2, 2, Vector2i(1, 0))
		goals.append(goal2)
		level.update_tile(goal2, 3)

func move_antagonists():
	if len(antagonists) < neutralized:
		if len(antagonists)<4:
			add_antagonist()
		elif len(antagonists)+len(goals) < neutralized:
			add_goal()
			
	for antagonist in antagonists:
		move_antagonist(antagonist)
	await get_tree().create_timer(antagonist_speed).timeout
	call_deferred("move_antagonists")

func move_antagonist_conditions(antagonist):
	# there was a double steal when rearranging the level while at the goal
	if not antagonist.moved:
		return
	var current_tile = map.get_tile_kind_at(antagonist.coords)
	if current_tile==5:
		# neutralize the antagonist
		snd.stop()
		snd.stream = snd_antagonist
		snd.play()
		neutralized +=1
		$antagonists.text = "Antagonists neutralized: " + str(neutralized)
		if neutralized < stolen:
			$warning.text = "\n\nWarning, an antagonist fell into a trap, they will remember it, make sure you move it somewhere else when they are not looking."
			$warning.show()
			memory.append(antagonist.coords)
			# how many traps do we keep in memory?
			if len(memory) > len(antagonists)*3:
				memory.pop_front()
			print("memory", memory)
		else:
			# delete trap
			terrain_altered(antagonist.coords, 0)
			$warning.text = "\n\nWarning, sometimes traps will expire, you'll need to find another one you can use."
			$warning.show()


		# TODO die animation and delay before spawning next one
		antagonist.coords = exits[randi()%exits.size()]
		antagonist.target = goals[randi()%goals.size()]
		antagonist.path = []
		pathfinding_rebuild()
	elif current_tile == 3 and antagonist.coords in goals:
		# got stolen
		snd.stop()
		snd.stream = snd_stolen
		snd.play()
		stolen +=1
		$essence.text = "Stolen essence: " + str(stolen)
		if neutralized < stolen*1.25:
			# create a new trap to help the player
			var coords = map.get_random_empty_tile()
			print("creating trap at ", coords)
			terrain_altered(coords, 5, false)


func move_antagonist(antagonist: MyAntagonist):
	move_antagonist_conditions(antagonist)
	antagonist.moved = false
	# where is the antagonist?		
	if not antagonist.path:
		if not antagonist.coords in goals:
			antagonist.target = goals[randi()%goals.size()]
		else:
			antagonist.target = exits[randi()%exits.size()]
		var path_data = map.find_path(antagonist.coords, antagonist.target, memory)
		antagonist.path = path_data[1]
		print("antagonist target", antagonist.id, antagonist.target, path_data)
		if path_data[0]==false:
			antagonist_path_failures +=1
			print("path failure ", antagonist_path_failures)
			$warning.text = "\n\nWarning, an antagonist cannot find its way in the forest, you must open a path or neutralize it with a trap as soon as possible, otherwise, they will open their own path and destroy your forest permanently."
			$warning.show()
			if antagonist_path_failures >= 4:
				reset_paths()
					
	if antagonist.path:
		antagonist.moved = true
		if antagonist.tween:
			antagonist.tween.kill()
		antagonist.tween = create_tween()
		antagonist.coords = antagonist.path.pop_front()
		antagonist.tween.tween_property(antagonist.sprite, "position", level.map_reference[antagonist.coords].position, antagonist_speed)

func reset_paths():
	antagonist_path_failures = 0
	for coords in default_paths_to_clear:
		memory.erase(coords)
		map.set_cell(0, coords, 2, Vector2i(0, 1))
		level.update_tile(coords, 0)
	pathfinding_rebuild()

func terrain_altered(coords, kind, recompute = true):
	if kind!=0:
		snd.stream = snd_environment[randi()%snd_environment.size()]
		snd.play()
	if kind == 1:
		# tree
		map.set_cell(0, coords, 2, Vector2i(5, 4))
	elif kind == 5:
		# trap
		map.set_cell(0, coords, 2, Vector2i(3, 0))
	elif kind == 0:
		# empty
		map.set_cell(0, coords, 2, Vector2i(0, 1))
	
	level.update_tile(coords, kind)
	if recompute:
		pathfinding_rebuild()

func pathfinding_rebuild():
	# rebuild the pathfinding graph and recompute antagonist path when needed
	map.graph = {}
	map.build_graph(goal1)
	for antagonist in antagonists:
		var path_data = map.find_path(antagonist.coords, antagonist.target, memory)
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
	if map.get_tile_kind_at(to) in [1, 5]:
		level.map_reference[to].modulate = Color(0.5,0.5,1.0,1.0)
		# it's a tree or a trap
		
	
	

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
			
	
	
	
	
