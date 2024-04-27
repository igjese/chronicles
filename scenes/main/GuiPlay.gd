extends Control

@onready var gui_status = get_node("/root/Main/GuiPlay/Status")
@onready var gui_money = get_node("/root/Main/GuiPlay/Money")
@onready var gui_army = get_node("/root/Main/GuiPlay/Army")
@onready var sound_coin = get_node("/root/Main/Sounds/Coin")
@onready var sound_punch = get_node("/root/Main/Sounds/Punch")

func _ready():
    Game.resources_updated.connect(refresh_statusbar)
    Game.statuses_updated.connect(refresh_statusbar)


func _on_btn_exit_pressed():
    get_tree().quit()


func _on_btn_restart_pressed():
    get_node("/root/Main/StateLoop").start_game_loop()


func refresh_statusbar():
    gui_status.set_text("Turn %d | Money %d - Army %d | Actions %d - Buys %d" % [Game.turn, Game.money, Game.army, Game.actions, Game.buys])
    
    var old_money = int(gui_money.text)
    var old_army = int(gui_army.text)
    var delay = 0.4
    if Game.money != old_money:
        await get_tree().create_timer(0.2).timeout
        if Game.money > old_money:
            sound_coin.play()
        elif Game.money < old_money:
            sound_punch.play()
        var tween = create_tween()
        tween.tween_property(gui_money, "scale", Vector2(1.5, 1.5), delay/2).set_ease(Tween.EASE_IN)
        tween.tween_callback(func(): gui_money.text = str(Game.money))
        tween.tween_property(gui_money, "scale", Vector2(1, 1), delay/2).set_ease(Tween.EASE_OUT)
    if Game.army != old_army:
        await get_tree().create_timer(0.2).timeout
        if Game.army > old_army:
            sound_coin.play()
        elif Game.army < old_army:
            sound_punch.play()
        var tween = create_tween()
        tween.tween_property(gui_army, "scale", Vector2(1.5, 1.5), delay/2).set_ease(Tween.EASE_IN)
        tween.tween_callback(func(): gui_army.text = str(Game.army))
        tween.tween_property(gui_army, "scale", Vector2(1, 1), delay/2).set_ease(Tween.EASE_OUT)

            
