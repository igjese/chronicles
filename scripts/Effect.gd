class_name Effect
extends RefCounted

enum {DRAW, TRASH, TAKE_MONEY2, FREE_CARD, DOUBLE_ACTION, REPLACE, UPGRADE_2, UPGRADE_MONEY, DISCARD}

var effect_id = null
var effect_name = null
var cards_to_select = 0
var max_cost = 0

func _init(effect_id, effect_name, cards_to_select=0, max_cost=0):
    self.effect_id = effect_id
    self.effect_name = effect_name
    self.cards_to_select = cards_to_select
    self.max_cost = max_cost
    
