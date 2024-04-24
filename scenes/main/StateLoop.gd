extends Node

@onready var gui_intro = get_node("/root/Main/GuiIntro")
@onready var intro_resources = gui_intro.get_node("Resources")
@onready var intro_main = gui_intro.get_node("MainText")
@onready var resources = get_node("/root/Main/Resources")

var utils = Utils.new()

enum {SETUP, INTRO_BUY_RESOURCES, DEAL_RESOURCES, PLAY}
var sm:= SM.new({
    SETUP: {SM.ENTER: setup_enter},
    INTRO_BUY_RESOURCES: {SM.ENTER: intro_buy_resources_enter},
    DEAL_RESOURCES: {SM.ENTER: deal_resources_enter},
    PLAY: {SM.ENTER: play_enter}
})

enum {CONTEXT_INTRO, CONTEXT_PLAY}

var context = CONTEXT_PLAY

func start_game_loop(requested_context = CONTEXT_PLAY):
    context = requested_context
    sm.change_state(SETUP)


func _process(delta):
    sm.process(delta)
    
    
func setup_enter():
    resources.visible = false
    if context == CONTEXT_INTRO:
        gui_intro.visible = true
        intro_main.visible = false
        intro_resources.visible = false
        sm.change_state(INTRO_BUY_RESOURCES)
    elif context == CONTEXT_PLAY:
        gui_intro.visible = false
        sm.change_state(DEAL_RESOURCES)


func intro_buy_resources_enter(): 
    var intro_text = gui_intro.get_node("MainText")
    fade(intro_text, FADE_IN, 3, DEAL_RESOURCES)
    

func deal_resources_enter(): 
    resources.visible = true
    deal_resources()
    fade(intro_resources, FADE_IN, 3, PLAY)
    
    
func deal_resources():
    var card_scene = preload("res://scenes/card/card.tscn")
    var start_node = get_node("/root/Main/Offscreen/Top")
    var resources_node = get_node("/root/Main/Resources")
    var duration = 0.35
    var start_delay = 0
    for card_type in ["Army1","Money1","Army2","Money2"]:
        var card_data = utils.get_cards_by_type(card_type)[0]
        for i in range(5):
            var card = card_scene.instantiate()
            start_node.add_child(card)
            card.set_card_data(card_data) 
            start_delay += 0.3
            var target_node = resources_node.get_node(card_type)
            card.fly(start_node, target_node, duration, start_delay, target_node.add_card.bind(card))


func play_enter(): 
    if context == CONTEXT_INTRO:
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
