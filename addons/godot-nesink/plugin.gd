@tool
extends EditorPlugin

#-------------------------------------------------------------------------------

func _enter_tree() -> void:
	add_autoload_singleton("NesinkronaCanon", "res://addons/godot-nesink/NesinkronaCanon.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("NesinkronaCanon")
