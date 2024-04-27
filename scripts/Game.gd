extends Node

signal resources_updated()
signal statuses_updated()

var cards_by_name = {}

var turn: 
    set(value): 
        turn = value
        statuses_updated.emit()
    
var money:
    set(value): 
        money = value
        resources_updated.emit()
        
var army:
    set(value):
        army = value
        resources_updated.emit()
        
var actions:
    set(value):
        actions = value
        statuses_updated.emit()
        
var buys:
    set(value):
        buys = value
        statuses_updated.emit()

func _ready():
    turn = 0
    money = 0
    army = 0
    actions = 0
    buys = 0
