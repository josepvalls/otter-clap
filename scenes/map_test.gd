extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	tween_around()


func tween_around():
	var tween = create_tween() as Tween
	tween.tween_property($antagonist, "position", $treasure.position, 1.0)
	tween.tween_property($antagonist, "position", $exit2.position, 1.0)
	tween.set_loops()
	tween.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
