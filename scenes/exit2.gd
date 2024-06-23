extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(fetch_treasure)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func fetch_treasure(area_or_body):
	$"../antagonist/NavigationAgent2D".target_position = $"../tresure".global_position
