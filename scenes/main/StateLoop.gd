extends Node

@onready var gui_intro = get_node("/root/Main/GuiIntro")
@onready var intro_resources = gui_intro.get_node("Resources")
@onready var intro_actions = gui_intro.get_node("Actions")
@onready var intro_hand = gui_intro.get_node("Hand")
@onready var intro_challenge = gui_intro.get_node("Challenges")
@onready var intro_main = gui_intro.get_node("MainText")
@onready var intro_rightclick = gui_intro.get_node("HintRightClick")
@onready var resource_slots = get_node("/root/Main/Resources")
@onready var action_slots = get_node("/root/Main/Actions")
@onready var challenge_slot = get_node("/root/Main/Challenge")
@onready var hand_slots = get_node("/root/Main/Hand")
@onready var discarded_slot = get_node("/root/Main/Hand")
@onready var deck_slot = get_node("/root/Main/Deck")
@onready var offscreen_top = get_node("/root/Main/Offscreen/Top")
@onready var offscreen_left = get_node("/root/Main/Offscreen/Left")

var card_scene = preload("res://scenes/card/card.tscn")
var utils = Utils.new()

enum {SETUP, INTRO_RESOURCES, DEAL_RESOURCES, INTRO_ACTIONS, DEAL_ACTIONS, INTRO_DECK, PREPARE_DECK, DEAL_HAND, INTRO_CHALLENGE, DEAL_CHALLENGES, PLAY}
var sm:= SM.new({
    SETUP: {SM.ENTER: setup_enter},
    INTRO_RESOURCES: {SM.ENTER: intro_resources_enter},
    DEAL_RESOURCES: {SM.ENTER: deal_resources_enter, SM.PROCESS: deal_resources_process, SM.EXIT: deal_resources_exit},
    INTRO_ACTIONS: {SM.ENTER: intro_actions_enter},
    DEAL_ACTIONS: {SM.ENTER: deal_actions_enter, SM.PROCESS: deal_actions_process, SM.EXIT: deal_actions_exit},
    INTRO_DECK: {SM.ENTER: intro_deck_enter},
    PREPARE_DECK: {SM.ENTER: prepare_deck_enter, SM.PROCESS: prepare_deck_process},
    DEAL_HAND: {SM.ENTER: deal_hand_enter, SM.PROCESS: deal_hand_process, SM.EXIT: deal_hand_exit},
    INTRO_CHALLENGE: {SM.ENTER: intro_challenge_enter},
    DEAL_CHALLENGES: {SM.ENTER: deal_challenges_enter, SM.PROCESS: deal_challenges_process, SM.EXIT: deal_challenges_exit},
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
    resource_slots.visible = false
    if context == CONTEXT_INTRO:
        gui_intro.visible = true
        hide([intro_main, intro_resources, intro_actions, intro_challenge, intro_hand, intro_rightclick])
        sm.change_state(INTRO_RESOURCES)
    elif context == CONTEXT_PLAY:
        gui_intro.visible = false
        sm.change_state(DEAL_RESOURCES)


func intro_resources_enter(): 
    intro("Buy resources.", 3, DEAL_RESOURCES)
    

func deal_resources_enter(): 
    resource_slots.visible = true
    deal_resources()
    
    
func deal_resources_exit():
    fade(intro_resources, FADE_IN, 3)
    
    
func deal_resources():
    var start_delay = 0
    for card_type in ["Army1","Money1","Army2","Money2"]:
        var card_data = utils.get_cards_by_type(card_type)[0]
        for i in range(5):
            var card = spawn_card(card_data, offscreen_top, CardScene.FACE_UP)
            start_delay += 0.3
            var target_node = resource_slots.get_node(card_type)
            card.fly(offscreen_top, target_node, 0.35, start_delay, target_node.add_card.bind(card))
        start_delay += 0.15
        
        
func deal_resources_process(delta):
    if card_count(resource_slots) == 20:
        sm.change_state(INTRO_ACTIONS)
                
        
func intro_actions_enter():
    intro("Buy action cards.", 3, DEAL_ACTIONS)
    
    
func deal_actions_enter():
    var selected_actions = choose_action_set()
    var start_delay = 0
    for i in range(10):
        for j in range(5):
            var card = spawn_card(selected_actions[i], offscreen_top, CardScene.FACE_UP)
            start_delay += 0.3
            var target_node = action_slots.get_node("Action" + str(i+1))
            card.fly(offscreen_top, target_node, 0.35, start_delay, target_node.add_card.bind(card))
        start_delay += 0.15
        
        
func deal_actions_process(delta):
    if card_count(action_slots) == 50:
        sm.change_state(INTRO_DECK)
    
    
func deal_actions_exit():
    fade(intro_actions, FADE_IN, 3)
    
    
func intro_deck_enter():
    intro("Improve your deck.", 3, PREPARE_DECK)
    
    
func prepare_deck_enter():
    var money1 = utils.get_cards_by_type("Money1")[0]
    var army1 = utils.get_cards_by_type("Army1")[0]
    var players_deck = []
    for i in range(7): players_deck.append(money1)
    for i in range(3): players_deck.append(army1)
    players_deck.shuffle()
    var start_delay = 0
    for card_data in players_deck:
        var card = spawn_card(card_data, offscreen_left, CardScene.FACE_DOWN)
        card.fly(offscreen_left, deck_slot, 0.4, start_delay, deck_slot.add_card.bind(card))
        start_delay += 0.3
    
    
func prepare_deck_process(delta):
    if deck_slot.get_node("cards").get_child_count() == 10:
        sm.change_state(DEAL_HAND)
    
    
func deal_hand_enter():
    var deck = deck_slot.get_node("cards").get_children()
    deck.reverse()
    for i in range(5):
        var card = deck[i]
        var target_slot = find_slot_for_card(card, hand_slots)
        card.fly_and_flip(deck_slot, target_slot, 0.5, 0.1, target_slot.add_card.bind(card))
        await get_tree().create_timer(0.6).timeout
    
    
func deal_hand_process(delta):
    if card_count(hand_slots) == 5:
        sm.change_state(INTRO_CHALLENGE)
    
    
func deal_hand_exit():
    fade(intro_hand, FADE_IN, 3)
    
    
func intro_challenge_enter():
    intro("Overcome historical challenges.", 3, DEAL_CHALLENGES)
    
    
func deal_challenges_enter():
    var challenges = utils.get_cards_by_type("History")
    challenges.shuffle()
    challenges.append(utils.get_cards_by_type("Victory1")[0])
    challenges.append(utils.get_cards_by_type("Victory2")[0])
    challenges.append(utils.get_cards_by_type("Victory3")[0])
    challenges.reverse()
    
    var start_delay = 0
    for card_data in challenges:
        var card = spawn_card(card_data, offscreen_left, CardScene.FACE_UP)
        card.fly(offscreen_left, challenge_slot, 0.3, start_delay, challenge_slot.add_card.bind(card))
        start_delay += 0.15

    
func deal_challenges_process(delta):
    if challenge_slot.get_node("cards").get_child_count() == 22:
        sm.change_state(PLAY)
    
    
func deal_challenges_exit():
    fade(intro_challenge, FADE_IN, 3)
    fade(intro_rightclick, FADE_IN, 3)

func play_enter(): 
    if context == CONTEXT_INTRO:
        fade(gui_intro, FADE_OUT, 2)
        

# FUNCTIONS #########################
    
enum {FADE_OUT, FADE_IN}
    
    
func fade(node, fade_mode, duration, request_state = null):
    var tween = create_tween()
    node.modulate.a = 0 if fade_mode == FADE_IN else 1
    node.visible = true
    tween.tween_property(node,"modulate:a",fade_mode,duration)
    if fade_mode == FADE_OUT: 
        tween.tween_property(node, "visible", false, 0)
    if request_state:
        tween.tween_callback(sm.change_state.bind(request_state))
        
        
func intro(text, duration, request_state = null):
    var tween = create_tween()
    intro_main.bbcode_text = "[center]%s[/center]" % text
    intro_main.modulate.a = 0
    intro_main.visible = true
    intro_main.pivot_offset = intro_main.size / 2
    tween.tween_property(intro_main, "modulate:a", 1, duration).set_ease(Tween.EASE_IN)
    tween.parallel().tween_property(intro_main, "scale", Vector2(1,1), duration).from(Vector2(0,0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    if request_state:
            tween.tween_callback(sm.change_state.bind(request_state))
            
            
func sort_cards_by_cost(a, b):
    return a["cost_money"] < b["cost_money"]  # Ascending order 


func hide(nodes):
    for node in nodes:
        node.visible = false


func spawn_card(card_data, parent_node, face):
    var card = card_scene.instantiate()
    parent_node.add_child(card)
    card.set_card_data(card_data) 
    card.set_face(face)
    return card


func choose_action_set():
    var all_actions = utils.get_cards_by_type("Action")
    var selected_actions = []
    while selected_actions.size() < 10:
        var choice = randi() % all_actions.size()
        selected_actions.append(all_actions.pop_at(choice))
    selected_actions.sort_custom(sort_cards_by_cost)
    return selected_actions


func find_slot_for_card(card: CardScene, slot_group: Control) -> SlotScene:
    var found : Control = null
    var free_slots = []
    for slot: SlotScene in slot_group.get_children():
        if slot.get_node("cards").get_child_count() > 0:
            if card.card_name == slot.get_node("cards").get_children()[0].card_name:
                return slot
        else:
            free_slots.append(slot)
    return free_slots[0]


func card_count(slot_group):
    var card_count = 0
    for slot in slot_group.get_children():
        card_count += slot.get_node("cards").get_child_count()
    return card_count
