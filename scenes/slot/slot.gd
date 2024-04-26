class_name SlotScene
extends ColorRect

func _ready():
    $qty.visible = false
    self.color.a = 0

func add_card(card_node):
    var old_parent = card_node.get_parent().get_parent() if card_node.get_parent() else null
    card_node.reparent($cards)
    update_qty()
    if old_parent and old_parent.has_method("update_qty"):
            old_parent.update_qty() 


    

func update_qty():
    var qty = $cards.get_child_count()
    if qty > 1:
        $qty.text = str(qty)
        $qty.visible = true
    else:
        $qty.visible = false
