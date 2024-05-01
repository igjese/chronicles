extends Node2D

func _ready():
    print("*** Main scene tree ***")
    print_scene_tree(get_tree().get_root())
    print_slot_and_card_trees() 
    load_card_definitions_from_csv()
    load_history_texts_from_md()
    $Discarded/qty.position.x = 20
    $StateLoop.start_game_loop($StateLoop.CONTEXT_INTRO)


func print_scene_tree(node: Node, indent: int = 0, dive_in_card=false, dive_in_slot=false):
    var sample_card = null
    var sample_slot = null
    var indents = "    ".repeat(indent)
    var node_info = "%s- %s (%s)" % [indents, node.name, node.get_class()]
    var dive_in = true

    if node is CardScene:
        sample_card = node
        node_info += " [Card Scene]"
        dive_in = dive_in_card
    elif node is SlotScene:
        sample_slot = node
        node_info += " [Slot Scene]"
        dive_in = dive_in_slot
        
    if dive_in:
        if node.script:
            node_info += " <-- %s" % node.script.resource_path
        
    print(node_info)
    
    if dive_in:
        for child in node.get_children():
            print_scene_tree(child, indent + 1)    
            
    
func print_slot_and_card_trees():
    var dummy_card = preload("res://scenes/card/card.tscn").instantiate()
    print("*** CardScene tree ***")
    print_scene_tree(dummy_card, 0, true) 
    dummy_card.free()
    
    var dummy_slot = preload("res://scenes/slot/slot.tscn").instantiate()    
    print("*** SlotScene tree ***")
    print_scene_tree(dummy_slot, 0, false, true) 
    dummy_slot.free()

    

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
        
        var normalized_name = card["name"].replace(" ", "_").to_lower()
        var image_path = "res://visuals/cards/" + normalized_name + ".png"
        card["visual"] = load(image_path)
        
        Game.cards_by_name[card["name"]] = card

    file.close()


func load_history_texts_from_md():
    var path = "res://data/history.md"
    var file = FileAccess.open(path, FileAccess.READ)
    if !file:
        print("Failed to open file: ", path)
        return

    var content = file.get_as_text()
    file.close()

    var lines = content.split("\n")
    var current_card_name = ""
    for line in lines:
        if line.begins_with("### "):  # New card heading
            current_card_name = line.substr(3).strip_edges()  # Remove '### ' prefix and non-printable chars at both sides
            Game.cards_by_name[current_card_name]["history_text"] = ""
        elif current_card_name != "" and not line.begins_with("#"):
            # Append paragraph text to the current card's history, add newline for paragraph separation
            Game.cards_by_name[current_card_name]["history_text"] += line.strip_edges() + "\n"


func toggle_cheats():
    print("toggle cheats")
    $GuiPlay/CheatAction.visible = not $GuiPlay/CheatAction.visible
    $GuiPlay/CheatValue.visible = not $GuiPlay/CheatValue.visible


func _input(event):
    if Input.is_action_just_pressed("toggle_cheats"):
        toggle_cheats()
        
