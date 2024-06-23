extends Node2D
class_name Antagonist

var exits = [Vector2i(30,14), Vector2i(30,5), Vector2i(23,-1), Vector2i(23,20)]
#var exits = [Vector2i(30,14)]#, Vector2i(30,5), Vector2i(23,-1), Vector2i(23,20)]
@export var coords = Vector2i(30,14)
var goal = Vector2i(5,8)
var target = Vector2i.ZERO
@export var map: MyTileMap
@onready var navigation_agent: NavigationAgent2D
var path: Array = []
func _ready():
	pass
	#navigation_agent = $NavigationAgent2D
	#navigation_agent.target_position = target.global_position
	#print(navigation_agent.target_position, global_position, navigation_agent.get_next_path_position())

func _process(delta):
	pass
	#var direction = navigation_agent.get_next_path_position() - global_position
	#direction = direction.normalized()
	#velocity = velocity.lerp(direction * speed, acceleration * delta)
	#velocity = direction * speed
	#move_and_slide()
