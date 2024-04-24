extends Node

enum {IDLE, WALK}
var sm:= SM.new({
    IDLE: {SM.PROCESS: _idle_process},
    WALK: {SM.PROCESS: _walk_process, SM.ENTER: _walk_enter, SM.EXIT: _walk_exit
}})
    
func _ready():
    sm.change_state(IDLE)

func _process(delta):
    sm.process(delta)

func _idle_process(delta): print("IDLE PROCESS")
func _walk_enter(): print("WALK ENTER")
func _walk_exit(): print("WALK EXIT")
func _walk_process(delta): print("WALK PROCESS")
