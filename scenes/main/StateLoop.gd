extends Node

@onready var gui_intro = get_node("/root/Main/GuiIntro")
@onready var gui_play = get_node("/root/Main/GuiPlay")
@onready var intro_resources = gui_intro.get_node("Resources")
@onready var intro_actions = gui_intro.get_node("Actions")
@onready var intro_hand = gui_intro.get_node("Hand")
@onready var intro_challenge = gui_intro.get_node("Challenges")
@onready var intro_main = gui_intro.get_node("MainText")
@onready var intro_rightclick = gui_intro.get_node("HintRightClick")
@onready var intro_startgame = gui_intro.get_node("BtnStartGame")
@onready var resource_slots = get_node("/root/Main/Resources")
@onready var action_slots = get_node("/root/Main/Actions")
@onready var table_slots = get_node("/root/Main/Table")
@onready var challenge_slot = get_node("/root/Main/Challenge")
@onready var hand_slots = get_node("/root/Main/Hand")
@onready var discarded_slot = get_node("/root/Main/Discarded")
@onready var trash_slot = get_node("/root/Main/Trash")
@onready var deck_slot = get_node("/root/Main/Deck")
@onready var offscreen_top = get_node("/root/Main/Offscreen/Top")
@onready var offscreen_left = get_node("/root/Main/Offscreen/Left")
@onready var sounds = get_node("/root/Main/Sounds")
@onready var gui_hint = gui_play.get_node("Hint")


var helpers = Helpers.new()

enum {SETUP, INTRO_RESOURCES, DEAL_RESOURCES, INTRO_ACTIONS, DEAL_ACTIONS, INTRO_DECK, PREPARE_DECK, DEAL_HAND, INTRO_CHALLENGE,
     DEAL_CHALLENGES, FLIP_CHALLENGE, INTRO_STARTGAME, START_PLAY, ACTIVATE_CHALLENGE, ACTIVATE_CARD, APPLY_EFFECT, DISCARD, PLAY_ACTION,
    PLAY_RESOURCES, BUY_CARDS, CLEANUP, TRASH}
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
    DEAL_CHALLENGES: {SM.ENTER: deal_challenges_enter, SM.PROCESS: deal_challenges_process},
    FLIP_CHALLENGE: {SM.ENTER: flip_challenge_enter, SM.EXIT: flip_challenge_exit},
    INTRO_STARTGAME: {SM.ENTER: intro_startgame_enter, SM.EXIT: intro_startgame_exit, SM.INPUT: intro_startgame_input},
    START_PLAY: {SM.ENTER: start_play_enter},
    ACTIVATE_CHALLENGE: {SM.ENTER: activate_challenge_enter},
    ACTIVATE_CARD: {SM.ENTER: activate_card_enter},
    APPLY_EFFECT: {SM.ENTER: apply_effect_enter},
    DISCARD: {SM.ENTER: discard_enter, SM.INPUT: discard_input, SM.EXIT: discard_exit},
    PLAY_ACTION: {SM.ENTER: play_action_enter, SM.INPUT: play_action_input, SM.EXIT: play_action_exit},
    PLAY_RESOURCES: {SM.ENTER: play_resources_enter, SM.INPUT: play_resources_input},
    BUY_CARDS: {SM.ENTER: buy_cards_enter, SM.INPUT: buy_cards_input, SM.EXIT: buy_cards_exit},
    CLEANUP: {SM.ENTER: cleanup_enter},
    TRASH: {SM.ENTER: trash_enter, SM.INPUT: trash_input, SM.EXIT: trash_exit}
})


func _ready():
    Game.sm = sm
    Game.connect_gui(get_node("/root/Main"))
    helpers.connect_gui(get_node("/root/Main"))


enum {CONTEXT_INTRO, CONTEXT_PLAY}

var context = CONTEXT_PLAY

func start_game_loop(requested_context = CONTEXT_PLAY):
    context = requested_context
    sm.change_state(SETUP)


func _process(delta):
    sm.process(delta)
    
    
func setup_enter():
    gui_play.z_index = 0
    resource_slots.visible = false
    if context == CONTEXT_INTRO:
        gui_intro.visible = true
        helpers.hide([intro_main, intro_resources, intro_actions, intro_challenge, intro_hand, intro_rightclick, intro_startgame, table_slots])
        sm.change_state(INTRO_RESOURCES)
    elif context == CONTEXT_PLAY:
        gui_intro.visible = false
        sm.change_state(DEAL_RESOURCES)


func intro_resources_enter(): 
    helpers.intro("Buy resources.", 3, DEAL_RESOURCES)
    

func deal_resources_enter(): 
    resource_slots.visible = true
    deal_resources()
    
    
func deal_resources_exit():
    helpers.fade(intro_resources, helpers.FADE_IN, 3)
    
    
func deal_resources():
    var start_delay = 0
    for card_type in ["Army1","Money1","Army2","Money2"]:
        var card_data = helpers.get_cards_by_type(card_type)[0]
        for i in range(5):
            var card = helpers.spawn_card(card_data, offscreen_top, CardScene.FACE_UP)
            start_delay += 0.3
            var target_node = resource_slots.get_node(card_type)
            card.fly(offscreen_top, target_node, 0.35, start_delay, target_node.add_card.bind(card), CardScene.SOUND_DEAL)
        start_delay += 0.15
        
        
func deal_resources_process(_delta):
    if helpers.count_cards(resource_slots) == 20:
        sm.change_state(INTRO_ACTIONS)
                
        
func intro_actions_enter():
    helpers.intro("Buy action cards.", 3, DEAL_ACTIONS)
    
    
func deal_actions_enter():
    var selected_actions = helpers.choose_action_set()
    var start_delay = 0
    for i in range(10):
        for j in range(5):
            var card = helpers.spawn_card(selected_actions[i], offscreen_top, CardScene.FACE_UP)
            start_delay += 0.3
            var target_node = action_slots.get_node("Action" + str(i+1))
            card.fly(offscreen_top, target_node, 0.35, start_delay, target_node.add_card.bind(card), CardScene.SOUND_DEAL)
        start_delay += 0.15
        
        
func deal_actions_process(_delta):
    if helpers.count_cards(action_slots) == 50:
        sm.change_state(INTRO_DECK)
    
    
func deal_actions_exit():
    helpers.fade(intro_actions, helpers.FADE_IN, 3)
    
    
func intro_deck_enter():
    helpers.intro("Improve your deck.", 3, PREPARE_DECK)
    
    
func prepare_deck_enter():
    var money1 = helpers.get_cards_by_type("Money1")[0]
    var army1 = helpers.get_cards_by_type("Army1")[0]
    var players_deck = []
    for i in range(7): players_deck.append(money1)
    for i in range(3): players_deck.append(army1)
    players_deck.shuffle()
    var start_delay = 0
    for card_data in players_deck:
        var card = helpers.spawn_card(card_data, offscreen_left, CardScene.FACE_DOWN)
        card.fly(offscreen_left, deck_slot, 0.35, start_delay, deck_slot.add_card.bind(card), CardScene.SOUND_DEAL)
        start_delay += 0.25 + randf_range(-0.05, 0.05)
    
    
func prepare_deck_process(_delta):
    if deck_slot.get_node("cards").get_child_count() == 10:
        sm.change_state(DEAL_HAND)
    
    
func deal_hand_enter():
    await get_tree().create_timer(0.2).timeout
    var deck = deck_slot.get_node("cards").get_children()
    deck.reverse()
    for i in range(5):
        var card = deck[i]
        var target_slot = helpers.find_slot_for_card(card, hand_slots)
        card.fly_and_flip(deck_slot, target_slot, 0.4, 0.1, target_slot.add_card.bind(card), CardScene.SOUND_DRAW)
        await get_tree().create_timer(0.6).timeout
    
    
func deal_hand_process(_delta):
    if helpers.count_cards(hand_slots) == 5:
        sm.change_state(INTRO_CHALLENGE)
    
    
func deal_hand_exit():
    helpers.fade(intro_hand, helpers.FADE_IN, 3)
    
    
func intro_challenge_enter():
    helpers.intro("Overcome historical challenges.", 3, DEAL_CHALLENGES)
    
    
func deal_challenges_enter():
    var challenges = helpers.prepare_challenges()
    var start_delay = 0
    for card_data in challenges:
        var card = helpers.spawn_card(card_data, offscreen_left, CardScene.FACE_DOWN)
        card.fly(offscreen_left, challenge_slot, 0.35, start_delay, challenge_slot.add_card.bind(card), CardScene.SOUND_DEAL)
        start_delay += 0.12

    
func deal_challenges_process(_delta):
    if challenge_slot.get_node("cards").get_child_count() == 22:
        sm.change_state(FLIP_CHALLENGE)
        
        
func flip_challenge_enter():
    challenge_slot.top_card().flip_card(0.6, 0.2)
    challenge_slot.pulse_qty_for_flip(0.6,0.2)
    await get_tree().create_timer(0.6).timeout
    challenge_slot.start_glow(Color.RED)
    sm.change_state(INTRO_STARTGAME)
    
    
func flip_challenge_exit():
    intro_main.visible = false
    helpers.fade(intro_challenge, helpers.FADE_IN, 3)
    helpers.fade(intro_rightclick, helpers.FADE_IN, 3)
    
    
func intro_startgame_enter():
    await get_tree().create_timer(4).timeout
    sounds.get_node("Clang").play()
    intro_startgame.visible = true
    intro_startgame.get_node("Glow").start_glow(Color.GREEN, Color.GREEN)
    
    
func intro_startgame_input(data):
    if data == gui_play.STARTGAME_BTN_PRESSED:
        sm.change_state(START_PLAY)

    
func intro_startgame_exit():
    helpers.fade(gui_intro, helpers.FADE_OUT, 1)


func start_play_enter(): 
    helpers.hide([gui_hint])
    context = CONTEXT_PLAY
    table_slots.visible = true
    Game.turn = 1  
    await get_tree().create_timer(1).timeout
    gui_play.z_index = 2
    sm.change_state(ACTIVATE_CHALLENGE)
    
    
func activate_challenge_enter():
    var card = challenge_slot.top_card()
    challenge_slot.stop_glow()
    #challenge_slot.pulse_qty(0.3)
    Game.card_stack.push_front(card)
    card.pulse(0.3, sm.change_state.bind(ACTIVATE_CARD), CardScene.SOUND_HIT)
    
    
func activate_card_enter():
    var card : CardScene = Game.card_stack.pop_front()
    if card:
        Game.money += card.effect_money
        Game.army += card.effect_army
        Game.actions += card.extra_actions
        Game.buys += card.extra_buys
        helpers.queue_effects(card)
        sm.change_state(APPLY_EFFECT)
    else:
        sm.change_state(PLAY_ACTION)
    

func apply_effect_enter():
    var effect = Game.effect_stack.pop_front()
    if effect:
        Game.cards_to_select = effect.cards_to_select
        Game.max_cost = effect.max_cost
        match  effect.effect_id:
            Effect.DISCARD: sm.change_state(DISCARD)
            Effect.TRASH: sm.change_state(TRASH)
            _ : pass # TODO: other effects
    else:
        sm.change_state(ACTIVATE_CARD)
    
    
func discard_enter():
    helpers.glow_slot_group(hand_slots, Color.GREEN)
    gui_play.show_hint()


func discard_input(card):
    if Game.cards_to_select > 0 and card.slot() in hand_slots.get_children():
        card.fly_and_flip(card.slot(), discarded_slot, 0.4, 0, discarded_slot.add_card.bind(card), CardScene.SOUND_DEAL)
        Game.cards_to_select -= 1
    if Game.cards_to_select <= 0:
        sm.change_state(APPLY_EFFECT)
        gui_play.hide_hint()
        
        
func discard_exit():
    helpers.stop_glow_slot_group(hand_slots)

    
func play_action_enter():
    if Game.actions > 0 and helpers.has_actions():
        helpers.glow_valid_actions()
        gui_play.show_hint() 
    else:
        sm.change_state(PLAY_RESOURCES)
    
    
func play_action_input(data):
    if typeof(data) == typeof(CardScene):
        var card : CardScene = data
        if Game.actions > 0 and card.card_type == "Action":
            Game.actions -= 1
            var target_slot = helpers.find_slot_for_card(card, table_slots)
            card.fly(card.slot(), target_slot, 0.4, 0, target_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            card.slot().stop_glow_if_count(1)
            Game.card_stack.push_front(card)
            await get_tree().create_timer(0.4).timeout
            sm.change_state(ACTIVATE_CARD)
            return
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(PLAY_RESOURCES)
            return
    if Game.actions <= 0:
        sm.change_state(PLAY_RESOURCES)
        
        
func play_action_exit():
    helpers.stop_glow_slot_group(hand_slots)
    gui_play.hide_hint()
    
func play_resources_enter():
    if helpers.get_hand_resource_cards().size() == 0:
        sm.change_state(BUY_CARDS)
    gui_play.show_hint()
    
    
func play_resources_input(data):
    if typeof(data) == TYPE_INT and data == gui_play.HINT_BTN_PRESSED:
        gui_play.hide_hint()
        for card :CardScene in helpers.get_hand_resource_cards():
            Game.money += card.effect_money
            Game.army += card.effect_army
            card.pulse(0.4)
            await get_tree().create_timer(0.4).timeout
        sm.change_state(BUY_CARDS)
    
    
func buy_cards_enter():
    helpers.glow_valid_buys()
    gui_play.show_hint()


func buy_cards_input(data):
    if typeof(data) == typeof(CardScene):
        var card : CardScene = data
        if Game.buys > 0 and helpers.valid_buy(card):
            Game.money -= card.cost_money
            Game.buys -= 1
            card.fly_and_flip(card.slot(), discarded_slot, 0.5, 0, discarded_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            helpers.glow_valid_buys()
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(CLEANUP)
    if Game.buys <= 0:
        sm.change_state(CLEANUP)


func buy_cards_exit():
    gui_play.hide_hint()
    helpers.stop_glow_slot_group(resource_slots)
    helpers.stop_glow_slot_group(action_slots)


func cleanup_enter():
    await get_tree().create_timer(1).timeout
    helpers.discard_slot_group(hand_slots)
    helpers.discard_slot_group(table_slots)


func trash_enter():
    helpers.glow_slot_group(hand_slots, Color.GREEN)
    gui_play.show_hint()


func trash_input(data):
    if typeof(data) == typeof(CardScene):
        var card : CardScene = data
        if Game.cards_to_select > 0 and card.slot() in hand_slots.get_children():
            card.slot().stop_glow_if_count(1)
            card.fly(card.slot(), trash_slot, 0.4, 0, trash_slot.add_card.bind(card), CardScene.SOUND_SWOOP)
            Game.cards_to_select -= 1
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(APPLY_EFFECT)
    if Game.cards_to_select <= 0:
        sm.change_state(APPLY_EFFECT)


func trash_exit():
    helpers.stop_glow_slot_group(hand_slots)
    gui_play.hide_hint()
