extends Node2D
class_name MyIsometricMap

var map_reference = {}
var tween: Tween
var tween2: Tween

@export var tiles: Array[PackedScene]
@export var footprint: PackedScene
var footprints = []
@onready var footprint_container: Node2D = $footprints
func _ready():
	add_footprints(32)
	
func add_footprints(num):
	for i in num:
		var f = footprint.instantiate() as Sprite2D
		footprint_container.add_child(f)
		f.rotate(PI * randf() * 2)
		footprints.append(f)


func draw_footprints(data):
	if len(data) > len(footprints):
		add_footprints(len(data) - len(footprints))
	for i in footprints:
		i.hide()
	for idx in len(data):
		footprints[idx].position = to_local_(data[idx])
		footprints[idx].show()


func to_local_(v: Vector2):
	var offset = Vector2(120,72)
	var offset_ = Vector2(-120,72)
	return offset * v.x + offset_ * v.y

func create_map(data):
	for datum in data:
		var coords = datum[0]
		var kind = datum[1]
		var tile = tiles[kind].instantiate()
		tile.position = to_local_(coords)
		tile.set_kind(kind)
		$ysorter.add_child(tile)
		map_reference[coords] = tile
		
func move_to_(p, who, t):
	if t:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property($ysorter.get_node(who), "position",map_reference[p].position+Vector2(0.0,10.0), t)
		tween.play()
	else:
		$ysorter.get_node(who).position = map_reference[p].position+Vector2(0.0,10.0)

func movement_path(path, who, t):
	var node: Node2D = $ysorter.get_node(who)
	if tween2:
		tween2.kill()
	tween2 = create_tween()
	for p_idx in path.size()-1:
		var p = path[p_idx+1]
		tween2.tween_property(node, "position", map_reference[p].position+Vector2(0.0,10.0), t)


func update_tile(p, k):
	if p in map_reference:
		var tile = tiles[k].instantiate()
		tile.set_kind(k)
		$ysorter.add_child(tile)
		tile.position = map_reference[p].position
		map_reference[p].queue_free()
		map_reference[p] = tile

var blue_tween: Tween

func hide_hint():
	if blue_tween:
		blue_tween.kill()
	blue_tween = create_tween()
	blue_tween.tween_property($ysorter/blue, "scale", Vector2.ONE, 0.3)
	blue_tween.play()
	no_emit()
	#$ysorter/blue/hint.hide()
	#$ysorter/blue/blue.show()
	
func show_hint():
	if blue_tween:
		blue_tween.kill()
	blue_tween = create_tween()
	blue_tween.tween_property($ysorter/blue, "scale", Vector2(0.01, 0.01), 0.3)
	blue_tween.play()
	emit()
	#$ysorter/blue/hint.show()
	#$ysorter/blue/blue.hide()
	
func no_emit():
	$ysorter/hint.emitting = false
	
func emit():
	$ysorter/hint.emitting = true
	
	
