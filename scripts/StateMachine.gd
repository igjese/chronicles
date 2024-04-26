class_name SM

enum {ENTER, EXIT, PROCESS}
var states; var current_state

''' Example how to initialize state machine:
enum {IDLE, WALK}
var sm:= SM.new({   IDLE: {SM.PROCESS: _idle_process},
                    WALK: {SM.PROCESS: _walk_process, SM.ENTER: _walk_enter, SM.EXIT: _walk_exit}})
'''
func _init(states_dict):
    states = states_dict

func change_state(new_state):
    print("change state: ", current_state, " --> ", new_state)
    var old_state = current_state
    current_state = states[new_state] if states.has(new_state) else null
    if current_state != old_state:
        if old_state and old_state.has(EXIT): 
            old_state[EXIT].call()
        if current_state and current_state.has(ENTER): 
            current_state[ENTER].call()
    
func process(delta):
    if current_state and current_state.has(PROCESS): 
        current_state[PROCESS].call(delta)



