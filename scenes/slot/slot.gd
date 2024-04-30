class_name SlotScene
extends ColorRect

func _ready():
    $qty.visible = false
    self.color.a = 0


func add_card(card_node):
    var old_parent = card_node.get_parent().get_parent() if card_node.get_parent() else null
    print("Card moved: %s from %s to %s" % [card_node.card_name, old_parent.name, self.name])
    card_node.reparent($cards)
    card_node.position = Vector2(0,0)
    update_qty()
    if old_parent and old_parent.has_method("update_qty"):
            old_parent.update_qty() 
            old_parent.stop_glow_if_count()
            
            
func stop_glow_if_count(count=0):
    if get_node("cards").get_child_count() <= count:
        stop_glow()


func update_qty():
    var qty = $cards.get_child_count()
    if qty > 1:
        $qty.text = str(qty)
        $qty.visible = true
    else:
        $qty.visible = false


func top_card():
    if $cards.get_child_count() == 0:
        return null
    return $cards.get_children()[-1]
    
    
func pulse_qty_for_flip(duration, start_delay):
    var tween = create_tween()
    tween.tween_interval(start_delay)
    tween.tween_property($qty, "scale", Vector2(1.5, 1.5), duration/4)
    tween.tween_property($qty, "scale", Vector2(0, 1.5), duration/4)
    tween.tween_property($qty, "scale", Vector2(1.5, 1.5), duration/4)
    tween.tween_property($qty, "scale", Vector2(1, 1), duration/4)
    
    
func pulse_qty(duration):
    var tween = create_tween()
    tween.tween_property($qty, "scale", Vector2(1.5, 1.5), duration * 3/5)
    tween.tween_property($qty, "scale", Vector2(1, 1), duration * 2/5)


func start_glow(glow_color : Color, bg_color : Color = Color.TRANSPARENT):
    get_node("Glow").start_glow(glow_color, bg_color)
    
    
func stop_glow():
    get_node("Glow").visible = false


func card_count():
    return $cards.get_child_count()
    
