extends Area2D


func _ready():
	body_entered.connect(escape)
	area_entered.connect(escape)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func escape(area_or_body):
	if randf() < 0.5:
		$"../antagonist/NavigationAgent2D".target_position = $"../exit1".global_position
	else:
		$"../antagonist/NavigationAgent2D".target_position = $"../exit2".global_position
