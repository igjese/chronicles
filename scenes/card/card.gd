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
