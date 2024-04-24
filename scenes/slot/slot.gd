class_name SlotScene
extends ColorRect

func _ready():
    $qty.visible = false
    self.color.a = 0

func add_card(node):
    node.reparent($cards)
    update_qty()
    

func update_qty():
    var qty = $cards.get_child_count()
    if qty > 1:
        $qty.text = str(qty)
        $qty.visible = true
    else:
        $qty.visible = false
