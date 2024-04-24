class_name Utils
extends Node

func get_cards_by_type(card_type: String) -> Array:
    var cards_of_type = []
    for card in Game.cards_by_name.values():
        if card["type"] == card_type:
            cards_of_type.append(card)
    return cards_of_type


