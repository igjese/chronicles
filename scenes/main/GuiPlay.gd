extends Control

@onready var gui_status = get_node("/root/Main/GuiPlay/Status")
@onready var gui_money = get_node("/root/Main/GuiPlay/Money")
@onready var gui_army = get_node("/root/Main/GuiPlay/Army")
@onready var sound_coin = get_node("/root/Main/Sounds/Coin")
@onready var sound_punch = get_node("/root/Main/Sounds/Punch")
@onready var sm = get_node("/root/Main/StateLoop").sm
@onready var state_loop = get_node("/root/Main/StateLoop")

var helpers = Helpers.new()

var hint_position
var hiding_hint_tween = false
var money_being_refreshed = false

enum {HINT_BTN_PRESSED, STARTGAME_BTN_PRESSED}

func _ready():
    Game.money_updated.connect(refresh_money)
    Game.army_updated.connect(refresh_army)
    Game.info_updated.connect(refresh_info)
    $CheatValue.get_popup().index_pressed.connect(apply_cheat)
    hint_position = $Hint.global_position
    

func refresh_money():
    update_resource_badge(gui_money, "money", 0.4, 0.2) 
    
    
func refresh_army():
    var delay = 0.2
    if money_being_refreshed: delay += 0.3
    update_resource_badge(gui_army, "army", 0.4, delay) 

        
func update_resource_badge(resource_node, resource_name, duration, delay):
    if resource_name == "money": money_being_refreshed = true
    await get_tree().create_timer(delay).timeout
    var tween = create_tween()
    tween.tween_property(resource_node, "scale", Vector2(1.5, 1.5), duration/2).set_ease(Tween.EASE_IN)
    tween.tween_property(resource_node, "scale", Vector2(1, 1), duration/2).set_ease(Tween.EASE_OUT)
    
    await get_tree().create_timer(duration/2).timeout
    if Game[resource_name] > int(resource_node.text):
        sound_coin.play()
    else:
        sound_punch.play()
    resource_node.text = str(Game[resource_name])
    if resource_name == "money": money_being_refreshed = false
    refresh_info()
        
        
func refresh_info():
    gui_status.set_text("Turn %d | Money %d - Army %d | Actions %d - Buys %d" % [Game.turn, Game.money, Game.army, Game.actions, Game.buys])        
    update_hint()
    
    
func apply_cheat(index):
    var option_text = $CheatValue.get_popup().get_item_text(index)
    match $CheatAction.get_item_index($CheatAction.get_selected_id()):
        0: # Put action card into Hand7
            helpers.spawn_card(Game.cards_by_name[option_text], get_node("/root/Main/Hand/Hand8/cards"),CardScene.FACE_UP)
        1: # Put history card on Challenge top and run it
            helpers.spawn_card(Game.cards_by_name[option_text], get_node("/root/Main/Challenge/cards"),CardScene.FACE_UP)
            Game.card_stack.clear()
            Game.effect_stack.clear()
            sm.change_state(state_loop.ACTIVATE_CHALLENGE)
        2: # Change to chosen state
            match option_text:
                "PLAY_ACTION": sm.change_state(state_loop.PLAY_ACTION)
                "PLAY_RESOURCES": sm.change_state(state_loop.PLAY_RESOURCES)
                
func show_hint():
    update_hint()
    if hiding_hint_tween: hiding_hint_tween.kill()
    var tween = create_tween()
    tween.tween_property($Hint, "global_position", hint_position, 0.4).from(hint_position - Vector2(500,0))
    $Hint.visible = true
    
    
func update_hint():
    var state = sm.current_state_id
    var hints = {
        state_loop.DISCARD: {"msg": "Discard %d cards." % Game.cards_to_select, "cmd": "!", "disabled": true},
        state_loop.PLAY_RESOURCES: {"msg": "Play your resources.", "cmd": "Play",},
        state_loop.BUY_CARDS: {"msg": "Buy up to %d cards. Money available: %d." % [Game.buys, Game.money], "cmd": "Done"},
        state_loop.TRASH: {"msg": "Trash up to %d cards." % Game.cards_to_select, "cmd": "Done"},
        state_loop.PLAY_ACTION: {"msg": "Play your action cards.", "cmd": "Done"}
    }
    if hints.has(state):
        $Hint.get_node("Message").bbcode_text = "[center]%s[/center]" % hints[state]["msg"]
        $Hint.get_node("BtnHint").text = hints[state]["cmd"]
        if hints.has("disabled"): $Hint.get_node("BtnHint").disabled = hints[state]["disabled"]
    
    
func hide_hint():
    var tween = create_tween()
    hiding_hint_tween = tween
    tween.tween_property($Hint, "global_position", hint_position - Vector2(500,0), 0.4)
    tween.tween_callback(post_hide_hint)
    

func post_hide_hint():
    $Hint.visible = false
    hiding_hint_tween = null
    $Hint.global_position = hint_position


# SIGNALS AND INPUTS #################

func _on_btn_exit_pressed():
    get_tree().quit()


func _on_btn_restart_pressed():
    get_node("/root/Main/StateLoop").start_game_loop()
    

func on_card_clicked(card):
    print("card clicked: ", card.card_name)
    sm.handle_input(card)
    
    
func on_card_right_clicked(card):
    print("card right-clicked: ", card.card_name)
            

func _on_cheat_action_item_selected(index):
    var options = []
    match index:
        0: options = helpers.get_cards_by_type("Action")
        1: options = helpers.get_cards_by_type("History")
        2: options = [{"name":"PLAY_ACTION"}, {"name": "PLAY_RESOURCES"}]
    var popup = $CheatValue.get_popup()
    popup.clear()
    for option in options:
        popup.add_item(option["name"])


func _on_btn_hint_pressed():
    sm.handle_input(HINT_BTN_PRESSED)


func _on_btn_start_game_pressed():
    sm.handle_input(STARTGAME_BTN_PRESSED)
