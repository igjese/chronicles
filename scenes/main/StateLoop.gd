extends Node

@onready var gui_intro = get_node("/root/Main/GuiIntro")

enum {SETUP, INTRO_BUY_RESOURCES, DEAL_RESOURCES, PLAY}
var sm:= SM.new({
    SETUP: {SM.ENTER: setup_enter},
    INTRO_BUY_RESOURCES: {SM.ENTER: intro_buy_resources_enter},
    DEAL_RESOURCES: {SM.ENTER: deal_resources_enter},
    PLAY: {SM.ENTER: play_enter}
})


func start_game_loop():
    sm.change_state(SETUP)


func _process(delta):
    sm.process(delta)
    
    
func setup_enter():
    gui_intro.visible = true
    gui_intro.get_node("MainText").visible = false
    gui_intro.get_node("Resources").visible = false
    sm.change_state(INTRO_BUY_RESOURCES)


func intro_buy_resources_enter(): 
    var intro_text = gui_intro.get_node("MainText")
    fade(intro_text, FADE_IN, 3, DEAL_RESOURCES)
    

func deal_resources_enter(): 
    var resource_text = gui_intro.get_node("Resources")
    fade(resource_text, FADE_IN, 3, PLAY)


func play_enter(): 
    fade(gui_intro, FADE_OUT, 3)
    
    
enum {FADE_OUT, FADE_IN}
    
func fade(node, fade_mode, delay, request_state = null):
    var tween = create_tween()
    node.modulate.a = 0 if fade_mode == FADE_IN else 1
    node.visible = true
    tween.tween_property(node,"modulate:a",fade_mode,delay)
    if fade_mode == FADE_OUT: 
        tween.tween_property(node, "visible", false, 0)
    if request_state:
        tween.tween_callback(sm.change_state.bind(request_state))
