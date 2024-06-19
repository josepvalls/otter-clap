extends Sprite2D

var shadow_position = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shadow_position.y += delta * 0.5
	material.set_shader_parameter("tr", shadow_position)
