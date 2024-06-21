extends CharacterBody2D

@export var target: Node2D
var speed = 100
var acceleration = 300

@onready var navigation_agent: NavigationAgent2D

func _ready():
	navigation_agent = $NavigationAgent2D
	navigation_agent.target_position = target.global_position
	#print(navigation_agent.target_position, global_position, navigation_agent.get_next_path_position())

func _process(delta):
	#var direction = Vector2.ZERO
	var direction = navigation_agent.get_next_path_position() - global_position
	
	#print(direction, velocity)
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	velocity = direction * speed
	
	
	move_and_slide()
