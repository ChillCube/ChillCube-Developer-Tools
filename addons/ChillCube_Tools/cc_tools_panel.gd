@tool
extends Control

const Ops = preload("res://addons/ChillCube_Tools/addon_ops.gd")

# ─── Node refs ───────────────────────────────────────────────────────────────

var _addon_list: VBoxContainer
var _installed_log: TextEdit
var _create_name: LineEdit
var _create_desc: TextEdit
var _create_author: LineEdit
var _create_category: OptionButton
var _create_gh: CheckBox
var _create_btn: Button
var _create_log: TextEdit
var _clone_url: LineEdit
var _clone_btn: Button
var _push_btn: Button
var _update_plugin_btn: Button

var _dep_addon_list: VBoxContainer
var _dep_details: VBoxContainer
var _dep_selected_folder: String = ""
var _registry_entries: Array = []

var _plan_list: VBoxContainer
var _plan_editor: VBoxContainer
var _plan_selected: int = -1
var _planned_addons: Array = []
var _plan_name_edit: LineEdit
var _plan_class_edit: LineEdit
var _plan_extends_edit: LineEdit
var _plan_desc_edit: TextEdit
var _plan_author_edit: LineEdit
var _plan_cat_edit: OptionButton
var _plan_status_lbl: Label
var _plan_thread: Thread = null

var _bug_list: VBoxContainer
var _bug_items: Array = []
var _bug_editing_idx: int = -1

var _todo_list: VBoxContainer
var _todo_input: LineEdit
var _todo_push_btn: Button
var _todo_status_lbl: Label
var _todo_items: Array = []
var _todo_thread: Thread = null
var _todo_editing_idx: int = -1
var _todo_active_tag: String = ""
var _todo_tag_bar: HBoxContainer

var _term_output: TextEdit
var _term_input: LineEdit
var _term_cwd_label: Label
var _term_run_btn: Button
var _term_cwd: String = ""
var _term_history: Array[String] = []
var _term_hist_idx: int = -1
var _term_thread: Thread = null

var _vault_path_lbl: Label
var _vault_browser: VBoxContainer
var _vault_current_dir: String = ""
var _vault_remote_sel: String = ""
var _vault_local_sel: String = ""
var _vault_local_sel_lbl: Label
var _vault_remote_sel_lbl: Label
var _vault_upload_dest: LineEdit
var _vault_download_dest: LineEdit
var _vault_status_lbl: Label
var _vault_refresh_btn: Button
var _vault_log: TextEdit
var _vault_thread: Thread = null
var _vault_cache: String = ""
var _vault_file_dialog: EditorFileDialog
var _vault_files: Array[String] = []
var _vault_preview_panel: VBoxContainer
var _vault_preview_name_lbl: Label
var _vault_img_rect: TextureRect
var _vault_audio_container: VBoxContainer
var _vault_audio_player: AudioStreamPlayer
var _vault_audio_play_btn: Button
var _vault_text_preview: TextEdit
var _vault_video_container: VBoxContainer
var _vault_video_player: VideoStreamPlayer
var _vault_video_play_btn: Button
var _vault_preview_unsupported: Label
var _vault_preview_loading_lbl: Label
var _vault_preview_thread: Thread = null
var _vault_move_dialog: AcceptDialog
var _vault_move_dest_input: LineEdit
var _vault_newdir_dialog: AcceptDialog
var _vault_newdir_input: LineEdit

var _http: HTTPRequest
var _registry_list: VBoxContainer
var _registry_status: Label
var _browse_log: TextEdit
var _registry_installed: Dictionary  # url -> folder name

var _activity_items: Array = []
var _activity_list: VBoxContainer
var _activity_push_btn: Button
var _activity_status_lbl: Label
var _activity_thread: Thread = null

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

	_build_addons_supertab(tabs)
	_build_planning_tab(tabs)
	_build_vault_tab(tabs)
	_build_terminal_tab(tabs)
	_build_activity_tab(tabs)

	_refresh_addons()
	_vault_connect()
	_load_activity()

func _exit_tree() -> void:
	if _thread and _thread.is_started():
		_thread.wait_to_finish()
	if _term_thread and _term_thread.is_started():
		_term_thread.wait_to_finish()
	if _todo_thread and _todo_thread.is_started():
		_todo_thread.wait_to_finish()
	if _plan_thread and _plan_thread.is_started():
		_plan_thread.wait_to_finish()
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	if _vault_preview_thread and _vault_preview_thread.is_started():
		_vault_preview_thread.wait_to_finish()
	if _activity_thread and _activity_thread.is_started():
		_activity_thread.wait_to_finish()

# ─── Tab builders ─────────────────────────────────────────────────────────────

func _build_addons_supertab(tabs: TabContainer) -> void:
	var outer := _vbox("Addons", tabs)
	var inner_tabs := TabContainer.new()
	inner_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(inner_tabs)
	_build_browse_tab(inner_tabs)
	_build_addons_tab(inner_tabs)
	_build_add_addon_tab(inner_tabs)
	_build_deps_tab(inner_tabs)

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
	_push_btn = Button.new()
	_push_btn.text = "🚀 Push All"
	_push_btn.tooltip_text = "Scans all addons, generates README + DOCUMENTATION, commits, pushes to GitHub, and updates the ChillCube registry."
	_push_btn.pressed.connect(_start_push)
	_update_plugin_btn = Button.new()
	_update_plugin_btn.text = "⬆ Update Plugin"
	_update_plugin_btn.tooltip_text = "Pull the latest version of ChillCube Tools from GitHub."
	_update_plugin_btn.pressed.connect(_start_update_plugin)
	header.add_child(lbl)
	header.add_child(refresh_btn)
	header.add_child(_push_btn)
	header.add_child(_update_plugin_btn)
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

func _build_add_addon_tab(tabs: TabContainer) -> void:
	var root := _vbox("Add Addon", tabs)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# ── Create section ──
	var create_heading := Label.new()
	create_heading.text = "✨ Create New Addon"
	create_heading.add_theme_font_size_override("font_size", 14)
	left.add_child(create_heading)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_create_name = _field(grid, "Addon Name")
	_create_author = _field(grid, "Author")
	var cat_lbl := Label.new()
	cat_lbl.text = "Category:"
	grid.add_child(cat_lbl)
	_create_category = OptionButton.new()
	_create_category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_create_category.add_item("Loading…")
	grid.add_child(_create_category)
	left.add_child(grid)

	var desc_lbl2 := Label.new()
	desc_lbl2.text = "Description:"
	left.add_child(desc_lbl2)
	_create_desc = TextEdit.new()
	_create_desc.placeholder_text = "What does this addon do?"
	_create_desc.custom_minimum_size = Vector2(0, 70)
	_create_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_create_desc.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	left.add_child(_create_desc)

	_create_gh = CheckBox.new()
	_create_gh.text = "Create GitHub repo (requires gh CLI)"
	_create_gh.button_pressed = true
	left.add_child(_create_gh)

	_create_btn = Button.new()
	_create_btn.text = "✨ Create Addon"
	_create_btn.pressed.connect(_start_create)
	left.add_child(_create_btn)

	# ── Separator ──
	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 6)
	left.add_child(spacer_top)
	left.add_child(HSeparator.new())
	var spacer_bot := Control.new()
	spacer_bot.custom_minimum_size = Vector2(0, 6)
	left.add_child(spacer_bot)

	# ── Clone section ──
	var clone_heading := Label.new()
	clone_heading.text = "📥 Clone Existing Addon"
	clone_heading.add_theme_font_size_override("font_size", 14)
	left.add_child(clone_heading)

	var clone_lbl := Label.new()
	clone_lbl.text = "Paste a Git URL to clone and install a ChillCube addon:"
	clone_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	left.add_child(clone_lbl)

	var clone_row := HBoxContainer.new()
	_clone_url = LineEdit.new()
	_clone_url.placeholder_text = "https://github.com/ChillCube/MyAddon.git"
	_clone_url.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clone_btn = Button.new()
	_clone_btn.text = "📥 Clone"
	_clone_btn.pressed.connect(_start_clone)
	clone_row.add_child(_clone_url)
	clone_row.add_child(_clone_btn)
	left.add_child(clone_row)

	split.add_child(left)
	split.add_child(VSeparator.new())

	_create_log = _side_log()
	split.add_child(_create_log)
	root.add_child(split)

func _build_deps_tab(tabs: TabContainer) -> void:
	var root := _vbox("Dependencies", tabs)

	var toolbar := HBoxContainer.new()
	var refresh_btn := Button.new()
	refresh_btn.text = "↺ Refresh"
	refresh_btn.pressed.connect(_refresh_dep_list)
	toolbar.add_child(refresh_btn)
	root.add_child(toolbar)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left_scroll := ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(180, 0)
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dep_addon_list = VBoxContainer.new()
	_dep_addon_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.add_child(_dep_addon_list)
	split.add_child(left_scroll)

	split.add_child(VSeparator.new())

	var right_scroll := ScrollContainer.new()
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dep_details = VBoxContainer.new()
	_dep_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.add_child(_dep_details)
	split.add_child(right_scroll)

	root.add_child(split)

	_refresh_dep_list()

# ─── Dependency list logic ────────────────────────────────────────────────────

func _refresh_dep_list() -> void:
	for child in _dep_addon_list.get_children():
		child.queue_free()

	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var folders := Ops.list_addons(root)

	if folders.is_empty():
		var lbl := Label.new()
		lbl.text = "No addons installed."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_dep_addon_list.add_child(lbl)
		_dep_selected_folder = ""
		_refresh_dep_details()
		return

	if _dep_selected_folder not in folders:
		_dep_selected_folder = folders[0]

	for folder: String in folders:
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		var btn := Button.new()
		btn.text = cfg.get("name", folder)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		if folder == _dep_selected_folder:
			btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		var cap := folder
		btn.pressed.connect(func():
			_dep_selected_folder = cap
			_refresh_dep_list()
		)
		_dep_addon_list.add_child(btn)

	_refresh_dep_details()

func _refresh_dep_details() -> void:
	for child in _dep_details.get_children():
		child.queue_free()

	if _dep_selected_folder.is_empty():
		var hint := Label.new()
		hint.text = "Select an addon on the left."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_dep_details.add_child(hint)
		return

	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var folder := _dep_selected_folder
	var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")

	var title_lbl := Label.new()
	title_lbl.text = cfg.get("name", folder)
	title_lbl.add_theme_font_size_override("font_size", 14)
	_dep_details.add_child(title_lbl)
	_dep_details.add_child(HSeparator.new())

	var dep_heading := Label.new()
	dep_heading.text = "Dependencies:"
	_dep_details.add_child(dep_heading)

	var deps := Ops.read_dep_urls(root + "/addons/" + folder)
	if deps.is_empty():
		var none_lbl := Label.new()
		none_lbl.text = "(none)"
		none_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_dep_details.add_child(none_lbl)
	else:
		for dep_url: String in deps:
			var row := HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var dep_lbl := Label.new()
			dep_lbl.text = _url_to_display_name(dep_url)
			dep_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			dep_lbl.tooltip_text = dep_url
			var rm_btn := Button.new()
			rm_btn.text = "✕"
			var cap_url := dep_url
			rm_btn.pressed.connect(func():
				Ops.remove_dep(root + "/addons/" + folder, cap_url)
				_refresh_dep_details()
			)
			row.add_child(dep_lbl)
			row.add_child(rm_btn)
			_dep_details.add_child(row)

	_dep_details.add_child(HSeparator.new())

	var add_lbl := Label.new()
	add_lbl.text = "Add dependency:"
	_dep_details.add_child(add_lbl)

	_dep_search_widget(_dep_details, _build_dep_candidates(folder, deps), func(url: String):
		Ops.add_dep(root + "/addons/" + folder, url)
		_refresh_dep_details()
	)

func _build_dep_candidates(current_folder: String, current_deps: Array) -> Array:
	var result := []
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var installed_urls: Array[String] = []
	for folder: String in Ops.list_addons(root):
		var u := Ops.git_remote(root + "/addons/" + folder)
		if not u.is_empty():
			installed_urls.append(u)
	for folder: String in Ops.list_addons(root):
		if not current_folder.is_empty() and folder == current_folder:
			continue
		var url := Ops.git_remote(root + "/addons/" + folder)
		if url.is_empty() or url in current_deps:
			continue
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		var n: String = cfg.get("name", folder)
		result.append({"name": n.to_lower(), "label": "📦 " + n, "url": url})
	var self_url := ""
	if not current_folder.is_empty():
		self_url = Ops.git_remote(root + "/addons/" + current_folder)
	for entry: Dictionary in _registry_entries:
		var raw: String = entry.get("url", "")
		var clean := raw.replace(".git", "").replace("git@github.com:", "https://github.com/")
		if clean.is_empty() or clean == self_url or clean in current_deps or clean in installed_urls:
			continue
		var n: String = entry.get("name", clean.get_file())
		result.append({"name": n.to_lower(), "label": "🌐 " + n, "url": clean})
	return result

func _dep_search_widget(parent: VBoxContainer, candidates: Array, on_add: Callable) -> void:
	var search := LineEdit.new()
	search.placeholder_text = "Search to add…"
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(search)
	var results := VBoxContainer.new()
	results.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(results)
	var populate := func(query: String):
		for child in results.get_children():
			child.queue_free()
		var q := query.to_lower().strip_edges()
		var count := 0
		for c: Dictionary in candidates:
			if not q.is_empty() and not (c.get("name","") as String).contains(q):
				continue
			var btn := Button.new()
			btn.text = c.get("label", "")
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			var cap_url: String = c.get("url", "")
			btn.pressed.connect(func(): on_add.call(cap_url))
			results.add_child(btn)
			count += 1
			if count >= 7:
				var more := Label.new()
				more.text = "… type to filter"
				more.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
				results.add_child(more)
				break
		if count == 0 and not q.is_empty():
			var none := Label.new()
			none.text = "(no matches)"
			none.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
			results.add_child(none)
	search.text_changed.connect(populate)
	populate.call("")

func _url_to_display_name(url: String) -> String:
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	for folder: String in Ops.list_addons(root):
		if Ops.git_remote(root + "/addons/" + folder) == url:
			return Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg").get("name", folder)
	for entry: Dictionary in _registry_entries:
		var raw: String = entry.get("url", "")
		var clean := raw.replace(".git", "").replace("git@github.com:", "https://github.com/")
		if clean == url:
			return entry.get("name", url.get_file())
	return url.get_file()

func _build_planning_tab(tabs: TabContainer) -> void:
	var outer := _vbox("Planning", tabs)
	var inner_tabs := TabContainer.new()
	inner_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(inner_tabs)
	_build_planned_subtab(inner_tabs)
	_build_bugs_subtab(inner_tabs)
	_build_todo_subtab(inner_tabs)

func _build_planned_subtab(tabs: TabContainer) -> void:
	var root := _vbox("Addons", tabs)

	var toolbar := HBoxContainer.new()
	var new_btn := Button.new()
	new_btn.text = "➕ New"
	new_btn.pressed.connect(_plan_new)
	var push_btn := Button.new()
	push_btn.text = "⬆ Push"
	push_btn.tooltip_text = "Commit and push PLANNED_ADDONS.json to the project's GitHub repo."
	push_btn.pressed.connect(_plan_push)
	_plan_status_lbl = Label.new()
	_plan_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_plan_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(new_btn)
	toolbar.add_child(push_btn)
	toolbar.add_child(_plan_status_lbl)
	root.add_child(toolbar)

	var legend := Label.new()
	legend.text = "🚀 Create Repo   ✅ Mark Done   🗑 Delete"
	legend.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	legend.add_theme_font_size_override("font_size", 11)
	root.add_child(legend)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left_scroll := ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(210, 0)
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_plan_list = VBoxContainer.new()
	_plan_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.add_child(_plan_list)
	split.add_child(left_scroll)

	split.add_child(VSeparator.new())

	var right_scroll := ScrollContainer.new()
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_plan_editor = VBoxContainer.new()
	_plan_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.add_child(_plan_editor)
	split.add_child(right_scroll)

	root.add_child(split)

	_load_planned()
	_refresh_plan_list()

# ─── Planned addons logic ─────────────────────────────────────────────────────

func _plan_file() -> String:
	return ProjectSettings.globalize_path("res://").rstrip("/") + "/PLANNED_ADDONS.json"

func _load_planned() -> void:
	_planned_addons = []
	var path := _plan_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var parsed := JSON.parse_string(f.get_as_text())
		f.close()
		if parsed is Array:
			_planned_addons = parsed

func _save_planned() -> void:
	var fw := FileAccess.open(_plan_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_planned_addons, "\t"))
		fw.close()

func _get_in_dev_folders() -> Array[String]:
	var result: Array[String] = []
	for pa: Dictionary in _planned_addons:
		if pa.get("created", false):
			result.append((pa.get("name", "") as String).replace(" ", "_"))
	return result

func _plan_new() -> void:
	_planned_addons.append({
		"name": "NewAddon", "desc": "", "author": "", "category": "Uncategorized",
		"class_name": "", "extends": "Node",
		"deps": [], "exports": [], "funcs": [], "created": false
	})
	_plan_selected = _planned_addons.size() - 1
	_save_planned()
	_refresh_plan_list()

func _plan_push() -> void:
	if _plan_thread and _plan_thread.is_started():
		return
	_plan_status_lbl.text = "Pushing…"
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	_plan_thread = Thread.new()
	_plan_thread.start(func():
		OS.execute("git", PackedStringArray(["-C", root, "add", "PLANNED_ADDONS.json"]), [], true)
		OS.execute("git", PackedStringArray(["-C", root, "commit", "-m", "plan: update planned addons"]), [], true)
		var push_out := []
		var push_code := OS.execute("git", PackedStringArray(["-C", root, "push", "origin", "main"]), push_out, true)
		var msg := "✅ Pushed!" if push_code == OK else "❌ Push failed (no network?)"
		call_deferred("_plan_on_pushed", msg)
	)

func _plan_on_pushed(msg: String = "✅ Pushed!") -> void:
	if _plan_thread and _plan_thread.is_started():
		_plan_thread.wait_to_finish()
	_plan_thread = null
	_plan_status_lbl.text = msg
	get_tree().create_timer(2.5).timeout.connect(func():
		if is_instance_valid(_plan_status_lbl): _plan_status_lbl.text = ""
	)

func _plan_create_repo(idx: int) -> void:
	if _thread and _thread.is_started():
		_plan_status_lbl.text = "⚠ Another operation is running."
		return
	var pa: Dictionary = _planned_addons[idx]
	var name: String = (pa.get("name", "") as String).strip_edges()
	if name.is_empty():
		return
	_plan_status_lbl.text = "Creating repo…"
	var cap_idx := idx
	_thread = Thread.new()
	_thread.start(func():
		var root := ProjectSettings.globalize_path("res://").rstrip("/")
		Ops.create_addon(root, name, pa.get("desc", ""), pa.get("author", ""),
			pa.get("category", "Uncategorized"), true, func(_msg): pass)
		call_deferred("_plan_on_created", cap_idx)
	)

func _plan_on_created(idx: int) -> void:
	if _thread and _thread.is_started():
		_thread.wait_to_finish()
	_thread = null
	if idx < _planned_addons.size():
		_planned_addons[idx]["created"] = true
		_save_planned()
		var pa: Dictionary = _planned_addons[idx]
		var addon_name: String = (pa.get("name","") as String).strip_edges().replace(" ","_")
		var root := ProjectSettings.globalize_path("res://").rstrip("/")
		var script_path := root + "/addons/" + addon_name + "/" + addon_name.to_lower() + ".gd"
		var fw := FileAccess.open(script_path, FileAccess.WRITE)
		if fw:
			fw.store_string(_plan_generate_script(pa))
			fw.close()
	_refresh_plan_list()
	_refresh_addons()
	EditorInterface.get_resource_filesystem().scan()
	_plan_status_lbl.text = "✅ Repo created!"
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(_plan_status_lbl): _plan_status_lbl.text = ""
	)

func _plan_declare_finished(idx: int) -> void:
	_planned_addons.remove_at(idx)
	_save_planned()
	_plan_selected = clampi(_plan_selected, 0, max(0, _planned_addons.size() - 1))
	if _planned_addons.is_empty():
		_plan_selected = -1
	_refresh_plan_list()
	_refresh_addons()

func _plan_save_basic() -> void:
	if _plan_selected < 0 or _plan_selected >= _planned_addons.size():
		return
	_planned_addons[_plan_selected]["name"] = _plan_name_edit.text.strip_edges()
	_planned_addons[_plan_selected]["author"] = _plan_author_edit.text.strip_edges()
	_planned_addons[_plan_selected]["class_name"] = _plan_class_edit.text.strip_edges()
	_planned_addons[_plan_selected]["extends"] = _plan_extends_edit.text.strip_edges() if not _plan_extends_edit.text.strip_edges().is_empty() else "Node"
	_planned_addons[_plan_selected]["desc"] = _plan_desc_edit.text.strip_edges()
	if is_instance_valid(_plan_cat_edit) and _plan_cat_edit.selected >= 0:
		_planned_addons[_plan_selected]["category"] = _plan_cat_edit.get_item_text(_plan_cat_edit.selected)
	_save_planned()
	_refresh_plan_list()

func _plan_generate_script(pa: Dictionary) -> String:
	var lines: PackedStringArray = []
	var cname: String = pa.get("class_name", "")
	var ext: String = pa.get("extends", "Node")
	var desc: String = pa.get("desc", "")
	if not cname.is_empty():
		lines.append("class_name " + cname)
	lines.append("extends " + (ext if not ext.is_empty() else "Node"))
	lines.append("")
	if not desc.is_empty():
		for line in desc.split("\n"):
			lines.append("## " + line)
		lines.append("")
	var exports: Array = pa.get("exports", [])
	for ev: Dictionary in exports:
		var d: String = ev.get("desc", "")
		if not d.is_empty():
			for dl in d.split("\n"):
				lines.append("## " + dl)
		lines.append("@export var %s: %s = %s" % [ev.get("name","var_name"), ev.get("type","Variant"), ev.get("default","null")])
	if not exports.is_empty():
		lines.append("")
	for fn: Dictionary in pa.get("funcs", []):
		var d: String = fn.get("desc", "")
		if not d.is_empty():
			for dl in d.split("\n"):
				lines.append("## " + dl)
		var ret: String = fn.get("return_type", "void")
		var sig := "func %s(%s)" % [fn.get("name","_fn"), fn.get("params","")]
		lines.append((sig + " -> " + ret + ":") if ret != "void" else (sig + ":"))
		lines.append("\tpass")
		lines.append("")
	return "\n".join(lines)

func _refresh_plan_list() -> void:
	for child in _plan_list.get_children():
		child.queue_free()

	if _planned_addons.is_empty():
		var lbl := Label.new()
		lbl.text = "No planned addons yet.\nClick ➕ to start planning one."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_plan_list.add_child(lbl)
		_plan_selected = -1
		_refresh_plan_editor()
		return

	_plan_selected = clampi(_plan_selected, 0, _planned_addons.size() - 1)

	for i in range(_planned_addons.size()):
		var pa: Dictionary = _planned_addons[i]
		var item := VBoxContainer.new()
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_btn := Button.new()
		name_btn.text = ("🔨 " if pa.get("created", false) else "📋 ") + pa.get("name", "Unnamed")
		name_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_btn.flat = true
		if i == _plan_selected:
			name_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		var cap_i := i
		name_btn.pressed.connect(func():
			_plan_selected = cap_i
			_refresh_plan_list()
		)
		item.add_child(name_btn)

		var actions := HBoxContainer.new()
		var create_btn := Button.new()
		create_btn.text = "🚀"
		create_btn.disabled = pa.get("created", false)
		create_btn.tooltip_text = "Create Repo — initialize git repo and addon files" if not pa.get("created", false) else "Already created"
		create_btn.pressed.connect(func(): _plan_create_repo(cap_i))
		actions.add_child(create_btn)

		var finish_btn := Button.new()
		finish_btn.text = "✅"
		finish_btn.tooltip_text = "Mark Done — addon moves to Installed Addons"
		finish_btn.pressed.connect(func(): _plan_declare_finished(cap_i))
		actions.add_child(finish_btn)

		var del_btn := Button.new()
		del_btn.text = "🗑"
		del_btn.tooltip_text = "Delete this planned addon entry"
		del_btn.pressed.connect(func():
			_planned_addons.remove_at(cap_i)
			_save_planned()
			_plan_selected = clampi(_plan_selected, 0, max(0, _planned_addons.size() - 1))
			if _planned_addons.is_empty(): _plan_selected = -1
			_refresh_plan_list()
		)
		actions.add_child(del_btn)
		item.add_child(actions)

		item.add_child(HSeparator.new())
		_plan_list.add_child(item)

	_refresh_plan_editor()

func _refresh_plan_editor() -> void:
	for child in _plan_editor.get_children():
		child.queue_free()

	if _plan_selected < 0 or _plan_selected >= _planned_addons.size():
		var hint := Label.new()
		hint.text = "Select a planned addon on the left to edit it."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_plan_editor.add_child(hint)
		return

	var pa: Dictionary = _planned_addons[_plan_selected]

	# ── Basic info ──
	var basic_hdr := Label.new()
	basic_hdr.text = "Basic Info"
	basic_hdr.add_theme_font_size_override("font_size", 13)
	_plan_editor.add_child(basic_hdr)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_plan_name_edit = _field(grid, "Name")
	_plan_name_edit.text = pa.get("name", "")
	_plan_author_edit = _field(grid, "Author")
	_plan_author_edit.text = pa.get("author", "")
	_plan_class_edit = _field(grid, "Class name")
	_plan_class_edit.text = pa.get("class_name", "")
	_plan_class_edit.placeholder_text = "(optional)"
	_plan_extends_edit = _field(grid, "Extends")
	_plan_extends_edit.text = pa.get("extends", "Node")

	var cat_lbl := Label.new()
	cat_lbl.text = "Category:"
	grid.add_child(cat_lbl)
	_plan_cat_edit = OptionButton.new()
	_plan_cat_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var seen_cats: Array[String] = []
	for entry: Dictionary in _registry_entries:
		var cat: String = entry.get("category", "")
		if not cat.is_empty() and cat not in seen_cats:
			seen_cats.append(cat)
			_plan_cat_edit.add_item(cat)
	if _plan_cat_edit.item_count == 0:
		_plan_cat_edit.add_item("Uncategorized")
	var cur_cat: String = pa.get("category", "")
	for i in range(_plan_cat_edit.item_count):
		if _plan_cat_edit.get_item_text(i) == cur_cat:
			_plan_cat_edit.selected = i
			break
	grid.add_child(_plan_cat_edit)
	_plan_editor.add_child(grid)

	var desc_lbl := Label.new()
	desc_lbl.text = "Description:"
	_plan_editor.add_child(desc_lbl)
	_plan_desc_edit = TextEdit.new()
	_plan_desc_edit.text = pa.get("desc", "")
	_plan_desc_edit.placeholder_text = "What does this addon do?"
	_plan_desc_edit.custom_minimum_size = Vector2(0, 80)
	_plan_desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_plan_desc_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_plan_editor.add_child(_plan_desc_edit)

	var save_btn := Button.new()
	save_btn.text = "💾 Save Basic Info"
	save_btn.pressed.connect(_plan_save_basic)
	_plan_editor.add_child(save_btn)

	_plan_editor.add_child(HSeparator.new())

	# ── Dependencies ──
	var dep_hdr := Label.new()
	dep_hdr.text = "Dependencies"
	dep_hdr.add_theme_font_size_override("font_size", 13)
	_plan_editor.add_child(dep_hdr)

	var deps: Array = pa.get("deps", [])
	if deps.is_empty():
		var none_lbl := Label.new()
		none_lbl.text = "(none)"
		none_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_plan_editor.add_child(none_lbl)
	for dep_url: String in deps:
		var row := HBoxContainer.new()
		var dl := Label.new()
		dl.text = _url_to_display_name(dep_url)
		dl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dl.tooltip_text = dep_url
		var rm := Button.new()
		rm.text = "✕"
		var cap_url := dep_url
		rm.pressed.connect(func():
			(_planned_addons[_plan_selected]["deps"] as Array).erase(cap_url)
			_save_planned()
			_refresh_plan_editor()
		)
		row.add_child(dl)
		row.add_child(rm)
		_plan_editor.add_child(row)

	_dep_search_widget(_plan_editor, _build_dep_candidates("", deps), func(url: String):
		(_planned_addons[_plan_selected]["deps"] as Array).append(url)
		_save_planned()
		_refresh_plan_editor()
	)

	_plan_editor.add_child(HSeparator.new())

	# ── Export variables ──
	var ev_hdr := Label.new()
	ev_hdr.text = "Export Variables"
	ev_hdr.add_theme_font_size_override("font_size", 13)
	_plan_editor.add_child(ev_hdr)

	var exports: Array = pa.get("exports", [])
	for i in range(exports.size()):
		var ev: Dictionary = exports[i]
		var row := HBoxContainer.new()
		var ev_lbl := Label.new()
		ev_lbl.text = "@export var %s: %s = %s  # %s" % [ev.get("name","?"), ev.get("type","Variant"), ev.get("default","-"), ev.get("desc","")]
		ev_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ev_lbl.clip_text = true
		ev_lbl.tooltip_text = ev_lbl.text
		var rm := Button.new()
		rm.text = "✕"
		var cap_i := i
		rm.pressed.connect(func():
			(_planned_addons[_plan_selected]["exports"] as Array).remove_at(cap_i)
			_save_planned()
			_refresh_plan_editor()
		)
		row.add_child(ev_lbl)
		row.add_child(rm)
		_plan_editor.add_child(row)

	var ev_top := HBoxContainer.new()
	var ev_name := LineEdit.new()
	ev_name.placeholder_text = "name"
	ev_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ev_type := LineEdit.new()
	ev_type.placeholder_text = "type"
	ev_type.text = "float"
	ev_type.custom_minimum_size = Vector2(70, 0)
	var ev_def := LineEdit.new()
	ev_def.placeholder_text = "default"
	ev_def.custom_minimum_size = Vector2(70, 0)
	for c in [ev_name, ev_type, ev_def]:
		ev_top.add_child(c)
	_plan_editor.add_child(ev_top)
	var ev_desc := TextEdit.new()
	ev_desc.placeholder_text = "Variable description (becomes a ## comment)"
	ev_desc.custom_minimum_size = Vector2(0, 50)
	ev_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ev_desc.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_plan_editor.add_child(ev_desc)
	var ev_add := Button.new()
	ev_add.text = "➕ Add Variable"
	ev_add.pressed.connect(func():
		var n := ev_name.text.strip_edges()
		if n.is_empty(): return
		if not _planned_addons[_plan_selected].has("exports"):
			_planned_addons[_plan_selected]["exports"] = []
		(_planned_addons[_plan_selected]["exports"] as Array).append({
			"name": n,
			"type": ev_type.text.strip_edges() if not ev_type.text.strip_edges().is_empty() else "Variant",
			"default": ev_def.text.strip_edges() if not ev_def.text.strip_edges().is_empty() else "null",
			"desc": ev_desc.text.strip_edges()
		})
		_save_planned()
		_refresh_plan_editor()
	)
	_plan_editor.add_child(ev_add)

	_plan_editor.add_child(HSeparator.new())

	# ── Functions ──
	var fn_hdr := Label.new()
	fn_hdr.text = "Functions"
	fn_hdr.add_theme_font_size_override("font_size", 13)
	_plan_editor.add_child(fn_hdr)

	var funcs: Array = pa.get("funcs", [])
	for i in range(funcs.size()):
		var fn: Dictionary = funcs[i]
		var row := HBoxContainer.new()
		var fn_lbl := Label.new()
		fn_lbl.text = "func %s(%s) → %s  # %s" % [fn.get("name","?"), fn.get("params",""), fn.get("return_type","void"), fn.get("desc","")]
		fn_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fn_lbl.clip_text = true
		fn_lbl.tooltip_text = fn_lbl.text
		var rm := Button.new()
		rm.text = "✕"
		var cap_i := i
		rm.pressed.connect(func():
			(_planned_addons[_plan_selected]["funcs"] as Array).remove_at(cap_i)
			_save_planned()
			_refresh_plan_editor()
		)
		row.add_child(fn_lbl)
		row.add_child(rm)
		_plan_editor.add_child(row)

	var fn_top := HBoxContainer.new()
	var fn_name := LineEdit.new()
	fn_name.placeholder_text = "name"
	fn_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var fn_params := LineEdit.new()
	fn_params.placeholder_text = "params"
	fn_params.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var fn_ret := LineEdit.new()
	fn_ret.placeholder_text = "return"
	fn_ret.text = "void"
	fn_ret.custom_minimum_size = Vector2(60, 0)
	for c in [fn_name, fn_params, fn_ret]:
		fn_top.add_child(c)
	_plan_editor.add_child(fn_top)
	var fn_desc := TextEdit.new()
	fn_desc.placeholder_text = "Function description (becomes a ## comment)"
	fn_desc.custom_minimum_size = Vector2(0, 50)
	fn_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fn_desc.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_plan_editor.add_child(fn_desc)
	var fn_add := Button.new()
	fn_add.text = "➕ Add Function"
	fn_add.pressed.connect(func():
		var n := fn_name.text.strip_edges()
		if n.is_empty(): return
		if not _planned_addons[_plan_selected].has("funcs"):
			_planned_addons[_plan_selected]["funcs"] = []
		(_planned_addons[_plan_selected]["funcs"] as Array).append({
			"name": n,
			"params": fn_params.text.strip_edges(),
			"return_type": fn_ret.text.strip_edges() if not fn_ret.text.strip_edges().is_empty() else "void",
			"desc": fn_desc.text.strip_edges()
		})
		_save_planned()
		_refresh_plan_editor()
	)
	_plan_editor.add_child(fn_add)

func _build_bugs_subtab(tabs: TabContainer) -> void:
	var root := _vbox("Bugs", tabs)

	var toolbar := HBoxContainer.new()
	var title := Label.new()
	title.text = "Add  #bug <description>  at the end of any line in a .gd file to track it here."
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	var refresh_btn := Button.new()
	refresh_btn.text = "↺ Refresh"
	refresh_btn.pressed.connect(_refresh_bugs)
	toolbar.add_child(title)
	toolbar.add_child(refresh_btn)
	root.add_child(toolbar)
	root.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bug_list = VBoxContainer.new()
	_bug_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_bug_list)
	root.add_child(scroll)

	_refresh_bugs()

func _build_todo_subtab(tabs: TabContainer) -> void:
	var root := _vbox("To-Do", tabs)

	var toolbar := HBoxContainer.new()
	_todo_input = LineEdit.new()
	_todo_input.placeholder_text = "New to-do item…"
	_todo_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_todo_input.text_submitted.connect(func(_t): _todo_add())
	var add_btn := Button.new()
	add_btn.text = "➕ Add"
	add_btn.pressed.connect(_todo_add)
	_todo_push_btn = Button.new()
	_todo_push_btn.text = "⬆ Push"
	_todo_push_btn.tooltip_text = "Commit and push TODO.md to the project's GitHub repo."
	_todo_push_btn.pressed.connect(_todo_push)
	_todo_status_lbl = Label.new()
	_todo_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(_todo_input)
	toolbar.add_child(add_btn)
	toolbar.add_child(_todo_push_btn)
	toolbar.add_child(_todo_status_lbl)
	root.add_child(toolbar)
	root.add_child(HSeparator.new())

	_todo_tag_bar = HBoxContainer.new()
	_todo_tag_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_todo_tag_bar)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_todo_list = VBoxContainer.new()
	_todo_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_todo_list)
	root.add_child(scroll)

	_load_todo()
	_refresh_todo()

# ─── Bug tracker logic ────────────────────────────────────────────────────────

func _refresh_bugs() -> void:
	for child in _bug_list.get_children():
		child.queue_free()

	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var plugin_dir := ProjectSettings.globalize_path(get_script().resource_path.get_base_dir())
	_bug_items = _scan_bugs(project_root, plugin_dir)

	if _bug_items.is_empty():
		var lbl := Label.new()
		lbl.text = "No bugs found."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_bug_list.add_child(lbl)
		return

	for i in range(_bug_items.size()):
		var bug: Dictionary = _bug_items[i]
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var check := CheckBox.new()
		row.add_child(check)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var cap_i := i
		var cap_bug := bug
		check.toggled.connect(func(pressed: bool):
			if pressed:
				_resolve_bug(cap_bug)
		)

		var rel_path: String = (bug.get("path", "") as String).replace(project_root + "/", "")

		if _bug_editing_idx == i:
			var edit := LineEdit.new()
			edit.text = bug.get("desc", "")
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			info.add_child(edit)
			var loc_lbl := Label.new()
			loc_lbl.text = rel_path + ":" + str(int(bug.get("line", 0)) + 1)
			loc_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
			loc_lbl.clip_text = true
			info.add_child(loc_lbl)
			row.add_child(info)
			var confirm_btn := Button.new()
			confirm_btn.text = "✓"
			var cap_edit := edit
			confirm_btn.pressed.connect(func():
				_bug_save_edit(cap_i, cap_edit.text.strip_edges())
			)
			edit.text_submitted.connect(func(_t):
				_bug_save_edit(cap_i, cap_edit.text.strip_edges())
			)
			row.add_child(confirm_btn)
		else:
			var desc_lbl := Label.new()
			desc_lbl.text = bug.get("desc", "")
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info.add_child(desc_lbl)
			var loc_lbl := Label.new()
			loc_lbl.text = rel_path + ":" + str(int(bug.get("line", 0)) + 1)
			loc_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
			loc_lbl.clip_text = true
			info.add_child(loc_lbl)
			row.add_child(info)
			var edit_btn := Button.new()
			edit_btn.text = "✏"
			edit_btn.pressed.connect(func():
				_bug_editing_idx = cap_i
				_refresh_bugs()
			)
			row.add_child(edit_btn)

		_bug_list.add_child(row)
		_bug_list.add_child(HSeparator.new())

func _scan_bugs(path: String, exclude: String = "") -> Array:
	var result := []
	var dir := DirAccess.open(path)
	if not dir:
		return result
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var full := path + "/" + entry
			if dir.current_is_dir():
				if entry != ".godot" and entry != ".git" and full != exclude:
					result.append_array(_scan_bugs(full, exclude))
			elif entry.ends_with(".gd"):
				var f := FileAccess.open(full, FileAccess.READ)
				if f:
					var text := f.get_as_text()
					f.close()
					var line_num := 0
					for line: String in text.split("\n"):
						var idx := line.to_lower().find("#bug ")
						if idx != -1:
							var desc := line.substr(idx + 5).strip_edges()
							if not desc.is_empty():
								result.append({"path": full, "line": line_num, "desc": desc, "full_line": line})
						line_num += 1
		entry = dir.get_next()
	dir.list_dir_end()
	return result

func _resolve_bug(bug: Dictionary) -> void:
	var path: String = bug.get("path", "")
	var line_num: int = bug.get("line", -1)
	if path.is_empty() or line_num < 0:
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var lines := f.get_as_text().split("\n")
	f.close()
	if line_num >= lines.size():
		return
	var current := lines[line_num]
	var idx := current.to_lower().find("#bug ")
	if idx == -1:
		return
	var stripped := current.substr(0, idx).rstrip(" \t")
	var new_lines: PackedStringArray = []
	for i in range(lines.size()):
		if i == line_num:
			if not stripped.is_empty():
				new_lines.append(stripped)
		else:
			new_lines.append(lines[i])
	var fw := FileAccess.open(path, FileAccess.WRITE)
	if not fw:
		return
	fw.store_string("\n".join(new_lines))
	fw.close()
	EditorInterface.get_resource_filesystem().scan()
	call_deferred("_refresh_bugs")

func _bug_save_edit(idx: int, new_desc: String) -> void:
	if idx < 0 or idx >= _bug_items.size():
		return
	var bug: Dictionary = _bug_items[idx]
	var path: String = bug.get("path", "")
	var line_num: int = bug.get("line", -1)
	if path.is_empty() or line_num < 0:
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var lines := f.get_as_text().split("\n")
	f.close()
	if line_num >= lines.size():
		return
	var current := lines[line_num]
	var tag_idx := current.to_lower().find("#bug ")
	if tag_idx == -1:
		return
	lines[line_num] = current.substr(0, tag_idx) + "#bug " + new_desc
	var fw := FileAccess.open(path, FileAccess.WRITE)
	if not fw:
		return
	fw.store_string("\n".join(PackedStringArray(lines)))
	fw.close()
	_bug_editing_idx = -1
	EditorInterface.get_resource_filesystem().scan()
	call_deferred("_refresh_bugs")

# ─── To-Do logic ─────────────────────────────────────────────────────────────

func _todo_file() -> String:
	return ProjectSettings.globalize_path("res://").rstrip("/") + "/TODO.md"

func _load_todo() -> void:
	_todo_items = []
	var path := _todo_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	for line: String in f.get_as_text().split("\n"):
		var t := line.strip_edges()
		if t.begins_with("- [ ] "):
			_todo_items.append({"text": t.substr(6).strip_edges(), "done": false})
		elif t.begins_with("- [x] ") or t.begins_with("- [X] "):
			_todo_items.append({"text": t.substr(6).strip_edges(), "done": true})
	f.close()

func _save_todo() -> void:
	var lines: PackedStringArray = ["# To-Do", ""]
	for item: Dictionary in _todo_items:
		var mark := "[x]" if item.get("done", false) else "[ ]"
		lines.append("- %s %s" % [mark, item.get("text", "")])
	var fw := FileAccess.open(_todo_file(), FileAccess.WRITE)
	if fw:
		fw.store_string("\n".join(lines) + "\n")
		fw.close()

func _todo_extract_tags(text: String) -> Array[String]:
	var tags: Array[String] = []
	for word: String in text.split(" "):
		var w := word.strip_edges()
		if w.begins_with("#") and w.length() > 1:
			var tag := w.substr(1).rstrip(".,!?;:")
			if not tag.is_empty() and tag not in tags:
				tags.append(tag)
	return tags

func _todo_all_tags() -> Array[String]:
	var tags: Array[String] = []
	for item: Dictionary in _todo_items:
		for tag: String in _todo_extract_tags(item.get("text", "")):
			if tag not in tags:
				tags.append(tag)
	tags.sort()
	return tags

func _todo_tag_color(tag: String) -> Color:
	var h: float = 0.0
	for ch in tag.to_lower():
		h = fmod(h * 31.0 + float(ch.unicode_at(0)), 360.0)
	return Color.from_hsv(h / 360.0, 0.70, 0.95)

func _todo_bbcode(text: String, done: bool = false) -> String:
	var out := ""
	for word: String in text.split(" "):
		if not out.is_empty():
			out += " "
		var stripped := word.strip_edges()
		if stripped.begins_with("#") and stripped.length() > 1:
			var tag := stripped.substr(1).rstrip(".,!?;:")
			if not tag.is_empty():
				var col := _todo_tag_color(tag)
				if done:
					col = col.darkened(0.45)
				out += "[color=#%s]%s[/color]" % [col.to_html(false), word]
				continue
		out += word
	return out

func _refresh_todo() -> void:
	for child in _todo_list.get_children():
		child.queue_free()

	# Rebuild tag filter bar
	for child in _todo_tag_bar.get_children():
		child.queue_free()
	var all_tags := _todo_all_tags()
	if not all_tags.is_empty():
		var all_btn := Button.new()
		all_btn.text = "All"
		all_btn.flat = not _todo_active_tag.is_empty()
		if _todo_active_tag.is_empty():
			all_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		all_btn.pressed.connect(func():
			_todo_active_tag = ""
			_refresh_todo()
		)
		_todo_tag_bar.add_child(all_btn)
		for tag: String in all_tags:
			var tag_btn := Button.new()
			tag_btn.text = "#" + tag
			tag_btn.flat = _todo_active_tag != tag
			var tc := _todo_tag_color(tag)
			tag_btn.add_theme_color_override("font_color", tc)
			var cap_tag := tag
			tag_btn.pressed.connect(func():
				_todo_active_tag = cap_tag
				_refresh_todo()
			)
			_todo_tag_bar.add_child(tag_btn)

	# Build filtered index list
	var filtered: Array[int] = []
	for i in range(_todo_items.size()):
		if _todo_active_tag.is_empty() or _todo_active_tag in _todo_extract_tags(_todo_items[i].get("text", "")):
			filtered.append(i)

	if filtered.is_empty():
		var lbl := Label.new()
		lbl.text = "No items" + (" tagged #" + _todo_active_tag if not _todo_active_tag.is_empty() else "") + "."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_todo_list.add_child(lbl)
		return

	var cap_filtered: Array[int] = filtered.duplicate()

	for fi in range(filtered.size()):
		var i := filtered[fi]
		var item: Dictionary = _todo_items[i]
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var check := CheckBox.new()
		check.button_pressed = false
		var cap_i := i
		check.toggled.connect(func(pressed: bool):
			if not pressed:
				return
			var done_text: String = _todo_items[cap_i].get("text", "")
			_todo_items.remove_at(cap_i)
			if _todo_editing_idx == cap_i:
				_todo_editing_idx = -1
			elif _todo_editing_idx > cap_i:
				_todo_editing_idx -= 1
			_save_todo()
			_log_activity("task_completed", done_text)
			_refresh_todo()
		)
		row.add_child(check)

		if _todo_editing_idx == i:
			var edit := LineEdit.new()
			edit.text = item.get("text", "")
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			edit.placeholder_text = "Task text… use #tag for hashtags"
			var cap_edit := edit
			edit.text_submitted.connect(func(_t):
				_todo_items[cap_i]["text"] = cap_edit.text.strip_edges()
				_save_todo()
				_todo_editing_idx = -1
				_refresh_todo()
			)
			row.add_child(edit)
			var confirm_btn := Button.new()
			confirm_btn.text = "✓"
			confirm_btn.pressed.connect(func():
				_todo_items[cap_i]["text"] = cap_edit.text.strip_edges()
				_save_todo()
				_todo_editing_idx = -1
				_refresh_todo()
			)
			row.add_child(confirm_btn)
		else:
			var lbl := RichTextLabel.new()
			lbl.bbcode_enabled = true
			lbl.fit_content = true
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.scroll_active = false
			var base_color := Color(0.4, 0.4, 0.4) if item.get("done", false) else Color(1, 1, 1)
			lbl.push_color(base_color)
			lbl.append_text(_todo_bbcode(item.get("text", ""), item.get("done", false)))
			lbl.pop()
			row.add_child(lbl)
			var edit_btn := Button.new()
			edit_btn.text = "✏"
			edit_btn.pressed.connect(func():
				_todo_editing_idx = cap_i
				_refresh_todo()
			)
			row.add_child(edit_btn)

		var cap_fi := fi
		var up_btn := Button.new()
		up_btn.text = "↑"
		up_btn.disabled = fi == 0
		up_btn.pressed.connect(func():
			var a := cap_filtered[cap_fi]
			var b := cap_filtered[cap_fi - 1]
			var tmp: Dictionary = _todo_items[a]
			_todo_items[a] = _todo_items[b]
			_todo_items[b] = tmp
			_save_todo()
			if _todo_editing_idx == a:
				_todo_editing_idx = b
			elif _todo_editing_idx == b:
				_todo_editing_idx = a
			_refresh_todo()
		)
		row.add_child(up_btn)

		var down_btn := Button.new()
		down_btn.text = "↓"
		down_btn.disabled = fi == filtered.size() - 1
		down_btn.pressed.connect(func():
			var a := cap_filtered[cap_fi]
			var b := cap_filtered[cap_fi + 1]
			var tmp: Dictionary = _todo_items[a]
			_todo_items[a] = _todo_items[b]
			_todo_items[b] = tmp
			_save_todo()
			if _todo_editing_idx == a:
				_todo_editing_idx = b
			elif _todo_editing_idx == b:
				_todo_editing_idx = a
			_refresh_todo()
		)
		row.add_child(down_btn)

		var rm_btn := Button.new()
		rm_btn.text = "✕"
		rm_btn.pressed.connect(func():
			_todo_items.remove_at(cap_i)
			_save_todo()
			if _todo_editing_idx == cap_i:
				_todo_editing_idx = -1
			elif _todo_editing_idx > cap_i:
				_todo_editing_idx -= 1
			_refresh_todo()
		)
		row.add_child(rm_btn)
		_todo_list.add_child(row)

func _todo_add() -> void:
	if not is_instance_valid(_todo_input):
		return
	var text := _todo_input.text.strip_edges()
	if text.is_empty():
		return
	_todo_items.insert(0, {"text": text, "done": false})
	_todo_input.text = ""
	_save_todo()
	_log_activity("todo_added", text)
	_refresh_todo()

func _todo_push() -> void:
	if _todo_thread and _todo_thread.is_started():
		return
	_todo_push_btn.disabled = true
	_todo_status_lbl.text = "Pushing…"
	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	_todo_thread = Thread.new()
	_todo_thread.start(func():
		OS.execute("git", PackedStringArray(["-C", project_root, "add", "TODO.md"]), [], true)
		OS.execute("git", PackedStringArray(["-C", project_root, "commit", "-m", "todo: update"]), [], true)
		var push_out := []
		var push_code := OS.execute("git", PackedStringArray(["-C", project_root, "push", "origin", "main"]), push_out, true)
		var msg := "✅ Pushed!" if push_code == OK else "❌ Push failed (no network?)"
		call_deferred("_todo_on_pushed", msg)
	)

func _todo_on_pushed(msg: String = "✅ Pushed!") -> void:
	if _todo_thread and _todo_thread.is_started():
		_todo_thread.wait_to_finish()
	_todo_thread = null
	_todo_push_btn.disabled = false
	_todo_status_lbl.text = msg
	get_tree().create_timer(2.5).timeout.connect(func():
		if is_instance_valid(_todo_status_lbl):
			_todo_status_lbl.text = ""
	)

func _build_vault_tab(tabs: TabContainer) -> void:
	var root := _vbox("Vault", tabs)

	# ── Top bar ───────────────────────────────────────────────────────────────
	var top := HBoxContainer.new()
	var repo_lbl := Label.new()
	repo_lbl.text = "🔒 ChillCube/vault"
	repo_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	repo_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_refresh_btn = Button.new()
	_vault_refresh_btn.text = "🔄 Refresh"
	_vault_refresh_btn.tooltip_text = "Pull latest from ChillCube/vault"
	_vault_refresh_btn.pressed.connect(_vault_connect)
	var connect_btn := _vault_refresh_btn
	_vault_status_lbl = Label.new()
	_vault_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	top.add_child(repo_lbl)
	top.add_child(connect_btn)
	top.add_child(_vault_status_lbl)
	root.add_child(top)

	# ── Main split ────────────────────────────────────────────────────────────
	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Left: browser
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(180, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var path_row := HBoxContainer.new()
	_vault_path_lbl = Label.new()
	_vault_path_lbl.text = "/"
	_vault_path_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	_vault_path_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_path_lbl.clip_text = true
	var newdir_btn := Button.new()
	newdir_btn.text = "📁+"
	newdir_btn.tooltip_text = "Create new folder in vault"
	newdir_btn.pressed.connect(func():
		var pre := _vault_current_dir + ("/" if not _vault_current_dir.is_empty() else "") + "new-folder"
		_vault_newdir_input.text = pre
		_vault_newdir_dialog.popup_centered()
	)
	path_row.add_child(_vault_path_lbl)
	path_row.add_child(newdir_btn)
	left.add_child(path_row)

	var browser_scroll := ScrollContainer.new()
	browser_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	browser_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_browser = VBoxContainer.new()
	_vault_browser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	browser_scroll.add_child(_vault_browser)
	left.add_child(browser_scroll)

	_vault_remote_sel_lbl = Label.new()
	_vault_remote_sel_lbl.text = "Selected: (none)"
	_vault_remote_sel_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_vault_remote_sel_lbl.clip_text = true
	left.add_child(_vault_remote_sel_lbl)

	var action_row := HBoxContainer.new()
	var move_btn := Button.new()
	move_btn.text = "🗂 Move/Rename"
	move_btn.pressed.connect(func():
		if _vault_remote_sel.is_empty():
			_vault_log.text = "⚠ Select a file first."
			return
		_vault_move_dest_input.text = _vault_remote_sel
		_vault_move_dialog.popup_centered()
	)
	action_row.add_child(move_btn)
	left.add_child(action_row)

	var dl_row := HBoxContainer.new()
	var dl_lbl := Label.new()
	dl_lbl.text = "To:"
	_vault_download_dest = LineEdit.new()
	_vault_download_dest.text = "res://"
	_vault_download_dest.placeholder_text = "res://assets/"
	_vault_download_dest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dl_btn := Button.new()
	dl_btn.text = "⬇ Download"
	dl_btn.pressed.connect(_vault_download)
	dl_row.add_child(dl_lbl)
	dl_row.add_child(_vault_download_dest)
	dl_row.add_child(dl_btn)
	left.add_child(dl_row)

	split.add_child(left)
	split.add_child(VSeparator.new())

	# Center: preview
	_vault_preview_panel = VBoxContainer.new()
	_vault_preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_vault_preview_name_lbl = Label.new()
	_vault_preview_name_lbl.text = "Select a file to preview"
	_vault_preview_name_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_vault_preview_name_lbl.clip_text = true
	_vault_preview_panel.add_child(_vault_preview_name_lbl)

	_vault_preview_loading_lbl = Label.new()
	_vault_preview_loading_lbl.text = "Loading preview…"
	_vault_preview_loading_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	_vault_preview_loading_lbl.visible = false
	_vault_preview_panel.add_child(_vault_preview_loading_lbl)

	var preview_scroll := ScrollContainer.new()
	preview_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var preview_inner := VBoxContainer.new()
	preview_inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_scroll.add_child(preview_inner)
	_vault_preview_panel.add_child(preview_scroll)

	_vault_img_rect = TextureRect.new()
	_vault_img_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_vault_img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_vault_img_rect.custom_minimum_size = Vector2(0, 200)
	_vault_img_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_img_rect.visible = false
	preview_inner.add_child(_vault_img_rect)

	_vault_audio_container = VBoxContainer.new()
	_vault_audio_container.visible = false
	var audio_lbl := Label.new()
	audio_lbl.text = "🎵 Audio File"
	audio_lbl.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4))
	_vault_audio_container.add_child(audio_lbl)
	var audio_btns := HBoxContainer.new()
	_vault_audio_play_btn = Button.new()
	_vault_audio_play_btn.text = "▶ Play"
	_vault_audio_play_btn.pressed.connect(_vault_toggle_audio)
	audio_btns.add_child(_vault_audio_play_btn)
	_vault_audio_container.add_child(audio_btns)
	preview_inner.add_child(_vault_audio_container)

	_vault_text_preview = TextEdit.new()
	_vault_text_preview.editable = false
	_vault_text_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_text_preview.custom_minimum_size = Vector2(0, 200)
	_vault_text_preview.visible = false
	preview_inner.add_child(_vault_text_preview)

	_vault_video_container = VBoxContainer.new()
	_vault_video_container.visible = false
	_vault_video_player = VideoStreamPlayer.new()
	_vault_video_player.custom_minimum_size = Vector2(0, 180)
	_vault_video_player.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_video_player.expand = true
	_vault_video_container.add_child(_vault_video_player)
	var vid_btns := HBoxContainer.new()
	_vault_video_play_btn = Button.new()
	_vault_video_play_btn.text = "▶ Play"
	_vault_video_play_btn.pressed.connect(_vault_toggle_video)
	var vid_stop_btn := Button.new()
	vid_stop_btn.text = "⏹ Stop"
	vid_stop_btn.pressed.connect(func():
		_vault_video_player.stop()
		_vault_video_play_btn.text = "▶ Play"
	)
	vid_btns.add_child(_vault_video_play_btn)
	vid_btns.add_child(vid_stop_btn)
	_vault_video_container.add_child(vid_btns)
	preview_inner.add_child(_vault_video_container)

	_vault_preview_unsupported = Label.new()
	_vault_preview_unsupported.text = ""
	_vault_preview_unsupported.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_vault_preview_unsupported.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_vault_preview_unsupported.visible = false
	preview_inner.add_child(_vault_preview_unsupported)

	split.add_child(_vault_preview_panel)
	split.add_child(VSeparator.new())

	# Right: upload
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(200, 0)
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var up_title := Label.new()
	up_title.text = "Upload to Vault"
	up_title.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	right.add_child(up_title)

	_vault_local_sel_lbl = Label.new()
	_vault_local_sel_lbl.text = "No file selected"
	_vault_local_sel_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_vault_local_sel_lbl.clip_text = true
	right.add_child(_vault_local_sel_lbl)

	var pick_btn := Button.new()
	pick_btn.text = "📂 Select File…"
	pick_btn.pressed.connect(_vault_open_picker)
	right.add_child(pick_btn)

	var up_dest_row := HBoxContainer.new()
	var up_dest_lbl := Label.new()
	up_dest_lbl.text = "Folder:"
	_vault_upload_dest = LineEdit.new()
	_vault_upload_dest.text = "/"
	_vault_upload_dest.placeholder_text = "assets/"
	_vault_upload_dest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	up_dest_row.add_child(up_dest_lbl)
	up_dest_row.add_child(_vault_upload_dest)
	right.add_child(up_dest_row)

	var up_btn := Button.new()
	up_btn.text = "⬆ Upload"
	up_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	up_btn.pressed.connect(_vault_upload)
	right.add_child(up_btn)

	split.add_child(right)
	root.add_child(split)

	# ── Log ───────────────────────────────────────────────────────────────────
	_vault_log = TextEdit.new()
	_vault_log.custom_minimum_size = Vector2(0, 90)
	_vault_log.editable = false
	_vault_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_vault_log)

	# Audio player (must be in scene tree, not visual layout)
	_vault_audio_player = AudioStreamPlayer.new()
	_vault_audio_player.finished.connect(func(): _vault_audio_play_btn.text = "▶ Play")
	add_child(_vault_audio_player)

	# File picker dialog
	_vault_file_dialog = EditorFileDialog.new()
	_vault_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_vault_file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	_vault_file_dialog.file_selected.connect(func(path: String):
		_vault_local_sel = path
		_vault_local_sel_lbl.text = path.get_file()
	)
	add_child(_vault_file_dialog)

	# Move/rename dialog
	_vault_move_dialog = AcceptDialog.new()
	_vault_move_dialog.title = "Move / Rename File"
	_vault_move_dialog.size = Vector2i(420, 120)
	var move_vbox: VBoxContainer = _vault_move_dialog.get_vbox()
	var move_hint := Label.new()
	move_hint.text = "Destination path (e.g. images/photo.png):"
	move_vbox.add_child(move_hint)
	_vault_move_dest_input = LineEdit.new()
	_vault_move_dest_input.placeholder_text = "folder/filename.ext"
	_vault_move_dest_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_vbox.add_child(_vault_move_dest_input)
	_vault_move_dialog.confirmed.connect(_vault_do_move)
	add_child(_vault_move_dialog)

	# New folder dialog
	_vault_newdir_dialog = AcceptDialog.new()
	_vault_newdir_dialog.title = "New Folder"
	_vault_newdir_dialog.size = Vector2i(360, 110)
	var dir_vbox: VBoxContainer = _vault_newdir_dialog.get_vbox()
	var dir_hint := Label.new()
	dir_hint.text = "Folder path (e.g. images/subfolder):"
	dir_vbox.add_child(dir_hint)
	_vault_newdir_input = LineEdit.new()
	_vault_newdir_input.placeholder_text = "my-folder"
	_vault_newdir_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dir_vbox.add_child(_vault_newdir_input)
	_vault_newdir_dialog.confirmed.connect(_vault_do_mkdir)
	add_child(_vault_newdir_dialog)

	_vault_navigate("")

# ─── Vault logic ──────────────────────────────────────────────────────────────

func _vault_connect() -> void:
	_vault_cache = OS.get_user_data_dir() + "/cc_vault"
	_vault_status_lbl.text = "Connecting…"
	_vault_log.text = ""
	_vault_refresh_btn.disabled = true
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = Thread.new()
	var cache := _vault_cache
	_vault_thread.start(func():
		var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
		var ok := Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_on_connected", ok)
	)

func _vault_on_connected(ok: bool) -> void:
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = null
	_vault_refresh_btn.disabled = false
	_vault_status_lbl.text = "✅ Connected" if ok else "❌ Not found — see log"
	if ok:
		_vault_current_dir = ""
		_vault_remote_sel = ""
		_vault_files = Ops.vault_list_files(_vault_cache)
		_vault_navigate("")

func _vault_navigate(rel: String) -> void:
	_vault_current_dir = rel
	_vault_path_lbl.text = "/" + rel
	for c in _vault_browser.get_children():
		c.queue_free()

	if _vault_cache.is_empty() or not DirAccess.dir_exists_absolute(_vault_cache):
		var hint := Label.new()
		hint.text = "Not connected. Click 🔄 Refresh to connect.\n\nIf ChillCube/vault doesn't exist yet:\n→ github.com/new → Owner: ChillCube, Name: vault, Private ✓"
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_vault_browser.add_child(hint)
		return

	var prefix := (rel + "/") if not rel.is_empty() else ""
	var folders: Array[String] = []
	var files: Array[String] = []
	for path: String in _vault_files:
		if not path.begins_with(prefix):
			continue
		var rest := path.substr(prefix.length())
		if "/" in rest:
			var folder := rest.split("/")[0]
			if folder not in folders:
				folders.append(folder)
		elif rest != ".gitkeep":
			files.append(rest)
	folders.sort()
	files.sort()

	if not rel.is_empty():
		var up_btn := Button.new()
		up_btn.text = "📁 .."
		up_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		up_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var parent := rel.rstrip("/").get_base_dir()
		if parent == ".":
			parent = ""
		up_btn.pressed.connect(func(): _vault_navigate(parent))
		_vault_browser.add_child(up_btn)

	for folder: String in folders:
		var btn := Button.new()
		btn.text = "📁 " + folder
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cap := prefix + folder
		btn.pressed.connect(func(): _vault_navigate(cap))
		_vault_browser.add_child(btn)

	for file: String in files:
		var rel_file := prefix + file
		var btn := Button.new()
		btn.text = _vault_file_icon(file) + " " + file
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.flat = true
		if rel_file == _vault_remote_sel:
			btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		var cap_rel := rel_file
		btn.pressed.connect(func():
			_vault_remote_sel = cap_rel
			_vault_remote_sel_lbl.text = "Selected: " + cap_rel
			_vault_navigate(_vault_current_dir)
			_vault_request_preview(cap_rel)
		)
		_vault_browser.add_child(btn)

	_vault_upload_dest.text = "/" + prefix

func _vault_file_icon(filename: String) -> String:
	var ext := filename.get_extension().to_lower()
	if ext in ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg", "hdr"]:
		return "🖼"
	if ext in ["ogg", "mp3", "wav", "flac", "m4a"]:
		return "🎵"
	if ext in ["ogv", "webm", "mp4", "avi", "mov"]:
		return "🎬"
	if ext in ["txt", "md", "json", "csv", "gd", "cfg", "ini", "toml", "yaml", "yml", "xml", "html", "shader", "glsl"]:
		return "📄"
	return "📎"

func _vault_open_picker() -> void:
	_vault_file_dialog.popup_centered_ratio(0.7)

func _vault_upload() -> void:
	if _vault_cache.is_empty() or not DirAccess.dir_exists_absolute(_vault_cache):
		_vault_log.text = "⚠️ Not connected to a vault repo."
		return
	if _vault_local_sel.is_empty():
		_vault_log.text = "⚠️ No local file selected."
		return
	_vault_log.text = ""
	_vault_status_lbl.text = "Uploading…"
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = Thread.new()
	var cache := _vault_cache
	var local := _vault_local_sel
	var dest := _vault_upload_dest.text
	_vault_thread.start(func():
		var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
		Ops.vault_upload_file(local, dest, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_op", "")
	)

func _vault_download() -> void:
	if _vault_cache.is_empty() or not DirAccess.dir_exists_absolute(_vault_cache):
		_vault_log.text = "⚠️ Not connected to a vault repo."
		return
	if _vault_remote_sel.is_empty():
		_vault_log.text = "⚠️ No file selected in the browser."
		return
	_vault_log.text = ""
	_vault_status_lbl.text = "Downloading…"
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = Thread.new()
	var cache := _vault_cache
	var remote := _vault_remote_sel
	var dest := _vault_download_dest.text
	_vault_thread.start(func():
		var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
		Ops.vault_download_file(cache, remote, dest, log_fn)
		call_deferred("_vault_after_op", "")
	)

func _vault_after_op(status: String) -> void:
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = null
	_vault_status_lbl.text = status
	_vault_files = Ops.vault_list_files(_vault_cache)
	_vault_navigate(_vault_current_dir)
	EditorInterface.get_resource_filesystem().scan()

func _vault_request_preview(rel_path: String) -> void:
	if _vault_preview_thread and _vault_preview_thread.is_started():
		return
	_vault_clear_preview()
	_vault_preview_name_lbl.text = rel_path.get_file()
	var ext := rel_path.get_extension().to_lower()
	var IMAGE_EXTS := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg"]
	var AUDIO_EXTS := ["ogg", "mp3", "wav"]
	var VIDEO_EXTS := ["ogv", "webm", "mp4"]
	var TEXT_EXTS  := ["txt", "md", "json", "csv", "gd", "cfg", "ini", "toml", "yaml", "yml", "xml", "html", "shader", "glsl"]
	if ext not in IMAGE_EXTS and ext not in AUDIO_EXTS and ext not in VIDEO_EXTS and ext not in TEXT_EXTS:
		_vault_preview_unsupported.text = "No preview available for ." + ext + " files."
		_vault_preview_unsupported.visible = true
		return
	_vault_preview_loading_lbl.visible = true
	var cache := _vault_cache
	var tmp_dir := OS.get_temp_dir() + "/cc_vault_preview"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	_vault_preview_thread = Thread.new()
	_vault_preview_thread.start(func():
		Ops.vault_download_file(cache, rel_path, tmp_dir, Callable())
		var tmp_path := tmp_dir + "/" + rel_path.get_file()
		call_deferred("_vault_on_preview_ready", tmp_path, ext)
	)

func _vault_on_preview_ready(tmp_path: String, ext: String) -> void:
	if _vault_preview_thread and _vault_preview_thread.is_started():
		_vault_preview_thread.wait_to_finish()
	_vault_preview_thread = null
	_vault_preview_loading_lbl.visible = false
	if not FileAccess.file_exists(tmp_path):
		_vault_preview_unsupported.text = "Preview extraction failed."
		_vault_preview_unsupported.visible = true
		return
	var IMAGE_EXTS := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg"]
	var AUDIO_EXTS := ["ogg", "mp3", "wav"]
	var VIDEO_EXTS := ["ogv", "webm", "mp4"]
	if ext in IMAGE_EXTS:
		_vault_show_image(tmp_path)
	elif ext in AUDIO_EXTS:
		_vault_show_audio(tmp_path, ext)
	elif ext in VIDEO_EXTS:
		_vault_show_video(tmp_path, ext)
	else:
		_vault_show_text(tmp_path)

func _vault_clear_preview() -> void:
	if _vault_audio_player and _vault_audio_player.playing:
		_vault_audio_player.stop()
	if _vault_audio_player:
		_vault_audio_player.stream = null
	if _vault_audio_play_btn:
		_vault_audio_play_btn.text = "▶ Play"
	if _vault_img_rect:
		_vault_img_rect.texture = null
		_vault_img_rect.visible = false
	if _vault_audio_container:
		_vault_audio_container.visible = false
	if _vault_text_preview:
		_vault_text_preview.text = ""
		_vault_text_preview.visible = false
	if _vault_video_container:
		_vault_video_container.visible = false
	if _vault_video_player and _vault_video_player.is_playing():
		_vault_video_player.stop()
	if _vault_preview_unsupported:
		_vault_preview_unsupported.visible = false

func _vault_show_image(path: String) -> void:
	var img := Image.new()
	var err: Error
	if path.get_extension().to_lower() == "svg":
		var bytes := FileAccess.get_file_as_bytes(path)
		err = img.load_svg_from_buffer(bytes, 2.0)
	else:
		err = img.load(path)
	if err == OK:
		_vault_img_rect.texture = ImageTexture.create_from_image(img)
		_vault_img_rect.visible = true
	else:
		_vault_preview_unsupported.text = "Failed to load image."
		_vault_preview_unsupported.visible = true

func _vault_show_audio(path: String, ext: String) -> void:
	var stream: AudioStream = null
	match ext:
		"ogg":
			stream = AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			var bytes := FileAccess.get_file_as_bytes(path)
			if bytes.size() > 0:
				var s := AudioStreamMP3.new()
				s.data = bytes
				stream = s
		"wav":
			var bytes := FileAccess.get_file_as_bytes(path)
			if bytes.size() > 0:
				var user_path := "user://cc_preview_tmp.wav"
				var f := FileAccess.open(user_path, FileAccess.WRITE)
				if f:
					f.store_buffer(bytes)
					f.close()
					stream = ResourceLoader.load(user_path, "", ResourceLoader.CACHE_MODE_IGNORE) as AudioStream
	if stream:
		_vault_audio_player.stream = stream
		_vault_audio_container.visible = true
	else:
		_vault_preview_unsupported.text = "Could not load audio (" + ext + ")."
		_vault_preview_unsupported.visible = true

func _vault_show_text(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		_vault_text_preview.text = f.get_as_text()
		f.close()
		_vault_text_preview.visible = true
	else:
		_vault_preview_unsupported.text = "Could not read file."
		_vault_preview_unsupported.visible = true

func _vault_show_video(path: String, ext: String) -> void:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		_vault_preview_unsupported.text = "Could not read video file."
		_vault_preview_unsupported.visible = true
		return
	var user_path := "user://cc_preview_tmp." + ext
	var f := FileAccess.open(user_path, FileAccess.WRITE)
	if not f:
		_vault_preview_unsupported.text = "Could not write temp video file."
		_vault_preview_unsupported.visible = true
		return
	f.store_buffer(bytes)
	f.close()
	var stream := ResourceLoader.load(user_path, "", ResourceLoader.CACHE_MODE_IGNORE) as VideoStream
	if stream:
		_vault_video_player.stream = stream
		_vault_video_container.visible = true
	else:
		_vault_preview_unsupported.text = "Cannot preview ." + ext + " (try .ogv for video)."
		_vault_preview_unsupported.visible = true

func _vault_toggle_audio() -> void:
	if _vault_audio_player.playing:
		_vault_audio_player.stop()
		_vault_audio_play_btn.text = "▶ Play"
	else:
		_vault_audio_player.play()
		_vault_audio_play_btn.text = "⏸ Pause"

func _vault_toggle_video() -> void:
	if _vault_video_player.is_playing():
		_vault_video_player.paused = not _vault_video_player.paused
		_vault_video_play_btn.text = "⏸ Pause" if not _vault_video_player.paused else "▶ Play"
	else:
		_vault_video_player.play()
		_vault_video_play_btn.text = "⏸ Pause"

func _vault_do_move() -> void:
	var dest := _vault_move_dest_input.text.strip_edges().lstrip("/")
	if dest.is_empty() or dest == _vault_remote_sel.lstrip("/"):
		_vault_log.text = "⚠ Enter a different destination path."
		return
	if _vault_thread and _vault_thread.is_started():
		_vault_log.text = "⚠ Another operation is running."
		return
	_vault_log.text = ""
	_vault_status_lbl.text = "Moving…"
	_vault_thread = Thread.new()
	var src := _vault_remote_sel
	var cache := _vault_cache
	var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
	_vault_thread.start(func():
		Ops.vault_move_file(src, dest, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_manage")
	)

func _vault_do_mkdir() -> void:
	var name := _vault_newdir_input.text.strip_edges().lstrip("/")
	if name.is_empty():
		return
	if _vault_thread and _vault_thread.is_started():
		_vault_log.text = "⚠ Another operation is running."
		return
	_vault_log.text = ""
	_vault_status_lbl.text = "Creating folder…"
	_vault_thread = Thread.new()
	var cache := _vault_cache
	var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
	_vault_thread.start(func():
		Ops.vault_mkdir(name, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_manage")
	)

func _vault_after_manage() -> void:
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = null
	_vault_status_lbl.text = ""
	_vault_remote_sel = ""
	_vault_files = Ops.vault_list_files(_vault_cache)
	_vault_navigate(_vault_current_dir)

func _build_terminal_tab(tabs: TabContainer) -> void:
	var root := _vbox("Terminal", tabs)

	var header := HBoxContainer.new()
	_term_cwd_label = Label.new()
	_term_cwd_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_term_cwd_label.clip_text = true
	_term_cwd_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	var ext_btn := Button.new()
	ext_btn.text = "↗ Open in Terminal"
	ext_btn.tooltip_text = "Open an external terminal in the current directory (needed for interactive apps like Claude Code)."
	ext_btn.pressed.connect(_term_open_external)
	var clear_btn := Button.new()
	clear_btn.text = "Clear"
	clear_btn.pressed.connect(func(): _term_output.text = "")
	header.add_child(_term_cwd_label)
	header.add_child(ext_btn)
	header.add_child(clear_btn)
	root.add_child(header)

	_term_output = TextEdit.new()
	_term_output.editable = false
	_term_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_term_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_term_output.wrap_mode = TextEdit.LINE_WRAPPING_NONE
	var code_font: Font = EditorInterface.get_editor_theme().get_font("source", "EditorFonts")
	if code_font:
		_term_output.add_theme_font_override("font", code_font)
	root.add_child(_term_output)

	var input_row := HBoxContainer.new()
	_term_input = LineEdit.new()
	_term_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_term_input.placeholder_text = "Enter command…"
	_term_input.text_submitted.connect(func(_t): _term_run())
	_term_input.gui_input.connect(_term_history_key)
	_term_run_btn = Button.new()
	_term_run_btn.text = "▶ Run"
	_term_run_btn.pressed.connect(_term_run)
	input_row.add_child(_term_input)
	input_row.add_child(_term_run_btn)
	root.add_child(input_row)

	_term_cwd = ProjectSettings.globalize_path("res://").rstrip("/")
	_term_update_prompt()
	_term_append("ChillCube Terminal — " + OS.get_name() + "\n")

# ─── Terminal logic ───────────────────────────────────────────────────────────

const NEEDS_TTY := ["claude", "vim", "vi", "nvim", "nano", "htop", "top", "btop",
	"lazygit", "less", "more", "man", "ssh", "python", "python3", "node", "irb", "iex", "bash", "zsh", "sh"]

func _term_update_prompt() -> void:
	_term_cwd_label.text = _term_cwd + " $"

func _term_history_key(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed:
		return
	if event.keycode == KEY_UP:
		if _term_hist_idx < _term_history.size() - 1:
			_term_hist_idx += 1
			_term_input.text = _term_history[_term_hist_idx]
			_term_input.caret_column = _term_input.text.length()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_DOWN:
		if _term_hist_idx > 0:
			_term_hist_idx -= 1
			_term_input.text = _term_history[_term_hist_idx]
			_term_input.caret_column = _term_input.text.length()
		elif _term_hist_idx == 0:
			_term_hist_idx = -1
			_term_input.text = ""
		get_viewport().set_input_as_handled()

func _term_run() -> void:
	var cmd := _term_input.text.strip_edges()
	if cmd.is_empty():
		return
	if _term_thread and _term_thread.is_started():
		_term_append("⚠ A command is already running.")
		return

	_term_history.insert(0, cmd)
	_term_hist_idx = -1
	_term_input.text = ""

	# Redirect interactive apps to a real PTY terminal
	var base_cmd := cmd.split(" ")[0].get_file()
	if base_cmd in NEEDS_TTY:
		_term_append(_term_cwd + " $ " + cmd)
		_term_append("↗ '%s' needs a real TTY — launching in external terminal…" % base_cmd)
		_term_open_external(cmd)
		return

	_term_append(_term_cwd + " $ " + cmd)

	# Handle cd locally so directory state persists across commands
	if cmd == "cd" or cmd == "cd ~":
		_term_cwd = OS.get_environment("HOME")
		_term_update_prompt()
		return
	if cmd.begins_with("cd "):
		var arg := cmd.substr(3).strip_edges()
		if arg.begins_with("~/"):
			arg = OS.get_environment("HOME") + "/" + arg.substr(2)
		elif arg == "~":
			arg = OS.get_environment("HOME")
		elif not arg.begins_with("/"):
			arg = _term_cwd + "/" + arg
		if DirAccess.dir_exists_absolute(arg):
			_term_cwd = arg
			_term_update_prompt()
		else:
			_term_append("cd: " + arg + ": No such file or directory")
		return

	_term_run_btn.disabled = true
	_term_input.editable = false
	var cwd_snapshot := _term_cwd
	_term_thread = Thread.new()
	_term_thread.start(func():
		var output: Array = []
		var safe_cwd := cwd_snapshot.replace("'", "'\\''")
		OS.execute("bash", ["-c", "cd '" + safe_cwd + "' && " + cmd + " 2>&1"], output, true)
		var out: String = output[0] if not output.is_empty() else ""
		call_deferred("_term_on_done", out)
	)

func _term_on_done(raw: String) -> void:
	if _term_thread:
		_term_thread.wait_to_finish()
	_term_thread = null
	var cleaned := _strip_ansi(raw).rstrip("\n")
	if not cleaned.is_empty():
		_term_append(cleaned)
	_term_run_btn.disabled = false
	_term_input.editable = true
	_term_input.grab_focus()

func _term_open_external(initial_cmd: String = "") -> void:
	var candidates := ["xterm", "kitty", "alacritty", "konsole", "gnome-terminal", "xfce4-terminal", "lxterminal", "mate-terminal"]
	var found := ""
	for t in candidates:
		var which: Array = []
		if OS.execute("which", [t], which, true) == 0 and not (which[0] as String).strip_edges().is_empty():
			found = t
			break
	if found.is_empty():
		_term_append("⚠ No terminal emulator found. Install xterm, kitty, or konsole.")
		return
	# Build a bash script: cd to cwd, optionally run the command, then drop to shell
	var safe_cwd := _term_cwd.replace("'", "'\\''")
	var shell_script := "cd '" + safe_cwd + "'"
	if not initial_cmd.is_empty():
		shell_script += " && " + initial_cmd
	shell_script += "; exec bash"
	match found:
		"gnome-terminal":
			OS.create_process("gnome-terminal", ["--", "bash", "-c", shell_script])
		"konsole":
			OS.create_process("konsole", ["-e", "bash", "-c", shell_script])
		"kitty":
			OS.create_process("kitty", ["bash", "-c", shell_script])
		"alacritty":
			OS.create_process("alacritty", ["--", "bash", "-c", shell_script])
		_:
			OS.create_process(found, ["-e", "bash", "-c", shell_script])

func _term_append(text: String) -> void:
	_term_output.text += text + "\n"
	_term_output.scroll_vertical = _term_output.get_line_count()

func _strip_ansi(text: String) -> String:
	var re := RegEx.new()
	re.compile("\\x1b(\\[[0-9;?]*[A-Za-z]|\\][^\\x07]*\\x07|[()][A-Z0-9=]|[ABCDEFGHJKSTM])")
	return re.sub(text, "", true)

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
	var in_dev := _get_in_dev_folders()

	for folder: String in addons:
		if folder in in_dev:
			continue
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_lbl := Label.new()
		name_lbl.text = "📦 %s" % cfg.get("name", folder)
		var desc_lbl := Label.new()
		desc_lbl.text = cfg.get("description", "")
		desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		desc_lbl.clip_text = true
		info.add_child(name_lbl)
		info.add_child(desc_lbl)
		var dependers: Array = dependents.get(folder, [])
		if not dependers.is_empty():
			var dep_lbl := Label.new()
			dep_lbl.text = "dependency of: " + ", ".join(PackedStringArray(dependers))
			dep_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
			dep_lbl.clip_text = true
			info.add_child(dep_lbl)
		row.add_child(info)

		var url := Ops.git_remote(root + "/addons/" + folder)
		var owned := Ops.is_chillcube(url)

		var copy_btn := Button.new()
		copy_btn.text = "🔗"
		if url.is_empty():
			copy_btn.disabled = true
			copy_btn.tooltip_text = "No GitHub remote found"
		else:
			copy_btn.tooltip_text = (("🧊 ChillCube addon\n") if owned else ("⚠️ Third-party — push disabled\n")) + url
			var captured_url := url
			copy_btn.pressed.connect(func():
				DisplayServer.clipboard_set(captured_url)
				copy_btn.text = "✓"
				get_tree().create_timer(1.5).timeout.connect(func(): copy_btn.text = "🔗")
			)
		row.add_child(copy_btn)

		var sync_btn := Button.new()
		sync_btn.text = "↺ Sync"
		if url.is_empty():
			sync_btn.disabled = true
			sync_btn.tooltip_text = "No GitHub remote — cannot sync"
		else:
			var captured_url := url
			sync_btn.tooltip_text = (
				"Sync (pull + push) with " + url if owned
				else "Pull only — push disabled for third-party addons\n" + url
			)
			var captured_sync_name: String = cfg.get("name", folder)
			sync_btn.pressed.connect(func():
				_installed_log.text = ""
				_run_op(sync_btn, _installed_log, func():
					Ops.sync_addon(
						ProjectSettings.globalize_path("res://").rstrip("/"),
						captured_url,
						func(msg): call_deferred("_append_log", _installed_log, msg)
					)
					call_deferred("_refresh_addons")
					call_deferred("_log_activity", "addon_synced", captured_sync_name)
				)
			)
		row.add_child(sync_btn)

		var edit_btn := Button.new()
		edit_btn.text = "✏️ Edit"
		edit_btn.tooltip_text = "Open script editor for " + folder
		var captured_edit_folder := folder
		var captured_addon_name: String = cfg.get("name", folder)
		edit_btn.pressed.connect(func(): _open_script_editor(captured_edit_folder, captured_addon_name))
		row.add_child(edit_btn)

		var rm_btn := Button.new()
		rm_btn.text = "🗑️"
		if dependers.is_empty():
			rm_btn.tooltip_text = "Remove " + folder
			var captured_folder := folder
			var captured_rm_name: String = cfg.get("name", folder)
			rm_btn.pressed.connect(func():
				_installed_log.text = ""
				_run_op(rm_btn, _installed_log, func():
					Ops.remove_addon(
						ProjectSettings.globalize_path("res://").rstrip("/"),
						captured_folder,
						func(msg): call_deferred("_append_log", _installed_log, msg)
					)
					call_deferred("_refresh_addons")
					call_deferred("_log_activity", "addon_removed", captured_rm_name)
				)
			)
		else:
			rm_btn.disabled = true
			rm_btn.tooltip_text = "Cannot remove — required by: " + ", ".join(PackedStringArray(dependers))
		row.add_child(rm_btn)
		_addon_list.add_child(row)

# ─── Operation launchers ─────────────────────────────────────────────────────

func _start_create() -> void:
	var name := _create_name.text.strip_edges()
	if name.is_empty():
		_append_log(_create_log, "❌ Name is required.")
		return
	var sel := _create_category.selected
	if sel == -1 or _create_category.get_item_text(sel) == "Loading…":
		_append_log(_create_log, "❌ Category list is still loading — try again.")
		return
	var category := _create_category.get_item_text(sel)
	_run_op(_create_btn, _create_log, func():
		Ops.create_addon(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			name,
			_create_desc.text.strip_edges(),
			_create_author.text.strip_edges(),
			category,
			_create_gh.button_pressed,
			func(msg): call_deferred("_append_log", _create_log, msg)
		)
		call_deferred("_refresh_addons")
		call_deferred("_log_activity", "addon_created", name)
	)

func _start_clone() -> void:
	var url := _clone_url.text.strip_edges()
	if url.is_empty():
		_append_log(_create_log, "❌ URL is required.")
		return
	_create_log.text = ""
	_run_op(_clone_btn, _create_log, func():
		Ops.clone_addon(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			url,
			func(msg): call_deferred("_append_log", _create_log, msg)
		)
		call_deferred("_refresh_addons")
		call_deferred("_log_activity", "addon_cloned", url)
	)

func _start_update_plugin() -> void:
	_installed_log.text = ""
	_run_op(_update_plugin_btn, _installed_log, func():
		Ops.update_plugin(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			func(msg): call_deferred("_append_log", _installed_log, msg)
		)
	)

func _start_push() -> void:
	_installed_log.text = ""
	var self_folder: String = (get_script() as Script).resource_path.get_base_dir().get_file()
	_run_op(_push_btn, _installed_log, func():
		Ops.push_all(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			func(msg): call_deferred("_append_log", _installed_log, msg),
			[self_folder]
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
	EditorInterface.get_resource_filesystem().scan()

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
	_registry_entries = entries
	_build_installed_url_map()
	_populate_registry(entries)
	_populate_category_dropdown(entries)
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
		if url in _registry_installed:
			continue
		var btn := Button.new()
		btn.text = "⬇ Install"
		btn.tooltip_text = url
		btn.pressed.connect(_install_from_registry.bind(url, btn))
		row.add_child(btn)
		_registry_list.add_child(row)

func _populate_category_dropdown(entries: Array) -> void:
	var seen: Array[String] = []
	for entry: Dictionary in entries:
		var cat: String = entry.get("category", "Uncategorized")
		if cat not in seen:
			seen.append(cat)
	_create_category.clear()
	for cat in seen:
		_create_category.add_item(cat)
	if _create_category.item_count == 0:
		_create_category.add_item("Uncategorized")

func _install_from_registry(url: String, btn: Button) -> void:
	_run_op(btn, _browse_log, func():
		var root := ProjectSettings.globalize_path("res://").rstrip("/")
		var log_fn := func(msg: String): call_deferred("_append_log", _browse_log, msg)
		Ops.sync_addon(root, url, log_fn)
		call_deferred("_refresh_addons")
		call_deferred("_build_installed_url_map")
		call_deferred("_fetch_registry")
	)

# ─── Script editor ────────────────────────────────────────────────────────────

func _find_gd_files(base: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(base)
	if not dir:
		return result
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if not name.begins_with("."):
			var full := base + "/" + name
			if dir.current_is_dir():
				result.append_array(_find_gd_files(full))
			elif name.ends_with(".gd"):
				result.append(full)
		name = dir.get_next()
	dir.list_dir_end()
	return result

func _open_script_editor(folder: String, addon_name: String) -> void:
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var addon_path := root + "/addons/" + folder
	var scripts := _find_gd_files(addon_path)
	scripts.sort()

	if scripts.is_empty():
		_append_log(_installed_log, "ℹ️  No scripts found in " + addon_name)
		return

	var win := Window.new()
	win.title = "Edit Scripts — " + addon_name
	win.wrap_controls = true
	win.close_requested.connect(func(): win.queue_free())

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	win.add_child(vbox)

	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 6)
	var save_btn := Button.new()
	save_btn.text = "💾 Save All"
	var status_lbl := Label.new()
	status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(save_btn)
	toolbar.add_child(status_lbl)
	vbox.add_child(toolbar)
	vbox.add_child(HSeparator.new())

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(tabs)

	var editors: Dictionary = {}

	for script_path: String in scripts:
		var filename := script_path.get_file()
		var content := ""
		var f := FileAccess.open(script_path, FileAccess.READ)
		if f:
			content = f.get_as_text()
			f.close()

		var editor := CodeEdit.new()
		editor.name = filename
		editor.text = content
		editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		editor.gutters_draw_line_numbers = true
		editor.gutters_draw_fold_gutter = true
		editor.auto_brace_completion_enabled = true
		editor.indent_automatic = true
		editor.indent_use_spaces = false
		editor.minimap_draw = false

		var highlighter := GDScriptSyntaxHighlighter.new()
		editor.syntax_highlighter = highlighter

		tabs.add_child(editor)
		editors[script_path] = editor

	save_btn.pressed.connect(func():
		var saved := 0
		for path: String in editors:
			var ed: CodeEdit = editors[path]
			var fw := FileAccess.open(path, FileAccess.WRITE)
			if fw:
				fw.store_string(ed.text)
				fw.close()
				saved += 1
		status_lbl.text = "✅ Saved %d file(s)" % saved
		EditorInterface.get_resource_filesystem().scan()
		get_tree().create_timer(2.5).timeout.connect(func(): status_lbl.text = "")
	)

	add_child(win)
	win.popup_centered(Vector2i(960, 680))

# ─── Activity log ─────────────────────────────────────────────────────────────

func _build_activity_tab(tabs: TabContainer) -> void:
	var root := _vbox("Activity", tabs)

	var toolbar := HBoxContainer.new()
	_activity_push_btn = Button.new()
	_activity_push_btn.text = "⬆ Push"
	_activity_push_btn.tooltip_text = "Manually commit and push the activity log to GitHub."
	_activity_push_btn.pressed.connect(_activity_manual_push)
	_activity_status_lbl = Label.new()
	_activity_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_activity_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(_activity_push_btn)
	toolbar.add_child(_activity_status_lbl)
	root.add_child(toolbar)
	root.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_activity_list = VBoxContainer.new()
	_activity_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_activity_list)
	root.add_child(scroll)

	_refresh_activity_list()

func _activity_file() -> String:
	return ProjectSettings.globalize_path("res://").rstrip("/") + "/ACTIVITY_LOG.json"

func _load_activity() -> void:
	_activity_items = []
	var path := _activity_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		_activity_items = parsed
	_refresh_activity_list()

func _save_activity() -> void:
	var fw := FileAccess.open(_activity_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_activity_items, "\t") + "\n")
		fw.close()

func _log_activity(type: String, text: String) -> void:
	_activity_items.insert(0, {
		"type": type,
		"text": text,
		"timestamp": Time.get_datetime_string_from_system()
	})
	_save_activity()
	_refresh_activity_list()
	_activity_auto_push()

func _activity_auto_push() -> void:
	if _activity_thread and _activity_thread.is_started():
		return
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	_activity_thread = Thread.new()
	_activity_thread.start(func():
		Ops._git(["add", "ACTIVITY_LOG.json"], root, Callable())
		var code := Ops._git(["commit", "-m", "activity: auto-backup"], root, Callable())
		if code == OK:
			Ops._git(["push", "origin", "main"], root, Callable())
		call_deferred("_activity_on_pushed", code == OK)
	)

func _activity_manual_push() -> void:
	if _activity_thread and _activity_thread.is_started():
		return
	if is_instance_valid(_activity_push_btn):
		_activity_push_btn.disabled = true
	_activity_auto_push()

func _activity_on_pushed(pushed: bool) -> void:
	if _activity_thread:
		_activity_thread.wait_to_finish()
	_activity_thread = null
	if is_instance_valid(_activity_push_btn):
		_activity_push_btn.disabled = false
	if not is_instance_valid(_activity_status_lbl):
		return
	_activity_status_lbl.text = "✅ Backed up" if pushed else "✨ Nothing new to push"
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(_activity_status_lbl):
			_activity_status_lbl.text = ""
	)

func _refresh_activity_list() -> void:
	if not is_instance_valid(_activity_list):
		return
	for child in _activity_list.get_children():
		child.queue_free()

	if _activity_items.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No activity yet."
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_activity_list.add_child(empty_lbl)
		return

	var last_date := ""
	for entry: Dictionary in _activity_items:
		var ts: String = entry.get("timestamp", "")
		var date := ts.substr(0, 10) if ts.length() >= 10 else ts

		if date != last_date:
			last_date = date
			var date_lbl := Label.new()
			date_lbl.text = date
			date_lbl.add_theme_font_size_override("font_size", 11)
			date_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
			_activity_list.add_child(date_lbl)
			_activity_list.add_child(HSeparator.new())

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var type: String = entry.get("type", "")
		var icon_lbl := Label.new()
		icon_lbl.text = _activity_icon(type)
		icon_lbl.custom_minimum_size = Vector2(26, 0)
		row.add_child(icon_lbl)

		var text_lbl := RichTextLabel.new()
		text_lbl.bbcode_enabled = true
		text_lbl.fit_content = true
		text_lbl.scroll_active = false
		text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_lbl.push_color(_activity_color(type))
		text_lbl.append_text(_todo_bbcode(entry.get("text", "")))
		text_lbl.pop()
		row.add_child(text_lbl)

		var time_lbl := Label.new()
		time_lbl.text = ts.substr(11, 5) if ts.length() >= 16 else ""
		time_lbl.add_theme_font_size_override("font_size", 11)
		time_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		row.add_child(time_lbl)

		_activity_list.add_child(row)

func _activity_icon(type: String) -> String:
	match type:
		"task_completed": return "✅"
		"addon_created":  return "✨"
		"addon_cloned":   return "📥"
		"addon_removed":  return "🗑"
		"addon_synced":   return "↺"
		"todo_added":     return "➕"
		_:                return "•"

func _activity_color(type: String) -> Color:
	match type:
		"task_completed": return Color(0.4, 0.9, 0.4)
		"addon_created":  return Color(0.4, 0.8, 1.0)
		"addon_cloned":   return Color(0.6, 0.6, 1.0)
		"addon_removed":  return Color(1.0, 0.5, 0.4)
		"addon_synced":   return Color(1.0, 0.85, 0.3)
		"todo_added":     return Color(0.75, 0.75, 0.75)
		_:                return Color(0.6, 0.6, 0.6)
