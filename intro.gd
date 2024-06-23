extends Node2D


@export var story_text = [
	"Story about the forest and the magical essence at the core of it...",
	"Story about the antagonists that come to get it...",
	"Story about the protector of the forest setting traps for the antagonists..."
]

var tween: Tween
var step = 0
var t = 2.0
var elapsed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$i1.modulate = Color(1,1,1,1)
	$i2.modulate = Color(1,1,1,0)
	$i3.modulate = Color(1,1,1,0)
	$i4.modulate = Color(1,1,1,0)
	$menu.hide()
	$menu/Button.pressed.connect(main_menu_play)
	$fadeout.hide()
	start_step()


func start_step():
	print("start_step ", step)
	if tween:
		#tween.custom_step(t)
		tween.kill()
	if step==0:
		tween = create_tween()
		tween.tween_property($i1, "modulate", Color(1,1,1,1), t/2.0)
		tween.tween_callback(start_step)
	elif step==1:
		$i1.hide()
		tween = create_tween()
		tween.tween_property($i2, "modulate", Color(1,1,1,1), t)
		tween.tween_callback(start_step)
	elif step==2:
		$i2.hide()
		$i3/Label.text = ""
		$i3/img1.show()
		tween = create_tween()
		tween.tween_property($i3, "modulate", Color(1,1,1,1), t/2.0)
		tween.tween_callback(start_step)
	elif step==3:
		tween = create_tween()
		$i3/img1.show()
		$i3/Label.text = story_text[0]
		$i3/Label.visible_ratio = 0
		tween.tween_property($i3/Label, "visible_ratio", 1.0, t*2.0)
	elif step==4:
		$i3/img1.hide()
		$i3/img2.show()
		tween = create_tween()
		$i3/Label.text = story_text[1]
		$i3/Label.visible_ratio = 0
		tween.tween_property($i3/Label, "visible_ratio", 1.0, t*2.0)
	elif step==5:
		$i3/img2.hide()
		$i3/img3.show()
		tween = create_tween()
		$i3/Label.text = story_text[2]
		$i3/Label.visible_ratio = 0
		tween.tween_property($i3/Label, "visible_ratio", 1.0, t*2.0)
	elif step==6:
		$i3.hide()
		$i4.show()
		tween = create_tween()
		tween.tween_property($i4, "modulate", Color(1,1,1,1), t)
		tween.tween_callback(start_step)
	elif step==7:
		$continue.hide()
		$menu.show()
	elif step==8:
		main_menu_play()
	step += 1
	
func main_menu_play():
	$fadeout.modulate = Color(1,1,1,0)
	$fadeout.show()
	if tween:
		tween.custom_step(t)
		tween.kill()
	tween = create_tween()
	tween.tween_property($fadeout, "modulate", Color(1,1,1,1), 0.5)
	tween.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/transfer_test.tscn")
	

func _input(event):
	if event.is_action_pressed("ui_accept"):
		start_step()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	$continue.modulate = Color(1,1,1,abs(cos(elapsed*3)))
