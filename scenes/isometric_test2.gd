extends Node2D
class_name MyIsometricMap

var map_reference = {}
var tween: Tween
var tween2: Tween
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func to_local_(v: Vector2):
	var offset = Vector2(120,72)
	var offset_ = Vector2(-120,72)
	return offset * v.x + offset_ * v.y

func create_map(data):
	var reference = $ysorter/tiles0
	for datum in data:
		var coords = datum[0]
		var kind = datum[1]
		var tile = reference.duplicate()
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
		map_reference[p].set_kind(k)


func hide_hint():
	$ysorter/blue/hint.emitting = false
	$ysorter/blue/hint.hide()
	$ysorter/blue/blue.show()
	
func show_hint():
	$ysorter/blue/hint.emitting = true
	$ysorter/blue/hint.show()
	$ysorter/blue/blue.hide()
	
