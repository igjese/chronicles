extends Control

@onready var gui_status = get_node("/root/Main/GuiPlay/Status")
@onready var gui_money = get_node("/root/Main/GuiPlay/Money")
@onready var gui_army = get_node("/root/Main/GuiPlay/Army")
@onready var sound_coin = get_node("/root/Main/Sounds/Coin")
@onready var sound_punch = get_node("/root/Main/Sounds/Punch")
@onready var sm = get_node("/root/Main/StateLoop").sm
@onready var state_loop = get_node("/root/Main/StateLoop")

var helpers = Helpers.new()

func _ready():
    Game.resources_updated.connect(refresh_statusbar)
    Game.statuses_updated.connect(refresh_statusbar)
    $CheatValue.get_popup().index_pressed.connect(apply_cheat)


func _on_btn_exit_pressed():
    get_tree().quit()


func _on_btn_restart_pressed():
    get_node("/root/Main/StateLoop").start_game_loop()


func refresh_statusbar():
    gui_status.set_text("Turn %d | Money %d - Army %d | Actions %d - Buys %d" % [Game.turn, Game.money, Game.army, Game.actions, Game.buys])
    
    update_resource_display(gui_money, "money", 0.4) 
    update_resource_display(gui_army, "army", 0.4) 

        
func update_resource_display(resource_node, resource_name, delay):
    var old_value = int(resource_node.text)
    if Game[resource_name] != old_value:
        await get_tree().create_timer(0.2).timeout
        resource_node.text = str(Game[resource_name])
        var tween = create_tween()
        tween.tween_property(resource_node, "scale", Vector2(1.5, 1.5), delay/2).set_ease(Tween.EASE_IN)
        tween.tween_property(resource_node, "scale", Vector2(1, 1), delay/2).set_ease(Tween.EASE_OUT)
        await get_tree().create_timer(delay/2).timeout
        if Game[resource_name] > old_value:
            sound_coin.play()
        elif Game[resource_name] < old_value:
            sound_punch.play()


func on_card_clicked(card):
    print("card clicked: ", card.card_name)
    sm.handle_input(card)
    
    
func on_card_right_clicked(card):
    print("card right-clicked: ", card.card_name)
            

func _on_cheat_action_item_selected(index):
    var cards = []
    match index:
        0: cards = helpers.get_cards_by_type("Action")
        1: cards = helpers.get_cards_by_type("History")
    var popup = $CheatValue.get_popup()
    popup.clear()
    for card in cards:
        popup.add_item(card["name"])
        
        
func apply_cheat(index):
    var card_name = $CheatValue.get_popup().get_item_text(index)
    match $CheatAction.get_item_index($CheatAction.get_selected_id()):
        0: # Put action card into Hand1
            helpers.spawn_card(Game.cards_by_name[card_name], get_node("/root/Main/Hand/Hand1/cards"),CardScene.FACE_UP)
        1: # Put history card on Challenge top and run it
            helpers.spawn_card(Game.cards_by_name[card_name], get_node("/root/Main/Challenge/cards"),CardScene.FACE_UP)
            Game.card_stack.clear()
            Game.effect_stack.clear()
            sm.change_state(state_loop.ACTIVATE_CHALLENGE)


func show_hint(state):
    var msg = ""
    match state:
        state_loop.DISCARD: msg = "Discard %s card." % Game.cards_to_select
    $Hint.get_node("Message").bbcode_text = "[center]%s[/center]" % msg
    $Hint.visible = true
    var tween = create_tween()
    tween.tween_property($Hint, "global_position", $Hint.global_position, 0.4).from($Hint.global_position - Vector2(500,0))
