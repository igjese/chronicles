extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
    self.get("theme_override_styles/panel").bg_color = Color.WHITE
    self.get("theme_override_styles/panel").shadow_color = Color.WHITE
    self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var period = 3
    var sine_wave = sin(2 * PI * float(Time.get_ticks_msec()) / 1000 / period)
    self.get("theme_override_styles/panel").shadow_size = 15 + 10 * sine_wave
    self.modulate.a = 0.6 + sine_wave * 0.3


func start_glow(glow_color : Color, bg_color : Color = Color.TRANSPARENT):
    self.get("theme_override_styles/panel").bg_color = bg_color
    self.get("theme_override_styles/panel").shadow_color = glow_color
    self.visible = true
    
