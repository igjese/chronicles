extends State

@onready var gui_intro = get_node("/root/Main/GuiIntro")
@onready var gui_play = get_node("/root/Main/GuiPlay")
@onready var StateMachine = get_node("/root/Main/StateMachine")
@onready var play_state = get_node("/root/Main/StateMachine/PlayState")

enum fade {OUT,IN}

func enter():
    print("intro")
    gui_intro.visible = true
    
    await fade_in_out(gui_intro.get_node("MainText"),fade.IN,3)
    
    StateMachine.change_state(play_state)

func exit():
    await fade_in_out(gui_intro,fade.OUT,2)
    gui_intro.visible = false
    
func fade_in_out(node,in_or_out, delay):
    var tween = create_tween()
    node.modulate.a = 0 if in_or_out == 1 else 1
    await tween.tween_property(node,"modulate:a",in_or_out,delay).finished
