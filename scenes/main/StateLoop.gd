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
@onready var laurel = gui_play.get_node("Money/Laurel")

var helpers = Helpers.new()

enum {SETUP, INTRO_RESOURCES, DEAL_RESOURCES, INTRO_ACTIONS, DEAL_ACTIONS, INTRO_DECK, PREPARE_DECK, DEAL_HAND, INTRO_CHALLENGE, VICTORY,
     DEAL_CHALLENGES, FLIP_CHALLENGE, INTRO_STARTGAME, START_PLAY, ACTIVATE_CHALLENGE, ACTIVATE_CARD, APPLY_EFFECT, DISCARD, PLAY_ACTION,
    PLAY_RESOURCES, BUY_CARDS, CLEANUP, TRASH, NEXT_TURN, DRAW_CARD, TAKE_MONEY2, FREE_CARD, DOUBLE_ACTION, REPLACE_CARDS, UPGRADE_2, UPGRADE_MONEY}
    
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
    TRASH: {SM.ENTER: trash_enter, SM.INPUT: trash_input, SM.EXIT: trash_exit},
    NEXT_TURN: {SM.ENTER: next_turn_enter},
    DRAW_CARD: {SM.ENTER: draw_card_enter},
    TAKE_MONEY2: {SM.ENTER: take_money2_enter},
    FREE_CARD: {SM.ENTER: free_card_enter, SM.EXIT: free_card_exit, SM.INPUT: free_card_input},
    DOUBLE_ACTION: {SM.ENTER: double_action_enter, SM.EXIT: double_action_exit, SM.INPUT: double_action_input},
    REPLACE_CARDS: {SM.ENTER: replace_cards_enter, SM.EXIT: replace_cards_exit, SM.INPUT: replace_cards_input}, 
    UPGRADE_2: {SM.ENTER: upgrade_2_enter, SM.EXIT: upgrade_2_exit, SM.INPUT: upgrade_2_input}, 
    UPGRADE_MONEY: {SM.ENTER: upgrade_money_enter},
    VICTORY: {SM.ENTER: victory_enter, SM.EXIT: victory_exit}
})


func _ready():
    Game.sm = sm
    Game.connect_gui(get_node("/root/Main"))
    helpers.connect_gui(get_node("/root/Main"))


enum {CONTEXT_INTRO, CONTEXT_PLAY}

var context = CONTEXT_PLAY

func start_game_loop(requested_context = CONTEXT_PLAY):
    helpers.hide([gui_play.get_node("Money"), gui_play.get_node("Army")])
    gui_play.get_node("Money").text = "0"
    gui_play.get_node("Army").text = "0"
    gui_play.hide_hint()
    helpers.empty_all_decks()
    context = requested_context
    sm.change_state(SETUP)


func _process(delta):
    sm.process(delta)
    
    
func setup_enter():
    gui_play.z_index = 0
    Game.turn = 1
    resource_slots.visible = false
    if context == CONTEXT_INTRO:
        gui_intro.visible = true
        helpers.hide([intro_main, intro_resources, intro_actions, intro_challenge, intro_hand, intro_rightclick, intro_startgame, table_slots, laurel])
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
    if context == CONTEXT_INTRO:
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
        helpers.change_state_by_context(INTRO_ACTIONS, DEAL_ACTIONS)
                
        
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
        helpers.change_state_by_context(INTRO_DECK, PREPARE_DECK)
    
    
func deal_actions_exit():
    if context == CONTEXT_INTRO:
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
    var cards_dealt = 0
    while cards_dealt < 5:
        var deck_cards = deck_slot.get_node("cards").get_children()
        if deck_cards.is_empty():
            await helpers.reshuffle_discarded_to_deck()
            if deck_slot.card_count() == 0:
                print("deal_hand_enter EXITED: No cards left to deal even after reshuffling.")
                break  # Break the loop if still no cards after reshuffling
            continue
        else:
            var card = deck_cards[-1]
            var target_slot = helpers.find_slot_for_card(card, hand_slots)
            card.fly_and_flip(deck_slot, target_slot, 0.4, 0.1, target_slot.add_card.bind(card), CardScene.SOUND_DRAW)
            cards_dealt += 1
            await get_tree().create_timer(0.6).timeout
    
    
func deal_hand_process(_delta):
    if helpers.count_cards(hand_slots) == 5:
        helpers.change_state_by_context(INTRO_CHALLENGE, DEAL_CHALLENGES)
    
    
func deal_hand_exit():
    if context == CONTEXT_INTRO:
        helpers.fade(intro_hand, helpers.FADE_IN, 3)
    
    
func intro_challenge_enter():
    helpers.intro("Overcome historical challenges.", 3, DEAL_CHALLENGES)
    
    
func deal_challenges_enter():
    if challenge_slot.card_count() == 0:
        var challenges = helpers.prepare_challenges()
        var start_delay = 0
        for card_data in challenges:
        #for i in range(3):
         #   var card_data = challenges[i+5]
            var card = helpers.spawn_card(card_data, offscreen_left, CardScene.FACE_DOWN)
            card.fly(offscreen_left, challenge_slot, 0.35, start_delay, challenge_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            start_delay += 0.12
    else:
        sm.change_state(FLIP_CHALLENGE)

    
func deal_challenges_process(_delta):
    if challenge_slot.get_node("cards").get_child_count() == 22: #3: 
        sm.change_state(FLIP_CHALLENGE)
        
        
func flip_challenge_enter():
    gui_play.get_node("Money").visible = true
    gui_play.get_node("Army").visible = true
    if challenge_slot.top_card().get_node("Back").visible:
        challenge_slot.top_card().flip_card(0.6, 0.2)
        challenge_slot.pulse_qty_for_flip(0.6,0.2)
        await get_tree().create_timer(0.6).timeout
    Game.showcase_card = challenge_slot.top_card()
    Game.challenge_overcome = false
    challenge_slot.start_glow(Color.RED)
    helpers.change_state_by_context(INTRO_STARTGAME, START_PLAY)
    
    
func flip_challenge_exit():
    if context == CONTEXT_INTRO:
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
    await get_tree().create_timer(1).timeout
    gui_play.z_index = 2
    sm.change_state(ACTIVATE_CHALLENGE)
    
    
func activate_challenge_enter():
    var card = challenge_slot.top_card()
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
            Effect.DRAW: sm.change_state(DRAW_CARD)
            Effect.TAKE_MONEY2: sm.change_state(TAKE_MONEY2)
            Effect.DOUBLE_ACTION: sm.change_state(DOUBLE_ACTION)
            Effect.REPLACE: sm.change_state(REPLACE_CARDS)
            Effect.UPGRADE_2: sm.change_state(UPGRADE_2)
            Effect.UPGRADE_MONEY: sm.change_state(UPGRADE_MONEY)
            Effect.FREE_CARD: 
                Game.max_cost = effect.max_cost
                sm.change_state(FREE_CARD)
            _ : 
                print("APPLY EFFECT: ", effect.effect_name)
                sm.change_state(ACTIVATE_CARD)
    else:
        sm.change_state(ACTIVATE_CARD)
    
    
func discard_enter():
    helpers.glow_slot_group(hand_slots, Color.DEEP_SKY_BLUE)
    gui_play.show_hint()


func discard_input(data):
    if typeof(data) == typeof(CardScene):
        var card = data
        Game.showcase_card = card
        if Game.cards_to_select > 0 and card.slot() in hand_slots.get_children():
            card.fly_and_flip(card.slot(), discarded_slot, 0.4, 0, discarded_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            Game.cards_to_select -= 1
        if Game.cards_to_select <= 0:
            gui_play.hide_hint()
            sm.change_state(APPLY_EFFECT)
        
        
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
        Game.showcase_card = card
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
        Game.showcase_card = card
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
    var challenge_card = challenge_slot.top_card()
    if Game.challenge_overcome:
        challenge_card.fly(challenge_slot, offscreen_left, 0.5, 0, offscreen_left.add_card.bind(challenge_card), CardScene.SOUND_SWOOP)
        if challenge_slot.card_count() == 1:
            sm.change_state(VICTORY)
            return
        Game.challenge_overcome = false
    else:
        get_node("/root/Main/Sounds/Fail").play()
        challenge_card.pulse(0.4)
        await get_tree().create_timer(0.6).timeout
        var card = deck_slot.top_card()
        if not card:
            card = discarded_slot.top_card()
        card.flip_card(0.6, 0)
        await get_tree().create_timer(0.7).timeout
        card.fly(card.slot(), trash_slot, 0.5, 0, trash_slot.add_card.bind(card), CardScene.SOUND_SWOOP)
        await get_tree().create_timer(0.7).timeout
    helpers.discard_slot_group(hand_slots)
    helpers.discard_slot_group(table_slots)
    sm.change_state(NEXT_TURN)


func trash_enter():
    helpers.glow_slot_group(hand_slots, Color.RED)
    gui_play.show_hint()


func trash_input(data):
    if typeof(data) == typeof(CardScene):
        var card : CardScene = data
        Game.showcase_card = card
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


func next_turn_enter():
    await get_tree().create_timer(1).timeout
    Game.turn += 1
    Game.money = 0
    Game.army = 0
    Game.actions = 1
    Game.buys = 1
    Game.cards_to_select = 0
    sm.change_state(DEAL_HAND)
    

func draw_card_enter():
    if deck_slot.card_count() == 0:
        await helpers.reshuffle_discarded_to_deck()
    var card = deck_slot.top_card()
    var target_slot = helpers.find_slot_for_card(card, hand_slots)
    card.fly_and_flip(deck_slot, target_slot, 0.4, 0.1, target_slot.add_card.bind(card), CardScene.SOUND_DRAW)
    await get_tree().create_timer(0.6).timeout
    sm.change_state(APPLY_EFFECT)
    
    
func take_money2_enter():
    var slot = resource_slots.get_node("Money2")
    if slot.card_count() > 0:
        var card = slot.top_card()
        card.fly_and_flip(slot, discarded_slot, 0.55, 0, discarded_slot.add_card.bind(card), CardScene.SOUND_DEAL)
        await get_tree().create_timer(0.6).timeout
        sm.change_state(APPLY_EFFECT)


func free_card_enter():
    helpers.glow_valid_free_cards()
    gui_play.show_hint()


func free_card_exit():
    helpers.stop_glow_slot_group(resource_slots)
    helpers.stop_glow_slot_group(action_slots)
    gui_play.hide_hint()


func free_card_input(data):
    if typeof(data) == typeof(CardScene):
        var card : CardScene = data
        Game.showcase_card = card
        if Game.cards_to_select > 0 and helpers.valid_free_card(card):
            card.slot().stop_glow_if_count(1)
            card.fly_and_flip(card.slot(), discarded_slot, 0.55, 0, discarded_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            Game.cards_to_select -= 1
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(APPLY_EFFECT)
    if Game.cards_to_select <= 0:
        sm.change_state(APPLY_EFFECT)


func double_action_enter():
    if Game.actions > 0 and helpers.has_actions():
        helpers.glow_valid_actions()
        gui_play.show_hint() 
    else:
        sm.change_state(APPLY_EFFECT)
    
    
func double_action_exit():
    helpers.stop_glow_slot_group(hand_slots)
    
    
func double_action_input(data):
    if typeof(data) == typeof(CardScene):
        var card : CardScene = data
        Game.showcase_card = card
        if Game.cards_to_select > 0 and card.card_type == "Action":
            Game.actions -= 1
            Game.cards_to_select -= 1
            var target_slot = helpers.find_slot_for_card(card, table_slots)
            card.fly(card.slot(), target_slot, 0.4, 0, target_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            card.slot().stop_glow_if_count(1)
            Game.card_stack.push_front(card)
            Game.card_stack.push_front(card)
            await get_tree().create_timer(0.4).timeout
            sm.change_state(ACTIVATE_CARD)
            return
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(APPLY_EFFECT)
    if Game.cards_to_select <= 0:
        sm.change_state(APPLY_EFFECT)


func replace_cards_enter():
    helpers.glow_slot_group(hand_slots, Color.DEEP_SKY_BLUE)
    gui_play.show_hint()
    
    
func replace_cards_input(data):
    if typeof(data) == typeof(CardScene):
        var card = data
        Game.showcase_card = card
        if Game.cards_to_select > 0 and card.slot() in hand_slots.get_children():
            card.fly_and_flip(card.slot(), discarded_slot, 0.4, 0, discarded_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            card.slot().stop_glow_if_count(1)
            Game.cards_to_select -= 1
            await get_tree().create_timer(0.5).timeout
            if deck_slot.card_count() == 0:
                await helpers.reshuffle_discarded_to_deck()
            var new_card = deck_slot.top_card()
            var target_slot = helpers.find_slot_for_card(new_card, hand_slots)
            new_card.fly_and_flip(deck_slot, target_slot, 0.4, 0.1, target_slot.add_card.bind(new_card), CardScene.SOUND_DRAW)
            await get_tree().create_timer(0.6).timeout
            helpers.glow_slot_group(hand_slots, Color.DEEP_SKY_BLUE)
        if Game.cards_to_select <= 0:
            gui_play.hide_hint()
            sm.change_state(APPLY_EFFECT)
            return
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(APPLY_EFFECT)
    if Game.cards_to_select <= 0:
        sm.change_state(APPLY_EFFECT)
        
    
func replace_cards_exit():
    helpers.stop_glow_slot_group(hand_slots)
    
    
func upgrade_2_enter():
    helpers.glow_slot_group(hand_slots, Color.GREEN)
    gui_play.show_hint()
    
    
func upgrade_2_input(data):
    if typeof(data) == typeof(CardScene):
        var card = data
        Game.showcase_card = card
        if Game.cards_to_select > 0 and card.slot() in hand_slots.get_children():
            card.fly_and_flip(card.slot(), trash_slot, 0.4, 0, trash_slot.add_card.bind(card), CardScene.SOUND_DEAL)
            helpers.stop_glow_slot_group(hand_slots)
            Game.cards_to_select -= 1
            Game.effect_stack.push_front(Effect.new(Effect.FREE_CARD, "take_card", 1, card.cost_money + 2))
            await get_tree().create_timer(0.5).timeout
        if Game.cards_to_select <= 0:
            gui_play.hide_hint()
            sm.change_state(APPLY_EFFECT)
            return
    elif typeof(data) == TYPE_INT:
        if data == gui_play.HINT_BTN_PRESSED:
            sm.change_state(APPLY_EFFECT)
    if Game.cards_to_select <= 0:
        sm.change_state(APPLY_EFFECT)
        
        
func upgrade_2_exit():
    helpers.stop_glow_slot_group(hand_slots)


func upgrade_money_enter():
    var money1 = null
    var money2 = null
    for slot in hand_slots.get_children():
        if slot.top_card() and slot.top_card().card_type == "Money1":
            money1 = slot.top_card()
            break
    if resource_slots.get_node("Money2").card_count() > 0:
        money2 = resource_slots.get_node("Money2").top_card()
    if money1 and money2:
        var target_slot = helpers.find_slot_for_card(money2, hand_slots)
        money1.fly(money1.slot(), trash_slot, 0.4, 0, trash_slot.add_card.bind(money1), CardScene.SOUND_DRAW)
        await get_tree().create_timer(0.7).timeout
        money2.fly(money2.slot(), target_slot, 0.8, 0, target_slot.add_card.bind(money2), CardScene.SOUND_DEAL)
        await get_tree().create_timer(0.95).timeout
    sm.change_state(APPLY_EFFECT)
    

func victory_enter():
    get_node("/root/Main/Sounds/Victory").play()
    gui_play.get_node("Victory").visible = true
    
    
func victory_exit():
    gui_play.get_node("Victory").visible = false

