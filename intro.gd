extends Node2D


var story_text = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sed risus ultricies tristique nulla. Maecenas pharetra convallis posuere morbi leo urna molestie at elementum. Aliquet porttitor lacus luctus accumsan tortor posuere ac ut consequat. Tortor dignissim convallis aenean et tortor at risus viverra adipiscing. Eget felis eget nunc lobortis mattis.",
	"Diam volutpat commodo sed egestas egestas fringilla. Semper viverra nam libero justo laoreet sit amet. Faucibus purus in massa tempor nec. Lacus viverra vitae congue eu consequat ac felis donec et. Dui faucibus in ornare quam viverra orci sagittis eu volutpat. Suspendisse faucibus interdum posuere lorem ipsum dolor. Faucibus pulvinar elementum integer enim neque volutpat ac tincidunt vitae. Dictumst quisque sagittis purus sit amet. Netus et malesuada fames ac turpis egestas maecenas pharetra. Egestas egestas fringilla phasellus faucibus scelerisque eleifend donec. Mi eget mauris pharetra et ultrices. Consectetur a erat nam at.",
	"Some more story..."
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
		tween = create_tween()
		tween.tween_property($i2, "modulate", Color(1,1,1,1), t)
		tween.tween_callback(start_step)
	elif step==2:
		$i3/Label.text = ""
		tween = create_tween()
		tween.tween_property($i3, "modulate", Color(1,1,1,1), t/2.0)
		tween.tween_callback(start_step)
	elif step==3:
		tween = create_tween()
		$i3/Label.text = story_text[0]
		$i3/Label.visible_ratio = 0
		tween.tween_property($i3/Label, "visible_ratio", 1.0, t*2.0)
	elif step==4:
		tween = create_tween()
		$i3/Label.text = story_text[1]
		$i3/Label.visible_ratio = 0
		tween.tween_property($i3/Label, "visible_ratio", 1.0, t*2.0)
	elif step==5:
		tween = create_tween()
		$i3/Label.text = story_text[2]
		$i3/Label.visible_ratio = 0
		tween.tween_property($i3/Label, "visible_ratio", 1.0, t*2.0)
	elif step==6:
		tween = create_tween()
		tween.tween_property($i4, "modulate", Color(1,1,1,1), t)
		tween.tween_callback(start_step)
	elif step==7:
		$continue.hide()
		$menu.show()
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
	$continue.modulate = Color(1,1,1,abs(cos(elapsed*6)))
