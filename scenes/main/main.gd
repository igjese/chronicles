extends Node2D

func _ready():
    InitMgr.init()
    $StateMachine.change_state($StateMachine/IntroState)
