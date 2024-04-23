class_name StateMachine
extends Node

var current_state: State = null

func change_state(new_state: State):
    if current_state: current_state.exit() 
    current_state = new_state 
    current_state.enter()
