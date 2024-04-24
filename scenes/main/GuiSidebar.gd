extends Control


func _on_btn_exit_pressed():
    get_tree().quit()


func _on_btn_restart_pressed():
    get_node("/root/Main/StateLoop").start_game_loop()
