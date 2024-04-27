extends Control

@onready var gui_status = get_node("/root/Main/GuiPlay/Status")
@onready var gui_money = get_node("/root/Main/GuiPlay/Money")
@onready var gui_army = get_node("/root/Main/GuiPlay/Army")
@onready var sound_coin = get_node("/root/Main/Sounds/Coin")
@onready var sound_punch = get_node("/root/Main/Sounds/Punch")
@onready var sm = get_node("/root/Main/StateLoop").sm

func _ready():
    Game.resources_updated.connect(refresh_statusbar)
    Game.statuses_updated.connect(refresh_statusbar)


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
        if Game[resource_name] > old_value:
            sound_coin.play()
        elif Game[resource_name] < old_value:
            sound_punch.play()
        resource_node.text = str(Game[resource_name])
        var tween = create_tween()
        tween.tween_property(resource_node, "scale", Vector2(1.5, 1.5), delay/2).set_ease(Tween.EASE_IN)
        tween.tween_property(resource_node, "scale", Vector2(1, 1), delay/2).set_ease(Tween.EASE_OUT)


func on_card_clicked(card):
    print("card clicked: ", card.card_name)
    sm.handle_input(card)
    
    
func on_card_right_clicked(card):
    print("card right-clicked: ", card.card_name)
            
