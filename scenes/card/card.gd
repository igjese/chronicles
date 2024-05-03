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
var history_text: String = ""

enum { FACE_UP, FACE_DOWN, SOUND_DEAL, SOUND_DRAW, SOUND_HIT, SOUND_SWOOP}
var face = FACE_DOWN

@onready var sounds = {
    SOUND_DEAL: $SoundDeal,
    SOUND_DRAW: $SoundDraw,
    SOUND_HIT: $SoundHit,
    SOUND_SWOOP: $SoundSwoop
}

var helpers = Helpers.new()


func _ready():
    $Effects.visible = false


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
    history_text = card["history_text"]
    
    $Title.bbcode_text = "[center]%s[/center]" % card_name
    $MainVisual.texture = card["visual"]
    
    $Cost.text = str(cost_money)
    if card_type in ["History","Victory1","Victory2","Victory3"]:
        $Cost.visible = false

    $Effects.text = helpers.get_effect_text(self)
    
func fly(start_node, end_node, duration, start_delay, sound, end_position=null):
    if not end_position: 
        end_position = end_node
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_property(self, "global_position", end_position.global_position, duration).from(start_node.global_position).set_ease(Tween.EASE_OUT)
    tween.tween_callback(sounds[sound].play)
    tween.tween_callback(end_node.add_card.bind(self))


func fly_and_flip(start_node, end_node, duration, start_delay, callback, sound):
    var new_face = FACE_DOWN if face == FACE_UP else FACE_UP
    fly(start_node, end_node, duration, start_delay, sound)
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_property(self, "scale", Vector2(0.05,1), duration/2)
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
    
    
func pulse(duration, callback = null, sound=null):
    var tween = create_tween()
    tween.tween_property(self.slot(), "scale", Vector2(1.5, 1.5), duration * 3/5).set_ease(Tween.EASE_OUT)
    if sound == SOUND_HIT: tween.tween_callback($SoundHit.play)
    tween.tween_property(self.slot(), "scale", Vector2(1, 1), duration * 2/5).set_ease(Tween.EASE_IN)
    if callback: tween.tween_callback(callback)
    
    
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


func _on_mouse_entered():
    var state_loop = get_tree().root.get_node("/root/Main/StateLoop")
    if not $Back.visible and state_loop.context == state_loop.CONTEXT_PLAY:
        $Effects.visible = true


func _on_mouse_exited():
    $Effects.visible = false
