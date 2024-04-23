extends Node

func init():
    print_scene_tree(get_tree().get_root())


func print_scene_tree(node: Node, indent: int = 0):
    var indents = "    ".repeat(indent)
    var node_info = "%s- %s (%s)" % [indents, node.name, node.get_class()]
    
    if node.script:
        node_info += " <-- %s" % node.script.resource_path
    print(node_info)
    
    for child in node.get_children():
        print_scene_tree(child, indent + 1)

