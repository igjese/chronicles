class_name CardScene
extends Panel

var card_type: String = ""
var card_name: String = ""
var cost_money: int = 0
var effect_money: int = 0
var effect_army: int = 0
var discard: int = 0
var trash: int = 0
var extra_buys: int = 0
var draw_cards: int = 0
var extra_actions: int
var replace: int = 0
var upgrade_2: int = 0
var double_action: int = 0
var take_4: int = 0
var take_money2: int = 0
var take_5: int = 0
var upgrade_money: int = 0

enum { FACE_UP, FACE_DOWN, SOUND_DEAL, SOUND_DRAW }
var face = FACE_DOWN

func set_face(face):
    $Back.visible = true if face == FACE_DOWN else false        
    self.face = face

func set_card_data(card):
    card_type = card["type"]
    card_name = card["name"]
    cost_money = card["cost_money"]
    effect_money = card["effect_money"]
    effect_army = card["effect_army"]
    discard = card["discard"]
    trash = card["trash"]
    extra_buys = card["extra_buys"]
    draw_cards = card["draw"]
    extra_actions = card["extra_actions"]
    replace = card["replace"]
    upgrade_2 = card["upgrade_2"]
    double_action = card["double_action"]
    take_4 = card["take_4"]
    take_money2 = card["take_money2"]
    take_5 = card["take_5"]
    upgrade_money = card["upgrade_money"]
    
    $Title.bbcode_text = "[center]%s[/center]" % card_name
    $MainVisual.texture = card["visual"]
    
    $Cost.text = str(cost_money)
    if card_type in ["History","Victory1","Victory2","Victory3"]:
        $Cost.visible = false

    
func fly(start_node, end_node, duration, start_delay, callback, sound=SOUND_DEAL):
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_property(self, "global_position", end_node.global_position, duration).from(start_node.global_position).set_ease(Tween.EASE_OUT)
    tween.tween_callback($SoundDeal.play if sound == SOUND_DEAL else $SoundDraw.play)
    tween.tween_callback(callback)


func fly_and_flip(start_node, end_node, duration, start_delay, callback, sound=SOUND_DEAL):
    var new_face = FACE_DOWN if face == FACE_UP else FACE_UP
    fly(start_node, end_node, duration, start_delay, callback, SOUND_DRAW)
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_property(self, "scale", Vector2(0,1.3), duration/2)
    tween.tween_callback(self.set_face.bind(new_face))
    tween.tween_property(self, "scale", Vector2(1,1), duration/2)


func flip_card(duration, start_delay):
    var new_face = FACE_DOWN if face == FACE_UP else FACE_UP
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_callback($SoundFlip.play)
    tween.tween_property(self, "scale", Vector2(1.5, 1.5), duration/4)
    tween.tween_property(self, "scale", Vector2(0, 1.5), duration/4)
    tween.tween_callback(self.set_face.bind(new_face))
    tween.tween_property(self, "scale", Vector2(1.5, 1.5), duration/4)
    tween.tween_property(self, "scale", Vector2(1, 1), duration/4)
    
    
func pulse(duration, callback):
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.5, 1.5), duration * 3/5).set_ease(Tween.EASE_OUT)
    tween.tween_callback($SoundHit.play)
    tween.tween_property(self, "scale", Vector2(1, 1), duration * 2/5).set_ease(Tween.EASE_IN)
    tween.tween_callback(callback)
    
    
func start_glow(glow_color : Color, bg_color : Color = Color.TRANSPARENT):
    get_node("Glow").start_glow(glow_color, bg_color)
    
    
func stop_glow():
    get_node("Glow").visible = false
    
    
func slot():
    return get_parent().get_parent()


func _on_gui_input(event):
    var gui_play = get_tree().root.get_node("Main/GuiPlay")
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                gui_play.on_card_clicked(self)
        if event.button_index == MOUSE_BUTTON_RIGHT:
            if event.pressed:
                gui_play.on_card_right_clicked(self)

