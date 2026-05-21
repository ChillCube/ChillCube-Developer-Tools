@tool
extends EditorPlugin

var _panel: Control

func _enter_tree() -> void:
	_panel = preload("res://addons/ChillCube_Tools/cc_tools_panel.gd").new()
	add_control_to_bottom_panel(_panel, "🧊 CC Tools")

func _exit_tree() -> void:
	if is_instance_valid(_panel):
		remove_control_from_bottom_panel(_panel)
		_panel.queue_free()
	_panel = null
