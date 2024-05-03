class_name Helpers
extends Node

var card_scene = preload("res://scenes/card/card.tscn")

var resource_slots
var action_slots
var hand_slots
var discarded_slot
var offscreen_bottom
var gui_main


func connect_gui(main_scene):
    gui_main = main_scene
    resource_slots = gui_main.get_node("Resources")
    action_slots = gui_main.get_node("Actions")
    hand_slots = gui_main.get_node("Hand")
    discarded_slot = gui_main.get_node("Discarded")
    offscreen_bottom = gui_main.get_node("Offscreen/Bottom")


func get_cards_by_type(card_type: String) -> Array:
    var cards_of_type = []
    for card in Game.cards_by_name.values():
        if card["type"] == card_type:
            cards_of_type.append(card)
    return cards_of_type


func find_slot_for_card(card: CardScene, slot_group: Control) -> SlotScene:
    var free_slots = []
    for slot: SlotScene in slot_group.get_children():
        if slot.get_node("cards").get_child_count() > 0:
            if card.card_name == slot.get_node("cards").get_children()[0].card_name:
                return slot
        else:
            free_slots.append(slot)
    return free_slots[0]
    
    
func hide(nodes):
    for node in nodes:
        node.visible = false


func spawn_card(card_data, parent_node, face):
    var card = card_scene.instantiate()
    parent_node.add_child(card)
    card.set_card_data(card_data) 
    card.set_face(face)
    return card
    
    
enum {FADE_OUT, FADE_IN}
    
    
func fade(node, fade_mode, duration, request_state = null):
    var tween = node.create_tween()
    node.modulate.a = 0 if fade_mode == FADE_IN else 1
    node.visible = true
    tween.tween_property(node,"modulate:a",fade_mode,duration)
    if fade_mode == FADE_OUT: 
        tween.tween_property(node, "visible", false, 0)
    if request_state:
        tween.tween_callback(Game.sm.change_state.bind(request_state))
        
        
func intro(text, duration, request_state = null):
    var intro_main = Game.gui_intro.get_node("MainText")
    var tween = intro_main.create_tween()
    intro_main.bbcode_text = "[center]%s[/center]" % text
    intro_main.modulate.a = 0
    intro_main.visible = true
    intro_main.pivot_offset = intro_main.size / 2
    tween.tween_property(intro_main, "modulate:a", 1, duration).set_ease(Tween.EASE_IN)
    tween.parallel().tween_property(intro_main, "scale", Vector2(1,1), duration).from(Vector2(0,0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    if request_state:
            tween.tween_callback(Game.sm.change_state.bind(request_state))
            
            
func sort_cards_by_cost(a, b):
    return a["cost_money"] < b["cost_money"]  # Ascending order 
    
    
func count_cards(slot_group):
    var card_count = 0
    for slot in slot_group.get_children():
        card_count += slot.get_node("cards").get_child_count()
    return card_count
        
        
func glow_valid_buys():
    glow_slot_group(resource_slots, Color.GREEN, Game.money)
    glow_slot_group(action_slots, Color.GREEN, Game.money)
        

func glow_slot_group(slot_group, color, money_treshold = 999):
    for slot in slot_group.get_children():
        if slot.card_count() > 0:
            if slot.top_card().cost_money <= money_treshold:
                slot.start_glow(color)
            else:
                slot.stop_glow()
            
            
func stop_glow_slot_group(slot_group):
    for slot in slot_group.get_children():
        slot.stop_glow()
    

func choose_action_set():
    var all_actions = get_cards_by_type("Action")
    var selected_actions = []
    while selected_actions.size() < 10:
        var choice = randi() % all_actions.size()
        selected_actions.append(all_actions.pop_at(choice))
    selected_actions.sort_custom(sort_cards_by_cost)
    return selected_actions


func prepare_challenges():
    var challenges = get_cards_by_type("History")
    challenges.shuffle()
    challenges.append(get_cards_by_type("Victory1")[0])
    challenges.append(get_cards_by_type("Victory2")[0])
    challenges.append(get_cards_by_type("Victory3")[0])
    challenges.reverse()
    return challenges


func has_actions():
    for slot : SlotScene in hand_slots.get_children():
        if slot.card_count() > 0 and slot.top_card().card_type == "Action":
            return true
    return false


func get_hand_resource_cards():
    var resources = []
    for slot in hand_slots.get_children():
        for card in slot.get_node("cards").get_children():
            if card.card_type in ["Money1", "Money2", "Army1", "Army2"]:
                resources.append(card)
    return resources
    

func valid_buy(card):
    if card.cost_money <= Game.money:
        if card.slot() in resource_slots.get_children():
            return true
        if card.slot() in action_slots.get_children():
            return true
    return false


func glow_valid_actions():
    for slot in hand_slots.get_children():
        if slot.top_card() and slot.top_card().card_type == "Action":
            slot.start_glow(Color.GREEN)
        else:
            slot.stop_glow()


func discard_slot_group(slot_group):
    for slot in slot_group.get_children():
        var delay = 0
        for card in slot.get_node("cards").get_children():
            var sounds = [CardScene.SOUND_DEAL, CardScene.SOUND_DEAL, CardScene.SOUND_SWOOP]
            card.fly_and_flip(card.slot(), discarded_slot, 0.75, delay, discarded_slot.add_card.bind(card), sounds[randi() % sounds.size()])
            delay += 0.1713
            

func reshuffle_discarded_to_deck():
    await gui_main.get_tree().create_timer(0.3).timeout
    var cards = discarded_slot.get_node("cards").get_children()
    cards.reverse()
    move_cards(cards, discarded_slot, offscreen_bottom, 0.3, 0.11, gui_main.get_node("Offscreen/BottomRight"))
    await gui_main.get_tree().create_timer(cards.size() * 0.11 + 0.3).timeout

    gui_main.get_node("Sounds/Shuffle").play()
    await gui_main.get_tree().create_timer(2).timeout
    
    cards = offscreen_bottom.get_node("cards").get_children()
    cards.shuffle()
    move_cards(cards, offscreen_bottom, gui_main.get_node("Deck"), 0.4, 0.17)
    await gui_main.get_tree().create_timer(cards.size() * 0.17 + 0.4 + 0.2).timeout
    
        
func move_cards(cards, start_slot, end_slot, duration, delay, end_position=null):
    var delay_next = 0
    if not end_position: end_position = end_slot
    for card in cards:
        card.fly(start_slot, end_position, duration, delay_next, end_slot.add_card.bind(card), CardScene.SOUND_DEAL)
        delay_next += delay


func glow_valid_free_cards():
    for slot in action_slots.get_children():
        if slot.top_card() and slot.top_card().cost_money <= Game.max_cost:
            slot.start_glow(Color.GREEN)
        else:
            slot.stop_glow()
    for slot in resource_slots.get_children():
        if slot.top_card() and slot.top_card().cost_money <= Game.max_cost:
            slot.start_glow(Color.GREEN)
        else:
            slot.stop_glow()


func valid_free_card(card):
    if card.cost_money <= Game.max_cost: 
        return true
    return false
    
    
func queue_effects(card):
    if card["draw_cards"] > 0:
        for i in range(card["draw_cards"]):
            Game.effect_stack.push_front(Effect.new(Effect.DRAW, "draw_cards", card["draw_cards"]))
    if card["trash"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.TRASH, "trash", card["trash"]))
    if card["take_money2"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.TAKE_MONEY2, "take_money2"))
    if card["take_4"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.FREE_CARD, "take_card", card["take_4"], 4))
    if card["take_5"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.FREE_CARD, "take_card", card["take_5"], 5))
    if card["double_action"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.DOUBLE_ACTION, "double_action", card["double_action"]))
    if card["replace"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.REPLACE, "replace", card["replace"]))
    if card["upgrade_2"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.UPGRADE_2, "upgrade_2", card["upgrade_2"]))
    if card["upgrade_money"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.UPGRADE_MONEY, "upgrade_money"))
    if card["discard"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.DISCARD, "discard", card["discard"]))


func get_effect_text(card):
    var card_data = Game.cards_by_name[card.card_name]
    var effects = {
            "effect_money": "Money %+d" % card_data["effect_money"],
            "effect_army": "Army %+d" % card_data["effect_army"],
            "discard": "Discard %d card%s" % [card_data["discard"], "s" if card_data["discard"] > 1 else ""],
            "trash": "Trash up to %d card%s" % [card_data["trash"], "s" if card_data["trash"] > 1 else ""],
            "extra_buys": "Extra %d buy%s" % [card_data["extra_buys"], "s" if card_data["extra_buys"] > 1 else ""],
            "draw": "Draw %d card%s" % [card_data["draw"], "s" if card_data["draw"] > 1 else ""],
            "extra_actions": "Extra %d action%s" % [card_data["extra_actions"], "s" if card_data["extra_actions"] > 1 else ""],
            "replace": "Replace up to %d card%s" % [card_data["replace"], "s" if card_data["replace"] > 1 else ""],
            "upgrade_2": "Upgrade a card to +2 more costly one",
            "double_action": "Doubled effects for next action",
            "take_4": "Take a card costing max 4 money",
            "take_money2": "Take Aes Rude card",
            "take_5": "Take a card costing max 5 money",
            "upgrade_money": "Upgrade money card to next denomination",
        }
        
    var effect_text = ""
    for effect in effects:
        if card_data[effect] != 0:
            effect_text = "%s%s. " % [effect_text, effects[effect]]
    return effect_text


func empty_all_decks():
    for slot in resource_slots.get_children():
        slot.empty_cards()
    for slot in action_slots.get_children():
        slot.empty_cards()
    for slot in hand_slots.get_children():
        slot.empty_cards()
    for slot in gui_main.get_node("Table").get_children():
        slot.empty_cards()
    gui_main.get_node("Discarded").empty_cards()
    gui_main.get_node("Challenge").empty_cards()
    gui_main.get_node("Deck").empty_cards()
    gui_main.get_node("Trash").empty_cards()
    gui_main.get_node("Offscreen/Left").empty_cards()
    gui_main.get_node("Offscreen/Bottom").empty_cards()


func change_state_by_context(intro_state, play_state):
    var state_loop = gui_main.get_node("StateLoop")
    if state_loop.context == state_loop.CONTEXT_INTRO:
        Game.sm.change_state(intro_state)
    else:
        Game.sm.change_state(play_state)
        

func is_card(data):
    return typeof(data) == typeof(CardScene)


func is_hint_btn_pressed(data):
    return typeof(data) == TYPE_INT and data == gui_main.get_node("GuiPlay").HINT_BTN_PRESSED
    
    
