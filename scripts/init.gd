extends Node

func init():
    print_scene_tree(get_tree().get_root())


func print_scene_tree(node: Node, indent: int = 0):
    # Generate indentation string
    var indents = "    ".repeat(indent)
    # Print current node's information
    if node is Panel and node.script and node.script.resource_path == "res://card.gd":
        print("%s- %s [Card Scene Instance]" % [indents, node.name])
    else:
        # Print the node normally
        print("%s- %s (%s)" % [indents, node.name, node.get_class()])
        # Recurse for each child
        for child in node.get_children():
            print_scene_tree(child, indent + 1)
