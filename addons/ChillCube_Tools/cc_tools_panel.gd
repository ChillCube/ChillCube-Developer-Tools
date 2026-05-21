@tool
extends Control

const Ops = preload("res://addons/ChillCube_Tools/addon_ops.gd")

# ─── Node refs ───────────────────────────────────────────────────────────────

var _addon_list: VBoxContainer
var _installed_log: TextEdit
var _create_name: LineEdit
var _create_desc: LineEdit
var _create_author: LineEdit
var _create_gh: CheckBox
var _create_btn: Button
var _create_log: TextEdit
var _clone_url: LineEdit
var _clone_btn: Button
var _clone_log: TextEdit
var _push_btn: Button
var _push_log: TextEdit

var _http: HTTPRequest
var _registry_list: VBoxContainer
var _registry_status: Label
var _browse_log: TextEdit
var _registry_installed: Dictionary  # url -> folder name

var _thread: Thread = null

# ─── Setup ───────────────────────────────────────────────────────────────────

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_registry_fetched)

	var tabs := TabContainer.new()
	tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tabs)

	_build_browse_tab(tabs)
	_build_addons_tab(tabs)
	_build_create_tab(tabs)
	_build_clone_tab(tabs)
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
	lbl.text = "Installed addons — click 🗑️ to remove an addon and its orphaned dependencies."
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var refresh_btn := Button.new()
	refresh_btn.text = "↺ Refresh"
	refresh_btn.pressed.connect(_refresh_addons)
	header.add_child(lbl)
	header.add_child(refresh_btn)
	root.add_child(header)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_addon_list = VBoxContainer.new()
	_addon_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_addon_list)
	split.add_child(scroll)

	split.add_child(VSeparator.new())

	_installed_log = _side_log()
	split.add_child(_installed_log)
	root.add_child(split)

func _build_create_tab(tabs: TabContainer) -> void:
	var root := _vbox("Create Addon", tabs)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_create_name = _field(grid, "Addon Name")
	_create_desc = _field(grid, "Description")
	_create_author = _field(grid, "Author")
	left.add_child(grid)

	_create_gh = CheckBox.new()
	_create_gh.text = "Create GitHub repo (requires gh CLI)"
	_create_gh.button_pressed = true
	left.add_child(_create_gh)

	_create_btn = Button.new()
	_create_btn.text = "✨ Create Addon"
	_create_btn.pressed.connect(_start_create)
	left.add_child(_create_btn)

	split.add_child(left)
	split.add_child(VSeparator.new())

	_create_log = _side_log()
	split.add_child(_create_log)
	root.add_child(split)

func _build_clone_tab(tabs: TabContainer) -> void:
	var root := _vbox("Clone Addon", tabs)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var lbl := Label.new()
	lbl.text = "Paste a Git URL to clone and install a ChillCube addon:"
	left.add_child(lbl)

	var row := HBoxContainer.new()
	_clone_url = LineEdit.new()
	_clone_url.placeholder_text = "https://github.com/ChillCube/MyAddon.git"
	_clone_url.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clone_btn = Button.new()
	_clone_btn.text = "📥 Clone"
	_clone_btn.pressed.connect(_start_clone)
	row.add_child(_clone_url)
	row.add_child(_clone_btn)
	left.add_child(row)

	split.add_child(left)
	split.add_child(VSeparator.new())

	_clone_log = _side_log()
	split.add_child(_clone_log)
	root.add_child(split)

func _build_push_tab(tabs: TabContainer) -> void:
	var root := _vbox("Push All", tabs)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var info := Label.new()
	info.text = "Scans all addons, generates README + DOCUMENTATION, commits, pushes to GitHub, and updates the ChillCube registry."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(info)

	_push_btn = Button.new()
	_push_btn.text = "🚀 Push All Addons"
	_push_btn.pressed.connect(_start_push)
	left.add_child(_push_btn)

	split.add_child(left)
	split.add_child(VSeparator.new())

	_push_log = _side_log()
	split.add_child(_push_log)
	root.add_child(split)

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

func _side_log() -> TextEdit:
	var te := TextEdit.new()
	te.editable = false
	te.size_flags_vertical = Control.SIZE_EXPAND_FILL
	te.size_flags_horizontal = Control.SIZE_SHRINK_END
	te.custom_minimum_size = Vector2(240, 0)
	te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	return te

# ─── Refresh helpers ─────────────────────────────────────────────────────────

func _refresh_addons() -> void:
	for child in _addon_list.get_children():
		child.queue_free()

	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var addons := Ops.list_addons(root)

	if addons.is_empty():
		var lbl := Label.new()
		lbl.text = "No addons installed yet."
		_addon_list.add_child(lbl)
		return

	var dependents: Dictionary = Ops.get_dependents(root)

	for folder: String in addons:
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_lbl := Label.new()
		name_lbl.text = "📦 %s  v%s" % [cfg.get("name", folder), cfg.get("version", "?")]
		var desc_lbl := Label.new()
		desc_lbl.text = cfg.get("description", "")
		desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		desc_lbl.clip_text = true
		info.add_child(name_lbl)
		info.add_child(desc_lbl)
		row.add_child(info)

		var rm_btn := Button.new()
		rm_btn.text = "🗑️"
		var dependers: Array = dependents.get(folder, [])
		if dependers.is_empty():
			rm_btn.tooltip_text = "Remove " + folder
			var captured_folder := folder
			rm_btn.pressed.connect(func():
				_installed_log.text = ""
				_run_op(rm_btn, _installed_log, func():
					Ops.remove_addon(
						ProjectSettings.globalize_path("res://").rstrip("/"),
						captured_folder,
						func(msg): call_deferred("_append_log", _installed_log, msg)
					)
					call_deferred("_refresh_addons")
				)
			)
		else:
			rm_btn.disabled = true
			rm_btn.tooltip_text = folder + " is required by: " + ", ".join(PackedStringArray(dependers))
		row.add_child(rm_btn)
		_addon_list.add_child(row)

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

# ─── Browse tab ───────────────────────────────────────────────────────────────

func _build_browse_tab(tabs: TabContainer) -> void:
	var root := _vbox("Browse", tabs)

	var toolbar := HBoxContainer.new()
	var title := Label.new()
	title.text = "ChillCube Addon Registry"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_registry_status = Label.new()
	_registry_status.text = "Loading..."
	_registry_status.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	var refresh_btn := Button.new()
	refresh_btn.text = "↺ Refresh"
	refresh_btn.pressed.connect(_fetch_registry)
	toolbar.add_child(title)
	toolbar.add_child(_registry_status)
	toolbar.add_child(refresh_btn)
	root.add_child(toolbar)
	root.add_child(HSeparator.new())

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_registry_list = VBoxContainer.new()
	_registry_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_registry_list)
	split.add_child(scroll)

	split.add_child(VSeparator.new())

	_browse_log = _side_log()
	split.add_child(_browse_log)
	root.add_child(split)

	_fetch_registry()

func _fetch_registry() -> void:
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	_registry_status.text = "Fetching..."
	for child in _registry_list.get_children():
		child.queue_free()
	var err := _http.request(
		"https://raw.githubusercontent.com/ChillCube/.github/main/ADDONS.md"
	)
	if err != OK:
		_registry_status.text = "Request error."

func _on_registry_fetched(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_registry_status.text = "Failed (HTTP %d)" % response_code
		return
	var entries := _parse_registry(body.get_string_from_utf8())
	_build_installed_url_map()
	_populate_registry(entries)
	_registry_status.text = "%d addon(s) listed" % entries.size()

func _parse_registry(content: String) -> Array:
	var result := []
	var category := "Uncategorized"
	var in_tree := false
	for line: String in content.split("\n"):
		if "<!-- DEPENDENCY-TREE-START -->" in line:
			in_tree = true
		if in_tree:
			if "<!-- DEPENDENCY-TREE-END -->" in line:
				in_tree = false
			continue
		if line.begins_with("## "):
			category = line.substr(3).strip_edges()
		elif line.begins_with("* ["):
			var cb := line.find("](")
			if cb == -1:
				continue
			var name := line.substr(3, cb - 3)
			var rest := line.substr(cb + 2)
			var cp := rest.find(")")
			if cp == -1:
				continue
			var url := rest.substr(0, cp)
			var desc := rest.substr(cp + 1).strip_edges().lstrip("-").strip_edges()
			result.append({"category": category, "name": name, "url": url, "desc": desc})
	return result

func _build_installed_url_map() -> void:
	_registry_installed = {}
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	for folder: String in Ops.list_addons(root):
		var url := Ops.git_remote(root + "/addons/" + folder)
		if not url.is_empty():
			_registry_installed[url] = folder

func _populate_registry(entries: Array) -> void:
	for child in _registry_list.get_children():
		child.queue_free()

	var current_cat := ""
	for entry: Dictionary in entries:
		var cat: String = entry.get("category", "Uncategorized")
		if cat != current_cat:
			current_cat = cat
			_registry_list.add_child(HSeparator.new())
			var cat_lbl := Label.new()
			cat_lbl.text = cat
			cat_lbl.add_theme_font_size_override("font_size", 13)
			_registry_list.add_child(cat_lbl)

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_lbl := Label.new()
		name_lbl.text = entry.get("name", "")
		var desc_lbl := Label.new()
		desc_lbl.text = entry.get("desc", "")
		desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		desc_lbl.clip_text = true
		info.add_child(name_lbl)
		info.add_child(desc_lbl)
		row.add_child(info)

		var url: String = entry.get("url", "")
		var installed := url in _registry_installed
		var btn := Button.new()
		btn.text = "↺ Sync" if installed else "⬇ Install"
		btn.tooltip_text = url
		btn.pressed.connect(_install_from_registry.bind(url, btn))
		row.add_child(btn)
		_registry_list.add_child(row)

func _install_from_registry(url: String, btn: Button) -> void:
	_run_op(btn, _browse_log, func():
		var root := ProjectSettings.globalize_path("res://").rstrip("/")
		var log_fn := func(msg: String): call_deferred("_append_log", _browse_log, msg)
		Ops.sync_addon(root, url, log_fn)
		call_deferred("_refresh_addons")
		call_deferred("_build_installed_url_map")
		call_deferred("_fetch_registry")
	)
