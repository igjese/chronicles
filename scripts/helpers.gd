class_name Helpers
extends Node

var card_scene = preload("res://scenes/card/card.tscn")


func get_cards_by_type(card_type: String) -> Array:
    var cards_of_type = []
    for card in Game.cards_by_name.values():
        if card["type"] == card_type:
            cards_of_type.append(card)
    return cards_of_type


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
    
    
func card_count(slot_group):
    var card_count = 0
    for slot in slot_group.get_children():
        card_count += slot.get_node("cards").get_child_count()
    return card_count


func queue_effects(card):
    if card["draw_cards"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.DRAW, card["draw_cards"]))
    if card["trash"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.TRASH, card["trash"]))
    if card["take_money2"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.TAKE_MONEY2))
    if card["take_4"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.TAKE, card["take_4"], 4))
    if card["take_5"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.TAKE, card["take_5"], 5))
    if card["double_action"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.DOUBLE_ACTION))
    if card["replace"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.REPLACE, card["replace"]))
    if card["upgrade_2"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.UPGRADE_2))
    if card["upgrade_money"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.UPGRADE_MONEY))
    if card["discard"] > 0:
        Game.effect_stack.push_front(Effect.new(Effect.DISCARD))
        
