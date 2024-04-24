extends Node2D

func _ready():
    InitMgr.init()
    await $StateMachine.change_state($StateMachine/IntroState)
