extends Area2D


func _ready():
	body_entered.connect(escape)
	area_entered.connect(escape)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func escape(area_or_body):
	$"../antagonist/NavigationAgent2D".target_position = $"../exit2".global_position
