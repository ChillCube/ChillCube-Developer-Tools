@tool
extends EditorPlugin

var _panel: Control
var _terminal_panel: Control
var _chat_dock: Control

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

	_terminal_panel = _panel.build_terminal_panel()
	add_control_to_bottom_panel(_terminal_panel, "Terminal")

	_chat_dock = _panel.build_chat_dock()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _chat_dock)

func _exit_tree() -> void:
	if is_instance_valid(_terminal_panel):
		remove_control_from_bottom_panel(_terminal_panel)
		_terminal_panel.queue_free()
	_terminal_panel = null

	if is_instance_valid(_chat_dock):
		remove_control_from_docks(_chat_dock)
		_chat_dock.queue_free()
	_chat_dock = null

	if is_instance_valid(_panel):
		_panel.queue_free()
	_panel = null
