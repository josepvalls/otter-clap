extends Node2D

var map_reference = {}

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
		if coords == Vector2i.ZERO:
			continue
		var tile = reference.duplicate()
		tile.position = to_local_(coords)
		tile.set_kind(kind)
		$ysorter.add_child(tile)
		map_reference[coords] = tile
		
func move_to_(p, who):
	$ysorter.get_node(who).position = to_local_(p)

func update_tile(p, k):
	if p in map_reference:
		map_reference[p].set_kind(k)
