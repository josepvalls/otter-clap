extends Node2D

var alive = true
var enabled = true
var tween: Tween
var coords: Vector2i= Vector2i(5,9)
var travel = 0.3
var current_possession = null
@export var tilemap: MyTileMap

signal movement(from, to, travel)
signal terrain_altered(coords, kind)
signal terrain_possessed(coords, kind)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func check_tile(direction):
	print("checking ", direction)
	if current_possession == null:
		# go to paths or trees or traps
		return tilemap.get_tile_kind_at(coords+direction) in [0,1,4,5]
	else:
		# only go to paths
		return tilemap.get_tile_kind_at(coords+direction) == 0

func _process(delta):
	if not alive or not enabled:
		return
	if tween!=null and tween.is_running():
		# we are moving, don't do anything
		pass
	else:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if abs(direction.x)<1: direction.x = 0
		if abs(direction.y)<1: direction.y = 0
		var direction_ = Vector2i(direction)
		
		if direction_!=Vector2i.ZERO:
			print("direction ",direction_, " ", coords)
			if check_tile(direction_):
				movement.emit(coords, coords+direction_, travel)
				coords += direction_
				if tween!=null:
					tween.kill()
				tween = create_tween()
				tween.tween_property(self, "global_position", tilemap.to_global(tilemap.map_to_local(coords)), travel)
				if current_possession:
					await get_tree().create_timer(travel/2).timeout
					terrain_altered.emit(coords, current_possession)
					terrain_altered.emit(coords-direction_, 0)


func _input(event):
	if tween!=null and tween.is_running():
		# we are moving
		pass
	elif event.is_action_pressed("ui_accept"):
		if current_possession==null:
			if tilemap.get_tile_kind_at(coords) in [1,5]:
				# there is a tree or a trap, let's take over it
				terrain_possessed.emit(coords, tilemap.get_tile_kind_at(coords))
				current_possession = tilemap.get_tile_kind_at(coords)
		else:
			terrain_possessed.emit(coords, 0)
			current_possession = null
