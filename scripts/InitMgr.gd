extends Node

func init():
    print_scene_tree(get_tree().get_root())
    load_card_definitions_from_csv()


func print_scene_tree(node: Node, indent: int = 0):
    var indents = "    ".repeat(indent)
    var node_info = "%s- %s (%s)" % [indents, node.name, node.get_class()]

    if not (node is CardScene or node is SlotScene):
        if node.script:
            node_info += " <-- %s" % node.script.resource_path
    if node is CardScene:
        node_info += " [Card Scene]"
        print(node_info)
        return
    elif node is SlotScene:
        node_info += " [Slot Scene]"
        
    print(node_info)
    for child in node.get_children():
        print_scene_tree(child, indent + 1)


func load_card_definitions_from_csv():
    var path = "res://data/cards-csv.txt"
    
    var file = FileAccess.open(path, FileAccess.READ)
    if !file:
        print("Failed to open file: ", path)
        return

    file.get_line() # Skip the first line (header)
    while not file.eof_reached():   
        var line = file.get_line()
        if line == "":
            continue
        var card_data = line.split(";")
        var card = {
            "type": card_data[0],
            "name": card_data[1],
            "cost_money": int(card_data[2]),
            "effect_money": int(card_data[3]),
            "effect_army": int(card_data[4]),
            "discard": int(card_data[5]),
            "trash": int(card_data[6]),
            "extra_buys": int(card_data[7]),
            "draw": int(card_data[8]),
            "extra_actions": int(card_data[9]),
            "replace": int(card_data[10]),
            "upgrade_2": int(card_data[11]),
            "double_action": int(card_data[12]),
            "take_4": int(card_data[13]),
            "take_money2": int(card_data[14]),
            "take_5": int(card_data[15]),
            "upgrade_money": int(card_data[16])
        }
        Game.cards_by_name[card["name"]] = card

    file.close()
