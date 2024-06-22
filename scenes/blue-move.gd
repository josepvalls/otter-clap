extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	tween_around()


func tween_around():
	var tween = create_tween() as Tween
	tween.tween_property(self, "position", Vector2(1000,0), 3.0)
	tween.tween_property(self, "position", Vector2(320,440), 3.0)
	tween.set_loops()
	tween.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
