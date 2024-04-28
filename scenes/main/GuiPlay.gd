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

enum {HINT_BTN_PRESSED, STARTGAME_BTN_PRESSED}

func _ready():
    Game.resources_updated.connect(refresh_statusbar)
    Game.statuses_updated.connect(refresh_statusbar)
    $CheatValue.get_popup().index_pressed.connect(apply_cheat)
    hint_position = $Hint.global_position


func refresh_statusbar():
    gui_status.set_text("Turn %d | Money %d - Army %d | Actions %d - Buys %d" % [Game.turn, Game.money, Game.army, Game.actions, Game.buys])
    
    var delay = 0.2
    if Game.money != int(gui_money.text):
        update_resource_display(gui_money, "money", 0.4, delay) 
        delay += 0.3
    if Game.army != int(gui_army.text):
        update_resource_display(gui_army, "army", 0.4, delay) 

        
func update_resource_display(resource_node, resource_name, duration, delay):
    await get_tree().create_timer(delay).timeout
    var tween = create_tween()
    #tween.tween_interval(delay)
    tween.tween_property(resource_node, "scale", Vector2(1.5, 1.5), duration/2).set_ease(Tween.EASE_IN)
    tween.tween_property(resource_node, "scale", Vector2(1, 1), duration/2).set_ease(Tween.EASE_OUT)
    
    await get_tree().create_timer(duration/2).timeout
    resource_node.text = str(Game[resource_name])
    if Game[resource_name] > int(resource_node.text):
        sound_coin.play()
    else:
        sound_punch.play()
        
        
func apply_cheat(index):
    var option_text = $CheatValue.get_popup().get_item_text(index)
    match $CheatAction.get_item_index($CheatAction.get_selected_id()):
        0: # Put action card into Hand1
            helpers.spawn_card(Game.cards_by_name[option_text], get_node("/root/Main/Hand/Hand1/cards"),CardScene.FACE_UP)
        1: # Put history card on Challenge top and run it
            helpers.spawn_card(Game.cards_by_name[option_text], get_node("/root/Main/Challenge/cards"),CardScene.FACE_UP)
            Game.card_stack.clear()
            Game.effect_stack.clear()
            sm.change_state(state_loop.ACTIVATE_CHALLENGE)
        2: # Change to chosen state
            match option_text:
                "PLAY_ACTION": sm.change_state(state_loop.PLAY_ACTION)
                "PLAY_RESOURCES": sm.change_state(state_loop.PLAY_RESOURCES)
                
func show_hint(state):
    var hints = {
        state_loop.DISCARD: {"msg": "Discard %d cards." % Game.cards_to_select, "cmd": "!", "disabled": true},
        state_loop.PLAY_RESOURCES: {"msg": "Play your resources.", "cmd": "Play", "disabled": false},
        state_loop.BUY_CARDS: {"msg": "Buy up to %d cards. Money available: %d." % [Game.buys, Game.money], "cmd": "Done", "disabled": false}
    }
    $Hint.get_node("Message").bbcode_text = "[center]%s[/center]" % hints[state]["msg"]
    $Hint.get_node("BtnHint").text = hints[state]["cmd"]
    $Hint.get_node("BtnHint").disabled = hints[state]["disabled"]
    if hiding_hint_tween: hiding_hint_tween.kill()
    var tween = create_tween()
    tween.tween_property($Hint, "global_position", hint_position, 0.4).from(hint_position - Vector2(500,0))
    $Hint.visible = true
    
    
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
