extends Node2D

var lstNodeClicked = 0
var arrNodeClicked = []
var posButton = [Vector2(0, 0), Vector2(84, 15.5), Vector2(258, 15.5), Vector2(335, 170.5), Vector2(176, 296.5), Vector2(9, 170.5)]
var arrLine = []
var arrMagic = [[[1, 2, 3, 4, 5, 1], 1], [[1, 3, 5, 2, 4, 1], 2], [[1, 5, 2, 3, 1, 4, 2], 3]]
var magicName = ["", "Create", "Teleport", "Destroy"]
@onready var protagonist = get_node("../map_test/protagonist")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _draw():
	var white = Color.WHITE
	for arr in arrLine:
		draw_line(arr[0], arr[1], white, 6.0)


func on_button_pressed(id):
	if lstNodeClicked == id: return
	arrNodeClicked.append(id)
	print(arrNodeClicked)
	if lstNodeClicked != 0:
		arrLine.append([posButton[lstNodeClicked], posButton[id]])
		queue_redraw()
	lstNodeClicked = id


func _on_button_1_pressed():
	on_button_pressed(1)


func _on_button_2_pressed():
	on_button_pressed(2)


func _on_button_3_pressed():
	on_button_pressed(3)


func _on_button_4_pressed():
	on_button_pressed(4)


func _on_button_5_pressed():
	on_button_pressed(5)

func checkMagic():
	for magic in arrMagic:
		if magic[0] == arrNodeClicked:
			return magic[1]
	return -1


func _on_create_pressed():
	var type = checkMagic()
	arrLine = []
	arrNodeClicked = [1]
	queue_redraw()
	print(protagonist)
	protagonist.doMagic(type)
