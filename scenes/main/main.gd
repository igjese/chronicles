extends Node2D

func _ready():
    InitMgr.init()
    $StateLoop.start_game_loop($StateLoop.CONTEXT_INTRO)

