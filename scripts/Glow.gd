extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    self.get("theme_override_styles/panel").shadow_size = 15 + 10 * sin(Engine.get_frames_drawn() * 0.15)
    self.modulate.a = 0.6 + sin(Engine.get_frames_drawn() * 0.05) * 0.3
