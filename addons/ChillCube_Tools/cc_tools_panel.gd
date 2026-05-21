@tool
extends Control

const Ops = preload("res://addons/ChillCube_Tools/addon_ops.gd")

# ─── Node refs ───────────────────────────────────────────────────────────────

var _addon_list: VBoxContainer
var _create_name: LineEdit
var _create_desc: LineEdit
var _create_author: LineEdit
var _create_gh: CheckBox
var _create_btn: Button
var _create_log: TextEdit
var _clone_url: LineEdit
var _clone_btn: Button
var _clone_log: TextEdit
var _remove_option: OptionButton
var _remove_btn: Button
var _remove_log: TextEdit
var _push_btn: Button
var _push_log: TextEdit

var _thread: Thread = null

# ─── Setup ───────────────────────────────────────────────────────────────────

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var tabs := TabContainer.new()
	tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tabs)

	_build_addons_tab(tabs)
	_build_create_tab(tabs)
	_build_clone_tab(tabs)
	_build_remove_tab(tabs)
	_build_push_tab(tabs)

	_refresh_addons()

func _exit_tree() -> void:
	if _thread and _thread.is_started():
		_thread.wait_to_finish()

# ─── Tab builders ─────────────────────────────────────────────────────────────

func _build_addons_tab(tabs: TabContainer) -> void:
	var root := _vbox("Installed Addons", tabs)

	var header := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = "Installed addons in this project:"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var refresh_btn := Button.new()
	refresh_btn.text = "Refresh"
	refresh_btn.pressed.connect(_refresh_addons)
	header.add_child(lbl)
	header.add_child(refresh_btn)
	root.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_addon_list = VBoxContainer.new()
	_addon_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_addon_list)
	root.add_child(scroll)

func _build_create_tab(tabs: TabContainer) -> void:
	var root := _vbox("Create Addon", tabs)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_create_name = _field(grid, "Addon Name")
	_create_desc = _field(grid, "Description")
	_create_author = _field(grid, "Author")
	root.add_child(grid)

	_create_gh = CheckBox.new()
	_create_gh.text = "Create GitHub repo (requires gh CLI)"
	_create_gh.button_pressed = true
	root.add_child(_create_gh)

	_create_btn = Button.new()
	_create_btn.text = "✨ Create Addon"
	_create_btn.pressed.connect(_start_create)
	root.add_child(_create_btn)

	_create_log = _log_box(root)

func _build_clone_tab(tabs: TabContainer) -> void:
	var root := _vbox("Clone Addon", tabs)

	var lbl := Label.new()
	lbl.text = "Paste a Git URL to clone and install a ChillCube addon:"
	root.add_child(lbl)

	var row := HBoxContainer.new()
	_clone_url = LineEdit.new()
	_clone_url.placeholder_text = "https://github.com/ChillCube/MyAddon.git"
	_clone_url.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clone_btn = Button.new()
	_clone_btn.text = "📥 Clone"
	_clone_btn.pressed.connect(_start_clone)
	row.add_child(_clone_url)
	row.add_child(_clone_btn)
	root.add_child(row)

	_clone_log = _log_box(root)

func _build_remove_tab(tabs: TabContainer) -> void:
	var root := _vbox("Remove Addon", tabs)

	var lbl := Label.new()
	lbl.text = "Select an addon to remove. Orphaned dependencies will also be removed."
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(lbl)

	var row := HBoxContainer.new()
	_remove_option = OptionButton.new()
	_remove_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_remove_btn = Button.new()
	_remove_btn.text = "🗑️ Remove"
	_remove_btn.pressed.connect(_start_remove)
	row.add_child(_remove_option)
	row.add_child(_remove_btn)
	root.add_child(row)

	_remove_log = _log_box(root)

func _build_push_tab(tabs: TabContainer) -> void:
	var root := _vbox("Push All", tabs)

	var info := Label.new()
	info.text = "Scans all addons, generates README + DOCUMENTATION, commits, pushes to GitHub, and updates the ChillCube registry."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(info)

	_push_btn = Button.new()
	_push_btn.text = "🚀 Push All Addons"
	_push_btn.pressed.connect(_start_push)
	root.add_child(_push_btn)

	_push_log = _log_box(root)

# ─── UI helpers ───────────────────────────────────────────────────────────────

func _vbox(tab_name: String, parent: TabContainer) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.name = tab_name
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	margin.name = tab_name
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vb)
	parent.add_child(margin)
	return vb

func _field(grid: GridContainer, label: String) -> LineEdit:
	var lbl := Label.new()
	lbl.text = label + ":"
	grid.add_child(lbl)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(edit)
	return edit

func _log_box(parent: VBoxContainer) -> TextEdit:
	var te := TextEdit.new()
	te.editable = false
	te.size_flags_vertical = Control.SIZE_EXPAND_FILL
	te.custom_minimum_size = Vector2(0, 120)
	te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	parent.add_child(te)
	return te

# ─── Refresh helpers ─────────────────────────────────────────────────────────

func _refresh_addons() -> void:
	for child in _addon_list.get_children():
		child.queue_free()

	_remove_option.clear()

	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var addons := Ops.list_addons(root)

	if addons.is_empty():
		var lbl := Label.new()
		lbl.text = "No addons installed yet."
		_addon_list.add_child(lbl)
		return

	for folder: String in addons:
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "📦 %s  v%s  — %s" % [cfg.get("name", folder), cfg.get("version", "?"), cfg.get("description", "")]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.clip_text = true
		row.add_child(lbl)
		_addon_list.add_child(row)
		_remove_option.add_item(folder)

# ─── Operation launchers ─────────────────────────────────────────────────────

func _start_create() -> void:
	var name := _create_name.text.strip_edges()
	if name.is_empty():
		_append_log(_create_log, "❌ Name is required.")
		return
	_run_op(_create_btn, _create_log, func():
		Ops.create_addon(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			name,
			_create_desc.text.strip_edges(),
			_create_author.text.strip_edges(),
			_create_gh.button_pressed,
			func(msg): call_deferred("_append_log", _create_log, msg)
		)
		call_deferred("_refresh_addons")
	)

func _start_clone() -> void:
	var url := _clone_url.text.strip_edges()
	if url.is_empty():
		_append_log(_clone_log, "❌ URL is required.")
		return
	_run_op(_clone_btn, _clone_log, func():
		Ops.clone_addon(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			url,
			func(msg): call_deferred("_append_log", _clone_log, msg)
		)
		call_deferred("_refresh_addons")
	)

func _start_remove() -> void:
	if _remove_option.item_count == 0:
		_append_log(_remove_log, "❌ No addons to remove.")
		return
	var addon_name := _remove_option.get_item_text(_remove_option.selected)
	_run_op(_remove_btn, _remove_log, func():
		Ops.remove_addon(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			addon_name,
			func(msg): call_deferred("_append_log", _remove_log, msg)
		)
		call_deferred("_refresh_addons")
	)

func _start_push() -> void:
	_run_op(_push_btn, _push_log, func():
		Ops.push_all(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			func(msg): call_deferred("_append_log", _push_log, msg)
		)
	)

func _run_op(btn: Button, log: TextEdit, work: Callable) -> void:
	if _thread and _thread.is_started():
		_append_log(log, "⚠️  Another operation is already running.")
		return
	log.text = ""
	btn.disabled = true
	_thread = Thread.new()
	_thread.start(func():
		work.call()
		call_deferred("_finish_op", btn)
	)

func _finish_op(btn: Button) -> void:
	if _thread:
		_thread.wait_to_finish()
	_thread = null
	btn.disabled = false

func _append_log(control: TextEdit, msg: String) -> void:
	control.text += msg + "\n"
	control.scroll_vertical = control.get_line_count()
