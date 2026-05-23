## Usage anywhere in your game:
##   ChillCubeFeedback.submit("Player fell through floor")
##   ChillCubeFeedback.submit("Crash on level 3", {"scene": get_tree().current_scene.name})
##
## Reports appear in CC Tools → Planning → Bugs, marked 👤.
## Game name is captured automatically from ProjectSettings.

extends Object
class_name ChillCubeFeedback

static func submit(description: String, context: Dictionary = {}) -> void:
	var path := "user://cc_feedback.json"
	var items: Array = _load(path)
	var entry := {
		"desc": description,
		"timestamp": Time.get_datetime_string_from_system(),
		"game": ProjectSettings.get_setting("application/config/name", "Unknown"),
		"context": context
	}
	items.insert(0, entry)
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
