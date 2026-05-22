@tool
extends Control

const Ops = preload("res://addons/ChillCube_Tools/addon_ops.gd")

# ─── Node refs ───────────────────────────────────────────────────────────────

var _addon_list: VBoxContainer
var _installed_log: TextEdit
var _create_name: LineEdit
var _create_desc: LineEdit
var _create_author: LineEdit
var _create_category: OptionButton
var _create_gh: CheckBox
var _create_btn: Button
var _create_log: TextEdit
var _clone_url: LineEdit
var _clone_btn: Button
var _push_btn: Button
var _update_plugin_btn: Button

var _dep_graph: GraphEdit
var _dep_nodes: Dictionary       # eid -> GraphNode
var _dep_node_folders: Dictionary  # eid -> folder  (installed addons only)
var _dep_node_urls: Dictionary   # eid -> cleaned url
var _dep_selected: String = ""
var _dep_side_content: VBoxContainer
var _dep_url_input: LineEdit
var _dep_show_all_btn: CheckButton
var _registry_entries: Array = []

var _term_output: TextEdit
var _term_input: LineEdit
var _term_cwd_label: Label
var _term_run_btn: Button
var _term_cwd: String = ""
var _term_history: Array[String] = []
var _term_hist_idx: int = -1
var _term_thread: Thread = null

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
	_build_add_addon_tab(tabs)
	_build_deps_tab(tabs)
	_build_terminal_tab(tabs)

	_refresh_addons()

func _exit_tree() -> void:
	if _thread and _thread.is_started():
		_thread.wait_to_finish()
	if _term_thread and _term_thread.is_started():
		_term_thread.wait_to_finish()

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
	_create_desc = _field(grid, "Description")
	_create_author = _field(grid, "Author")
	var cat_lbl := Label.new()
	cat_lbl.text = "Category:"
	grid.add_child(cat_lbl)
	_create_category = OptionButton.new()
	_create_category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_create_category.add_item("Loading…")
	grid.add_child(_create_category)
	left.add_child(grid)

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
	refresh_btn.pressed.connect(_refresh_deps)
	_dep_show_all_btn = CheckButton.new()
	_dep_show_all_btn.text = "Show all registry addons"
	_dep_show_all_btn.toggled.connect(func(_v): _refresh_deps())
	toolbar.add_child(refresh_btn)
	toolbar.add_child(_dep_show_all_btn)
	root.add_child(toolbar)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_dep_graph = GraphEdit.new()
	_dep_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dep_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dep_graph.connection_request.connect(_dep_on_connect)
	_dep_graph.disconnection_request.connect(_dep_on_disconnect)
	_dep_graph.node_selected.connect(_dep_on_node_selected)
	split.add_child(_dep_graph)

	split.add_child(VSeparator.new())

	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(220, 0)

	var hint := Label.new()
	hint.text = "Click a node to edit its dependencies.\nDrag from the green ● to add a dependency."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	side.add_child(hint)
	side.add_child(HSeparator.new())

	_dep_side_content = VBoxContainer.new()
	_dep_side_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(_dep_side_content)

	side.add_child(HSeparator.new())
	var ext_lbl := Label.new()
	ext_lbl.text = "Add external dependency URL:"
	side.add_child(ext_lbl)
	_dep_url_input = LineEdit.new()
	_dep_url_input.placeholder_text = "https://github.com/ChillCube/…"
	side.add_child(_dep_url_input)
	var add_ext_btn := Button.new()
	add_ext_btn.text = "➕ Add to Selected"
	add_ext_btn.pressed.connect(_dep_add_external)
	side.add_child(add_ext_btn)

	split.add_child(side)
	root.add_child(split)

	_refresh_deps()

# ─── Dependency graph logic ───────────────────────────────────────────────────

func _dep_eid(folder: String, url: String) -> String:
	return folder if not folder.is_empty() else "_r_" + url.get_file()

func _refresh_deps() -> void:
	_dep_graph.clear_connections()
	for node in _dep_nodes.values():
		if is_instance_valid(node):
			node.queue_free()
	_dep_nodes = {}
	_dep_node_folders = {}
	_dep_node_urls = {}
	_dep_selected = ""
	for child in _dep_side_content.get_children():
		child.queue_free()

	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var installed_folders := Ops.list_addons(root)

	# Build all entries: installed + optionally registry-only
	var all_entries: Array = []
	var seen_urls: Array[String] = []

	for folder: String in installed_folders:
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		var url := Ops.git_remote(root + "/addons/" + folder)
		var clean_url := url.replace(".git", "").replace("git@github.com:", "https://github.com/")
		var deps := Ops.read_dep_urls(root + "/addons/" + folder)
		all_entries.append({"name": cfg.get("name", folder), "folder": folder,
			"url": clean_url, "installed": true, "deps": deps})
		if not clean_url.is_empty():
			seen_urls.append(clean_url)

	if _dep_show_all_btn.button_pressed:
		for e: Dictionary in _registry_entries:
			var raw_url: String = e.get("url", "")
			var clean := raw_url.replace(".git", "").replace("git@github.com:", "https://github.com/")
			if clean not in seen_urls and not clean.is_empty():
				all_entries.append({"name": e.get("name", clean.get_file()),
					"folder": "", "url": clean, "installed": false, "deps": []})

	# url -> eid map for connection drawing
	var url_to_eid: Dictionary = {}
	for e: Dictionary in all_entries:
		var url: String = e.get("url", "")
		if not url.is_empty():
			url_to_eid[url] = _dep_eid(e.get("folder", ""), url)

	# Compute layout depth
	var depths: Dictionary = {}
	for e: Dictionary in all_entries:
		depths[_dep_eid(e.get("folder", ""), e.get("url", ""))] = 0
	for _i in range(all_entries.size()):
		var changed := false
		for e: Dictionary in all_entries:
			var eid := _dep_eid(e.get("folder", ""), e.get("url", ""))
			for dep_url: String in e.get("deps", []):
				if dep_url in url_to_eid:
					var dep_eid: String = url_to_eid[dep_url]
					if int(depths.get(eid, 0)) <= int(depths.get(dep_eid, 0)):
						depths[eid] = int(depths[dep_eid]) + 1
						changed = true
		if not changed:
			break

	# Create graph nodes
	var col_row: Dictionary = {}
	for e: Dictionary in all_entries:
		var folder: String = e.get("folder", "")
		var url: String = e.get("url", "")
		var eid := _dep_eid(folder, url)
		var is_installed: bool = e.get("installed", false)
		var deps: Array = e.get("deps", [])

		var node := GraphNode.new()
		node.title = e.get("name", eid)
		node.name = eid
		if not is_installed:
			node.modulate = Color(0.75, 0.75, 0.75)

		var depth := int(depths.get(eid, 0))
		var row := int(col_row.get(depth, 0))
		col_row[depth] = row + 1
		node.position_offset = Vector2(depth * 260, row * (130 + deps.size() * 22))

		# Slot 0: input only — "can be depended on by others"
		var in_lbl := Label.new()
		in_lbl.text = e.get("name", eid)
		in_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		node.add_child(in_lbl)
		node.set_slot(0, true, 0, Color(0.4, 0.7, 1.0), false, 0, Color.WHITE)

		if is_installed:
			# Slots 1..N: one output per existing dep
			for i in range(deps.size()):
				var dep_lbl := Label.new()
				dep_lbl.text = (deps[i] as String).get_file()
				dep_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
				node.add_child(dep_lbl)
				node.set_slot(i + 1, false, 0, Color.WHITE, true, 0, Color(1.0, 0.75, 0.3))

			# Last slot: green "+" to drag new connections
			var add_lbl := Label.new()
			add_lbl.text = "+ add dependency"
			add_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
			node.add_child(add_lbl)
			node.set_slot(deps.size() + 1, false, 0, Color.WHITE, true, 0, Color(0.4, 0.9, 0.4))

		_dep_graph.add_child(node)
		_dep_nodes[eid] = node
		_dep_node_urls[eid] = url
		if is_installed:
			_dep_node_folders[eid] = folder

	# Draw connections using unique from_port per dep
	for e: Dictionary in all_entries:
		var folder: String = e.get("folder", "")
		var url: String = e.get("url", "")
		var eid := _dep_eid(folder, url)
		var deps: Array = e.get("deps", [])
		for i in range(deps.size()):
			var dep_url: String = deps[i]
			if dep_url in url_to_eid:
				var dep_eid: String = url_to_eid[dep_url]
				if (eid in _dep_nodes) and (dep_eid in _dep_nodes):
					_dep_graph.connect_node(eid, i + 1, dep_eid, 0)

func _dep_on_connect(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_str := str(from_node)
	var to_str := str(to_node)
	if from_str == to_str or from_str not in _dep_node_folders:
		return
	# Only accept connections from the green "+" slot (last slot)
	var gn: GraphNode = _dep_nodes.get(from_str)
	if not is_instance_valid(gn):
		return
	if from_port != gn.get_child_count() - 1:
		return
	var to_url: String = _dep_node_urls.get(to_str, "")
	if to_url.is_empty():
		return
	var from_folder: String = _dep_node_folders[from_str]
	Ops.add_dep(ProjectSettings.globalize_path("res://").rstrip("/") + "/addons/" + from_folder, to_url)
	_dep_selected = from_str
	_refresh_deps()

func _dep_on_disconnect(from_node: StringName, from_port: int, _to_node: StringName, _to_port: int) -> void:
	var from_str := str(from_node)
	if from_str not in _dep_node_folders:
		return
	var from_folder: String = _dep_node_folders[from_str]
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var deps := Ops.read_dep_urls(root + "/addons/" + from_folder)
	var dep_idx := int(from_port) - 1  # slot 1 = dep[0], slot 2 = dep[1], …
	if dep_idx >= 0 and dep_idx < deps.size():
		Ops.remove_dep(root + "/addons/" + from_folder, deps[dep_idx])
		_dep_selected = from_str
		_refresh_deps()

func _dep_on_node_selected(node: Node) -> void:
	_dep_selected = node.name
	_dep_show_side(node.name)

func _dep_show_side(eid: String) -> void:
	for child in _dep_side_content.get_children():
		child.queue_free()
	if eid.is_empty():
		return
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var is_installed := eid in _dep_node_folders

	var name_lbl := Label.new()
	name_lbl.text = ((_dep_nodes.get(eid) as GraphNode).title if eid in _dep_nodes else eid)
	name_lbl.add_theme_font_size_override("font_size", 13)
	_dep_side_content.add_child(name_lbl)

	if not is_installed:
		var hint := Label.new()
		hint.text = "Not installed — install via Browse or Clone tab to edit dependencies."
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_dep_side_content.add_child(hint)
		return

	var folder: String = _dep_node_folders[eid]
	var dep_heading := Label.new()
	dep_heading.text = "Dependencies:"
	_dep_side_content.add_child(dep_heading)

	var deps := Ops.read_dep_urls(root + "/addons/" + folder)
	if deps.is_empty():
		var none_lbl := Label.new()
		none_lbl.text = "(none)"
		none_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_dep_side_content.add_child(none_lbl)
	else:
		for dep_url: String in deps:
			var row := HBoxContainer.new()
			var dep_lbl := Label.new()
			dep_lbl.text = dep_url.get_file()
			dep_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			dep_lbl.clip_text = true
			dep_lbl.tooltip_text = dep_url
			var rm_btn := Button.new()
			rm_btn.text = "✕"
			var cap_folder := folder
			var cap_url := dep_url
			rm_btn.pressed.connect(func():
				Ops.remove_dep(root + "/addons/" + cap_folder, cap_url)
				_dep_selected = eid
				_refresh_deps()
			)
			row.add_child(dep_lbl)
			row.add_child(rm_btn)
			_dep_side_content.add_child(row)

func _dep_add_external() -> void:
	if _dep_selected.is_empty() or _dep_selected not in _dep_node_folders:
		return
	var url := _dep_url_input.text.strip_edges()
	if url.is_empty():
		return
	var folder: String = _dep_node_folders[_dep_selected]
	var clean := url.replace(".git", "").replace("git@github.com:", "https://github.com/")
	Ops.add_dep(ProjectSettings.globalize_path("res://").rstrip("/") + "/addons/" + folder, clean)
	_dep_url_input.text = ""
	_refresh_deps()

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

	for folder: String in addons:
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
		var copy_btn := Button.new()
		copy_btn.text = "🔗"
		if url.is_empty():
			copy_btn.disabled = true
			copy_btn.tooltip_text = "No GitHub remote found"
		else:
			copy_btn.tooltip_text = url
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
			sync_btn.tooltip_text = "Pull latest from " + url
			sync_btn.pressed.connect(func():
				_installed_log.text = ""
				_run_op(sync_btn, _installed_log, func():
					Ops.sync_addon(
						ProjectSettings.globalize_path("res://").rstrip("/"),
						captured_url,
						func(msg): call_deferred("_append_log", _installed_log, msg)
					)
					call_deferred("_refresh_addons")
				)
			)
		row.add_child(sync_btn)

		var rm_btn := Button.new()
		rm_btn.text = "🗑️"
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
	_run_op(_push_btn, _installed_log, func():
		Ops.push_all(
			ProjectSettings.globalize_path("res://").rstrip("/"),
			func(msg): call_deferred("_append_log", _installed_log, msg)
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
