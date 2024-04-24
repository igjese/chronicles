class_name CardScene
extends Control

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

enum { FACE_UP, FACE_DOWN }
var face = FACE_DOWN

func set_face(face):
    if face == FACE_DOWN:
        $Back.visible = true
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
    
    var normalized_name = card_name.replace(" ", "_").to_lower()
    var image_path = "res://visuals/cards/" + normalized_name + ".png"
    $MainVisual.texture = load(image_path)
    
    $Cost.text = str(cost_money)
    if card_type in ["History","Victory1","Victory2","Victory3"]:
        $Cost.visible = false
        

    
    
func fly(start_node, end_node, duration, start_delay, callback):
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_property(self, "global_position", end_node.global_position, duration).from(start_node.global_position).set_ease(Tween.EASE_IN_OUT)
    tween.parallel().tween_callback($SoundDeal.play).set_delay(duration - 0.1)
    tween.tween_callback(callback)

