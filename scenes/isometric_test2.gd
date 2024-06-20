extends Node2D


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
		if datum == Vector2i.ZERO:
			continue
		var tile = reference.duplicate()
		tile.position = to_local_(datum)
		$ysorter.add_child(tile)
		
func move_to_(p):
	$ysorter/blue.position = to_local_(p)
