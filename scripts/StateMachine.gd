class_name SM

enum {ENTER, EXIT, PROCESS, INPUT}
var states
var current_state
var current_state_id
var last_printed

''' Example how to initialize state machine:
enum {IDLE, WALK}
var sm:= SM.new({   IDLE: {SM.PROCESS: _idle_process},
                    WALK: {SM.PROCESS: _walk_process, SM.ENTER: _walk_enter, SM.EXIT: _walk_exit}})
'''
func _init(states_dict):
    states = states_dict

func change_state(new_state):
    var old_state = current_state
    current_state = states[new_state] if states.has(new_state) else null
    current_state_id = new_state if states.has(new_state) else -1
    
    if current_state != old_state:
        if old_state and old_state.has(EXIT): 
            print_transition(old_state[EXIT])
            old_state[EXIT].call()
        if current_state and current_state.has(ENTER): 
            print_transition(current_state[ENTER])
            current_state[ENTER].call()
    
    
func process(delta):
    if current_state and current_state.has(PROCESS): 
        if current_state[PROCESS] != last_printed:
            print_transition(current_state[PROCESS])
        current_state[PROCESS].call(delta)
        

func handle_input(data=null):
    if current_state and current_state.has(INPUT):
        print_transition(current_state[INPUT])
        current_state[INPUT].call(data)


func print_transition(msg):
    last_printed = msg
    var cards = ""
    var effects = ""
    if Game.card_stack.size() > 0: 
        var card_stack = []
        for card in Game.card_stack:
            card_stack.append(card.card_name)
        cards = " -- Cards: %s" % str(card_stack)
    if Game.effect_stack.size() > 0: 
        var effect_stack = []
        for effect in Game.effect_stack:
            effect_stack.append(effect.effect_name)
        effects = " -- Effects: %s" % str(effect_stack)
    print(msg, cards, effects)
