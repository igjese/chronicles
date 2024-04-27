extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
    self.get("theme_override_styles/panel").bg_color = Color.WHITE
    self.get("theme_override_styles/panel").shadow_color = Color.WHITE
    self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    self.get("theme_override_styles/panel").shadow_size = 15 + 10 * sin(Engine.get_frames_drawn() * 0.15)
    self.modulate.a = 0.6 + sin(Engine.get_frames_drawn() * 0.05) * 0.3


func start_glow(glow_color : Color, bg_color : Color = Color.TRANSPARENT):
    self.get("theme_override_styles/panel").bg_color = bg_color
    self.get("theme_override_styles/panel").shadow_color = glow_color
    self.visible = true
    
