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

@onready var level: MyIsometricMap = $view/SubViewport/isometric_test2 as MyIsometricMap
@onready var map: MyTileMap = $map_test/map/NavigationRegion2D/TileMap as MyTileMap
var antagonist_path_failures = 0
var stolen = 0
var neutralized = 0
var default_paths_to_clear = {}
var memory = []
var antagonist_speed = 0.3
@onready var snd_environment_long = [preload("res://sound/Otterclap_SD_Environment Changing.1of3.2.wav"), preload("res://sound/Otterclap_SD_Environment Changing.2of3.2.wav"), preload("res://sound/Otterclap_SD_Environment Changing.3of3.2.wav")]
@onready var snd_environment = [preload("res://sound/Otterclap_SD_Environment Changing.1of3 (short).wav"), preload("res://sound/Otterclap_SD_Environment Changing.2of3 (short).wav"), preload("res://sound/Otterclap_SD_Environment Changing.3of3 (short).wav")]
@onready var snd_antagonist = preload("res://sound/Otterclap_SD_Hero Injured.wav")
@onready var snd_glyph = preload("res://sound/Otterclap_SD_Magic Glyph Create.4.wav")
@onready var snd_stolen = preload("res://sound/Otterclap_SD_Treasure-Core retrieved.wav")
@onready var snd: AudioStreamPlayer = $AudioStreamPlayer as AudioStreamPlayer
@onready var snd2: AudioStreamPlayer = $AudioStreamPlayer as AudioStreamPlayer
@onready var protagonist_logic: ProtagonistLogic = $map_test/protagonist as ProtagonistLogic
@onready var protagonist_body = $view/SubViewport/isometric_test2/ysorter/blue as ProtagonistBody
var stationary_time = 0.0

func _ready():
	get_map()
	$warning.hide()
	protagonist_logic.terrain_altered.connect(terrain_altered)
	protagonist_logic.terrain_possessed.connect(terrain_possessed)
	protagonist_logic.movement.connect(movement)
	level.move_to_(protagonist_logic.coords, "blue", null)
	map.build_graph(goal1)
	for exit in exits:
		for coords in map.find_path(exit, goal1)[1]:
			default_paths_to_clear[coords] = true
		default_paths_to_clear.erase(exit)
	default_paths_to_clear.erase(goal1)
	add_antagonist()
	#add_antagonist()
	#add_antagonist()
	move_antagonists()
	protagonist_body.hide_footsteps()

func add_antagonist():
	var antagonist_body = preload("res://scenes/red.tscn").instantiate()
	antagonist_body.set_kind(100)
	antagonist_body.name = "RED"+str(len(antagonists))
	level.get_node("ysorter").add_child(antagonist_body)
	antagonists.append(MyAntagonist.new(len(antagonists), map.end-Vector2i.ONE*2, Vector2i.ZERO, antagonist_body))
	protagonist_body.add_radar_target(antagonist_body)
	

func add_goal():
	if more_goals:
		var goal2 = more_goals.pop_front()
		map.set_cell(0, goal2, 2, Vector2i(1, 0))
		goals.append(goal2)
		level.update_tile(goal2, 3)

var antagonists_close_to_player: int
func move_antagonists():
	# update difficulty
	if len(antagonists) < neutralized:
		if len(antagonists)<4:
			add_antagonist()
		elif len(antagonists)+len(goals) < neutralized:
			add_goal()
			
			
	# move people
	antagonists_close_to_player = 0
	for antagonist in antagonists:
		move_antagonist(antagonist)
	
	# check if they are too close to the player
	if protagonist_logic.current_possession:
		if antagonists_close_to_player>0:
			protagonist_logic.enabled = false
			level.no_emit()
		else:
			protagonist_logic.enabled = true
			level.emit()
	else:
		protagonist_logic.enabled = true
		
		
	await get_tree().create_timer(antagonist_speed).timeout
	call_deferred("move_antagonists")

func move_antagonist_conditions(antagonist):
	# there was a double steal when rearranging the level while at the goal
	if not antagonist.moved:
		return
	var current_tile = map.get_tile_kind_at(antagonist.coords)
	if current_tile==5:
		# neutralize the antagonist
		snd2.stop()
		snd2.stream = snd_antagonist
		snd2.play()
		neutralized +=1
		$antagonists.text = "Humans neutralized: " + str(neutralized)
		if neutralized < stolen:
			$warning.text = "\n\nA human fell into a trap, they will remember it, make sure you move it somewhere else when they are not looking."
			$warning.show()
			memory.append(antagonist.coords)
			# how many traps do we keep in memory?
			if len(memory) > len(antagonists)*3:
				memory.pop_front()
			print("memory", memory)
		else:
			# delete trap
			if protagonist_logic.current_possession and protagonist_logic.coords == antagonist.coords:
				# being possessed
				protagonist_logic.current_possession = null
				protagonist_logic.enabled = true
				terrain_possessed(antagonist.coords, 0)
			else:
				# not being possessed
				terrain_altered(antagonist.coords, 0)
			$warning.text = "\n\nSometimes traps will expire, you'll need to find another one you can use."
			$warning.show()
		# TODO die animation and delay before spawning next one
		antagonist.coords = exits[randi()%exits.size()]
		antagonist.target = goals[randi()%goals.size()]
		antagonist.path = []
		pathfinding_rebuild()
	elif current_tile == 3 and antagonist.coords in goals:
		# got stolen
		snd2.stop()
		snd2.stream = snd_stolen
		snd2.play()
		stolen +=1
		$essence.text = "Stolen essence: " + str(stolen)
		if neutralized < stolen*1.25:
			# spawn/create a new trap to help the player
			var tiles_to_avoid = get_tiles_to_avoid()
			var coords = map.get_random_empty_tile(tiles_to_avoid, protagonist_logic.coords)
			if coords:
				$warning.text = "\n\nEssence was stolen, the forest will help you creating more traps for you to use."
				$warning.show()
				print("creating trap at ", coords)
				terrain_altered(coords, 5, false)
				#snd.stop()
				#snd.stream = snd_environment_long[randi()%snd_environment.size()]
				#snd.play()
			else:
				print("cannot create a new trap")
	
	if (antagonist.coords - protagonist_logic.coords).length() < 3:
		antagonists_close_to_player +=1

func get_tiles_to_avoid():
	var tiles_to_avoid = {}
	for antagonist in antagonists:
		tiles_to_avoid[antagonist.coords] = true
		for coords in antagonist.path:
			tiles_to_avoid[coords] = true
	return tiles_to_avoid

func show_paths():
	var data = []
	for antagonist in antagonists:
		data.append_array(antagonist.path)
	level.draw_footprints(data)

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
		show_paths()
		print("antagonist target", antagonist.id, antagonist.target, path_data)
		if path_data[0]==false:
			antagonist_path_failures +=1
			print("path failure ", antagonist_path_failures)
			$warning.text = "\n\nA human cannot find its way in the forest, you must open a path or neutralize it with a trap as soon as possible, otherwise, they will open their own path and destroy your forest permanently."
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
	show_paths()

func terrain_possessed(coords, kind):
	if kind == 0:
		level.hide_hint()
	else:
		snd.stop()
		snd.stream = snd_glyph
		snd.play()
		level.show_hint()

func movement(from, to, t):
	level.move_to_(to, "blue", t)
	level.map_reference[from].modulate = Color(1.0,1.0,1.0,1.0)
	if map.get_tile_kind_at(to) in [1, 5]:
		level.map_reference[to].modulate = Color(0.5,0.6,0.8,1.0)
		# it's a tree or a trap
	stationary_time = 0.0
	protagonist_body.hide_footsteps()
		
		
func _process(delta):
	stationary_time += delta
	if stationary_time > 1:
		protagonist_body.grow_footsteps(delta*10)

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
			
	
	
	
	
