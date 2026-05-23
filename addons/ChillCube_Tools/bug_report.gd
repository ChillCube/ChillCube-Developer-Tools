## ChillCubeFeedback — call from your game to send user feedback to the editor bug panel.
##
## Usage (anywhere in your game):
##   const Feedback = preload("res://addons/ChillCube_Tools/bug_report.gd")
##   Feedback.report("Player fell through floor", {"scene": get_tree().current_scene.name})
##
## Reports are saved to user://cc_feedback.json and appear in the CC Tools
## Planning → Bugs tab marked with 👤.

extends Object
class_name ChillCubeFeedback

static func report(description: String, context: Dictionary = {}) -> void:
	var path := "user://cc_feedback.json"
	var items: Array = _load(path)
	items.insert(0, {
		"desc": description,
		"timestamp": Time.get_datetime_string_from_system(),
		"context": context
	})
	_save(path, items)

static func _load(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Array else []

static func _save(path: String, items: Array) -> void:
	var fw := FileAccess.open(path, FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(items, "\t") + "\n")
		fw.close()
