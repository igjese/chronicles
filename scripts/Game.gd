extends Node

signal money_updated(increment, current_state_id, new_value)
signal army_updated(increment, current_state_id, new_value)
signal info_updated
signal showcase_updated(card)

var cards_by_name = {}
var sm = null
var gui_play = null
var gui_intro = null
var gui_main = null

var card_stack = []
var effect_stack = []

var max_cost = 0

var showcase_card = null:
    set(card):
        showcase_card = card
        showcase_updated.emit(card)

var cards_to_select:
    set(value): 
        cards_to_select = value
        info_updated.emit()

var turn: 
    set(value): 
        turn = value
        info_updated.emit()
    
var money = 0:
    set(value): 
        if money == value: return
        var old_value = money
        money = value
        money_updated.emit(value - old_value, sm.current_state_id, value)
        
var army = 0:
    set(value):
        if army == value: return
        var old_value = army
        army = value
        army_updated.emit(value - old_value, sm.current_state_id, value)
        
var actions:
    set(value):
        actions = value
        info_updated.emit()
        
var buys:
    set(value):
        buys = value
        info_updated.emit()


func _ready():
    turn = 1
    money = 0
    army = 0
    actions = 1
    buys = 1
    cards_to_select = 0
    
    
func connect_gui(gui_main):
    gui_play = gui_main.get_node("GuiPlay")
    gui_intro = gui_main.get_node("GuiIntro")
