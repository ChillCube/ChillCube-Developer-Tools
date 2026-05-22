@tool
extends EditorPlugin

var _panel: Control

func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "CC Tools"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func _make_visible(visible: bool) -> void:
	if is_instance_valid(_panel):
		_panel.visible = visible

func _enter_tree() -> void:
	_panel = preload("res://addons/ChillCube_Tools/cc_tools_panel.gd").new()
	_panel.visible = false
	EditorInterface.get_editor_main_screen().add_child(_panel)
	_make_visible(false)

func _exit_tree() -> void:
	if is_instance_valid(_panel):
		_panel.queue_free()
	_panel = null
