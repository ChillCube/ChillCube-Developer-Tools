@tool
extends Control

const Ops = preload("res://addons/ChillCube_Tools/addon_ops.gd")

# ─── Node refs ───────────────────────────────────────────────────────────────

var _addon_list: VBoxContainer
var _installed_log: TextEdit
var _installed_search_input: LineEdit
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

var _ws_addon_list: VBoxContainer
var _ws_editor_area: VBoxContainer
var _ws_dep_area: VBoxContainer
var _ws_selected: String = ""
var _ws_script_tabs: TabContainer
var _ws_editors: Dictionary = {}
var _ws_status_lbl: Label
var _ws_save_btn: Button
var _ws_dirty: bool = false
var _ws_known_classes: Array = []
var _ws_completion_cache: Array = []
var _ws_error_panel: VBoxContainer
var _ws_find_bar: HBoxContainer
var _ws_find_input: LineEdit
var _ws_check_gen: Dictionary = {}
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
var _todo_status_lbl: Label
var _todo_items: Array = []
var _todo_thread: Thread = null
var _todo_editing_idx: int = -1
var _todo_active_tag: String = ""
var _todo_tag_bar: HBoxContainer

var _asset_meta: Dictionary = {}

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
var _vault_pending_delete: String = ""
var _vault_delete_dialog: ConfirmationDialog
var _vault_download_dest_path: String = ""
var _vault_download_dest_btn: Button
var _vault_dir_dialog: EditorFileDialog
var _vault_status_lbl: Label
var _vault_refresh_btn: Button
var _vault_log: TextEdit
var _vault_thread: Thread = null
var _vault_cache: String = ""
var _vault_file_dialog: EditorFileDialog
var _vault_files: Array[String] = []
var _vault_sel_files: Array[String] = []
var _vault_sel_count_lbl: Label
var _vault_edit_sel_btn: Button
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
var _vault_gif_frame_container: HFlowContainer
var _vault_move_dialog: AcceptDialog
var _vault_move_dest_input: LineEdit
var _vault_newdir_dialog: AcceptDialog
var _vault_newdir_input: LineEdit

var _docs_browser: VBoxContainer
var _docs_path_lbl: Label
var _docs_title_lbl: Label
var _docs_current_dir: String = ""
var _docs_sel_path: String = ""
var _docs_files: Array[String] = []
var _docs_view: RichTextLabel
var _docs_view_scroll: ScrollContainer
var _docs_editor: TextEdit
var _docs_view_panel: VBoxContainer
var _docs_edit_btn: Button
var _docs_delete_header_btn: Button
var _docs_archive_suggest_btn: Button
var _docs_save_btn: Button
var _docs_cancel_btn: Button
var _docs_status_lbl: Label
var _docs_thread: Thread = null
var _docs_loaded_content: String = ""
var _docs_new_dialog: AcceptDialog
var _docs_new_input: LineEdit
var _docs_newdir_dialog: AcceptDialog
var _docs_newdir_input: LineEdit
var _docs_delete_dialog: ConfirmationDialog
var _docs_pending_delete: String = ""
var _docs_move_dialog: AcceptDialog
var _docs_move_input: LineEdit
var _docs_move_folder_btn: OptionButton
var _docs_move_folder_items: Array[String] = []
var _docs_new_doc_btn: Button
var _docs_new_dir_btn: Button

var _docs_permissions: Dictionary = {}  # full_path -> {"mode": "anyone"|"specific", "users": [...]}
var _docs_perm_btn: Button
var _docs_perm_dialog: AcceptDialog
var _docs_perm_mode: OptionButton
var _docs_perm_user_section: VBoxContainer
var _docs_perm_user_list: VBoxContainer
var _docs_perm_input: LineEdit
var _docs_perm_path: String = ""

var _docs_suggestions: Array = []
var _docs_suggest_btn: Button
var _docs_review_btn: Button
var _docs_suggest_submit_btn: Button
var _docs_in_suggest_mode: bool = false
var _docs_review_dialog: AcceptDialog
var _docs_review_list: VBoxContainer
var _docs_review_view: RichTextLabel

var _docs_perm_vote_check: CheckBox
var _docs_perm_vote_section: VBoxContainer
var _docs_perm_vote_thresh: OptionButton

var _docs_diff_dialog: AcceptDialog
var _docs_diff_left: RichTextLabel
var _docs_diff_right: RichTextLabel

var _http: HTTPRequest
var _registry_list: VBoxContainer
var _registry_status: Label
var _browse_log: TextEdit
var _registry_installed: Dictionary  # url -> folder name
var _browse_search_input: LineEdit
var _browse_tag_bar: HBoxContainer
var _browse_active_tag: String = ""

var _activity_items: Array = []
var _activity_list: VBoxContainer
var _activity_status_lbl: Label
var _activity_thread: Thread = null
var _activity_push_pending: bool = false
var _activity_comments_open: Dictionary = {}  # idx -> bool

var _vote_items: Array = []
var _vote_list: VBoxContainer
var _decision_log_list: VBoxContainer
var _decisions_status_lbl: Label
var _decisions_create_box: VBoxContainer
var _decisions_participant_list: VBoxContainer
var _decisions_participant_checks: Dictionary = {}
var _vote_status_lbl: Label
var _vote_create_box: Control
var _vote_thread: Thread = null
var _vote_comments_open: Dictionary = {}  # idx -> bool
const REVOTE_TIMEOUT_HOURS := 24

var _schedule_items: Array = []
var _schedule_list: VBoxContainer
var _schedule_status_lbl: Label
var _schedule_create_box: Control
var _schedule_edit_dialog: AcceptDialog
var _schedule_edit_idx: int = -1
var _schedule_edit_title: LineEdit
var _schedule_edit_date: LineEdit
var _schedule_edit_time: LineEdit
var _schedule_edit_desc: TextEdit

var _ideas_items: Array = []
var _ideas_list: VBoxContainer
var _ideas_status_lbl: Label
var _ideas_thread: Thread = null
var _ideas_comments_open: Dictionary = {}  # orig_idx -> bool

var _forum_items: Array = []
var _forum_content: VBoxContainer
var _forum_thread_idx: int = -1  # -1 = list view

var _contract_items: Dictionary = {}  # addon_name -> {symbols: [...], registered_at: "..."}
var _deps_items: Dictionary = {}       # depender -> {requires: {provider: [sym_names]}}
var _contract_errors: Array = []
var _contracts_status_lbl: Label
var _contracts_scroll_list: VBoxContainer

var _current_user: Dictionary = {}
var _login_overlay: Control
var _login_status_lbl: Label
var _reg_status_lbl: Label
var _account_status_lbl: Label
var _pending_list: VBoxContainer
var _login_thread: Thread = null

var _thread: Thread = null

# ─── Elections ────────────────────────────────────────────────────────────────
var _election_data: Dictionary = {}
var _election_sel_role: String = ""
var _election_members: Array = []
var _election_thread: Thread = null
var _election_status_lbl: Label
var _election_role_opt: OptionButton
var _election_member_list: VBoxContainer
var _election_desc_rtl: RichTextLabel
var _election_desc_edit: TextEdit
var _election_edit_desc_btn: Button
var _election_save_desc_btn: Button
var _election_cancel_desc_btn: Button
var _election_candidate_btn: Button
var _election_pending_lbl: Label
var _election_settings_dialog: AcceptDialog
var _election_settings_inner: VBoxContainer

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
	_build_team_supertab(tabs)
	_build_vault_tab(tabs)
	_build_terminal_tab(tabs)
	_build_account_tab(tabs)

	_refresh_addons()
	_vault_connect()
	_load_activity()
	_load_votes()
	_load_asset_meta()
	_load_contracts()
	_load_doc_permissions()
	_load_doc_suggestions()
	_load_elections()

	_login_overlay = _build_login_overlay()
	_login_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_login_overlay)
	_session_restore()

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
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	if _activity_thread and _activity_thread.is_started():
		_activity_thread.wait_to_finish()
	if _vote_thread and _vote_thread.is_started():
		_vote_thread.wait_to_finish()
	if _ideas_thread and _ideas_thread.is_started():
		_ideas_thread.wait_to_finish()
	if _login_thread and _login_thread.is_started():
		_login_thread.wait_to_finish()
	if _election_thread and _election_thread.is_started():
		_election_thread.wait_to_finish()

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
	_build_workspace_tab(inner_tabs)

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

	var search_row := HBoxContainer.new()
	search_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var search_icon := Label.new()
	search_icon.text = "🔍"
	_installed_search_input = LineEdit.new()
	_installed_search_input.placeholder_text = "Search installed addons..."
	_installed_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_installed_search_input.text_changed.connect(func(_t: String): _refresh_addons())
	search_row.add_child(search_icon)
	search_row.add_child(_installed_search_input)
	root.add_child(search_row)

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

# ─── Workspace tab ────────────────────────────────────────────────────────────

func _build_workspace_tab(tabs: TabContainer) -> void:
	var root_vbox := _vbox("Workspace", tabs)

	var toolbar := HBoxContainer.new()
	_ws_status_lbl = Label.new()
	_ws_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ws_status_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	_ws_save_btn = Button.new()
	_ws_save_btn.text = "💾 Save All"
	_ws_save_btn.disabled = true
	_ws_save_btn.pressed.connect(_ws_save_scripts)
	var refresh_btn := Button.new()
	refresh_btn.text = "↺"
	refresh_btn.tooltip_text = "Refresh addon list"
	refresh_btn.pressed.connect(_ws_refresh_list)
	toolbar.add_child(_ws_status_lbl)
	toolbar.add_child(_ws_save_btn)
	toolbar.add_child(refresh_btn)
	root_vbox.add_child(toolbar)
	root_vbox.add_child(HSeparator.new())

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(split)

	# Left panel: addon list (top half) + deps (bottom half)
	var left_panel := VBoxContainer.new()
	left_panel.custom_minimum_size = Vector2(200, 0)
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(left_panel)
	split.add_child(VSeparator.new())

	var addon_scroll := ScrollContainer.new()
	addon_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	addon_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ws_addon_list = VBoxContainer.new()
	_ws_addon_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	addon_scroll.add_child(_ws_addon_list)
	left_panel.add_child(addon_scroll)
	left_panel.add_child(HSeparator.new())

	var dep_scroll := ScrollContainer.new()
	dep_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dep_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ws_dep_area = VBoxContainer.new()
	_ws_dep_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dep_scroll.add_child(_ws_dep_area)
	left_panel.add_child(dep_scroll)

	# Middle: script editor (full remaining width)
	_ws_editor_area = VBoxContainer.new()
	_ws_editor_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ws_editor_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(_ws_editor_area)

	_ws_refresh_list()

func _ws_refresh_list() -> void:
	for child in _ws_addon_list.get_children():
		child.queue_free()

	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var folders := Ops.list_addons(project_root)

	if folders.is_empty():
		var lbl := Label.new()
		lbl.text = "No addons installed."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_ws_addon_list.add_child(lbl)
		_ws_selected = ""
		_ws_rebuild_editor()
		_ws_rebuild_deps()
		return

	if _ws_selected not in folders:
		_ws_selected = folders[0]

	for folder: String in folders:
		var cfg := Ops.parse_cfg(project_root + "/addons/" + folder + "/plugin.cfg")
		var btn := Button.new()
		btn.text = cfg.get("name", folder)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		if folder == _ws_selected:
			btn.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
		var cap := folder
		btn.pressed.connect(func():
			if _ws_dirty:
				_ws_save_scripts()
			_ws_selected = cap
			_ws_refresh_list()
		)
		_ws_addon_list.add_child(btn)

	_ws_rebuild_editor()
	_ws_rebuild_deps()

func _ws_rebuild_editor() -> void:
	for child in _ws_editor_area.get_children():
		child.queue_free()
	_ws_editors = {}
	_ws_check_gen = {}
	_ws_dirty = false
	_ws_error_panel = null
	_ws_find_bar = null
	_ws_find_input = null
	if is_instance_valid(_ws_save_btn):
		_ws_save_btn.disabled = true
	if is_instance_valid(_ws_status_lbl):
		_ws_status_lbl.text = ""

	if _ws_selected.is_empty():
		var hint := Label.new()
		hint.text = "Select an addon on the left."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		_ws_editor_area.add_child(hint)
		return

	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var addon_path := project_root + "/addons/" + _ws_selected
	var scripts := _find_gd_files(addon_path)
	scripts.sort()

	if scripts.is_empty():
		var hint := Label.new()
		hint.text = "No .gd scripts found in this addon."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_ws_editor_area.add_child(hint)
		return

	_ws_known_classes = _ws_build_known_classes(addon_path)
	_ws_completion_cache = _ws_build_completion_cache(addon_path)

	_ws_script_tabs = TabContainer.new()
	_ws_script_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_ws_script_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ws_editor_area.add_child(_ws_script_tabs)

	var err_icon: Texture2D = EditorInterface.get_editor_theme().get_icon("Error", "EditorIcons")

	for script_path: String in scripts:
		var content := ""
		var f := FileAccess.open(script_path, FileAccess.READ)
		if f:
			content = f.get_as_text()
			f.close()

		var editor := CodeEdit.new()
		editor.name = script_path.get_file()
		editor.text = content
		editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		editor.gutters_draw_line_numbers = true
		editor.gutters_draw_fold_gutter = true
		editor.auto_brace_completion_enabled = true
		editor.indent_automatic = true
		editor.indent_use_spaces = false
		editor.minimap_draw = true
		editor.draw_tabs = true
		editor.code_completion_enabled = true
		editor.syntax_highlighter = GDScriptSyntaxHighlighter.new()

		# Custom gutter for dep errors (index 0 in custom gutter space)
		editor.add_gutter()
		editor.set_gutter_name(0, "dep_errors")
		editor.set_gutter_type(0, TextEdit.GUTTER_TYPE_ICON)
		editor.set_gutter_width(0, 16)

		editor.text_changed.connect(func():
			_ws_dirty = true
			if is_instance_valid(_ws_save_btn):
				_ws_save_btn.disabled = false
			_ws_schedule_check(editor, addon_path, err_icon)
			editor.request_code_completion()
		)

		editor.code_completion_requested.connect(func():
			_ws_provide_completion(editor)
		)

		editor.gui_input.connect(func(event: InputEvent):
			if not (event is InputEventKey):
				return
			var ke := event as InputEventKey
			if not ke.pressed:
				return
			if ke.ctrl_pressed and ke.keycode == KEY_S:
				get_viewport().set_input_as_handled()
				_ws_save_scripts()
			elif ke.ctrl_pressed and ke.keycode == KEY_F:
				get_viewport().set_input_as_handled()
				_ws_toggle_find()
			elif ke.keycode == KEY_ESCAPE:
				if is_instance_valid(_ws_find_bar) and _ws_find_bar.visible:
					get_viewport().set_input_as_handled()
					_ws_find_bar.visible = false
		)

		_ws_script_tabs.add_child(editor)
		_ws_editors[script_path] = editor
		_ws_run_check(editor, addon_path, err_icon)

	# Find bar (hidden by default, shown by Ctrl+F)
	_ws_find_bar = HBoxContainer.new()
	_ws_find_bar.visible = false
	var find_lbl := Label.new()
	find_lbl.text = "Find:"
	_ws_find_input = LineEdit.new()
	_ws_find_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ws_find_input.placeholder_text = "Search in file…"
	var find_prev_btn := Button.new()
	find_prev_btn.text = "▲"
	find_prev_btn.tooltip_text = "Previous match"
	var find_next_btn := Button.new()
	find_next_btn.text = "▼"
	find_next_btn.tooltip_text = "Next match"
	var find_close_btn := Button.new()
	find_close_btn.text = "✕"
	_ws_find_bar.add_child(find_lbl)
	_ws_find_bar.add_child(_ws_find_input)
	_ws_find_bar.add_child(find_prev_btn)
	_ws_find_bar.add_child(find_next_btn)
	_ws_find_bar.add_child(find_close_btn)
	_ws_editor_area.add_child(_ws_find_bar)
	find_prev_btn.pressed.connect(func(): _ws_find_next(true))
	find_next_btn.pressed.connect(func(): _ws_find_next(false))
	find_close_btn.pressed.connect(func():
		if is_instance_valid(_ws_find_bar):
			_ws_find_bar.visible = false
	)
	_ws_find_input.text_submitted.connect(func(_t: String): _ws_find_next(false))

	# Error panel (populated by dep check, hidden when clean)
	_ws_error_panel = VBoxContainer.new()
	_ws_error_panel.visible = false
	_ws_editor_area.add_child(_ws_error_panel)

func _ws_rebuild_deps() -> void:
	for child in _ws_dep_area.get_children():
		child.queue_free()

	if _ws_selected.is_empty():
		var hint := Label.new()
		hint.text = "Select an addon to view its dependencies."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_ws_dep_area.add_child(hint)
		return

	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var folder := _ws_selected
	var cfg := Ops.parse_cfg(project_root + "/addons/" + folder + "/plugin.cfg")

	var title := Label.new()
	title.text = cfg.get("name", folder)
	title.add_theme_font_size_override("font_size", 13)
	_ws_dep_area.add_child(title)
	_ws_dep_area.add_child(HSeparator.new())

	var dep_hdr := Label.new()
	dep_hdr.text = "Dependencies"
	_ws_dep_area.add_child(dep_hdr)

	var deps := Ops.read_dep_urls(project_root + "/addons/" + folder)
	if deps.is_empty():
		var none := Label.new()
		none.text = "(none)"
		none.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_ws_dep_area.add_child(none)
	else:
		for dep_url: String in deps:
			var row := HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var lbl := Label.new()
			lbl.text = _url_to_display_name(dep_url)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.tooltip_text = dep_url
			lbl.clip_text = true
			var rm := Button.new()
			rm.text = "✕"
			var cap_url := dep_url
			rm.pressed.connect(func():
				Ops.remove_dep(project_root + "/addons/" + folder, cap_url)
				_ws_rebuild_deps()
			)
			row.add_child(lbl)
			row.add_child(rm)
			_ws_dep_area.add_child(row)

	_ws_dep_area.add_child(HSeparator.new())
	var add_hdr := Label.new()
	add_hdr.text = "Add dependency:"
	_ws_dep_area.add_child(add_hdr)

	_dep_search_widget(_ws_dep_area, _build_dep_candidates(folder, deps), func(url: String):
		Ops.add_dep(project_root + "/addons/" + folder, url)
		_ws_rebuild_deps()
	)

func _ws_save_scripts() -> void:
	var saved := 0
	for path: String in _ws_editors:
		var ed: CodeEdit = _ws_editors[path]
		var fw := FileAccess.open(path, FileAccess.WRITE)
		if fw:
			fw.store_string(ed.text)
			fw.close()
			saved += 1
	EditorInterface.get_resource_filesystem().scan()
	_ws_dirty = false
	if is_instance_valid(_ws_save_btn):
		_ws_save_btn.disabled = true
	if is_instance_valid(_ws_status_lbl):
		_ws_status_lbl.text = "✅ Saved %d file(s)" % saved
		_ws_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		get_tree().create_timer(2.5).timeout.connect(func():
			if is_instance_valid(_ws_status_lbl) and not _ws_dirty:
				_ws_status_lbl.text = ""
		)

# ─── Workspace: known-class cache ────────────────────────────────────────────

func _ws_build_known_classes(addon_path: String) -> Array:
	var classes: Array = []
	for cls: String in ClassDB.get_class_list():
		classes.append(cls)
	# Add primitive/script types not always in ClassDB
	for builtin: String in ["int", "float", "bool", "String", "StringName", "NodePath",
			"Vector2", "Vector2i", "Vector3", "Vector3i", "Vector4", "Vector4i",
			"Color", "Rect2", "Rect2i", "Transform2D", "Transform3D", "Basis",
			"Quaternion", "Plane", "AABB", "RID", "Callable", "Signal",
			"Array", "Dictionary", "PackedByteArray", "PackedInt32Array",
			"PackedInt64Array", "PackedFloat32Array", "PackedFloat64Array",
			"PackedStringArray", "PackedVector2Array", "PackedVector3Array",
			"PackedColorArray", "Variant"]:
		if not classes.has(builtin):
			classes.append(builtin)
	# Add class_name declarations from declared dep addons
	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var deps := Ops.read_dep_urls(addon_path)
	var cname_re := RegEx.new()
	cname_re.compile("^class_name\\s+(\\w+)")
	for dep_url: String in deps:
		var norm_dep := dep_url.rstrip("/").replace(".git", "")
		for folder: String in Ops.list_addons(project_root):
			var dep_folder_path := project_root + "/addons/" + folder
			var remote := Ops.git_remote(dep_folder_path).rstrip("/").replace(".git", "")
			if remote == norm_dep:
				for gf: String in _find_gd_files(dep_folder_path):
					var gf_file := FileAccess.open(gf, FileAccess.READ)
					if not gf_file:
						continue
					for line: String in gf_file.get_as_text().split("\n"):
						var m := cname_re.search(line.strip_edges())
						if m:
							var cname := m.get_string(1)
							if not classes.has(cname):
								classes.append(cname)
					gf_file.close()
	return classes

# ─── Workspace: completion cache (built once per addon selection) ─────────────

func _ws_build_completion_cache(addon_path: String) -> Array:
	var cache: Array = []
	for kw: String in _WS_KEYWORDS:
		cache.append({"k": CodeEdit.KIND_PLAIN_TEXT, "d": kw, "i": kw})
	for cls: String in _ws_known_classes:
		cache.append({"k": CodeEdit.KIND_CLASS, "d": cls, "i": cls})
	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var deps := Ops.read_dep_urls(addon_path)
	for dep_url: String in deps:
		var norm_dep := dep_url.rstrip("/").replace(".git", "")
		for folder: String in Ops.list_addons(project_root):
			var dep_folder_path := project_root + "/addons/" + folder
			var remote := Ops.git_remote(dep_folder_path).rstrip("/").replace(".git", "")
			if remote != norm_dep:
				continue
			for sym: Dictionary in Ops.extract_api(dep_folder_path):
				var kind_str: String = sym.get("kind", "")
				var sym_name: String = sym.get("name", "")
				if sym_name.is_empty():
					continue
				if kind_str == "func":
					var sig_str: String = sym.get("signature", "()")
					cache.append({"k": CodeEdit.KIND_FUNCTION,
						"d": sym_name + sig_str, "i": sym_name + "("})
				elif kind_str == "export_var":
					cache.append({"k": CodeEdit.KIND_VARIABLE, "d": sym_name, "i": sym_name})
				elif kind_str == "signal":
					cache.append({"k": CodeEdit.KIND_SIGNAL, "d": sym_name, "i": sym_name})
	return cache

# ─── Workspace: code completion ──────────────────────────────────────────────

var _WS_KEYWORDS: PackedStringArray = PackedStringArray([
	"var", "const", "func", "class", "class_name", "extends", "return",
	"if", "elif", "else", "for", "while", "break", "continue", "pass",
	"and", "or", "not", "in", "is", "as", "null", "true", "false",
	"self", "super", "static", "signal", "enum", "match", "await",
	"@tool", "@export", "@export_range", "@export_enum", "@export_flags",
	"@export_group", "@export_subgroup", "@onready", "@static_unload",
	"@warning_ignore", "preload", "load", "print", "printerr",
	"push_error", "push_warning", "get_tree", "get_parent", "add_child",
	"queue_free", "call_deferred", "set_deferred", "is_instance_valid",
	"typeof", "len", "abs", "sign", "ceil", "floor", "round", "sqrt",
	"pow", "max", "min", "clamp", "lerp", "remap", "deg_to_rad",
	"rad_to_deg", "sin", "cos", "tan", "atan2", "snapped", "randf",
	"randi", "randf_range", "randi_range", "seed", "randomize",
	"emit_signal", "connect", "disconnect", "has_signal", "new", "free"
])

func _ws_provide_completion(editor: CodeEdit) -> void:
	for item: Dictionary in _ws_completion_cache:
		editor.add_code_completion_option(item["k"] as int, item["d"], item["i"])
	# Also include functions defined in the current file
	var fn_re := RegEx.new()
	fn_re.compile("^(?:static\\s+)?func\\s+(\\w+)\\s*\\(")
	for line: String in editor.text.split("\n"):
		var m := fn_re.search(line.strip_edges())
		if m:
			var fn_name := m.get_string(1)
			editor.add_code_completion_option(CodeEdit.KIND_FUNCTION, fn_name + "()", fn_name + "(")
	editor.update_code_completion_options(true)

# ─── Workspace: dep-class check ──────────────────────────────────────────────

func _ws_schedule_check(editor: CodeEdit, addon_path: String, err_icon: Texture2D) -> void:
	var gen: int = (_ws_check_gen.get(editor, 0) as int) + 1
	_ws_check_gen[editor] = gen
	var cap_gen := gen
	get_tree().create_timer(0.8).timeout.connect(func():
		if not is_instance_valid(editor):
			return
		if (_ws_check_gen.get(editor, 0) as int) == cap_gen:
			_ws_run_check(editor, addon_path, err_icon)
	)

func _ws_run_check(editor: CodeEdit, addon_path: String, err_icon: Texture2D) -> void:
	# Clear previous gutter markers
	for i in editor.get_line_count():
		editor.set_line_gutter_icon(i, 0, null)

	var errors := _ws_check_dep_classes(editor.text, addon_path)

	# Binary syntax check — strip class_name declarations first to avoid
	# "hides a global script class" errors from re-registering already-loaded classes
	var stripped: PackedStringArray = []
	for line: String in editor.text.split("\n"):
		if line.strip_edges().begins_with("class_name "):
			stripped.append("")
		else:
			stripped.append(line)
	var gs := GDScript.new()
	gs.source_code = "\n".join(stripped)
	var rc := gs.reload()
	var syntax_ok := rc == OK

	# Gutter markers for dep errors
	for err: Dictionary in errors:
		var line_idx: int = err.get("line", 0) as int
		if line_idx >= 0 and line_idx < editor.get_line_count():
			editor.set_line_gutter_icon(line_idx, 0, err_icon)

	# Status label: syntax error takes priority, then dep-error count
	if is_instance_valid(_ws_status_lbl):
		if not syntax_ok:
			_ws_status_lbl.text = "⚠ Syntax error"
			_ws_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.55, 0.15))
		elif not errors.is_empty():
			_ws_status_lbl.text = "⚠ %d dep error(s)" % errors.size()
			_ws_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
		elif _ws_dirty:
			_ws_status_lbl.text = "● Unsaved changes"
			_ws_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
		else:
			_ws_status_lbl.text = ""

	# Error panel: dep errors only (these have real line numbers)
	if is_instance_valid(_ws_error_panel):
		for child in _ws_error_panel.get_children():
			child.queue_free()
		if errors.is_empty():
			_ws_error_panel.visible = false
		else:
			_ws_error_panel.visible = true
			for err: Dictionary in errors:
				var row := HBoxContainer.new()
				var line_num: int = (err.get("line", 0) as int) + 1
				var lbl := Label.new()
				lbl.text = "Line %d: %s" % [line_num, err.get("msg", "")]
				lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
				lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				lbl.clip_text = true
				lbl.tooltip_text = lbl.text
				var jump_btn := Button.new()
				jump_btn.text = "→"
				jump_btn.tooltip_text = "Go to line"
				var cap_line: int = err.get("line", 0) as int
				jump_btn.pressed.connect(func():
					editor.set_caret_line(cap_line)
					editor.scroll_vertical = cap_line
					editor.grab_focus()
				)
				row.add_child(lbl)
				row.add_child(jump_btn)
				_ws_error_panel.add_child(row)

func _ws_check_dep_classes(code: String, addon_path: String) -> Array:
	var errors: Array = []
	# Patterns that reference a type name
	var patterns: Array[String] = [
		"(?:^|[^\\w])(?:var\\s+\\w+|\\w+)\\s*:\\s*([A-Z][A-Za-z0-9_]*)",  # : TypeName
		"->\\s*([A-Z][A-Za-z0-9_]*)",                                       # -> TypeName
		"\\bas\\s+([A-Z][A-Za-z0-9_]*)",                                    # as TypeName
		"([A-Z][A-Za-z0-9_]*)\\.new\\(",                                    # TypeName.new(
	]
	var compiled: Array[RegEx] = []
	for p: String in patterns:
		var re := RegEx.new()
		re.compile(p)
		compiled.append(re)

	var lines := code.split("\n")
	for line_idx in lines.size():
		var line: String = lines[line_idx]
		var stripped := line.strip_edges()
		# Skip comment lines and annotations
		if stripped.begins_with("#") or stripped.begins_with("@"):
			continue
		# Strip inline comments
		var comment_pos := line.find("#")
		var scan_line := line if comment_pos == -1 else line.left(comment_pos)

		var found_on_line: Array[String] = []
		for re: RegEx in compiled:
			for m: RegExMatch in re.search_all(scan_line):
				var type_name := m.get_string(1)
				if type_name.is_empty():
					continue
				if not found_on_line.has(type_name):
					found_on_line.append(type_name)

		for type_name: String in found_on_line:
			if not _ws_known_classes.has(type_name):
				errors.append({
					"line": line_idx,
					"msg": "Unknown class '%s' — add it as a dependency or it's not a Godot built-in" % type_name
				})

	return errors

# ─── Workspace: find bar ─────────────────────────────────────────────────────

func _ws_toggle_find() -> void:
	if not is_instance_valid(_ws_find_bar):
		return
	_ws_find_bar.visible = not _ws_find_bar.visible
	if _ws_find_bar.visible and is_instance_valid(_ws_find_input):
		_ws_find_input.grab_focus()
		_ws_find_input.select_all()

func _ws_get_active_editor() -> CodeEdit:
	if not is_instance_valid(_ws_script_tabs):
		return null
	var idx := _ws_script_tabs.current_tab
	if idx < 0 or idx >= _ws_script_tabs.get_tab_count():
		return null
	var child := _ws_script_tabs.get_child(idx)
	if child is CodeEdit:
		return child as CodeEdit
	return null

func _ws_find_next(backwards: bool) -> void:
	if not is_instance_valid(_ws_find_input):
		return
	var query := _ws_find_input.text
	if query.is_empty():
		return
	var editor := _ws_get_active_editor()
	if not is_instance_valid(editor):
		return
	var flags := 0  # TextEdit.SearchFlags
	if backwards:
		flags |= TextEdit.SEARCH_BACKWARDS
	var from_line := editor.get_caret_line()
	var from_col := editor.get_caret_column() + (0 if backwards else 1)
	var result := editor.search(query, flags, from_line, from_col)
	if result == Vector2i(-1, -1):
		# Wrap around
		var wrap_line := editor.get_line_count() - 1 if backwards else 0
		var wrap_col := editor.get_line(wrap_line).length() if backwards else 0
		result = editor.search(query, flags, wrap_line, wrap_col)
	if result != Vector2i(-1, -1):
		editor.set_caret_line(result.y)
		editor.set_caret_column(result.x)
		editor.select(result.y, result.x, result.y, result.x + query.length())
		editor.scroll_vertical = result.y

func _build_planning_tab(tabs: TabContainer) -> void:
	var outer := _vbox("Planning", tabs)
	var inner_tabs := TabContainer.new()
	inner_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(inner_tabs)
	_build_planned_subtab(inner_tabs)
	_build_ideas_subtab(inner_tabs)
	_build_bugs_subtab(inner_tabs)
	_build_todo_subtab(inner_tabs)

func _build_planned_subtab(tabs: TabContainer) -> void:
	var root := _vbox("Addons", tabs)

	var toolbar := HBoxContainer.new()
	var new_btn := Button.new()
	new_btn.text = "➕ New"
	new_btn.pressed.connect(_plan_new)
	_plan_status_lbl = Label.new()
	_plan_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_plan_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(new_btn)
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
	return ProjectSettings.globalize_path("user://cc_planned.json")

func _load_planned() -> void:
	_planned_addons = []
	var path := _plan_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		f.close()
		if parsed is Array:
			_planned_addons = parsed

func _save_planned() -> void:
	var fw := FileAccess.open(_plan_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_planned_addons, "\t"))
		fw.close()
	_activity_auto_push()

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
		var sig: String = "func %s(%s)" % [fn.get("name","_fn"), fn.get("params","")]
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

func _build_ideas_subtab(tabs: TabContainer) -> void:
	var root := _vbox("Game Ideas", tabs)

	var toolbar := HBoxContainer.new()
	var suggest_btn := Button.new()
	suggest_btn.text = "💡 Suggest Idea"
	suggest_btn.pressed.connect(_ideas_prompt_new)
	_ideas_status_lbl = Label.new()
	_ideas_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ideas_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(suggest_btn)
	toolbar.add_child(_ideas_status_lbl)
	root.add_child(toolbar)

	var hint := Label.new()
	hint.text = "Rate ideas from 1–5 ⭐. Top-rated ideas appear first."
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.add_theme_font_size_override("font_size", 11)
	root.add_child(hint)

	root.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ideas_list = VBoxContainer.new()
	_ideas_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ideas_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_ideas_list)
	root.add_child(scroll)

	_load_ideas()

func _ideas_file() -> String:
	return ProjectSettings.globalize_path("user://cc_ideas.json")

func _load_ideas() -> void:
	_ideas_items = []
	var path := _ideas_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		_ideas_items = parsed
	if is_instance_valid(_ideas_list):
		_refresh_ideas_list()

func _save_ideas() -> void:
	var fw := FileAccess.open(_ideas_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_ideas_items, "\t") + "\n")
		fw.close()

func _ideas_avg_score(idea: Dictionary) -> float:
	var ratings: Array = idea.get("ratings", [])
	if ratings.is_empty():
		return 0.0
	var total := 0.0
	for r: Dictionary in ratings:
		total += float(r.get("score", 0))
	return total / ratings.size()

func _ideas_user_rating(idea: Dictionary) -> int:
	var user: String = _current_user.get("username", "")
	if user.is_empty():
		return 0
	for r: Dictionary in idea.get("ratings", []):
		if r.get("user", "") == user:
			return int(r.get("score", 0))
	return 0

func _refresh_ideas_list() -> void:
	if not is_instance_valid(_ideas_list):
		return
	for c in _ideas_list.get_children():
		c.queue_free()

	var sorted := _ideas_items.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _ideas_avg_score(a) > _ideas_avg_score(b)
	)

	if sorted.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No ideas yet. Be the first to suggest one!"
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_ideas_list.add_child(empty_lbl)
		return

	for idea: Dictionary in sorted:
		var orig_idx := _ideas_items.find(idea)
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var card_vbox := VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 4)
		card.add_child(card_vbox)

		var top_row := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = idea.get("title", "Untitled")
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.add_theme_font_size_override("font_size", 13)
		top_row.add_child(title_lbl)

		var avg := _ideas_avg_score(idea)
		var count := (idea.get("ratings", []) as Array).size()
		var score_lbl := Label.new()
		score_lbl.text = "%.1f ⭐ (%d)" % [avg, count]
		score_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		top_row.add_child(score_lbl)

		var del_btn := Button.new()
		del_btn.text = "🗑"
		del_btn.flat = true
		del_btn.tooltip_text = "Delete idea"
		var cap_idx := orig_idx
		del_btn.pressed.connect(func():
			if cap_idx >= 0 and cap_idx < _ideas_items.size():
				_ideas_items.remove_at(cap_idx)
				_save_ideas()
				_refresh_ideas_list()
				_activity_auto_push()
		)
		top_row.add_child(del_btn)
		card_vbox.add_child(top_row)

		var desc: String = idea.get("description", "")
		if not desc.is_empty():
			var desc_lbl := Label.new()
			desc_lbl.text = desc
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
			card_vbox.add_child(desc_lbl)

		var meta_row := HBoxContainer.new()
		var by_lbl := Label.new()
		by_lbl.text = "by @" + idea.get("author", "?") + "  " + idea.get("timestamp", "").substr(0, 10)
		by_lbl.add_theme_font_size_override("font_size", 11)
		by_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		by_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		meta_row.add_child(by_lbl)

		var my_rating := _ideas_user_rating(idea)
		var rate_lbl := Label.new()
		rate_lbl.text = "Your rating:"
		rate_lbl.add_theme_font_size_override("font_size", 11)
		meta_row.add_child(rate_lbl)

		for star: int in range(1, 6):
			var star_btn := Button.new()
			star_btn.text = "★" if star <= my_rating else "☆"
			star_btn.flat = true
			star_btn.custom_minimum_size = Vector2(22, 0)
			if star <= my_rating:
				star_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
			var cap_star := star
			var cap_idea_idx := orig_idx
			star_btn.pressed.connect(func():
				if cap_idea_idx < 0 or cap_idea_idx >= _ideas_items.size():
					return
				var user: String = _current_user.get("username", "")
				if user.is_empty():
					return
				var ratings: Array = _ideas_items[cap_idea_idx].get("ratings", [])
				var found := false
				for i in range(ratings.size()):
					if (ratings[i] as Dictionary).get("user", "") == user:
						ratings[i] = {"user": user, "score": cap_star}
						found = true
						break
				if not found:
					ratings.append({"user": user, "score": cap_star})
				_ideas_items[cap_idea_idx]["ratings"] = ratings
				_save_ideas()
				_refresh_ideas_list()
				var idea_title: String = _ideas_items[cap_idea_idx].get("title", "")
				_log_activity("idea_rated", '%s rated "%s" %d/5' % [user, idea_title, cap_star])
			)
			meta_row.add_child(star_btn)

		# Comment count / toggle button
		var idea_comments: Array = idea.get("comments", [])
		var cmt_btn := Button.new()
		cmt_btn.text = "💬 %d" % idea_comments.size() if not idea_comments.is_empty() else "💬"
		cmt_btn.flat = true
		cmt_btn.add_theme_font_size_override("font_size", 11)
		cmt_btn.tooltip_text = "Show / hide comments"
		if _ideas_comments_open.get(orig_idx, false):
			cmt_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		var cap_oidx := orig_idx
		cmt_btn.pressed.connect(func():
			_ideas_comments_open[cap_oidx] = not _ideas_comments_open.get(cap_oidx, false)
			_refresh_ideas_list()
		)
		meta_row.add_child(cmt_btn)

		card_vbox.add_child(meta_row)

		# Collapsible comments section
		if _ideas_comments_open.get(orig_idx, false):
			card_vbox.add_child(HSeparator.new())
			var cmts_box := VBoxContainer.new()
			cmts_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cmts_box.add_theme_constant_override("separation", 2)

			for comment: Dictionary in idea_comments:
				var c_row := HBoxContainer.new()
				c_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var c_lbl := RichTextLabel.new()
				c_lbl.bbcode_enabled = true
				c_lbl.fit_content = true
				c_lbl.scroll_active = false
				c_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				c_lbl.push_color(Color(0.7, 0.7, 0.7))
				c_lbl.append_text("[b]@" + comment.get("user", "?") + "[/b]  " + comment.get("text", ""))
				c_lbl.pop()
				c_row.add_child(c_lbl)
				var c_time := Label.new()
				c_time.text = (comment.get("timestamp", "")).substr(11, 5)
				c_time.add_theme_font_size_override("font_size", 10)
				c_time.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
				c_row.add_child(c_time)
				cmts_box.add_child(c_row)

			var add_row := HBoxContainer.new()
			add_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var c_input := LineEdit.new()
			c_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c_input.placeholder_text = "Add a comment…"
			c_input.add_theme_font_size_override("font_size", 11)
			add_row.add_child(c_input)
			var post_btn := Button.new()
			post_btn.text = "Post"
			post_btn.add_theme_font_size_override("font_size", 11)
			var cap_post_idx := orig_idx
			var me: String = _current_user.get("username", "?")
			var post_fn := func():
				var text := c_input.text.strip_edges()
				if text.is_empty() or cap_post_idx < 0 or cap_post_idx >= _ideas_items.size():
					return
				var clist: Array = _ideas_items[cap_post_idx].get("comments", [])
				clist.append({
					"user": me,
					"text": text,
					"timestamp": Time.get_datetime_string_from_system()
				})
				_ideas_items[cap_post_idx]["comments"] = clist
				_save_ideas()
				_refresh_ideas_list()
			post_btn.pressed.connect(post_fn)
			c_input.text_submitted.connect(func(_t): post_fn.call())
			add_row.add_child(post_btn)
			cmts_box.add_child(add_row)
			card_vbox.add_child(cmts_box)

		_ideas_list.add_child(card)

func _ideas_prompt_new() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Suggest a Game Idea"
	dialog.size = Vector2i(440, 220)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	dialog.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "Title:"
	vbox.add_child(title_lbl)
	var title_edit := LineEdit.new()
	title_edit.placeholder_text = "Short catchy title…"
	title_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_edit)

	var desc_lbl := Label.new()
	desc_lbl.text = "Description (optional):"
	vbox.add_child(desc_lbl)
	var desc_edit := TextEdit.new()
	desc_edit.custom_minimum_size = Vector2(0, 60)
	desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_edit.placeholder_text = "What's the core concept?"
	vbox.add_child(desc_edit)

	dialog.confirmed.connect(func():
		var title := title_edit.text.strip_edges()
		if title.is_empty():
			return
		var user: String = _current_user.get("username", "?")
		_ideas_items.append({
			"title": title,
			"description": desc_edit.text.strip_edges(),
			"author": user,
			"timestamp": Time.get_datetime_string_from_system(),
			"ratings": []
		})
		_save_ideas()
		_refresh_ideas_list()
		_log_activity("idea_suggested", '%s suggested game idea: "%s"' % [user, title])
	)
	add_child(dialog)
	dialog.popup_centered()

func _build_bugs_subtab(tabs: TabContainer) -> void:
	var root := _vbox("Bugs", tabs)

	var toolbar := HBoxContainer.new()
	var title := Label.new()
	title.text = "Add  #bug <description>  in any .gd file, or call  ChillCubeFeedback.report()  from your game."
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
	_todo_status_lbl = Label.new()
	_todo_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(_todo_input)
	toolbar.add_child(add_btn)
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

func _feedback_file() -> String:
	return ProjectSettings.globalize_path("user://cc_feedback.json")

func _load_feedback() -> Array:
	var path := _feedback_file()
	if not FileAccess.file_exists(path):
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Array else []

func _save_feedback(items: Array) -> void:
	var fw := FileAccess.open(_feedback_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(items, "\t") + "\n")
		fw.close()

func _refresh_bugs() -> void:
	for child in _bug_list.get_children():
		child.queue_free()

	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	var plugin_dir := ProjectSettings.globalize_path((get_script() as Script).resource_path.get_base_dir())
	_bug_items = _scan_bugs(project_root, plugin_dir)

	# Prepend user feedback entries
	var feedback := _load_feedback()
	for fi in range(feedback.size()):
		var entry: Dictionary = feedback[fi]
		_bug_items.insert(fi, {
			"source": "feedback",
			"desc": entry.get("desc", ""),
			"timestamp": entry.get("timestamp", ""),
			"game": entry.get("game", ""),
			"context": entry.get("context", {}),
			"feedback_idx": fi
		})

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

		var is_feedback: bool = bug.get("source", "") == "feedback"
		var rel_path: String = (bug.get("path", "") as String).replace(project_root + "/", "")

		if is_feedback:
			check.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))

		if _bug_editing_idx == i:
			var edit := LineEdit.new()
			edit.text = bug.get("desc", "")
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			info.add_child(edit)
			var loc_lbl := Label.new()
			loc_lbl.text = "👤 " + bug.get("timestamp", "") if is_feedback else rel_path + ":" + str(int(bug.get("line", 0)) + 1)
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
			desc_lbl.text = ("👤 " if is_feedback else "") + bug.get("desc", "")
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			if is_feedback:
				desc_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.35))
			info.add_child(desc_lbl)
			var loc_lbl := Label.new()
			var game_tag: String = ("  [" + bug.get("game", "") + "]") if not (bug.get("game", "") as String).is_empty() else ""
			loc_lbl.text = "👤 User feedback" + game_tag + "  " + bug.get("timestamp", "") if is_feedback \
				else rel_path + ":" + str(int(bug.get("line", 0)) + 1)
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
	if bug.get("source", "") == "feedback":
		var items := _load_feedback()
		var idx: int = bug.get("feedback_idx", -1)
		if idx >= 0 and idx < items.size():
			items.remove_at(idx)
			_save_feedback(items)
		call_deferred("_refresh_bugs")
		return
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
	if bug.get("source", "") == "feedback":
		var items := _load_feedback()
		var fi: int = bug.get("feedback_idx", -1)
		if fi >= 0 and fi < items.size():
			(items[fi] as Dictionary)["desc"] = new_desc
			_save_feedback(items)
		_bug_editing_idx = -1
		call_deferred("_refresh_bugs")
		return
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
	return ProjectSettings.globalize_path("user://cc_todo.json")

func _load_todo() -> void:
	_todo_items = []
	var path := _todo_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		_todo_items = parsed

func _save_todo() -> void:
	var fw := FileAccess.open(_todo_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_todo_items, "\t") + "\n")
		fw.close()
	_activity_auto_push()

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
			_log_activity("task_completed", 'Task completed: "%s"' % done_text)
			_refresh_todo()
		)
		row.add_child(check)

		if _todo_editing_idx == i:
			var fields := VBoxContainer.new()
			fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			fields.add_theme_constant_override("separation", 2)
			var edit := LineEdit.new()
			edit.text = item.get("text", "")
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			edit.placeholder_text = "Task text… use #tag for hashtags"
			fields.add_child(edit)
			var assign_row := HBoxContainer.new()
			var assign_lbl := Label.new()
			assign_lbl.text = "Assign:"
			assign_lbl.add_theme_font_size_override("font_size", 11)
			assign_lbl.custom_minimum_size = Vector2(44, 0)
			assign_row.add_child(assign_lbl)
			var assign_edit := LineEdit.new()
			assign_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			assign_edit.placeholder_text = "username (leave blank to unassign)"
			assign_edit.add_theme_font_size_override("font_size", 11)
			assign_edit.text = item.get("assigned_to", "")
			assign_row.add_child(assign_edit)
			fields.add_child(assign_row)
			row.add_child(fields)
			var cap_edit := edit
			var cap_assign := assign_edit
			var confirm_btn := Button.new()
			confirm_btn.text = "✓"
			confirm_btn.pressed.connect(func():
				_todo_items[cap_i]["text"] = cap_edit.text.strip_edges()
				var assignee := cap_assign.text.strip_edges().lstrip("@")
				if assignee.is_empty():
					_todo_items[cap_i].erase("assigned_to")
				else:
					_todo_items[cap_i]["assigned_to"] = assignee
				_save_todo()
				_todo_editing_idx = -1
				_refresh_todo()
			)
			edit.text_submitted.connect(func(_t): confirm_btn.pressed.emit())
			row.add_child(confirm_btn)
		else:
			var lbl := RichTextLabel.new()
			lbl.bbcode_enabled = true
			lbl.fit_content = true
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.scroll_active = false
			var base_color: Color = Color(0.4, 0.4, 0.4) if item.get("done", false) else Color(1, 1, 1)
			lbl.push_color(base_color)
			lbl.append_text(_todo_bbcode(item.get("text", ""), item.get("done", false)))
			lbl.pop()
			row.add_child(lbl)
			var assignee: String = item.get("assigned_to", "")
			if not assignee.is_empty():
				var a_lbl := Label.new()
				a_lbl.text = "@" + assignee
				a_lbl.add_theme_font_size_override("font_size", 11)
				a_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
				a_lbl.tooltip_text = "Assigned to " + assignee
				row.add_child(a_lbl)
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
	_log_activity("todo_added", 'Added task: "%s"' % text)
	_refresh_todo()

func _cc_data_bundle() -> Dictionary:
	var fb_path := ProjectSettings.globalize_path("user://cc_feedback.json")
	var fb_f := FileAccess.open(fb_path, FileAccess.READ)
	var fb_str := "[]"
	if fb_f:
		fb_str = fb_f.get_as_text()
		fb_f.close()
	return {
		"todo.json": JSON.stringify(_todo_items, "\t") + "\n",
		"planned.json": JSON.stringify(_planned_addons, "\t") + "\n",
		"activity.json": JSON.stringify(_activity_items, "\t") + "\n",
		"feedback.json": fb_str,
		"votes.json": JSON.stringify(_vote_items, "\t") + "\n",
		"ideas.json": JSON.stringify(_ideas_items, "\t") + "\n",
		"asset_meta.json": JSON.stringify(_asset_meta, "\t") + "\n",
		"schedule.json": JSON.stringify(_schedule_items, "\t") + "\n",
		"forum.json": JSON.stringify(_forum_items, "\t") + "\n",
		"contracts.json": JSON.stringify(_contract_items, "\t") + "\n",
		"deps.json": JSON.stringify(_deps_items, "\t") + "\n",
		"doc_permissions.json": JSON.stringify(_docs_permissions, "\t") + "\n",
		"doc_suggestions.json": JSON.stringify(_docs_suggestions, "\t") + "\n",
		"elections.json": JSON.stringify(_election_data, "\t") + "\n"
	}

func _todo_on_pushed(msg: String = "✅ Pushed!") -> void:
	if _todo_thread and _todo_thread.is_started():
		_todo_thread.wait_to_finish()
	_todo_thread = null
	_todo_status_lbl.text = msg
	get_tree().create_timer(2.5).timeout.connect(func():
		if is_instance_valid(_todo_status_lbl):
			_todo_status_lbl.text = ""
	)

# ─── Team supertab (Activity + Votes) ────────────────────────────────────────

func _build_team_supertab(tabs: TabContainer) -> void:
	var root := _vbox("Team", tabs)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var inner_tabs := TabContainer.new()
	inner_tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(inner_tabs)
	_build_activity_tab(inner_tabs)
	_build_votes_tab(inner_tabs)
	_build_decision_log_tab(inner_tabs)
	_build_schedule_tab(inner_tabs)
	_build_forum_tab(inner_tabs)
	_build_docs_tab(inner_tabs)
	_build_elections_tab(inner_tabs)

# ─── Votes tab ────────────────────────────────────────────────────────────────

func _build_votes_tab(tabs: TabContainer) -> void:
	var root := _vbox("Votes", tabs)

	var toolbar := HBoxContainer.new()
	var new_btn := Button.new()
	new_btn.text = "+ New Vote"
	new_btn.pressed.connect(func():
		if is_instance_valid(_vote_create_box):
			_vote_create_box.visible = not _vote_create_box.visible
	)
	toolbar.add_child(new_btn)
	_vote_status_lbl = Label.new()
	_vote_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(_vote_status_lbl)
	root.add_child(toolbar)

	# ── Create form ───────────────────────────────────────────────────────────
	_vote_create_box = VBoxContainer.new()
	_vote_create_box.visible = false
	_vote_create_box.add_theme_constant_override("separation", 4)
	var cg := GridContainer.new()
	cg.columns = 2
	cg.add_theme_constant_override("h_separation", 8)
	var t_lbl := Label.new(); t_lbl.text = "Title"
	var t_field := LineEdit.new(); t_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var d_lbl := Label.new(); d_lbl.text = "Deadline"
	var d_field := LineEdit.new()
	d_field.placeholder_text = "YYYY-MM-DD (optional)"
	d_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var o_lbl := Label.new(); o_lbl.text = "Options"
	var o_field := LineEdit.new()
	o_field.text = "Yes, No"
	o_field.placeholder_text = "Comma-separated"
	o_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cg.add_child(t_lbl); cg.add_child(t_field)
	cg.add_child(d_lbl); cg.add_child(d_field)
	cg.add_child(o_lbl); cg.add_child(o_field)
	_vote_create_box.add_child(cg)
	var desc_field := TextEdit.new()
	desc_field.placeholder_text = "Description (optional)"
	desc_field.custom_minimum_size = Vector2(0, 50)
	_vote_create_box.add_child(desc_field)
	var create_btn := Button.new()
	create_btn.text = "Create Vote"
	create_btn.pressed.connect(func():
		var title := t_field.text.strip_edges()
		if title.is_empty():
			_vote_status_lbl.text = "Title is required."
			return
		var options: Array[String] = []
		for opt: String in o_field.text.split(","):
			var o := opt.strip_edges()
			if not o.is_empty():
				options.append(o)
		if options.size() < 2:
			_vote_status_lbl.text = "At least 2 options required."
			return
		_create_vote(title, desc_field.text.strip_edges(), options, d_field.text.strip_edges())
		t_field.text = ""; desc_field.text = ""; d_field.text = ""; o_field.text = "Yes, No"
		_vote_create_box.visible = false
	)
	_vote_create_box.add_child(create_btn)
	root.add_child(_vote_create_box)
	root.add_child(HSeparator.new())

	# ── Vote list ─────────────────────────────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vote_list = VBoxContainer.new()
	_vote_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vote_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_vote_list)
	root.add_child(scroll)

func _vote_file() -> String:
	return ProjectSettings.globalize_path("user://cc_votes.json")

func _load_votes() -> void:
	_vote_items = []
	var path := _vote_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		_vote_items = parsed
	_refresh_vote_list()

func _save_votes() -> void:
	var fw := FileAccess.open(_vote_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_vote_items, "\t") + "\n")
		fw.close()

func _vote_is_expired(vote: Dictionary) -> bool:
	var dl: String = vote.get("deadline", "")
	if dl.is_empty():
		return false
	return dl < Time.get_datetime_string_from_system().substr(0, 10)

func _vote_tally(vote: Dictionary) -> Dictionary:
	var options: Array = vote.get("options", [])
	var counts := {}
	for opt: String in options:
		counts[opt] = 0
	for v: String in (vote.get("votes", {}) as Dictionary).values():
		if v in counts:
			counts[v] += 1
	return counts

func _vote_leading_option(vote: Dictionary) -> String:
	var tally := _vote_tally(vote)
	var best := ""; var best_n := -1
	for opt: String in tally:
		if tally[opt] > best_n:
			best_n = tally[opt]; best = opt
	return best

func _create_vote(title: String, desc: String, options: Array[String], deadline: String) -> void:
	var vote := {
		"id": str(int(Time.get_unix_time_from_system())),
		"title": title,
		"description": desc,
		"created_by": _current_user.get("username", "?"),
		"created_at": Time.get_datetime_string_from_system(),
		"deadline": deadline,
		"options": options,
		"votes": {},
		"closed": false
	}
	_vote_items.insert(0, vote)
	_save_votes()
	_log_activity("vote_created", 'New vote opened: "%s"' % title)
	_refresh_vote_list()

func _cast_vote(vote_idx: int, option: String) -> void:
	if vote_idx < 0 or vote_idx >= _vote_items.size():
		return
	var username: String = _current_user.get("username", "")
	if username.is_empty():
		return
	var vote: Dictionary = _vote_items[vote_idx]
	var votes_dict: Dictionary = vote.get("votes", {})
	votes_dict[username] = option
	vote["votes"] = votes_dict
	_vote_items[vote_idx] = vote
	_save_votes()
	_log_activity("vote_cast", '%s voted "%s" on "%s"' % [username, option, vote.get("title", "")])
	_refresh_vote_list()
	if _vote_thread and _vote_thread.is_started():
		return
	var cap_idx := vote_idx
	_vote_thread = Thread.new()
	_vote_thread.start(func():
		var all_users := Ops.auth_fetch_all(Callable())
		var member_count := 0
		for u: Dictionary in all_users:
			if u.get("approved", false):
				member_count += 1
		call_deferred("_on_vote_member_count", cap_idx, member_count)
	)

func _on_vote_member_count(vote_idx: int, member_count: int) -> void:
	if _vote_thread:
		_vote_thread.wait_to_finish()
	_vote_thread = null
	if vote_idx < 0 or vote_idx >= _vote_items.size():
		return
	var vote: Dictionary = _vote_items[vote_idx]
	if not vote.get("closed", false):
		var cast_count := (vote.get("votes", {}) as Dictionary).size()
		if member_count > 0 and cast_count * 2 > member_count:
			vote["closed"] = true
			vote["result"] = _vote_leading_option(vote)
			vote["closed_at"] = Time.get_datetime_string_from_system()
			vote["closed_at_unix"] = int(Time.get_unix_time_from_system())
			vote["close_reason"] = "majority"
			_vote_items[vote_idx] = vote
			_save_votes()
			_log_activity("vote_closed",
				'Vote "%s" closed by majority — result: %s (%d/%d voted)' % [
				vote.get("title", ""), vote.get("result", ""), cast_count, member_count])
			_refresh_vote_list()


func _refresh_vote_list() -> void:
	if not is_instance_valid(_vote_list):
		return
	for c in _vote_list.get_children():
		c.queue_free()
	var username: String = _current_user.get("username", "")
	for i in range(_vote_items.size()):
		var vote: Dictionary = _vote_items[i]
		var title: String = vote.get("title", "Untitled")
		var options: Array = vote.get("options", [])
		var votes_dict: Dictionary = vote.get("votes", {})
		var is_closed: bool = vote.get("closed", false)
		var my_vote: String = votes_dict.get(username, "")
		# Auto-close expired votes
		if not is_closed and _vote_is_expired(vote):
			vote["closed"] = true
			vote["result"] = _vote_leading_option(vote)
			vote["closed_at"] = Time.get_datetime_string_from_system()
			vote["closed_at_unix"] = int(Time.get_unix_time_from_system())
			vote["close_reason"] = "deadline"
			_vote_items[i] = vote
			is_closed = true
			_save_votes()
			_log_activity("vote_closed",
				'Vote "%s" closed — deadline reached. Result: %s' % [
				title, vote.get("result", "")])
		if is_closed:
			continue  # concluded votes live in the Decision Log
		var result: String = vote.get("result", "")
		var total: int = votes_dict.size()
		# Card
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		panel.add_child(cvbox)
		# Title + status
		var header := HBoxContainer.new()
		var title_lbl := RichTextLabel.new()
		title_lbl.bbcode_enabled = true
		title_lbl.fit_content = true
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sc := "66bb6a" if is_closed else "42a5f5"
		var st := ("CLOSED" if is_closed else "OPEN")
		title_lbl.text = "[b]%s[/b]  [color=#%s][%s][/color]" % [title, sc, st]
		header.add_child(title_lbl)
		var count_lbl := Label.new()
		count_lbl.text = "%d voted" % total
		count_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		header.add_child(count_lbl)
		cvbox.add_child(header)
		# Description
		var desc: String = vote.get("description", "")
		if not desc.is_empty():
			var dl := Label.new(); dl.text = desc
			dl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cvbox.add_child(dl)
		# Deadline
		var deadline: String = vote.get("deadline", "")
		if not deadline.is_empty():
			var dll := Label.new()
			dll.text = ("⏰ Ended: " if is_closed else "⏰ Ends: ") + deadline
			dll.add_theme_color_override("font_color", Color(0.6, 0.5, 0.3))
			cvbox.add_child(dll)
		# Options: bars if voted/closed, buttons if open and unvoted
		if is_closed or not my_vote.is_empty():
			var tally := _vote_tally(vote)
			for opt: String in options:
				var row := HBoxContainer.new()
				var winner := (result == opt) and is_closed
				var lbl := Label.new()
				lbl.text = ("✅ " if winner else "   ") + opt
				lbl.custom_minimum_size = Vector2(110, 0)
				if winner:
					lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
				elif opt == my_vote:
					lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
				row.add_child(lbl)
				var pbar := ProgressBar.new()
				pbar.min_value = 0
				pbar.max_value = max(total, 1)
				pbar.value = tally.get(opt, 0)
				pbar.show_percentage = false
				pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				pbar.custom_minimum_size = Vector2(0, 16)
				row.add_child(pbar)
				var n_lbl := Label.new()
				n_lbl.text = " %d" % tally.get(opt, 0)
				row.add_child(n_lbl)
				cvbox.add_child(row)
			if not my_vote.is_empty() and not is_closed:
				var vl := Label.new()
				vl.text = "Your vote: " + my_vote
				vl.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
				cvbox.add_child(vl)
		else:
			var btn_row := HBoxContainer.new()
			for opt: String in options:
				var obtn := Button.new()
				obtn.text = opt
				var cap_i := i; var cap_opt := opt
				obtn.pressed.connect(func(): _cast_vote(cap_i, cap_opt))
				btn_row.add_child(obtn)
			cvbox.add_child(btn_row)
		# Footer row: meta + comment toggle
		var footer := HBoxContainer.new()
		var meta := Label.new()
		var cr: String = vote.get("close_reason", "")
		var close_note := (" — closed by " + ("majority vote" if cr == "majority" else "deadline")) if is_closed else ""
		meta.text = "by %s  %s%s" % [vote.get("created_by", "?"),
			vote.get("created_at", "").substr(0, 16), close_note]
		meta.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		meta.add_theme_font_size_override("font_size", 11)
		meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(meta)

		var vote_comments: Array = vote.get("comments", [])
		var vcmt_btn := Button.new()
		vcmt_btn.text = ("💬 %d" % vote_comments.size()) if not vote_comments.is_empty() else "💬 Discuss"
		vcmt_btn.flat = true
		vcmt_btn.add_theme_font_size_override("font_size", 11)
		if _vote_comments_open.get(i, false):
			vcmt_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		var cap_vi := i
		vcmt_btn.pressed.connect(func():
			_vote_comments_open[cap_vi] = not _vote_comments_open.get(cap_vi, false)
			_refresh_vote_list()
		)
		footer.add_child(vcmt_btn)
		cvbox.add_child(footer)

		# Comments section
		if _vote_comments_open.get(i, false):
			cvbox.add_child(HSeparator.new())
			for comment: Dictionary in vote_comments:
				var c_row := HBoxContainer.new()
				c_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var c_user: String = comment.get("user", "?")
				var c_text: String = comment.get("text", "")
				var c_ts: String = comment.get("timestamp", "")
				var c_lbl := RichTextLabel.new()
				c_lbl.bbcode_enabled = true
				c_lbl.fit_content = true
				c_lbl.scroll_active = false
				c_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				c_lbl.push_color(Color(0.75, 0.75, 0.75))
				c_lbl.append_text("[b]@" + c_user + "[/b]  " + c_text)
				c_lbl.pop()
				c_row.add_child(c_lbl)
				var ct_lbl := Label.new()
				ct_lbl.text = c_ts.substr(11, 5) if c_ts.length() >= 16 else ""
				ct_lbl.add_theme_font_size_override("font_size", 10)
				ct_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
				c_row.add_child(ct_lbl)
				cvbox.add_child(c_row)
			var add_row := HBoxContainer.new()
			add_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var c_input := LineEdit.new()
			c_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c_input.placeholder_text = "Share your thoughts…"
			c_input.add_theme_font_size_override("font_size", 11)
			add_row.add_child(c_input)
			var post_btn := Button.new()
			post_btn.text = "Post"
			post_btn.add_theme_font_size_override("font_size", 11)
			var cap_vi2 := i
			var cap_me := username
			var post_fn := func():
				var text := c_input.text.strip_edges()
				if text.is_empty():
					return
				var clist: Array = _vote_items[cap_vi2].get("comments", [])
				clist.append({
					"user": cap_me if not cap_me.is_empty() else "?",
					"text": text,
					"timestamp": Time.get_datetime_string_from_system()
				})
				_vote_items[cap_vi2]["comments"] = clist
				_save_votes()
				_refresh_vote_list()
			post_btn.pressed.connect(post_fn)
			c_input.text_submitted.connect(func(_t): post_fn.call())
			add_row.add_child(post_btn)
			cvbox.add_child(add_row)

		_vote_list.add_child(panel)

	# ── Doc vote suggestions ─────────────────────────────────────────────────
	var doc_votes: Array = []
	for s: Dictionary in _docs_suggestions:
		if s.get("vote_required", false) and s.get("status", "") == "pending":
			doc_votes.append(s)
	for s: Dictionary in doc_votes:
		var sugg_idx := _docs_suggestions.find(s)
		var cap_si := sugg_idx
		var doc_path: String = s.get("doc_path", "")
		var doc_name: String = doc_path.get_file().get_basename()
		var author: String = s.get("author", "?")
		var ts: String = s.get("timestamp", "")
		var thresh: String = s.get("vote_threshold", "1/2")
		var votes_d: Dictionary = s.get("votes", {})
		var yes_list: Array = votes_d.get("yes", [])
		var no_list: Array = votes_d.get("no", [])
		var yes_n := yes_list.size()
		var no_n := no_list.size()
		var total_n := yes_n + no_n
		var is_perm: bool = s.get("type", "") == "permission_change"
		var is_archive: bool = s.get("type", "") == "archive_request"
		var is_move_req2: bool = s.get("type", "") == "move_request"
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		panel.add_child(cvbox)
		# Header
		var header := HBoxContainer.new()
		var title_lbl := RichTextLabel.new()
		title_lbl.bbcode_enabled = true
		title_lbl.fit_content = true
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var kind := "🔒 Permission Change" if is_perm else ("📦 Archive Request" if is_archive else ("📁 Move Request" if is_move_req2 else "📄 " + doc_name))
		title_lbl.text = "[b]%s[/b]  [color=#aaaaff][DOC VOTE][/color]  [color=#42a5f5][OPEN][/color]" % kind
		header.add_child(title_lbl)
		var diff_btn := Button.new()
		diff_btn.text = "📊 View Diff"
		diff_btn.flat = false
		if is_perm or is_archive or is_move_req2:
			diff_btn.disabled = true
			diff_btn.tooltip_text = "No content diff for this vote type"
		else:
			diff_btn.pressed.connect(func(): _docs_open_diff_dialog(cap_si))
		header.add_child(diff_btn)
		cvbox.add_child(header)
		# Subtitle
		var sub_lbl := Label.new()
		sub_lbl.text = "Proposed by %s  —  %s  |  Threshold: %s" % [author, ts.substr(0, 16), thresh]
		sub_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		sub_lbl.add_theme_font_size_override("font_size", 11)
		cvbox.add_child(sub_lbl)
		if is_perm:
			var perm_lbl := Label.new()
			var new_p: Dictionary = s.get("new_permissions", {})
			var req_v: bool = new_p.get("require_vote", false)
			var mode: String = new_p.get("mode", "anyone")
			perm_lbl.text = "  Edit access: %s   Vote lock: %s" % [
				mode, ("on (%s)" % new_p.get("vote_threshold", "")) if req_v else "off"]
			perm_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 1.0))
			cvbox.add_child(perm_lbl)
		# Vote bars
		var tally_row := HBoxContainer.new()
		for pair in [["👍 For", yes_n, Color(0.4, 0.9, 0.5)], ["👎 Against", no_n, Color(0.9, 0.4, 0.4)]]:
			var opt_lbl := Label.new()
			opt_lbl.text = pair[0] as String
			opt_lbl.custom_minimum_size = Vector2(90, 0)
			opt_lbl.add_theme_color_override("font_color", pair[2] as Color)
			tally_row.add_child(opt_lbl)
			var pbar := ProgressBar.new()
			pbar.min_value = 0
			pbar.max_value = max(total_n, 1)
			pbar.value = pair[1] as int
			pbar.show_percentage = false
			pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			pbar.custom_minimum_size = Vector2(0, 16)
			tally_row.add_child(pbar)
			var n_lbl := Label.new()
			n_lbl.text = " %d" % (pair[1] as int)
			tally_row.add_child(n_lbl)
		cvbox.add_child(tally_row)
		# Vote buttons or "already voted" label
		var already_yes: bool = username in yes_list
		var already_no: bool = username in no_list
		if not already_yes and not already_no:
			var btn_row := HBoxContainer.new()
			var yes_btn := Button.new()
			yes_btn.text = "👍 For"
			yes_btn.pressed.connect(func(): _docs_vote_cast(cap_si, true))
			var no_btn := Button.new()
			no_btn.text = "👎 Against"
			no_btn.pressed.connect(func(): _docs_vote_cast(cap_si, false))
			btn_row.add_child(yes_btn)
			btn_row.add_child(no_btn)
			cvbox.add_child(btn_row)
		else:
			var voted_row := HBoxContainer.new()
			var voted_lbl := Label.new()
			voted_lbl.text = "Your vote: " + ("👍 For" if already_yes else "👎 Against")
			voted_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
			voted_row.add_child(voted_lbl)
			var change_btn := Button.new()
			change_btn.text = "Change"
			change_btn.flat = true
			change_btn.pressed.connect(func(): _docs_vote_cast(cap_si, not already_yes))
			voted_row.add_child(change_btn)
			cvbox.add_child(voted_row)
		_vote_list.add_child(panel)

	# ── Election pending votes ────────────────────────────────────────────────
	var el_pvotes: Array = _election_pending_votes()
	for elv: Dictionary in el_pvotes:
		var cap_id: String = elv.get("id", "")
		var elv_title: String = elv.get("title", "Election vote")
		var elv_desc: String = elv.get("description", "")
		var is_closed: bool = elv.get("closed", false)
		var result: String = elv.get("result", "")
		var thresh: String = elv.get("threshold", "2/3")
		var votes_d: Dictionary = elv.get("votes", {"yes": [], "no": []})
		var yes_list: Array = votes_d.get("yes", [])
		var no_list: Array = votes_d.get("no", [])
		var yes_n := yes_list.size()
		var no_n := no_list.size()
		var total_n := yes_n + no_n
		var already_yes: bool = username in yes_list
		var already_no: bool = username in no_list

		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		panel.add_child(cvbox)

		var header := HBoxContainer.new()
		var title_lbl := RichTextLabel.new()
		title_lbl.bbcode_enabled = true
		title_lbl.fit_content = true
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sc := "66bb6a" if is_closed else "ffaa44"
		var st := ("CLOSED — " + result.to_upper() if is_closed else "OPEN")
		title_lbl.text = "[b]%s[/b]  [color=#ffaa44][ELECTION][/color]  [color=#%s][%s][/color]" % [elv_title, sc, st]
		header.add_child(title_lbl)
		cvbox.add_child(header)

		if not elv_desc.is_empty():
			var desc_lbl := Label.new()
			desc_lbl.text = elv_desc
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			desc_lbl.add_theme_font_size_override("font_size", 11)
			cvbox.add_child(desc_lbl)

		var sub_lbl := Label.new()
		sub_lbl.text = "Proposed by %s  |  Threshold: %s" % [elv.get("created_by", "?"), thresh]
		sub_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		sub_lbl.add_theme_font_size_override("font_size", 11)
		cvbox.add_child(sub_lbl)

		var tally_row := HBoxContainer.new()
		for pair: Array in [["👍 For", yes_n, Color(0.4, 0.9, 0.5)], ["👎 Against", no_n, Color(0.9, 0.4, 0.4)]]:
			var opt_lbl := Label.new()
			opt_lbl.text = pair[0] as String
			opt_lbl.custom_minimum_size = Vector2(90, 0)
			opt_lbl.add_theme_color_override("font_color", pair[2] as Color)
			tally_row.add_child(opt_lbl)
			var pbar := ProgressBar.new()
			pbar.min_value = 0
			pbar.max_value = max(total_n, 1)
			pbar.value = pair[1] as int
			pbar.show_percentage = false
			pbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			pbar.custom_minimum_size = Vector2(0, 16)
			tally_row.add_child(pbar)
			var n_lbl := Label.new()
			n_lbl.text = " %d" % (pair[1] as int)
			tally_row.add_child(n_lbl)
		cvbox.add_child(tally_row)

		if not is_closed:
			if not already_yes and not already_no:
				var btn_row := HBoxContainer.new()
				var yes_btn := Button.new()
				yes_btn.text = "👍 For"
				yes_btn.pressed.connect(func(): _election_cast_vote(cap_id, true))
				var no_btn := Button.new()
				no_btn.text = "👎 Against"
				no_btn.pressed.connect(func(): _election_cast_vote(cap_id, false))
				btn_row.add_child(yes_btn)
				btn_row.add_child(no_btn)
				cvbox.add_child(btn_row)
			else:
				var voted_row := HBoxContainer.new()
				var voted_lbl := Label.new()
				voted_lbl.text = "Your vote: " + ("👍 For" if already_yes else "👎 Against")
				voted_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
				voted_row.add_child(voted_lbl)
				var change_btn := Button.new()
				change_btn.text = "Change"
				change_btn.flat = true
				change_btn.pressed.connect(func(): _election_cast_vote(cap_id, not already_yes))
				voted_row.add_child(change_btn)
				cvbox.add_child(voted_row)
		_vote_list.add_child(panel)

	# Show hint if no open votes remain
	var open_votes := 0
	for v: Dictionary in _vote_items:
		if not v.get("closed", false):
			open_votes += 1
	if open_votes == 0 and doc_votes.is_empty() and el_pvotes.is_empty():
		for c in _vote_list.get_children():
			c.queue_free()
		var hint := Label.new()
		var has_closed: bool = _vote_items.any(func(v: Dictionary) -> bool: return v.get("closed", false))
		hint.text = "All votes concluded — see Decision Log." if has_closed else "No votes yet. Use + New Vote to start one."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_vote_list.add_child(hint)
	_refresh_decision_log()

# ─── Decision Log tab ─────────────────────────────────────────────────────────

func _build_decision_log_tab(tabs: TabContainer) -> void:
	var root := _vbox("Decisions", tabs)

	var toolbar := HBoxContainer.new()
	var new_btn := Button.new()
	new_btn.text = "📋 Add Decision"
	_decisions_status_lbl = Label.new()
	_decisions_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decisions_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(new_btn)
	toolbar.add_child(_decisions_status_lbl)
	root.add_child(toolbar)

	# ── Create form ─────────────────────────────────────────────────────────────
	_decisions_create_box = VBoxContainer.new()
	_decisions_create_box.visible = false
	_decisions_create_box.add_theme_constant_override("separation", 4)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 4)

	var t_lbl := Label.new(); t_lbl.text = "Title *"
	var t_field := LineEdit.new()
	t_field.placeholder_text = "What was decided"
	t_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(t_lbl); grid.add_child(t_field)

	var r_lbl := Label.new(); r_lbl.text = "Outcome *"
	var r_field := LineEdit.new()
	r_field.placeholder_text = "The result of the decision"
	r_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(r_lbl); grid.add_child(r_field)

	var n_lbl := Label.new(); n_lbl.text = "Notes"
	var n_field := TextEdit.new()
	n_field.placeholder_text = "Optional context or rationale"
	n_field.custom_minimum_size = Vector2(0, 52)
	n_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(n_lbl); grid.add_child(n_field)

	_decisions_create_box.add_child(grid)

	var p_hdr := Label.new()
	p_hdr.text = "Members present at the decision:"
	p_hdr.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_decisions_create_box.add_child(p_hdr)

	_decisions_participant_list = VBoxContainer.new()
	_decisions_create_box.add_child(_decisions_participant_list)

	var create_btn := Button.new()
	create_btn.text = "📋 Post Decision"
	create_btn.pressed.connect(func():
		var title := t_field.text.strip_edges()
		var outcome := r_field.text.strip_edges()
		if title.is_empty() or outcome.is_empty():
			_decisions_status_lbl.text = "Title and outcome are required."
			return
		var participants: Array = []
		for uname: String in _decisions_participant_checks:
			if (_decisions_participant_checks[uname] as CheckBox).button_pressed:
				participants.append(uname)
		var me2: String = _current_user.get("username", "")
		var decision := {
			"id": str(int(Time.get_unix_time_from_system())),
			"type": "manual",
			"title": title,
			"result": outcome,
			"description": n_field.text.strip_edges(),
			"created_by": me2,
			"created_at": Time.get_datetime_string_from_system(),
			"closed": true,
			"closed_at": Time.get_datetime_string_from_system(),
			"closed_at_unix": int(Time.get_unix_time_from_system()),
			"close_reason": "manual",
			"participants": participants,
			"confirmations": ([me2] if me2 in participants else []),
			"extra_approvals": [],
			"revote_count": 0,
			"revote_requesters": [],
			"history": []
		}
		_vote_items.insert(0, decision)
		_save_votes()
		_log_activity("decision_posted",
			'"%s" posted manual decision: "%s" → %s' % [me2, title, outcome])
		t_field.text = ""; r_field.text = ""; n_field.text = ""
		_decisions_create_box.visible = false
		_decisions_status_lbl.text = "✅ Decision posted"
		get_tree().create_timer(3.0).timeout.connect(func():
			if is_instance_valid(_decisions_status_lbl): _decisions_status_lbl.text = ""
		)
		_refresh_decision_log()
	)
	_decisions_create_box.add_child(create_btn)
	root.add_child(_decisions_create_box)
	root.add_child(HSeparator.new())

	new_btn.pressed.connect(func():
		_decisions_create_box.visible = not _decisions_create_box.visible
		if _decisions_create_box.visible:
			_populate_decisions_participant_list()
	)

	# ── List ──────────────────────────────────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decision_log_list = VBoxContainer.new()
	_decision_log_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decision_log_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_decision_log_list)
	root.add_child(scroll)

func _populate_decisions_participant_list() -> void:
	if not is_instance_valid(_decisions_participant_list):
		return
	for c in _decisions_participant_list.get_children():
		c.queue_free()
	_decisions_participant_checks.clear()
	if _election_members.is_empty():
		var hint := Label.new()
		hint.text = "No members loaded yet — open the Elections tab first."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_decisions_participant_list.add_child(hint)
		return
	var me2: String = _current_user.get("username", "")
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 12)
	for u: Dictionary in _election_members:
		var uname: String = u.get("username", "")
		if uname.is_empty():
			continue
		var cb := CheckBox.new()
		cb.text = uname
		cb.button_pressed = (uname == me2)
		_decisions_participant_checks[uname] = cb
		flow.add_child(cb)
	_decisions_participant_list.add_child(flow)

func _find_vote_by_id(id: String) -> Dictionary:
	for v: Dictionary in _vote_items:
		if v.get("id", "") == id:
			return v
	return {}

func _refresh_decision_log() -> void:
	if not is_instance_valid(_decision_log_list):
		return
	for c in _decision_log_list.get_children():
		c.queue_free()

	var closed_items: Array = []
	for i in range(_vote_items.size()):
		var v: Dictionary = _vote_items[i]
		# Exclude challenge meta-votes — they surface through the manual decision card
		if v.get("closed", false) and v.get("type", "") != "challenge":
			closed_items.append({"vote": v, "idx": i})
	closed_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (a["vote"].get("closed_at", "") as String) > (b["vote"].get("closed_at", "") as String)
	)

	if closed_items.is_empty():
		var hint := Label.new()
		hint.text = "No concluded votes or decisions yet."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_decision_log_list.add_child(hint)
		return

	var me: String = _current_user.get("username", "")
	var total_members: int = max(_election_members.size(), int(_election_setting("cached_member_count", 1)))

	for entry: Dictionary in closed_items:
		var vote: Dictionary = entry["vote"]
		var cap_i: int = entry["idx"]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		panel.add_child(cvbox)
		if vote.get("type", "") == "manual":
			_render_manual_decision_card(cvbox, cap_i, vote, me, total_members)
		else:
			_render_concluded_vote_card(cvbox, cap_i, vote, me)
		_decision_log_list.add_child(panel)

func _render_manual_decision_card(cvbox: VBoxContainer, cap_i: int, vote: Dictionary, me: String, total_members: int) -> void:
	var title: String = vote.get("title", "Untitled")
	var result: String = vote.get("result", "")
	var description: String = vote.get("description", "")
	var created_by: String = vote.get("created_by", "?")
	var created_at: String = vote.get("created_at", "")
	var participants: Array = vote.get("participants", [])
	var confirmations: Array = vote.get("confirmations", [])
	var extra_approvals: Array = vote.get("extra_approvals", [])
	var challenge_id: String = vote.get("challenge_vote_id", "")
	var challenge_vote: Dictionary = {} if challenge_id.is_empty() else _find_vote_by_id(challenge_id)
	var challenge_closed: bool = challenge_vote.get("closed", false)
	var overturned: bool = challenge_closed and challenge_vote.get("result", "") == "Override"

	# Title + outcome
	var header_lbl := RichTextLabel.new()
	header_lbl.bbcode_enabled = true
	header_lbl.fit_content = true
	header_lbl.text = "[b]%s[/b]  [color=#888][MANUAL][/color]  →  [color=%s]%s[/color]%s" % [
		title,
		"#aaaaaa" if overturned else "#66bb6a",
		result,
		"  [color=#ff6b6b][OVERTURNED][/color]" if overturned else ""]
	cvbox.add_child(header_lbl)

	# Meta
	var meta_lbl := Label.new()
	meta_lbl.text = "by %s  ·  %s" % [created_by, created_at.substr(0, 16)]
	meta_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	meta_lbl.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(meta_lbl)

	if not description.is_empty():
		var desc_lbl := Label.new()
		desc_lbl.text = description
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		cvbox.add_child(desc_lbl)

	# Participants with confirmation status
	if not participants.is_empty():
		var parts_row := HFlowContainer.new()
		parts_row.add_theme_constant_override("h_separation", 8)
		var parts_hdr := Label.new()
		parts_hdr.text = "Present:"
		parts_hdr.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		parts_hdr.add_theme_font_size_override("font_size", 11)
		parts_row.add_child(parts_hdr)
		for p: String in participants:
			var confirmed: bool = p in confirmations
			var pl := Label.new()
			pl.text = ("✅ " if confirmed else "⏳ ") + p
			pl.add_theme_font_size_override("font_size", 11)
			pl.add_theme_color_override("font_color",
				Color(0.4, 0.85, 0.5) if confirmed else Color(0.65, 0.65, 0.65))
			parts_row.add_child(pl)
		cvbox.add_child(parts_row)

	# Approval tally
	var all_approvals: Array = confirmations.duplicate()
	for ea: String in extra_approvals:
		if ea not in all_approvals:
			all_approvals.append(ea)
	var majority: bool = all_approvals.size() * 2 > total_members
	var tally_lbl := Label.new()
	tally_lbl.text = "%d/%d approved%s" % [all_approvals.size(), total_members,
		"  ✅ majority reached" if majority else ""]
	tally_lbl.add_theme_color_override("font_color",
		Color(0.4, 0.85, 0.5) if majority else Color(0.55, 0.55, 0.55))
	tally_lbl.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(tally_lbl)

	# Action buttons
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)

	if not me.is_empty():
		# Confirm presence (participant only, not yet confirmed)
		if me in participants and me not in confirmations:
			var confirm_btn := Button.new()
			confirm_btn.text = "✅ Confirm I was present"
			confirm_btn.add_theme_font_size_override("font_size", 11)
			var cap_idx := cap_i
			confirm_btn.pressed.connect(func():
				var v: Dictionary = _vote_items[cap_idx]
				var conf: Array = v.get("confirmations", [])
				if me not in conf:
					conf.append(me)
					v["confirmations"] = conf
					_vote_items[cap_idx] = v
					_save_votes()
					_log_activity("decision_confirmed",
						'%s confirmed presence in: "%s"' % [me, v.get("title", "")])
				_refresh_decision_log()
			)
			btn_row.add_child(confirm_btn)

		# Add approval (anyone, while below majority)
		if not majority and me not in all_approvals:
			var approve_btn := Button.new()
			approve_btn.text = "👍 Add My Approval"
			approve_btn.add_theme_font_size_override("font_size", 11)
			approve_btn.tooltip_text = "Endorse this decision even if you weren't present"
			var cap_idx2 := cap_i
			approve_btn.pressed.connect(func():
				var v: Dictionary = _vote_items[cap_idx2]
				var ea: Array = v.get("extra_approvals", [])
				if me not in ea:
					ea.append(me)
					v["extra_approvals"] = ea
					_vote_items[cap_idx2] = v
					_save_votes()
					_log_activity("decision_approved",
						'%s endorsed decision: "%s"' % [me, v.get("title", "")])
				_refresh_decision_log()
			)
			btn_row.add_child(approve_btn)

	# Challenge section
	if challenge_vote.is_empty():
		if not me.is_empty():
			var chal_btn := Button.new()
			chal_btn.text = "⚠ Request Vote"
			chal_btn.add_theme_font_size_override("font_size", 11)
			chal_btn.tooltip_text = "Open a formal vote to challenge this decision"
			var cap_decision_id: String = vote.get("id", "")
			chal_btn.pressed.connect(func():
				var chal_id := str(int(Time.get_unix_time_from_system())) + "_chal"
				var chal_vote := {
					"id": chal_id,
					"type": "challenge",
					"title": "Challenge: " + vote.get("title", ""),
					"description": 'Should "%s → %s" be overridden?' % [
						vote.get("title", ""), vote.get("result", "")],
					"created_by": me,
					"created_at": Time.get_datetime_string_from_system(),
					"deadline": "",
					"options": ["Uphold", "Override"],
					"votes": {},
					"closed": false
				}
				_vote_items.insert(0, chal_vote)
				for j in range(_vote_items.size()):
					if (_vote_items[j] as Dictionary).get("id", "") == cap_decision_id:
						var upd: Dictionary = _vote_items[j]
						upd["challenge_vote_id"] = chal_id
						_vote_items[j] = upd
						break
				_save_votes()
				_log_activity("decision_challenged",
					'%s challenged decision: "%s"' % [me, vote.get("title", "")])
				_refresh_vote_list()
			)
			btn_row.add_child(chal_btn)
	elif not challenge_closed:
		var lbl := Label.new()
		lbl.text = "⚠ Challenge vote open — see Votes tab"
		lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
		lbl.add_theme_font_size_override("font_size", 11)
		btn_row.add_child(lbl)
	elif overturned:
		var lbl := Label.new()
		lbl.text = "Overturned by vote"
		lbl.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
		lbl.add_theme_font_size_override("font_size", 11)
		btn_row.add_child(lbl)
	else:
		var lbl := Label.new()
		lbl.text = "✅ Challenge rejected — decision upheld"
		lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
		lbl.add_theme_font_size_override("font_size", 11)
		btn_row.add_child(lbl)

	if btn_row.get_child_count() > 0:
		cvbox.add_child(btn_row)

func _render_concluded_vote_card(cvbox: VBoxContainer, cap_i: int, vote: Dictionary, me: String) -> void:
	var title: String = vote.get("title", "Untitled")
	var result: String = vote.get("result", "")
	var closed_at: String = vote.get("closed_at", "")
	var close_reason: String = vote.get("close_reason", "")
	var revote_count: int = int(vote.get("revote_count", 0))
	var requesters: Array = vote.get("revote_requesters", [])
	var history: Array = vote.get("history", [])
	var threshold: int = revote_count + 1

	var header_lbl := RichTextLabel.new()
	header_lbl.bbcode_enabled = true
	header_lbl.fit_content = true
	var rv_tag := (" [color=#888](revote #%d)[/color]" % revote_count) if revote_count > 0 else ""
	header_lbl.text = "[b]%s[/b]%s  →  [color=#66bb6a]%s[/color]" % [title, rv_tag, result]
	cvbox.add_child(header_lbl)

	var close_note := "majority vote" if close_reason == "majority" else "deadline"
	var meta_lbl := Label.new()
	meta_lbl.text = "Decided by %s  ·  %s" % [close_note, closed_at.substr(0, 16)]
	meta_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	meta_lbl.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(meta_lbl)

	if not history.is_empty():
		var hist_hdr := Label.new()
		hist_hdr.text = "Previous:"
		hist_hdr.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hist_hdr.add_theme_font_size_override("font_size", 11)
		cvbox.add_child(hist_hdr)
		for h: Dictionary in history:
			var hl := Label.new()
			hl.text = "  • %s  (%s)" % [h.get("result", "?"), (h.get("closed_at", "") as String).substr(0, 16)]
			hl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
			hl.add_theme_font_size_override("font_size", 11)
			cvbox.add_child(hl)

	var already_requested: bool = me in requesters
	var closed_at_unix: int = int(vote.get("closed_at_unix", 0))
	var can_revote := true
	var hours_left := 0.0
	if closed_at_unix > 0:
		var elapsed := float(int(Time.get_unix_time_from_system()) - closed_at_unix) / 3600.0
		if elapsed < float(REVOTE_TIMEOUT_HOURS):
			can_revote = false
			hours_left = float(REVOTE_TIMEOUT_HOURS) - elapsed

	var revote_row := HBoxContainer.new()
	if not can_revote:
		var wait_lbl := Label.new()
		wait_lbl.text = "⏳ Revote available in %.0fh" % ceili(hours_left)
		wait_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		wait_lbl.add_theme_font_size_override("font_size", 11)
		revote_row.add_child(wait_lbl)
	else:
		var tally_lbl := Label.new()
		tally_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tally_lbl.add_theme_font_size_override("font_size", 11)
		tally_lbl.text = ("%d/%d requested revote" % [requesters.size(), threshold]) if not requesters.is_empty() \
			else ("Need %d to revote" % threshold)
		tally_lbl.add_theme_color_override("font_color",
			Color(0.4, 0.8, 0.5) if already_requested else Color(0.5, 0.5, 0.5))
		revote_row.add_child(tally_lbl)

		if not already_requested:
			var revote_btn := Button.new()
			revote_btn.text = "🔄 Revote"
			revote_btn.add_theme_font_size_override("font_size", 11)
			revote_btn.disabled = me.is_empty()
			revote_btn.tooltip_text = "Log in to request a revote" if me.is_empty() else \
				"Request a revote (need %d, have %d)" % [threshold, requesters.size()]
			var cap_idx := cap_i
			revote_btn.pressed.connect(func():
				if me.is_empty():
					return
				var v: Dictionary = _vote_items[cap_idx]
				var req: Array = v.get("revote_requesters", [])
				if me in req:
					return
				req.append(me)
				var thresh: int = int(v.get("revote_count", 0)) + 1
				if req.size() >= thresh:
					var hist: Array = v.get("history", [])
					hist.append({"result": v.get("result", ""), "closed_at": v.get("closed_at", ""),
						"close_reason": v.get("close_reason", "")})
					v["history"] = hist
					v["revote_count"] = int(v.get("revote_count", 0)) + 1
					v["closed"] = false
					v["result"] = ""
					v["closed_at"] = ""
					v["closed_at_unix"] = 0
					v["close_reason"] = ""
					v["votes"] = {}
					v["revote_requesters"] = []
					_vote_items[cap_idx] = v
					_save_votes()
					_log_activity("vote_revote", 'Vote "%s" reopened for revote #%d (by %s)' % [
						v.get("title", ""), v.get("revote_count", 0), me])
					_refresh_vote_list()
				else:
					v["revote_requesters"] = req
					_vote_items[cap_idx] = v
					_save_votes()
					_log_activity("vote_revote_request", '%s requested revote on "%s" (%d/%d)' % [
						me, v.get("title", ""), req.size(), thresh])
					_refresh_decision_log()
			)
			revote_row.add_child(revote_btn)

	cvbox.add_child(revote_row)

# ─── Schedule tab ─────────────────────────────────────────────────────────────

func _build_schedule_tab(tabs: TabContainer) -> void:
	var root := _vbox("Schedule", tabs)

	var toolbar := HBoxContainer.new()
	var new_btn := Button.new()
	new_btn.text = "➕ Add Event"
	new_btn.pressed.connect(func():
		if is_instance_valid(_schedule_create_box):
			_schedule_create_box.visible = not _schedule_create_box.visible
	)
	_schedule_status_lbl = Label.new()
	_schedule_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_schedule_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	toolbar.add_child(new_btn)
	toolbar.add_child(_schedule_status_lbl)
	root.add_child(toolbar)

	# ── Create form ───────────────────────────────────────────────────────────
	_schedule_create_box = VBoxContainer.new()
	_schedule_create_box.visible = false
	_schedule_create_box.add_theme_constant_override("separation", 4)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 4)

	var title_lbl := Label.new(); title_lbl.text = "Title *"
	var title_field := LineEdit.new()
	title_field.placeholder_text = "Event name"
	title_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(title_lbl); grid.add_child(title_field)

	var date_lbl := Label.new(); date_lbl.text = "Date *"
	var date_field := LineEdit.new()
	date_field.placeholder_text = "YYYY-MM-DD"
	date_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(date_lbl); grid.add_child(date_field)

	var time_lbl := Label.new(); time_lbl.text = "Time"
	var time_field := LineEdit.new()
	time_field.placeholder_text = "HH:MM (optional)"
	time_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(time_lbl); grid.add_child(time_field)

	var desc_lbl := Label.new(); desc_lbl.text = "Description"
	var desc_field := TextEdit.new()
	desc_field.placeholder_text = "Details…"
	desc_field.custom_minimum_size = Vector2(0, 48)
	desc_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(desc_lbl); grid.add_child(desc_field)

	_schedule_create_box.add_child(grid)

	var create_btn := Button.new()
	create_btn.text = "Create Event"
	create_btn.pressed.connect(func():
		var title := title_field.text.strip_edges()
		var date := date_field.text.strip_edges()
		if title.is_empty() or date.is_empty():
			_schedule_status_lbl.text = "⚠ Title and date are required."
			return
		var user: String = _current_user.get("username", "?")
		_schedule_items.append({
			"title": title,
			"date": date,
			"time": time_field.text.strip_edges(),
			"description": desc_field.text.strip_edges(),
			"created_by": user,
			"created_at": Time.get_datetime_string_from_system(),
			"rsvp": {}
		})
		_schedule_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return (a.get("date", "") + "T" + a.get("time", "")) < (b.get("date", "") + "T" + b.get("time", ""))
		)
		_save_schedule()
		_log_activity("event_created", '%s added event: "%s" on %s' % [user, title, date])
		title_field.text = ""; date_field.text = ""; time_field.text = ""; desc_field.text = ""
		_schedule_create_box.visible = false
		_refresh_schedule_list()
	)
	_schedule_create_box.add_child(create_btn)
	_schedule_create_box.add_child(HSeparator.new())
	root.add_child(_schedule_create_box)

	# ── Event list ────────────────────────────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_schedule_list = VBoxContainer.new()
	_schedule_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_schedule_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_schedule_list)
	root.add_child(scroll)

	# ── Edit dialog ───────────────────────────────────────────────────────────
	_schedule_edit_dialog = AcceptDialog.new()
	_schedule_edit_dialog.title = "Edit Event"
	_schedule_edit_dialog.size = Vector2i(440, 240)
	var edit_vbox := VBoxContainer.new()
	edit_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	edit_vbox.add_theme_constant_override("separation", 4)
	_schedule_edit_dialog.add_child(edit_vbox)
	var edit_grid := GridContainer.new()
	edit_grid.columns = 2
	edit_grid.add_theme_constant_override("h_separation", 8)
	edit_grid.add_theme_constant_override("v_separation", 4)
	var et_lbl := Label.new(); et_lbl.text = "Title *"
	_schedule_edit_title = LineEdit.new()
	_schedule_edit_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_grid.add_child(et_lbl); edit_grid.add_child(_schedule_edit_title)
	var ed_lbl := Label.new(); ed_lbl.text = "Date *"
	_schedule_edit_date = LineEdit.new()
	_schedule_edit_date.placeholder_text = "YYYY-MM-DD"
	_schedule_edit_date.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_grid.add_child(ed_lbl); edit_grid.add_child(_schedule_edit_date)
	var etm_lbl := Label.new(); etm_lbl.text = "Time"
	_schedule_edit_time = LineEdit.new()
	_schedule_edit_time.placeholder_text = "HH:MM (optional)"
	_schedule_edit_time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_grid.add_child(etm_lbl); edit_grid.add_child(_schedule_edit_time)
	var edc_lbl := Label.new(); edc_lbl.text = "Description"
	_schedule_edit_desc = TextEdit.new()
	_schedule_edit_desc.custom_minimum_size = Vector2(0, 48)
	_schedule_edit_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_grid.add_child(edc_lbl); edit_grid.add_child(_schedule_edit_desc)
	edit_vbox.add_child(edit_grid)
	_schedule_edit_dialog.confirmed.connect(func():
		if _schedule_edit_idx < 0 or _schedule_edit_idx >= _schedule_items.size():
			return
		var t := _schedule_edit_title.text.strip_edges()
		var d := _schedule_edit_date.text.strip_edges()
		if t.is_empty() or d.is_empty():
			return
		var ev: Dictionary = _schedule_items[_schedule_edit_idx]
		ev["title"] = t
		ev["date"] = d
		ev["time"] = _schedule_edit_time.text.strip_edges()
		ev["description"] = _schedule_edit_desc.text.strip_edges()
		_schedule_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return (a.get("date", "") + "T" + a.get("time", "")) < (b.get("date", "") + "T" + b.get("time", ""))
		)
		_save_schedule()
		_refresh_schedule_list()
	)
	add_child(_schedule_edit_dialog)

	_load_schedule()

func _schedule_file() -> String:
	return ProjectSettings.globalize_path("user://cc_schedule.json")

func _load_schedule() -> void:
	_schedule_items = []
	var path := _schedule_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		_schedule_items = parsed
	_schedule_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (a.get("date", "") + "T" + a.get("time", "")) < (b.get("date", "") + "T" + b.get("time", ""))
	)
	if is_instance_valid(_schedule_list):
		_refresh_schedule_list()

func _save_schedule() -> void:
	var fw := FileAccess.open(_schedule_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_schedule_items, "\t") + "\n")
		fw.close()
	_activity_auto_push()

func _refresh_schedule_list() -> void:
	if not is_instance_valid(_schedule_list):
		return
	for c in _schedule_list.get_children():
		c.queue_free()

	if _schedule_items.is_empty():
		var hint := Label.new()
		hint.text = "No events scheduled. Use ➕ Add Event to create one."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_schedule_list.add_child(hint)
		return

	var me: String = _current_user.get("username", "")
	var today := Time.get_date_string_from_system()

	for i in range(_schedule_items.size()):
		var ev: Dictionary = _schedule_items[i]
		var ev_date: String = ev.get("date", "")
		var ev_time: String = ev.get("time", "")
		var is_past := ev_date < today

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if is_past:
			card.modulate = Color(1, 1, 1, 0.5)
		var cvbox := VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		card.add_child(cvbox)

		# Header row
		var header := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = ev.get("title", "Untitled")
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.add_theme_font_size_override("font_size", 14)
		if is_past:
			title_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		header.add_child(title_lbl)

		# Date/time chip
		var dt_str := ev_date
		if not ev_time.is_empty():
			dt_str += "  " + ev_time
		var dt_lbl := Label.new()
		dt_lbl.text = dt_str
		dt_lbl.add_theme_color_override("font_color", Color(0.5, 0.75, 1.0) if not is_past else Color(0.4, 0.4, 0.4))
		dt_lbl.add_theme_font_size_override("font_size", 12)
		header.add_child(dt_lbl)

		# Edit / delete buttons
		var cap_i := i
		var edit_btn := Button.new()
		edit_btn.text = "✏️"
		edit_btn.flat = true
		edit_btn.tooltip_text = "Edit event"
		edit_btn.pressed.connect(func():
			_schedule_edit_idx = cap_i
			_schedule_edit_title.text = _schedule_items[cap_i].get("title", "")
			_schedule_edit_date.text = _schedule_items[cap_i].get("date", "")
			_schedule_edit_time.text = _schedule_items[cap_i].get("time", "")
			_schedule_edit_desc.text = _schedule_items[cap_i].get("description", "")
			_schedule_edit_dialog.popup_centered()
		)
		header.add_child(edit_btn)

		var del_btn := Button.new()
		del_btn.text = "🗑"
		del_btn.flat = true
		del_btn.tooltip_text = "Delete event"
		del_btn.pressed.connect(func():
			var cap_title: String = _schedule_items[cap_i].get("title", "")
			_schedule_items.remove_at(cap_i)
			_save_schedule()
			_log_activity("event_deleted", '%s deleted event: "%s"' % [me if not me.is_empty() else "?", cap_title])
			_refresh_schedule_list()
		)
		header.add_child(del_btn)
		cvbox.add_child(header)

		# Description
		var desc: String = ev.get("description", "")
		if not desc.is_empty():
			var dl := Label.new()
			dl.text = desc
			dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			dl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			cvbox.add_child(dl)

		# Creator
		var meta_lbl := Label.new()
		meta_lbl.text = "Created by @" + ev.get("created_by", "?")
		meta_lbl.add_theme_font_size_override("font_size", 11)
		meta_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		cvbox.add_child(meta_lbl)

		cvbox.add_child(HSeparator.new())

		# RSVP buttons
		var rsvp: Dictionary = ev.get("rsvp", {})
		var my_rsvp: String = rsvp.get(me, "")
		if not is_past and not me.is_empty():
			var rsvp_row := HBoxContainer.new()
			rsvp_row.add_theme_constant_override("separation", 6)
			var rsvp_lbl := Label.new()
			rsvp_lbl.text = "Your RSVP:"
			rsvp_lbl.add_theme_font_size_override("font_size", 11)
			rsvp_row.add_child(rsvp_lbl)
			for opt_key: String in ["yes", "no", "maybe"]:
				var opt_text: String = {"yes": "✅ Can join", "no": "❌ Can't join", "maybe": "🤔 Maybe"}[opt_key]
				var rbtn := Button.new()
				rbtn.text = opt_text
				rbtn.add_theme_font_size_override("font_size", 11)
				rbtn.flat = my_rsvp != opt_key
				if my_rsvp == opt_key:
					rbtn.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
				var cap_i2 := i
				var cap_opt := opt_key
				rbtn.pressed.connect(func():
					var cur: String = _schedule_items[cap_i2].get("rsvp", {}).get(me, "")
					if cur == cap_opt:
						(_schedule_items[cap_i2]["rsvp"] as Dictionary).erase(me)
					else:
						(_schedule_items[cap_i2]["rsvp"] as Dictionary)[me] = cap_opt
					_save_schedule()
					_refresh_schedule_list()
				)
				rsvp_row.add_child(rbtn)
			cvbox.add_child(rsvp_row)

		# Attendee list
		var yes_list: Array = []
		var no_list: Array = []
		var maybe_list: Array = []
		for uname: String in rsvp:
			match rsvp[uname]:
				"yes":   yes_list.append(uname)
				"no":    no_list.append(uname)
				"maybe": maybe_list.append(uname)

		if not yes_list.is_empty() or not no_list.is_empty() or not maybe_list.is_empty():
			var attend_grid := GridContainer.new()
			attend_grid.columns = 3
			attend_grid.add_theme_constant_override("h_separation", 12)

			for grp: Array in [[yes_list, "✅ Joining", Color(0.4, 0.9, 0.5)],
								[maybe_list, "🤔 Maybe", Color(0.9, 0.8, 0.3)],
								[no_list, "❌ Can't join", Color(0.9, 0.4, 0.4)]]:
				var col := VBoxContainer.new()
				col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var col_hdr := Label.new()
				col_hdr.text = grp[1]
				col_hdr.add_theme_font_size_override("font_size", 11)
				col_hdr.add_theme_color_override("font_color", grp[2])
				col.add_child(col_hdr)
				if (grp[0] as Array).is_empty():
					var none_lbl := Label.new()
					none_lbl.text = "—"
					none_lbl.add_theme_font_size_override("font_size", 11)
					none_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
					col.add_child(none_lbl)
				else:
					for uname: String in grp[0]:
						var u_lbl := Label.new()
						u_lbl.text = "@" + uname
						u_lbl.add_theme_font_size_override("font_size", 11)
						u_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
						col.add_child(u_lbl)
				attend_grid.add_child(col)
			cvbox.add_child(attend_grid)

		_schedule_list.add_child(card)

# ─── Forum tab ────────────────────────────────────────────────────────────────

func _build_forum_tab(tabs: TabContainer) -> void:
	var root := _vbox("Forum", tabs)

	_forum_content = VBoxContainer.new()
	_forum_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_forum_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_forum_content)

	_load_forum()

func _forum_file() -> String:
	return ProjectSettings.globalize_path("user://cc_forum.json")

func _load_forum() -> void:
	_forum_items = []
	var path := _forum_file()
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Array:
				_forum_items = parsed
	if is_instance_valid(_forum_content):
		_forum_show_list()

func _save_forum() -> void:
	var fw := FileAccess.open(_forum_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_forum_items, "\t") + "\n")
		fw.close()
	_activity_auto_push()

func _forum_clear() -> void:
	for c in _forum_content.get_children():
		c.queue_free()

func _forum_show_list() -> void:
	_forum_thread_idx = -1
	_forum_clear()

	# Toolbar
	var toolbar := HBoxContainer.new()
	var new_btn := Button.new()
	new_btn.text = "✏ New Thread"
	new_btn.pressed.connect(_forum_prompt_new_thread)
	toolbar.add_child(new_btn)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(spacer)
	var count_lbl := Label.new()
	count_lbl.text = "%d thread%s" % [_forum_items.size(), "s" if _forum_items.size() != 1 else ""]
	count_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	count_lbl.add_theme_font_size_override("font_size", 11)
	toolbar.add_child(count_lbl)
	_forum_content.add_child(toolbar)
	_forum_content.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 2)
	scroll.add_child(list)
	_forum_content.add_child(scroll)

	if _forum_items.is_empty():
		var hint := Label.new()
		hint.text = "No threads yet. Start a discussion!"
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		list.add_child(hint)
		return

	for i in range(_forum_items.size()):
		var thread: Dictionary = _forum_items[i]
		var replies: Array = thread.get("replies", [])
		var last_ts: String = replies.back().get("timestamp", thread.get("created_at", "")) if not replies.is_empty() else thread.get("created_at", "")

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var left := VBoxContainer.new()
		left.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var title_btn := Button.new()
		title_btn.text = thread.get("title", "Untitled")
		title_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		title_btn.flat = true
		title_btn.add_theme_font_size_override("font_size", 13)
		var cap_i := i
		title_btn.pressed.connect(func(): _forum_show_thread(cap_i))
		left.add_child(title_btn)

		var meta := Label.new()
		var body_preview: String = thread.get("body", "")
		if body_preview.length() > 80:
			body_preview = body_preview.substr(0, 80) + "…"
		meta.text = body_preview
		meta.add_theme_font_size_override("font_size", 11)
		meta.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
		meta.clip_text = true
		left.add_child(meta)

		row.add_child(left)

		var right := VBoxContainer.new()
		right.custom_minimum_size = Vector2(110, 0)

		var reply_lbl := Label.new()
		reply_lbl.text = "💬 %d" % replies.size()
		reply_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		reply_lbl.add_theme_font_size_override("font_size", 11)
		reply_lbl.add_theme_color_override("font_color", Color(0.5, 0.65, 0.8))
		right.add_child(reply_lbl)

		var by_lbl := Label.new()
		by_lbl.text = "@" + thread.get("author", "?")
		by_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		by_lbl.add_theme_font_size_override("font_size", 10)
		by_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		right.add_child(by_lbl)

		var time_lbl := Label.new()
		time_lbl.text = last_ts.substr(0, 10) if last_ts.length() >= 10 else ""
		time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		time_lbl.add_theme_font_size_override("font_size", 10)
		time_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
		right.add_child(time_lbl)

		row.add_child(right)

		var del_btn := Button.new()
		del_btn.text = "🗑"
		del_btn.flat = true
		del_btn.tooltip_text = "Delete thread"
		var cap_i2 := i
		del_btn.pressed.connect(func():
			var cap_title: String = _forum_items[cap_i2].get("title", "")
			var me: String = _current_user.get("username", "?")
			_forum_items.remove_at(cap_i2)
			_save_forum()
			_log_activity("forum_deleted", '%s deleted thread: "%s"' % [me, cap_title])
			_forum_show_list()
		)
		row.add_child(del_btn)

		list.add_child(row)
		list.add_child(HSeparator.new())

func _forum_show_thread(idx: int) -> void:
	_forum_thread_idx = idx
	_forum_clear()
	if idx < 0 or idx >= _forum_items.size():
		_forum_show_list()
		return

	var thread: Dictionary = _forum_items[idx]
	var me: String = _current_user.get("username", "?")

	# Back button + title header
	var header := HBoxContainer.new()
	var back_btn := Button.new()
	back_btn.text = "← Back"
	back_btn.pressed.connect(_forum_show_list)
	header.add_child(back_btn)
	var h_title := Label.new()
	h_title.text = thread.get("title", "Untitled")
	h_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h_title.add_theme_font_size_override("font_size", 15)
	h_title.clip_text = true
	header.add_child(h_title)
	_forum_content.add_child(header)
	_forum_content.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var posts_box := VBoxContainer.new()
	posts_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	posts_box.add_theme_constant_override("separation", 6)
	scroll.add_child(posts_box)
	_forum_content.add_child(scroll)

	# Original post
	_forum_add_post_card(posts_box, {
		"user": thread.get("author", "?"),
		"text": thread.get("body", ""),
		"timestamp": thread.get("created_at", "")
	}, true)

	# Replies
	var replies: Array = thread.get("replies", [])
	for reply: Dictionary in replies:
		_forum_add_post_card(posts_box, reply, false)

	posts_box.add_child(HSeparator.new())

	# Reply input
	var reply_box := VBoxContainer.new()
	reply_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reply_box.add_theme_constant_override("separation", 4)

	var reply_lbl := Label.new()
	reply_lbl.text = "Reply as @" + me
	reply_lbl.add_theme_font_size_override("font_size", 11)
	reply_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	reply_box.add_child(reply_lbl)

	var reply_input := TextEdit.new()
	reply_input.placeholder_text = "Write your reply…"
	reply_input.custom_minimum_size = Vector2(0, 60)
	reply_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reply_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	reply_box.add_child(reply_input)

	var submit_btn := Button.new()
	submit_btn.text = "Post Reply"
	submit_btn.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var cap_idx := idx
	submit_btn.pressed.connect(func():
		var text := reply_input.text.strip_edges()
		if text.is_empty() or cap_idx < 0 or cap_idx >= _forum_items.size():
			return
		var rlist: Array = _forum_items[cap_idx].get("replies", [])
		rlist.append({
			"user": me,
			"text": text,
			"timestamp": Time.get_datetime_string_from_system()
		})
		_forum_items[cap_idx]["replies"] = rlist
		_save_forum()
		_forum_show_thread(cap_idx)
	)
	reply_box.add_child(submit_btn)
	_forum_content.add_child(reply_box)

func _forum_add_post_card(parent: VBoxContainer, post: Dictionary, is_op: bool) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 4)
	card.add_child(cvbox)

	var post_header := HBoxContainer.new()
	var user_lbl := Label.new()
	user_lbl.text = "@" + post.get("user", "?")
	user_lbl.add_theme_font_size_override("font_size", 12)
	user_lbl.add_theme_color_override("font_color", Color(0.5, 0.75, 1.0))
	post_header.add_child(user_lbl)
	if is_op:
		var op_lbl := Label.new()
		op_lbl.text = "OP"
		op_lbl.add_theme_font_size_override("font_size", 10)
		op_lbl.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
		post_header.add_child(op_lbl)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	post_header.add_child(spacer)
	var ts: String = post.get("timestamp", "")
	var ts_lbl := Label.new()
	ts_lbl.text = ts.substr(0, 16).replace("T", "  ") if ts.length() >= 16 else ts
	ts_lbl.add_theme_font_size_override("font_size", 10)
	ts_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	post_header.add_child(ts_lbl)
	cvbox.add_child(post_header)

	var body_lbl := Label.new()
	body_lbl.text = post.get("text", "")
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cvbox.add_child(body_lbl)

	parent.add_child(card)

func _forum_prompt_new_thread() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "New Thread"
	dialog.size = Vector2i(480, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	dialog.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "Title:"
	vbox.add_child(title_lbl)
	var title_edit := LineEdit.new()
	title_edit.placeholder_text = "Thread subject…"
	title_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_edit)

	var body_lbl := Label.new()
	body_lbl.text = "Post:"
	vbox.add_child(body_lbl)
	var body_edit := TextEdit.new()
	body_edit.placeholder_text = "Write your post…"
	body_edit.custom_minimum_size = Vector2(0, 80)
	body_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	vbox.add_child(body_edit)

	dialog.confirmed.connect(func():
		var title := title_edit.text.strip_edges()
		var body := body_edit.text.strip_edges()
		if title.is_empty():
			return
		var user: String = _current_user.get("username", "?")
		_forum_items.insert(0, {
			"title": title,
			"body": body,
			"author": user,
			"created_at": Time.get_datetime_string_from_system(),
			"replies": []
		})
		_save_forum()
		_log_activity("forum_posted", '%s started thread: "%s"' % [user, title])
		_forum_show_list()
	)
	add_child(dialog)
	dialog.popup_centered()

func _build_vault_tab(tabs: TabContainer) -> void:
	var root := _vbox("Assets", tabs)

	# ── Top bar ───────────────────────────────────────────────────────────────
	var top := HBoxContainer.new()
	var repo_lbl := Label.new()
	repo_lbl.text = "🔒 ChillCube/assets"
	repo_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	repo_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_refresh_btn = Button.new()
	_vault_refresh_btn.text = "🔄 Refresh"
	_vault_refresh_btn.tooltip_text = "Pull latest file list from ChillCube/assets"
	_vault_refresh_btn.pressed.connect(_vault_connect)
	_vault_status_lbl = Label.new()
	_vault_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	top.add_child(repo_lbl)
	top.add_child(_vault_refresh_btn)
	top.add_child(_vault_status_lbl)
	root.add_child(top)

	# ── Main split ────────────────────────────────────────────────────────────
	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# ── Left: browser ─────────────────────────────────────────────────────────
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(320, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.45
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Path + action buttons row
	var path_row := HBoxContainer.new()
	_vault_path_lbl = Label.new()
	_vault_path_lbl.text = "/"
	_vault_path_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	_vault_path_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_path_lbl.clip_text = true
	var upload_btn := Button.new()
	upload_btn.text = "⬆ Upload"
	upload_btn.tooltip_text = "Upload files to the current folder (supports zip auto-extract, multi-select)"
	upload_btn.pressed.connect(_vault_open_picker)
	_vault_sel_count_lbl = Label.new()
	_vault_sel_count_lbl.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0))
	_vault_sel_count_lbl.visible = false
	_vault_edit_sel_btn = Button.new()
	_vault_edit_sel_btn.text = "✏ Edit Selected"
	_vault_edit_sel_btn.visible = false
	_vault_edit_sel_btn.pressed.connect(func(): _asset_meta_bulk_edit(_vault_sel_files.duplicate()))
	var newdir_btn := Button.new()
	newdir_btn.text = "📁+"
	newdir_btn.tooltip_text = "Create new folder"
	newdir_btn.pressed.connect(func():
		var pre := (_vault_current_dir + "/") if not _vault_current_dir.is_empty() else ""
		_vault_newdir_input.text = pre
		_vault_newdir_dialog.popup_centered()
	)
	path_row.add_child(_vault_path_lbl)
	path_row.add_child(upload_btn)
	path_row.add_child(_vault_sel_count_lbl)
	path_row.add_child(_vault_edit_sel_btn)
	path_row.add_child(newdir_btn)
	left.add_child(path_row)
	left.add_child(HSeparator.new())

	# File browser
	var browser_scroll := ScrollContainer.new()
	browser_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	browser_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_browser = VBoxContainer.new()
	_vault_browser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_browser.add_theme_constant_override("separation", 2)
	browser_scroll.add_child(_vault_browser)
	left.add_child(browser_scroll)

	left.add_child(HSeparator.new())
	# Download destination row
	var dl_row := HBoxContainer.new()
	var dl_lbl := Label.new()
	dl_lbl.text = "⬇ To:"
	dl_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_vault_download_dest_btn = Button.new()
	_vault_download_dest_btn.text = "📁 Choose folder…"
	_vault_download_dest_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_download_dest_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_vault_download_dest_btn.tooltip_text = "Choose where to save downloaded files"
	_vault_download_dest_btn.pressed.connect(func(): _vault_dir_dialog.popup_centered_ratio(0.7))
	dl_row.add_child(dl_lbl)
	dl_row.add_child(_vault_download_dest_btn)
	left.add_child(dl_row)

	split.add_child(left)
	split.add_child(VSeparator.new())

	# ── Right: preview ────────────────────────────────────────────────────────
	_vault_preview_panel = VBoxContainer.new()
	_vault_preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_preview_panel.size_flags_stretch_ratio = 0.55
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

	_vault_gif_frame_container = HFlowContainer.new()
	_vault_gif_frame_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vault_gif_frame_container.add_theme_constant_override("h_separation", 4)
	_vault_gif_frame_container.add_theme_constant_override("v_separation", 4)
	_vault_gif_frame_container.visible = false
	preview_inner.add_child(_vault_gif_frame_container)

	split.add_child(_vault_preview_panel)
	root.add_child(split)

	# ── Log ───────────────────────────────────────────────────────────────────
	_vault_log = TextEdit.new()
	_vault_log.custom_minimum_size = Vector2(0, 60)
	_vault_log.editable = false
	_vault_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_vault_log)

	# Audio player (must be in scene tree)
	_vault_audio_player = AudioStreamPlayer.new()
	_vault_audio_player.finished.connect(func(): _vault_audio_play_btn.text = "▶ Play")
	add_child(_vault_audio_player)

	# File picker — selecting a file auto-uploads to current directory
	_vault_file_dialog = EditorFileDialog.new()
	_vault_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	_vault_file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	_vault_file_dialog.files_selected.connect(func(paths: PackedStringArray):
		_vault_upload_batch(Array(paths))
	)
	add_child(_vault_file_dialog)

	# Directory picker — choose download destination
	_vault_dir_dialog = EditorFileDialog.new()
	_vault_dir_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	_vault_dir_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	_vault_dir_dialog.dir_selected.connect(func(path: String):
		_vault_download_dest_path = path
		var short := path.get_file()
		_vault_download_dest_btn.text = "📁 " + (short if not short.is_empty() else path)
	)
	add_child(_vault_dir_dialog)

	# Move/rename dialog
	_vault_move_dialog = AcceptDialog.new()
	_vault_move_dialog.title = "Rename / Move File"
	_vault_move_dialog.size = Vector2i(420, 120)
	var move_vbox := VBoxContainer.new()
	move_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vault_move_dialog.add_child(move_vbox)
	var move_hint := Label.new()
	move_hint.text = "New path (e.g. images/photo.png):"
	move_vbox.add_child(move_hint)
	_vault_move_dest_input = LineEdit.new()
	_vault_move_dest_input.placeholder_text = "folder/filename.ext"
	_vault_move_dest_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_vbox.add_child(_vault_move_dest_input)
	_vault_move_dialog.confirmed.connect(_vault_do_move)
	add_child(_vault_move_dialog)

	# Delete confirm dialog
	_vault_delete_dialog = ConfirmationDialog.new()
	_vault_delete_dialog.title = "Archive File"
	_vault_delete_dialog.dialog_text = "Move this file to the archive?"
	_vault_delete_dialog.confirmed.connect(_vault_do_archive)
	add_child(_vault_delete_dialog)

	# New folder dialog
	_vault_newdir_dialog = AcceptDialog.new()
	_vault_newdir_dialog.title = "New Folder"
	_vault_newdir_dialog.size = Vector2i(360, 110)
	var dir_vbox := VBoxContainer.new()
	dir_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vault_newdir_dialog.add_child(dir_vbox)
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
		_docs_files = _docs_filter_files(_vault_files)
		_docs_navigate(_docs_current_dir)

func _vault_navigate(rel: String) -> void:
	if rel != _vault_current_dir:
		_vault_sel_files.clear()
		_vault_update_sel_ui()
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
		if path.begins_with("_cc_tools/") or path == "_cc_tools" \
				or path.begins_with("_docs/") or path == "_docs" \
				or path.begins_with("_archive/") or path == "_archive":
			continue
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
		var cap_folder := prefix + folder
		var folder_row := HBoxContainer.new()
		folder_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn := Button.new()
		btn.text = "📁 " + folder
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.flat = true
		btn.pressed.connect(func(): _vault_navigate(cap_folder))
		folder_row.add_child(btn)
		var ren_folder_btn := Button.new()
		ren_folder_btn.text = "✏"
		ren_folder_btn.tooltip_text = "Rename folder"
		ren_folder_btn.flat = true
		ren_folder_btn.custom_minimum_size = Vector2(26, 0)
		ren_folder_btn.pressed.connect(func():
			_vault_remote_sel = cap_folder
			_vault_move_dest_input.text = cap_folder
			_vault_move_dialog.title = "Rename Folder"
			_vault_move_dialog.popup_centered()
		)
		folder_row.add_child(ren_folder_btn)
		_vault_browser.add_child(folder_row)

	for file: String in files:
		var rel_file := prefix + file
		var cap_rel := rel_file
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var chk := CheckBox.new()
		chk.button_pressed = cap_rel in _vault_sel_files
		chk.toggled.connect(func(pressed: bool):
			if pressed:
				if cap_rel not in _vault_sel_files:
					_vault_sel_files.append(cap_rel)
			else:
				_vault_sel_files.erase(cap_rel)
			_vault_update_sel_ui()
		)
		row.add_child(chk)

		var file_btn := Button.new()
		file_btn.text = _vault_file_icon(file) + " " + file
		file_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		file_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		file_btn.flat = rel_file != _vault_remote_sel
		if rel_file == _vault_remote_sel:
			file_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		file_btn.pressed.connect(func():
			_vault_remote_sel = cap_rel
			_vault_navigate(_vault_current_dir)
			_vault_request_preview(cap_rel)
		)
		row.add_child(file_btn)

		var dl_btn := Button.new()
		dl_btn.text = "⬇"
		dl_btn.tooltip_text = "Download to selected folder"
		dl_btn.flat = true
		dl_btn.custom_minimum_size = Vector2(26, 0)
		dl_btn.pressed.connect(func():
			_vault_remote_sel = cap_rel
			_vault_download()
		)
		row.add_child(dl_btn)

		var ren_btn := Button.new()
		ren_btn.text = "✏"
		ren_btn.tooltip_text = "Rename / move"
		ren_btn.flat = true
		ren_btn.custom_minimum_size = Vector2(26, 0)
		ren_btn.pressed.connect(func():
			_vault_remote_sel = cap_rel
			_vault_move_dest_input.text = cap_rel
			_vault_move_dialog.title = "Rename / Move File"
			_vault_move_dialog.popup_centered()
		)
		row.add_child(ren_btn)

		var del_btn := Button.new()
		del_btn.text = "📦"
		del_btn.tooltip_text = "Archive"
		del_btn.flat = true
		del_btn.custom_minimum_size = Vector2(26, 0)
		del_btn.pressed.connect(func():
			_vault_confirm_delete(cap_rel)
		)
		row.add_child(del_btn)

		var meta_file: Dictionary = _asset_meta.get(cap_rel, {})
		var made_by: String = meta_file.get("made_by", "")
		var meta_btn := Button.new()
		meta_btn.flat = true
		meta_btn.custom_minimum_size = Vector2(26, 0)
		if not made_by.is_empty():
			meta_btn.text = "👤"
			meta_btn.tooltip_text = "Made by: " + made_by + "\n" + meta_file.get("notes", "") + "\nClick to edit"
		else:
			meta_btn.text = "👤"
			meta_btn.tooltip_text = "Add file info (author, notes)"
			meta_btn.modulate = Color(1, 1, 1, 0.3)
		meta_btn.pressed.connect(func():
			_asset_meta_edit(cap_rel)
		)
		row.add_child(meta_btn)

		if not made_by.is_empty():
			var by_lbl := Label.new()
			by_lbl.text = made_by
			by_lbl.add_theme_font_size_override("font_size", 10)
			by_lbl.add_theme_color_override("font_color", Color(0.5, 0.65, 0.5))
			by_lbl.custom_minimum_size = Vector2(60, 0)
			by_lbl.clip_text = true
			row.add_child(by_lbl)

		_vault_browser.add_child(row)

func _vault_file_icon(filename: String) -> String:
	var ext := filename.get_extension().to_lower()
	if ext in ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg", "hdr", "gif"]:
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

func _vault_upload_batch(files: Array) -> void:
	if _vault_cache.is_empty() or not DirAccess.dir_exists_absolute(_vault_cache):
		_vault_log.text = "⚠️ Not connected to a vault repo."
		return
	if files.is_empty():
		_vault_log.text = "⚠️ No files selected."
		return
	_vault_log.text = ""
	_vault_status_lbl.text = "Uploading…"
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = Thread.new()
	var cache := _vault_cache
	var dest := _vault_current_dir
	var local_files: Array[String] = []
	for f in files:
		local_files.append(str(f))
	_vault_thread.start(func():
		var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
		Ops.vault_upload_batch(local_files, dest, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_op", str(local_files.size()) + " file(s)", dest)
	)

func _vault_download() -> void:
	if _vault_cache.is_empty() or not DirAccess.dir_exists_absolute(_vault_cache):
		_vault_log.text = "⚠️ Not connected to a vault repo."
		return
	if _vault_remote_sel.is_empty():
		_vault_log.text = "⚠️ No file selected in the browser."
		return
	if _vault_download_dest_path.is_empty():
		_vault_log.text = "⚠️ No download folder selected. Use the ⬇ To: button."
		return
	_vault_log.text = ""
	_vault_status_lbl.text = "Downloading…"
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = Thread.new()
	var cache := _vault_cache
	var remote := _vault_remote_sel
	var dest := _vault_download_dest_path
	var is_gif := remote.get_extension().to_lower() == "gif"
	var gif_stem := remote.get_basename().get_file()
	_vault_thread.start(func():
		var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
		var ok := Ops.vault_download_file(cache, remote, dest, log_fn)
		if ok and is_gif:
			var gif_file: String = dest + "/" + remote.get_file()
			var frames_dir: String = dest + "/" + gif_stem
			var n := Ops.vault_gif_to_pngs(gif_file, frames_dir, log_fn)
			if n > 0:
				DirAccess.remove_absolute(gif_file)
				log_fn.call("✅ Extracted %d frame(s) to %s/" % [n, gif_stem])
		call_deferred("_vault_after_op", "", "")
	)

func _vault_after_op(uploaded_name: String, upload_dir: String) -> void:
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = null
	_vault_status_lbl.text = ""
	_vault_files = Ops.vault_list_files(_vault_cache)
	_vault_navigate(_vault_current_dir)
	EditorInterface.get_resource_filesystem().scan()
	if not uploaded_name.is_empty():
		var path := (upload_dir + "/" + uploaded_name).lstrip("/") if not upload_dir.is_empty() else uploaded_name
		_log_activity("asset_uploaded", 'Uploaded "%s" to assets' % path)

func _vault_request_preview(rel_path: String) -> void:
	if _vault_preview_thread and _vault_preview_thread.is_started():
		return
	_vault_clear_preview()
	_vault_preview_name_lbl.text = rel_path.get_file()
	var ext := rel_path.get_extension().to_lower()
	var IMAGE_EXTS := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg", "gif"]
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
	if ext == "gif":
		var gif_stem := rel_path.get_basename().get_file()
		_vault_preview_thread.start(func():
			Ops.vault_download_file(cache, rel_path, tmp_dir, Callable())
			var tmp_gif: String = tmp_dir + "/" + rel_path.get_file()
			var frames_dir: String = tmp_dir + "/frames_" + gif_stem
			var n := Ops.vault_gif_to_pngs(tmp_gif, frames_dir, Callable())
			call_deferred("_vault_on_gif_preview_ready", frames_dir, n, tmp_gif)
		)
	else:
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
	var IMAGE_EXTS := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg", "gif"]
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

func _vault_on_gif_preview_ready(frames_dir: String, count: int, fallback_gif: String) -> void:
	if _vault_preview_thread and _vault_preview_thread.is_started():
		_vault_preview_thread.wait_to_finish()
	_vault_preview_thread = null
	_vault_preview_loading_lbl.visible = false
	if count == 0:
		var img := Image.new()
		if img.load(fallback_gif) == OK:
			_vault_img_rect.texture = ImageTexture.create_from_image(img)
			_vault_img_rect.visible = true
			_vault_preview_name_lbl.text += "  (first frame — install ffmpeg for all frames)"
		else:
			_vault_preview_unsupported.text = "Could not preview GIF (install ffmpeg for frame extraction)."
			_vault_preview_unsupported.visible = true
		return
	_vault_preview_name_lbl.text += "  (%d frames)" % count
	const THUMB := 64
	for i in range(count):
		var frame_path: String = frames_dir + "/frame_%04d.png" % (i + 1)
		var img := Image.new()
		if img.load(frame_path) != OK:
			continue
		var w := img.get_width()
		var h := img.get_height()
		var scale := float(THUMB) / float(max(w, h))
		img.resize(int(w * scale), int(h * scale), Image.INTERPOLATE_NEAREST)
		var tex := ImageTexture.create_from_image(img)
		var frame_box := VBoxContainer.new()
		var rect := TextureRect.new()
		rect.texture = tex
		rect.custom_minimum_size = Vector2(THUMB, THUMB)
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		frame_box.add_child(rect)
		var num_lbl := Label.new()
		num_lbl.text = str(i + 1)
		num_lbl.add_theme_font_size_override("font_size", 9)
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		frame_box.add_child(num_lbl)
		_vault_gif_frame_container.add_child(frame_box)
	_vault_gif_frame_container.visible = true

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
	if _vault_gif_frame_container:
		for c in _vault_gif_frame_container.get_children():
			c.queue_free()
		_vault_gif_frame_container.visible = false

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
			stream = AudioStreamWAV.load_from_file(path)
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
	var cap_dest := dest
	var cache := _vault_cache
	var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
	_vault_thread.start(func():
		Ops.vault_move_file(src, cap_dest, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_manage_named", "asset_renamed",
			'Renamed "%s" → "%s"' % [src.get_file(), cap_dest.get_file()])
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
	var cap_name := name
	var cache := _vault_cache
	var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
	_vault_thread.start(func():
		Ops.vault_mkdir(cap_name, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_manage_named", "folder_created", 'Created folder "%s" in assets' % cap_name)
	)

func _vault_confirm_delete(rel_path: String) -> void:
	_vault_pending_delete = rel_path
	_vault_delete_dialog.dialog_text = 'Archive "%s"? It will be moved to _archive/YYYY/MM/.' % rel_path.get_file()
	_vault_delete_dialog.popup_centered()

func _vault_do_archive() -> void:
	if _vault_pending_delete.is_empty():
		return
	if _vault_thread and _vault_thread.is_started():
		_vault_log.text = "⚠ Another operation is running."
		return
	var target := _vault_pending_delete
	_vault_pending_delete = ""
	_vault_log.text = ""
	_vault_status_lbl.text = "Archiving…"
	_vault_thread = Thread.new()
	var cache := _vault_cache
	var dt := Time.get_datetime_dict_from_system()
	var dest: String = "_archive/%04d/%02d/%s" % [dt.year, dt.month, target.get_file()]
	_vault_thread.start(func():
		var log_fn := func(msg): call_deferred("_append_log", _vault_log, msg)
		Ops.vault_move_file(target, dest, log_fn)
		Ops.vault_refresh(cache, log_fn)
		call_deferred("_vault_after_manage_named", "asset_deleted", 'Archived "%s"' % target.get_file())
	)

func _vault_after_manage() -> void:
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = null
	_vault_status_lbl.text = ""
	_vault_remote_sel = ""
	_vault_files = Ops.vault_list_files(_vault_cache)
	_vault_navigate(_vault_current_dir)

func _vault_after_manage_named(log_type: String, log_text: String) -> void:
	if _vault_thread and _vault_thread.is_started():
		_vault_thread.wait_to_finish()
	_vault_thread = null
	_vault_status_lbl.text = ""
	_vault_remote_sel = ""
	_vault_files = Ops.vault_list_files(_vault_cache)
	_vault_navigate(_vault_current_dir)
	_log_activity(log_type, log_text)

func _asset_meta_file() -> String:
	return ProjectSettings.globalize_path("user://cc_asset_meta.json")

func _load_asset_meta() -> void:
	_asset_meta = {}
	var path := _asset_meta_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		_asset_meta = parsed

func _save_asset_meta() -> void:
	var fw := FileAccess.open(_asset_meta_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_asset_meta, "\t") + "\n")
		fw.close()
	_activity_auto_push()

func _asset_meta_edit(rel_path: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "File Info: " + rel_path.get_file()
	dialog.size = Vector2i(400, 130)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	dialog.add_child(vbox)

	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = "Made by:"
	lbl.custom_minimum_size = Vector2(70, 0)
	row.add_child(lbl)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.placeholder_text = "Name or username (any text)"
	var meta: Dictionary = _asset_meta.get(rel_path, {})
	edit.text = meta.get("made_by", "")
	row.add_child(edit)
	vbox.add_child(row)

	var notes_row := HBoxContainer.new()
	var notes_lbl := Label.new()
	notes_lbl.text = "Notes:"
	notes_lbl.custom_minimum_size = Vector2(70, 0)
	notes_row.add_child(notes_lbl)
	var notes_edit := LineEdit.new()
	notes_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notes_edit.placeholder_text = "Optional description…"
	notes_edit.text = meta.get("notes", "")
	notes_row.add_child(notes_edit)
	vbox.add_child(notes_row)

	var cap_path := rel_path
	dialog.confirmed.connect(func():
		var made_by := edit.text.strip_edges()
		var notes := notes_edit.text.strip_edges()
		if made_by.is_empty() and notes.is_empty():
			_asset_meta.erase(cap_path)
		else:
			_asset_meta[cap_path] = {"made_by": made_by, "notes": notes}
		_save_asset_meta()
		_vault_navigate(_vault_current_dir)
	)
	add_child(dialog)
	dialog.popup_centered()

func _vault_update_sel_ui() -> void:
	var n := _vault_sel_files.size()
	_vault_sel_count_lbl.text = "%d selected" % n
	_vault_sel_count_lbl.visible = n > 0
	_vault_edit_sel_btn.visible = n > 0

func _asset_meta_bulk_edit(paths: Array) -> void:
	if paths.is_empty():
		return
	const MIXED := "(mixed)"
	var first_made_by: String = (_asset_meta.get(paths[0], {}) as Dictionary).get("made_by", "")
	var first_notes: String = (_asset_meta.get(paths[0], {}) as Dictionary).get("notes", "")
	for p in paths:
		var meta: Dictionary = _asset_meta.get(str(p), {})
		if meta.get("made_by", "") != first_made_by:
			first_made_by = MIXED
		if meta.get("notes", "") != first_notes:
			first_notes = MIXED
	var dialog := AcceptDialog.new()
	dialog.title = "Bulk Edit (%d files)" % paths.size()
	dialog.size = Vector2i(440, 140)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	dialog.add_child(vbox)
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = "Made by:"
	lbl.custom_minimum_size = Vector2(70, 0)
	row.add_child(lbl)
	var made_by_edit := LineEdit.new()
	made_by_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if first_made_by == MIXED:
		made_by_edit.placeholder_text = "(mixed — type to override all)"
	else:
		made_by_edit.text = first_made_by
	row.add_child(made_by_edit)
	vbox.add_child(row)
	var notes_row := HBoxContainer.new()
	var notes_lbl := Label.new()
	notes_lbl.text = "Notes:"
	notes_lbl.custom_minimum_size = Vector2(70, 0)
	notes_row.add_child(notes_lbl)
	var notes_edit := LineEdit.new()
	notes_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if first_notes == MIXED:
		notes_edit.placeholder_text = "(mixed — type to override all)"
	else:
		notes_edit.text = first_notes
	notes_row.add_child(notes_edit)
	vbox.add_child(notes_row)
	var orig_mb := first_made_by
	var orig_n := first_notes
	dialog.confirmed.connect(func():
		var new_mb := made_by_edit.text.strip_edges()
		var new_n := notes_edit.text.strip_edges()
		var mb_changed: bool = (orig_mb == MIXED and not new_mb.is_empty()) or (orig_mb != MIXED and new_mb != orig_mb)
		var n_changed: bool = (orig_n == MIXED and not new_n.is_empty()) or (orig_n != MIXED and new_n != orig_n)
		for p in paths:
			var ps: String = str(p)
			var meta: Dictionary = (_asset_meta.get(ps, {}) as Dictionary).duplicate()
			if mb_changed:
				if new_mb.is_empty(): meta.erase("made_by") else: meta["made_by"] = new_mb
			if n_changed:
				if new_n.is_empty(): meta.erase("notes") else: meta["notes"] = new_n
			if meta.is_empty(): _asset_meta.erase(ps) else: _asset_meta[ps] = meta
		_save_asset_meta()
		_vault_navigate(_vault_current_dir)
	)
	add_child(dialog)
	dialog.popup_centered()

# ─── Docs tab ────────────────────────────────────────────────────────────────

const DOCS_PREFIX := "_docs"
const DOCS_ARCHIVE_REL := "_archive"

func _build_docs_tab(tabs: TabContainer) -> void:
	var root := _vbox("Docs", tabs)

	var top := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = "📖 Documentation"
	title_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var refresh_btn := Button.new()
	refresh_btn.text = "🔄 Refresh"
	refresh_btn.tooltip_text = "Re-fetch file list from vault"
	refresh_btn.pressed.connect(func():
		if not _vault_cache.is_empty():
			_vault_connect()
	)
	_docs_status_lbl = Label.new()
	_docs_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	top.add_child(title_lbl)
	top.add_child(refresh_btn)
	top.add_child(_docs_status_lbl)
	root.add_child(top)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# ── Left: folder browser ──────────────────────────────────────────────────
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(200, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var path_row := HBoxContainer.new()
	_docs_path_lbl = Label.new()
	_docs_path_lbl.text = "/"
	_docs_path_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	_docs_path_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_path_lbl.clip_text = true
	_docs_new_doc_btn = Button.new()
	_docs_new_doc_btn.text = "📄+"
	_docs_new_doc_btn.tooltip_text = "New document"
	_docs_new_doc_btn.pressed.connect(func():
		var pre := (_docs_current_dir + "/") if not _docs_current_dir.is_empty() else ""
		_docs_new_input.text = pre
		_docs_new_dialog.popup_centered()
	)
	_docs_new_dir_btn = Button.new()
	_docs_new_dir_btn.text = "📁+"
	_docs_new_dir_btn.tooltip_text = "New folder"
	_docs_new_dir_btn.pressed.connect(func():
		var pre := (_docs_current_dir + "/") if not _docs_current_dir.is_empty() else ""
		_docs_newdir_input.text = pre
		_docs_newdir_dialog.popup_centered()
	)
	path_row.add_child(_docs_path_lbl)
	path_row.add_child(_docs_new_doc_btn)
	path_row.add_child(_docs_new_dir_btn)
	left.add_child(path_row)
	left.add_child(HSeparator.new())

	var browser_scroll := ScrollContainer.new()
	browser_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	browser_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_browser = VBoxContainer.new()
	_docs_browser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_browser.add_theme_constant_override("separation", 2)
	browser_scroll.add_child(_docs_browser)
	left.add_child(browser_scroll)

	split.add_child(left)
	split.add_child(VSeparator.new())

	# ── Right: viewer / editor ────────────────────────────────────────────────
	_docs_view_panel = VBoxContainer.new()
	_docs_view_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_view_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var doc_header := HBoxContainer.new()
	_docs_title_lbl = Label.new()
	_docs_title_lbl.text = "Select a document"
	_docs_title_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_docs_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_title_lbl.clip_text = true
	_docs_edit_btn = Button.new()
	_docs_edit_btn.text = "✏️ Edit"
	_docs_edit_btn.visible = false
	_docs_edit_btn.pressed.connect(_docs_enter_edit)
	_docs_delete_header_btn = Button.new()
	_docs_delete_header_btn.text = "📦 Archive"
	_docs_delete_header_btn.visible = false
	_docs_delete_header_btn.pressed.connect(func():
		if not _docs_sel_path.is_empty():
			_docs_pending_delete = _docs_sel_path
			_docs_delete_dialog.popup_centered()
	)
	_docs_archive_suggest_btn = Button.new()
	_docs_archive_suggest_btn.text = "📦 Suggest Archive"
	_docs_archive_suggest_btn.tooltip_text = "Propose archiving this document (requires a vote)"
	_docs_archive_suggest_btn.visible = false
	_docs_archive_suggest_btn.pressed.connect(func():
		if _docs_sel_path.is_empty():
			return
		for s: Dictionary in _docs_suggestions:
			if s.get("doc_path", "") == _docs_sel_path and s.get("type", "") == "archive_request" and s.get("status", "") == "pending":
				_docs_status_lbl.text = "⚠ Archive vote already pending."
				return
		var me: String = _current_user.get("username", "?")
		var perm: Dictionary = _docs_permissions.get(_docs_sel_path, {})
		var sugg: Dictionary = {
			"id": str(Time.get_unix_time_from_system()) + "_" + me,
			"doc_path": _docs_sel_path,
			"author": me,
			"timestamp": Time.get_datetime_string_from_system(),
			"type": "archive_request",
			"vote_required": true,
			"vote_threshold": perm.get("vote_threshold", "1/2"),
			"votes": {"yes": [], "no": []},
			"status": "pending"
		}
		_docs_suggestions.append(sugg)
		_save_doc_suggestions()
		var doc_name := _docs_sel_path.get_file().get_basename()
		_log_activity("doc_suggestion", '"%s" proposed archiving: "%s"' % [me, doc_name])
		_refresh_vote_list()
		_docs_status_lbl.text = "✅ Archive vote submitted"
		get_tree().create_timer(3.0).timeout.connect(func():
			if is_instance_valid(_docs_status_lbl): _docs_status_lbl.text = ""
		)
	)
	_docs_save_btn = Button.new()
	_docs_save_btn.text = "💾 Save"
	_docs_save_btn.visible = false
	_docs_save_btn.pressed.connect(_docs_save)
	_docs_cancel_btn = Button.new()
	_docs_cancel_btn.text = "✕"
	_docs_cancel_btn.visible = false
	_docs_cancel_btn.pressed.connect(_docs_exit_edit)
	_docs_perm_btn = Button.new()
	_docs_perm_btn.text = "🔒"
	_docs_perm_btn.tooltip_text = "Edit permissions"
	_docs_perm_btn.visible = false
	_docs_perm_btn.pressed.connect(_docs_open_perm_dialog)
	_docs_suggest_btn = Button.new()
	_docs_suggest_btn.text = "💡 Suggest Edit"
	_docs_suggest_btn.tooltip_text = "Propose a change for review"
	_docs_suggest_btn.visible = false
	_docs_suggest_btn.pressed.connect(_docs_enter_suggest)
	_docs_suggest_submit_btn = Button.new()
	_docs_suggest_submit_btn.text = "📤 Submit"
	_docs_suggest_submit_btn.visible = false
	_docs_suggest_submit_btn.pressed.connect(_docs_suggest_submit)
	_docs_review_btn = Button.new()
	_docs_review_btn.text = "📬"
	_docs_review_btn.tooltip_text = "Review suggestions"
	_docs_review_btn.visible = false
	_docs_review_btn.pressed.connect(_docs_open_review_dialog)
	doc_header.add_child(_docs_title_lbl)
	doc_header.add_child(_docs_edit_btn)
	doc_header.add_child(_docs_suggest_btn)
	doc_header.add_child(_docs_delete_header_btn)
	doc_header.add_child(_docs_archive_suggest_btn)
	doc_header.add_child(_docs_save_btn)
	doc_header.add_child(_docs_suggest_submit_btn)
	doc_header.add_child(_docs_cancel_btn)
	doc_header.add_child(_docs_review_btn)
	doc_header.add_child(_docs_perm_btn)
	_docs_view_panel.add_child(doc_header)
	_docs_view_panel.add_child(HSeparator.new())

	_docs_view_scroll = ScrollContainer.new()
	var view_scroll := _docs_view_scroll
	view_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_view = RichTextLabel.new()
	_docs_view.bbcode_enabled = true
	_docs_view.fit_content = true
	_docs_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_view.size_flags_vertical = Control.SIZE_FILL
	_docs_view.scroll_active = false
	_docs_view.meta_clicked.connect(_docs_on_link_clicked)
	view_scroll.add_child(_docs_view)
	_docs_view_panel.add_child(view_scroll)

	_docs_editor = TextEdit.new()
	_docs_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_docs_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_docs_editor.visible = false
	var code_font: Font = EditorInterface.get_editor_theme().get_font("source", "EditorFonts")
	if code_font:
		_docs_editor.add_theme_font_override("font", code_font)
	_docs_view_panel.add_child(_docs_editor)

	split.add_child(_docs_view_panel)
	root.add_child(split)

	# ── Dialogs ───────────────────────────────────────────────────────────────
	_docs_new_dialog = AcceptDialog.new()
	_docs_new_dialog.title = "New Document"
	_docs_new_dialog.size = Vector2i(420, 110)
	var new_vbox := VBoxContainer.new()
	new_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_docs_new_dialog.add_child(new_vbox)
	var new_hint := Label.new()
	new_hint.text = "Path (e.g. guides/Getting Started — no .md needed):"
	new_vbox.add_child(new_hint)
	_docs_new_input = LineEdit.new()
	_docs_new_input.placeholder_text = "My Document"
	_docs_new_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_vbox.add_child(_docs_new_input)
	_docs_new_dialog.confirmed.connect(func():
		var path := _docs_new_input.text.strip_edges()
		if not path.is_empty():
			_docs_do_create(path)
	)
	add_child(_docs_new_dialog)

	_docs_newdir_dialog = AcceptDialog.new()
	_docs_newdir_dialog.title = "New Folder"
	_docs_newdir_dialog.size = Vector2i(380, 110)
	var dir_vbox := VBoxContainer.new()
	dir_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_docs_newdir_dialog.add_child(dir_vbox)
	var dir_hint := Label.new()
	dir_hint.text = "Folder path (e.g. guides/tutorials):"
	dir_vbox.add_child(dir_hint)
	_docs_newdir_input = LineEdit.new()
	_docs_newdir_input.placeholder_text = "my-folder"
	_docs_newdir_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dir_vbox.add_child(_docs_newdir_input)
	_docs_newdir_dialog.confirmed.connect(func():
		var path := _docs_newdir_input.text.strip_edges()
		if not path.is_empty():
			_docs_do_mkdir(path)
	)
	add_child(_docs_newdir_dialog)

	_docs_delete_dialog = ConfirmationDialog.new()
	_docs_delete_dialog.title = "Archive Document"
	_docs_delete_dialog.dialog_text = "Move this document to the archive?\nIt will be read-only and cannot be edited."
	_docs_delete_dialog.confirmed.connect(_docs_do_delete)
	add_child(_docs_delete_dialog)

	_docs_move_dialog = AcceptDialog.new()
	_docs_move_dialog.title = "Move / Rename Document"
	_docs_move_dialog.size = Vector2i(440, 180)
	var move_vbox := VBoxContainer.new()
	move_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_docs_move_dialog.add_child(move_vbox)
	var folder_lbl := Label.new()
	folder_lbl.text = "Destination folder:"
	move_vbox.add_child(folder_lbl)
	_docs_move_folder_btn = OptionButton.new()
	_docs_move_folder_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_vbox.add_child(_docs_move_folder_btn)
	var name_lbl := Label.new()
	name_lbl.text = "Document name:"
	move_vbox.add_child(name_lbl)
	_docs_move_input = LineEdit.new()
	_docs_move_input.placeholder_text = "document-name"
	_docs_move_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_vbox.add_child(_docs_move_input)
	_docs_move_dialog.confirmed.connect(func():
		var name := _docs_move_input.text.strip_edges()
		if name.is_empty():
			return
		var sel := _docs_move_folder_btn.selected
		var folder := _docs_move_folder_items[sel] if sel >= 0 and sel < _docs_move_folder_items.size() else ""
		var dest := (folder + "/" if not folder.is_empty() else "") + name
		_docs_do_move(dest)
	)
	add_child(_docs_move_dialog)

	_docs_perm_dialog = AcceptDialog.new()
	_docs_perm_dialog.title = "Document Permissions"
	_docs_perm_dialog.size = Vector2i(400, 420)
	var perm_vbox := VBoxContainer.new()
	perm_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_docs_perm_dialog.add_child(perm_vbox)
	var perm_mode_lbl := Label.new()
	perm_mode_lbl.text = "Who can edit this document?"
	perm_vbox.add_child(perm_mode_lbl)
	_docs_perm_mode = OptionButton.new()
	_docs_perm_mode.add_item("Anyone")
	_docs_perm_mode.add_item("Specific users only")
	perm_vbox.add_child(_docs_perm_mode)
	_docs_perm_user_section = VBoxContainer.new()
	var perm_user_section := _docs_perm_user_section
	perm_vbox.add_child(perm_user_section)
	var perm_users_lbl := Label.new()
	perm_users_lbl.text = "Allowed users:"
	perm_users_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	perm_user_section.add_child(perm_users_lbl)
	var perm_scroll := ScrollContainer.new()
	perm_scroll.custom_minimum_size = Vector2(0, 100)
	perm_user_section.add_child(perm_scroll)
	_docs_perm_user_list = VBoxContainer.new()
	_docs_perm_user_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	perm_scroll.add_child(_docs_perm_user_list)
	var perm_add_row := HBoxContainer.new()
	_docs_perm_input = LineEdit.new()
	_docs_perm_input.placeholder_text = "Username"
	_docs_perm_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var perm_add_btn := Button.new()
	perm_add_btn.text = "+ Add"
	perm_add_btn.pressed.connect(_docs_perm_add_user)
	perm_add_row.add_child(_docs_perm_input)
	perm_add_row.add_child(perm_add_btn)
	perm_user_section.add_child(perm_add_row)
	_docs_perm_mode.item_selected.connect(func(idx: int):
		if is_instance_valid(_docs_perm_user_section):
			_docs_perm_user_section.visible = idx == 1
	)
	perm_vbox.add_child(HSeparator.new())
	_docs_perm_vote_check = CheckBox.new()
	_docs_perm_vote_check.text = "Require team vote to change"
	perm_vbox.add_child(_docs_perm_vote_check)
	_docs_perm_vote_section = VBoxContainer.new()
	_docs_perm_vote_section.visible = false
	perm_vbox.add_child(_docs_perm_vote_section)
	var vote_thresh_lbl := Label.new()
	vote_thresh_lbl.text = "Approval threshold (yes / total votes cast):"
	vote_thresh_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_docs_perm_vote_section.add_child(vote_thresh_lbl)
	_docs_perm_vote_thresh = OptionButton.new()
	_docs_perm_vote_thresh.add_item("1/3  (any minority)")
	_docs_perm_vote_thresh.add_item("1/2  (simple majority)")
	_docs_perm_vote_thresh.add_item("2/3  (supermajority)")
	_docs_perm_vote_thresh.add_item("3/4  (strong consensus)")
	_docs_perm_vote_thresh.select(1)
	_docs_perm_vote_section.add_child(_docs_perm_vote_thresh)
	_docs_perm_vote_check.toggled.connect(func(on: bool):
		if is_instance_valid(_docs_perm_vote_section):
			_docs_perm_vote_section.visible = on
	)
	_docs_perm_dialog.confirmed.connect(_docs_perm_save)
	add_child(_docs_perm_dialog)

	_docs_review_dialog = AcceptDialog.new()
	_docs_review_dialog.title = "Suggested Edits"
	_docs_review_dialog.size = Vector2i(620, 520)
	var rev_vbox := VBoxContainer.new()
	rev_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_docs_review_dialog.add_child(rev_vbox)
	var rev_top := HBoxContainer.new()
	var rev_title := Label.new()
	rev_title.name = "_rev_title"
	rev_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rev_top.add_child(rev_title)
	rev_vbox.add_child(rev_top)
	rev_vbox.add_child(HSeparator.new())
	var rev_scroll := ScrollContainer.new()
	rev_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rev_scroll.custom_minimum_size = Vector2(0, 200)
	_docs_review_list = VBoxContainer.new()
	_docs_review_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_review_list.add_theme_constant_override("separation", 4)
	rev_scroll.add_child(_docs_review_list)
	rev_vbox.add_child(rev_scroll)
	rev_vbox.add_child(HSeparator.new())
	var rev_prev_lbl := Label.new()
	rev_prev_lbl.text = "Preview:"
	rev_prev_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	rev_vbox.add_child(rev_prev_lbl)
	var rev_prev_scroll := ScrollContainer.new()
	rev_prev_scroll.custom_minimum_size = Vector2(0, 140)
	_docs_review_view = RichTextLabel.new()
	_docs_review_view.bbcode_enabled = true
	_docs_review_view.fit_content = false
	_docs_review_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_review_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_docs_review_view.scroll_active = false
	rev_prev_scroll.add_child(_docs_review_view)
	rev_vbox.add_child(rev_prev_scroll)
	add_child(_docs_review_dialog)

	_docs_diff_dialog = AcceptDialog.new()
	_docs_diff_dialog.title = "Side-by-Side Diff"
	_docs_diff_dialog.size = Vector2i(960, 640)
	var diff_root := VBoxContainer.new()
	diff_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_docs_diff_dialog.add_child(diff_root)
	var diff_header := HBoxContainer.new()
	var diff_lbl_orig := Label.new()
	diff_lbl_orig.text = "Original"
	diff_lbl_orig.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diff_lbl_orig.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	var diff_lbl_prop := Label.new()
	diff_lbl_prop.text = "Proposed"
	diff_lbl_prop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diff_lbl_prop.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	diff_header.add_child(diff_lbl_orig)
	diff_header.add_child(VSeparator.new())
	diff_header.add_child(diff_lbl_prop)
	diff_root.add_child(diff_header)
	diff_root.add_child(HSeparator.new())
	var diff_scroll := ScrollContainer.new()
	diff_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	diff_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var diff_cols := HBoxContainer.new()
	diff_cols.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diff_cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_docs_diff_left = RichTextLabel.new()
	_docs_diff_left.bbcode_enabled = true
	_docs_diff_left.fit_content = true
	_docs_diff_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_diff_left.scroll_active = false
	_docs_diff_left.selection_enabled = true
	var diff_mono: Font = EditorInterface.get_editor_theme().get_font("source", "EditorFonts")
	if diff_mono:
		_docs_diff_left.add_theme_font_override("normal_font", diff_mono)
	diff_cols.add_child(_docs_diff_left)
	diff_cols.add_child(VSeparator.new())
	_docs_diff_right = RichTextLabel.new()
	_docs_diff_right.bbcode_enabled = true
	_docs_diff_right.fit_content = true
	_docs_diff_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_docs_diff_right.scroll_active = false
	_docs_diff_right.selection_enabled = true
	if diff_mono:
		_docs_diff_right.add_theme_font_override("normal_font", diff_mono)
	diff_cols.add_child(_docs_diff_right)
	diff_scroll.add_child(diff_cols)
	diff_root.add_child(diff_scroll)
	add_child(_docs_diff_dialog)

	_docs_navigate("")

# ─── Docs logic ───────────────────────────────────────────────────────────────

func _docs_filter_files(all_files: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for f: String in all_files:
		if f.begins_with(DOCS_PREFIX + "/"):
			if f.get_extension() == "md" or f.get_file() == ".gitkeep":
				result.append(f)
	return result

func _docs_get_folders() -> Array[String]:
	var folders: Array[String] = [""]
	for full_path: String in _docs_files:
		if _docs_is_archived(full_path) or full_path.get_file() == ".gitkeep":
			continue
		var rel := _docs_rel(full_path)
		var dir := rel.get_base_dir()
		if dir != "." and not dir.is_empty() and dir not in folders:
			folders.append(dir)
	folders.sort()
	return folders

func _docs_rel(full_path: String) -> String:
	return full_path.substr(DOCS_PREFIX.length() + 1)

func _docs_full(rel_path: String) -> String:
	return DOCS_PREFIX + "/" + rel_path

func _docs_navigate(rel: String) -> void:
	_docs_current_dir = rel
	_docs_path_lbl.text = "/" + rel

	for c in _docs_browser.get_children():
		c.queue_free()

	if _vault_cache.is_empty() or not DirAccess.dir_exists_absolute(_vault_cache):
		var hint := Label.new()
		hint.text = "Not connected. Use the Assets tab to connect first."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_docs_browser.add_child(hint)
		return

	var in_archive: bool = rel == DOCS_ARCHIVE_REL or rel.begins_with(DOCS_ARCHIVE_REL + "/")
	_docs_new_doc_btn.visible = not in_archive
	_docs_new_dir_btn.visible = not in_archive

	var prefix := (rel + "/") if not rel.is_empty() else ""
	var folders: Array[String] = []
	var files: Array[String] = []

	for full_path: String in _docs_files:
		var doc_rel := _docs_rel(full_path)
		if not doc_rel.begins_with(prefix):
			continue
		var rest := doc_rel.substr(prefix.length())
		if "/" in rest:
			var folder := rest.split("/")[0]
			# Hide the archive folder from normal listings — it gets its own button
			if folder == DOCS_ARCHIVE_REL and rel.is_empty():
				continue
			if folder not in folders:
				folders.append(folder)
		else:
			if full_path.get_file() != ".gitkeep":
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
		up_btn.pressed.connect(func(): _docs_navigate(parent))
		_docs_browser.add_child(up_btn)

	for folder: String in folders:
		var cap_folder := (prefix + folder).rstrip("/")
		var btn := Button.new()
		btn.text = "📁 " + folder
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.flat = true
		btn.pressed.connect(func(): _docs_navigate(cap_folder))
		_docs_browser.add_child(btn)

	for file: String in files:
		var rel_file := prefix + file
		var full_file := _docs_full(rel_file)
		var cap_rel := rel_file
		var cap_full := full_file

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var icon := "📦 " if in_archive else "📄 "
		var file_btn := Button.new()
		file_btn.text = icon + file.get_basename()
		file_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		file_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		file_btn.flat = cap_full != _docs_sel_path
		if cap_full == _docs_sel_path:
			file_btn.add_theme_color_override("font_color",
				Color(0.8, 0.6, 0.4) if in_archive else Color(0.4, 0.8, 1.0))
		file_btn.pressed.connect(func():
			_docs_sel_path = cap_full
			_docs_navigate(_docs_current_dir)
			_docs_select(cap_full)
		)
		row.add_child(file_btn)

		if not in_archive and _docs_can_edit(cap_full):
			var ren_btn := Button.new()
			ren_btn.text = "✏"
			ren_btn.flat = true
			ren_btn.custom_minimum_size = Vector2(26, 0)
			ren_btn.tooltip_text = "Rename / move" + (" (requires vote)" if _docs_requires_vote(cap_full) else "")
			ren_btn.pressed.connect(func():
				_docs_move_folder_btn.clear()
				_docs_move_folder_items = _docs_get_folders()
				var cur_dir := cap_rel.get_base_dir()
				if cur_dir == ".":
					cur_dir = ""
				var sel_idx := 0
				for fi: int in range(_docs_move_folder_items.size()):
					var f: String = _docs_move_folder_items[fi]
					_docs_move_folder_btn.add_item("/ (root)" if f.is_empty() else f)
					if f == cur_dir:
						sel_idx = fi
				_docs_move_folder_btn.select(sel_idx)
				_docs_move_input.text = cap_rel.get_file().get_basename()
				_docs_move_dialog.popup_centered()
			)
			row.add_child(ren_btn)

			if _docs_can_edit(cap_full) and not _docs_requires_vote(cap_full):
				var del_btn := Button.new()
				del_btn.text = "🗑"
				del_btn.flat = true
				del_btn.custom_minimum_size = Vector2(26, 0)
				del_btn.tooltip_text = "Archive"
				del_btn.pressed.connect(func():
					_docs_pending_delete = cap_full
					_docs_delete_dialog.popup_centered()
				)
				row.add_child(del_btn)

		_docs_browser.add_child(row)

	if folders.is_empty() and files.is_empty():
		var hint := Label.new()
		if in_archive:
			hint.text = "Archive is empty."
		elif rel.is_empty():
			hint.text = "No documents yet.\nClick 📄+ to create one."
		else:
			hint.text = "Empty folder."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_docs_browser.add_child(hint)

	# ── Archive folder button (always at the bottom of the root view) ─────────
	if rel.is_empty():
		var sep := HSeparator.new()
		_docs_browser.add_child(sep)
		var arc_btn := Button.new()
		var arc_count := 0
		for f: String in _docs_files:
			if _docs_is_archived(f) and f.get_file() != ".gitkeep":
				arc_count += 1
		arc_btn.text = "📦 Archive" + (" (%d)" % arc_count if arc_count > 0 else "")
		arc_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		arc_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		arc_btn.flat = true
		arc_btn.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))
		arc_btn.pressed.connect(func(): _docs_navigate(DOCS_ARCHIVE_REL))
		_docs_browser.add_child(arc_btn)

func _docs_select(full_path: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		return
	_docs_title_lbl.text = full_path.get_file().get_basename()
	_docs_title_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_docs_edit_btn.visible = false
	_docs_suggest_btn.visible = false
	_docs_delete_header_btn.visible = false
	_docs_archive_suggest_btn.visible = false
	_docs_perm_btn.visible = false
	_docs_review_btn.visible = false
	_docs_save_btn.visible = false
	_docs_suggest_submit_btn.visible = false
	_docs_cancel_btn.visible = false
	_docs_status_lbl.text = "Loading…"
	_docs_view.text = ""
	_docs_editor.visible = false
	_docs_view_scroll.visible = true
	var cache := _vault_cache
	var tmp_dir := OS.get_temp_dir() + "/cc_docs_preview"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var cap_path := full_path
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_download_file(cache, cap_path, tmp_dir, Callable())
		var tmp_file := tmp_dir + "/" + cap_path.get_file()
		call_deferred("_docs_on_loaded", tmp_file)
	)

func _docs_on_loaded(tmp_file: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	_docs_thread = null
	_docs_status_lbl.text = ""
	if not FileAccess.file_exists(tmp_file):
		_docs_view.parse_bbcode("[color=#f88]Failed to load document.[/color]")
		return
	var f := FileAccess.open(tmp_file, FileAccess.READ)
	if not f:
		_docs_view.parse_bbcode("[color=#f88]Could not read document.[/color]")
		return
	_docs_loaded_content = f.get_as_text()
	f.close()
	_docs_view.parse_bbcode(_md_to_bbcode(_docs_loaded_content))
	_docs_show_view_buttons(_docs_sel_path)

func _docs_enter_edit() -> void:
	_docs_editor.text = _docs_loaded_content
	_docs_view_scroll.visible = false
	_docs_editor.visible = true
	_docs_edit_btn.visible = false
	_docs_suggest_btn.visible = false
	_docs_delete_header_btn.visible = false
	_docs_archive_suggest_btn.visible = false
	_docs_review_btn.visible = false
	_docs_perm_btn.visible = false
	_docs_save_btn.visible = true
	_docs_cancel_btn.visible = true

func _docs_exit_edit() -> void:
	_docs_in_suggest_mode = false
	_docs_editor.visible = false
	_docs_view_scroll.visible = true
	_docs_save_btn.visible = false
	_docs_suggest_submit_btn.visible = false
	_docs_cancel_btn.visible = false
	_docs_show_view_buttons(_docs_sel_path)

func _docs_save() -> void:
	if _docs_sel_path.is_empty() or (_docs_thread and _docs_thread.is_started()):
		return
	var new_content := _docs_editor.text
	_docs_save_btn.disabled = true
	_docs_status_lbl.text = "Saving…"
	var tmp_dir := OS.get_temp_dir() + "/cc_docs_save"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var filename := _docs_sel_path.get_file()
	var tmp_file := tmp_dir + "/" + filename
	var f := FileAccess.open(tmp_file, FileAccess.WRITE)
	if not f:
		_docs_status_lbl.text = "❌ Could not write temp file."
		_docs_save_btn.disabled = false
		return
	f.store_string(new_content)
	f.close()
	var remote_dir := _docs_sel_path.get_base_dir()
	var cache := _vault_cache
	var cap_path := _docs_sel_path
	var cap_content := new_content
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_upload_file(tmp_file, remote_dir, Callable())
		Ops.vault_refresh(cache, Callable())
		call_deferred("_docs_on_saved", cap_path, cap_content)
	)

func _docs_on_saved(full_path: String, new_content: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	_docs_thread = null
	_docs_save_btn.disabled = false
	_docs_status_lbl.text = "✅ Saved"
	_docs_loaded_content = new_content
	_docs_view.parse_bbcode(_md_to_bbcode(new_content))
	_docs_exit_edit()
	var doc_name := full_path.get_file().get_basename()
	var me: String = _current_user.get("username", "?")
	_log_activity("doc_edited", '"%s" edited document: "%s"' % [me, doc_name])
	_vault_files = Ops.vault_list_files(_vault_cache)
	_docs_files = _docs_filter_files(_vault_files)

func _docs_on_link_clicked(meta: Variant) -> void:
	var m := str(meta)
	if m.begins_with("wiki:"):
		var target := m.substr(5).strip_edges()
		var found := _docs_find_by_name(target)
		if not found.is_empty():
			_docs_sel_path = found
			var folder := _docs_rel(found).get_base_dir()
			if folder == ".":
				folder = ""
			_docs_navigate(folder)
			_docs_select(found)
		else:
			_docs_status_lbl.text = '⚠️ Doc not found: "' + target + '"'

func _docs_find_by_name(name: String) -> String:
	var lower := name.to_lower()
	for path: String in _docs_files:
		if path.get_file().get_basename().to_lower() == lower:
			return path
	return ""

func _docs_do_create(doc_path: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		return
	var path := doc_path.strip_edges().lstrip("/")
	if not path.ends_with(".md"):
		path += ".md"
	var full_remote := DOCS_PREFIX + "/" + path
	var title := path.get_file().get_basename()
	var content := "# " + title + "\n\nWrite your documentation here.\n"
	var tmp_dir := OS.get_temp_dir() + "/cc_docs_new"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var tmp_file := tmp_dir + "/" + path.get_file()
	var f := FileAccess.open(tmp_file, FileAccess.WRITE)
	if not f:
		_docs_status_lbl.text = "❌ Could not create temp file."
		return
	f.store_string(content)
	f.close()
	var remote_dir := full_remote.get_base_dir()
	var cache := _vault_cache
	var cap_full := full_remote
	var cap_content := content
	_docs_status_lbl.text = "Creating…"
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_upload_file(tmp_file, remote_dir, Callable())
		Ops.vault_refresh(cache, Callable())
		call_deferred("_docs_on_created", cap_full, cap_content)
	)

func _docs_on_created(full_path: String, content: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	_docs_thread = null
	_docs_status_lbl.text = "✅ Created"
	# Refresh file list; if the vault fetch hasn't caught up yet, add it manually
	_vault_files = Ops.vault_list_files(_vault_cache)
	_docs_files = _docs_filter_files(_vault_files)
	if full_path not in _docs_files:
		_docs_files.append(full_path)
	_docs_sel_path = full_path
	var folder := _docs_rel(full_path).get_base_dir()
	if folder == ".":
		folder = ""
	_docs_navigate(folder)
	# Display the content we just wrote — no need to re-download from vault
	_docs_title_lbl.text = full_path.get_file().get_basename()
	_docs_title_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_docs_loaded_content = content
	_docs_view.parse_bbcode(_md_to_bbcode(content))
	_docs_view_scroll.visible = true
	_docs_editor.visible = false
	_docs_save_btn.visible = false
	_docs_suggest_submit_btn.visible = false
	_docs_cancel_btn.visible = false
	_docs_show_view_buttons(full_path)

func _docs_do_mkdir(dir_path: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		return
	var rdir := DOCS_PREFIX + "/" + dir_path.strip_edges().lstrip("/").rstrip("/")
	var cache := _vault_cache
	_docs_status_lbl.text = "Creating folder…"
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_mkdir(rdir, Callable())
		Ops.vault_refresh(cache, Callable())
		call_deferred("_docs_on_mkdir_done")
	)

func _docs_on_mkdir_done() -> void:
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	_docs_thread = null
	_docs_status_lbl.text = "✅ Folder created"
	_vault_files = Ops.vault_list_files(_vault_cache)
	_docs_files = _docs_filter_files(_vault_files)
	_docs_navigate(_docs_current_dir)

func _docs_do_delete() -> void:
	if _docs_pending_delete.is_empty() or (_docs_thread and _docs_thread.is_started()):
		return
	var src := _docs_pending_delete
	_docs_pending_delete = ""
	# Preserve relative path inside the archive (e.g. guides/foo.md → _archive/guides/foo.md)
	var rel := _docs_rel(src)
	var dest := DOCS_PREFIX + "/" + DOCS_ARCHIVE_REL + "/" + rel
	var cache := _vault_cache
	var cap_src := src
	var cap_dest := dest
	_docs_status_lbl.text = "Archiving…"
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_move_file(cap_src, cap_dest, Callable())
		Ops.vault_refresh(cache, Callable())
		call_deferred("_docs_on_archived", cap_src, cap_dest)
	)

func _docs_on_archived(old_path: String, new_path: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	_docs_thread = null
	_docs_status_lbl.text = "✅ Archived"
	_vault_files = Ops.vault_list_files(_vault_cache)
	_docs_files = _docs_filter_files(_vault_files)
	if _docs_sel_path == old_path:
		# Stay on the doc — it's now in the archive
		_docs_sel_path = new_path
		var folder := _docs_rel(new_path).get_base_dir()
		if folder == ".":
			folder = ""
		_docs_navigate(folder)
		_docs_show_view_buttons(new_path)
	else:
		_docs_navigate(_docs_current_dir)

func _docs_do_move(dest_rel: String) -> void:
	if _docs_sel_path.is_empty() or (_docs_thread and _docs_thread.is_started()):
		return
	var src := _docs_sel_path
	var dest_full := DOCS_PREFIX + "/" + dest_rel.strip_edges().lstrip("/")
	if not dest_full.ends_with(".md"):
		dest_full += ".md"
	if _docs_requires_vote(src):
		var me: String = _current_user.get("username", "?")
		var perm: Dictionary = _docs_permissions.get(src, {})
		_docs_suggestions.append({
			"id": str(Time.get_unix_time_from_system()) + "_move_" + me,
			"doc_path": src,
			"dest_path": dest_full,
			"author": me,
			"timestamp": Time.get_datetime_string_from_system(),
			"type": "move_request",
			"status": "pending",
			"vote_required": true,
			"vote_threshold": perm.get("vote_threshold", "1/2"),
			"votes": {"yes": [], "no": []}
		})
		_save_doc_suggestions()
		_log_activity("doc_suggestion", '"%s" requested move of: "%s"' % [me, src.get_file().get_basename()])
		_docs_status_lbl.text = "⏳ Move request submitted for team vote"
		get_tree().create_timer(3.0).timeout.connect(func():
			if is_instance_valid(_docs_status_lbl): _docs_status_lbl.text = ""
		)
		_refresh_vote_list()
		return
	var cache := _vault_cache
	var cap_src := src
	var cap_dest := dest_full
	_docs_status_lbl.text = "Moving…"
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_move_file(cap_src, cap_dest, Callable())
		Ops.vault_refresh(cache, Callable())
		call_deferred("_docs_on_moved", cap_src, cap_dest)
	)

func _docs_on_moved(old_path: String, new_path: String) -> void:
	if _docs_thread and _docs_thread.is_started():
		_docs_thread.wait_to_finish()
	_docs_thread = null
	_docs_status_lbl.text = "✅ Moved"
	# Migrate permissions so they follow the doc to its new path
	if _docs_permissions.has(old_path):
		_docs_permissions[new_path] = _docs_permissions[old_path]
		_docs_permissions.erase(old_path)
		_save_doc_permissions()
	# Update any pending suggestions that referenced the old path
	var sugg_updated := false
	for i: int in range(_docs_suggestions.size()):
		var s: Dictionary = _docs_suggestions[i]
		if s.get("doc_path", "") == old_path:
			s["doc_path"] = new_path
			_docs_suggestions[i] = s
			sugg_updated = true
	if sugg_updated:
		_save_doc_suggestions()
	_vault_files = Ops.vault_list_files(_vault_cache)
	_docs_files = _docs_filter_files(_vault_files)
	if _docs_sel_path == old_path:
		_docs_sel_path = new_path
	var folder := _docs_rel(new_path).get_base_dir()
	if folder == ".":
		folder = ""
	_docs_navigate(folder)

# ─── Docs permissions ─────────────────────────────────────────────────────────

func _docs_perm_file() -> String:
	return ProjectSettings.globalize_path("user://cc_doc_permissions.json")

func _load_doc_permissions() -> void:
	_docs_permissions = {}
	var path := _docs_perm_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		_docs_permissions = parsed

func _save_doc_permissions() -> void:
	var fw := FileAccess.open(_docs_perm_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_docs_permissions, "\t") + "\n")
		fw.close()
	_activity_auto_push()

func _docs_can_edit(full_path: String) -> bool:
	var perm: Dictionary = _docs_permissions.get(full_path, {})
	if perm.get("mode", "anyone") == "anyone":
		return true
	var users: Array = perm.get("users", [])
	var me: String = _current_user.get("username", "")
	return me.is_empty() or me in users

func _docs_open_perm_dialog() -> void:
	if _docs_sel_path.is_empty():
		return
	_docs_perm_path = _docs_sel_path
	var perm: Dictionary = _docs_permissions.get(_docs_perm_path, {})
	var mode: String = perm.get("mode", "anyone")
	_docs_perm_mode.select(0 if mode == "anyone" else 1)
	_docs_perm_user_section.visible = mode == "specific"
	_docs_perm_refresh_users(perm.get("users", []))
	_docs_perm_input.text = ""
	var req_vote: bool = perm.get("require_vote", false)
	_docs_perm_vote_check.set_pressed_no_signal(req_vote)
	_docs_perm_vote_section.visible = req_vote
	var thresh_map := {"1/3": 0, "1/2": 1, "2/3": 2, "3/4": 3}
	_docs_perm_vote_thresh.select(thresh_map.get(perm.get("vote_threshold", "1/2"), 1))
	_docs_perm_dialog.popup_centered()

func _docs_perm_refresh_users(users: Array) -> void:
	for c in _docs_perm_user_list.get_children():
		c.queue_free()
	for u: String in users:
		var cap_u := u
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = cap_u
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var rm := Button.new()
		rm.text = "✕"
		rm.flat = true
		rm.pressed.connect(func():
			var perm: Dictionary = _docs_permissions.get(_docs_perm_path, {})
			var lst: Array = perm.get("users", [])
			lst.erase(cap_u)
			perm["users"] = lst
			_docs_permissions[_docs_perm_path] = perm
			_docs_perm_refresh_users(lst)
		)
		row.add_child(lbl)
		row.add_child(rm)
		_docs_perm_user_list.add_child(row)

func _docs_perm_add_user() -> void:
	var username := _docs_perm_input.text.strip_edges()
	if username.is_empty():
		return
	var perm: Dictionary = _docs_permissions.get(_docs_perm_path, {})
	var users: Array = perm.get("users", [])
	if username not in users:
		users.append(username)
	perm["users"] = users
	_docs_permissions[_docs_perm_path] = perm
	_docs_perm_input.text = ""
	_docs_perm_refresh_users(users)

func _docs_perm_save() -> void:
	if _docs_perm_path.is_empty():
		return
	var old_perm: Dictionary = _docs_permissions.get(_docs_perm_path, {})
	var new_perm: Dictionary = old_perm.duplicate()
	new_perm["mode"] = "anyone" if _docs_perm_mode.selected == 0 else "specific"
	if new_perm["mode"] == "anyone":
		new_perm.erase("users")
	new_perm["require_vote"] = _docs_perm_vote_check.button_pressed
	if new_perm["require_vote"]:
		var thresh_list := ["1/3", "1/2", "2/3", "3/4"]
		new_perm["vote_threshold"] = thresh_list[_docs_perm_vote_thresh.selected]
	else:
		new_perm.erase("vote_threshold")
	# If the doc currently requires a vote, changing vote settings itself requires a vote
	if old_perm.get("require_vote", false):
		var me: String = _current_user.get("username", "?")
		_docs_suggestions.append({
			"id": str(Time.get_unix_time_from_system()) + "_perm_" + me,
			"doc_path": _docs_perm_path,
			"author": me,
			"timestamp": Time.get_datetime_string_from_system(),
			"content": _docs_loaded_content,
			"original_content": _docs_loaded_content,
			"status": "pending",
			"type": "permission_change",
			"new_permissions": new_perm,
			"vote_required": true,
			"vote_threshold": old_perm.get("vote_threshold", "1/2"),
			"votes": {"yes": [], "no": []}
		})
		_save_doc_suggestions()
		var doc_name := _docs_perm_path.get_file().get_basename()
		_log_activity("doc_suggestion", '"%s" proposed permission change for: "%s"' % [me, doc_name])
		_docs_perm_dialog.hide()
		_docs_status_lbl.text = "⏳ Permission change submitted for team vote"
		get_tree().create_timer(4.0).timeout.connect(func():
			if is_instance_valid(_docs_status_lbl): _docs_status_lbl.text = ""
		)
		if _docs_sel_path == _docs_perm_path:
			_docs_show_view_buttons(_docs_sel_path)
		return
	_docs_permissions[_docs_perm_path] = new_perm
	_save_doc_permissions()
	if _docs_sel_path == _docs_perm_path and not _docs_editor.visible:
		_docs_show_view_buttons(_docs_sel_path)

# ─── Docs suggestions ────────────────────────────────────────────────────────

func _docs_sugg_file() -> String:
	return ProjectSettings.globalize_path("user://cc_doc_suggestions.json")

func _load_doc_suggestions() -> void:
	_docs_suggestions = []
	var path := _docs_sugg_file()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		_docs_suggestions = parsed

func _save_doc_suggestions() -> void:
	var fw := FileAccess.open(_docs_sugg_file(), FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_docs_suggestions, "\t") + "\n")
		fw.close()
	_activity_auto_push()

func _docs_pending_suggestions(full_path: String) -> int:
	var count := 0
	for s: Dictionary in _docs_suggestions:
		if s.get("doc_path", "") == full_path and s.get("status", "") == "pending":
			count += 1
	return count

func _docs_is_archived(full_path: String) -> bool:
	return full_path.begins_with(DOCS_PREFIX + "/" + DOCS_ARCHIVE_REL + "/")

func _docs_show_view_buttons(full_path: String) -> void:
	if _docs_is_archived(full_path):
		_docs_edit_btn.visible = false
		_docs_suggest_btn.visible = false
		_docs_delete_header_btn.visible = false
		_docs_archive_suggest_btn.visible = false
		_docs_perm_btn.visible = false
		_docs_review_btn.visible = false
		_docs_save_btn.visible = false
		_docs_suggest_submit_btn.visible = false
		_docs_cancel_btn.visible = false
		_docs_title_lbl.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45))
		return
	var can_edit := _docs_can_edit(full_path)
	var req_vote := _docs_requires_vote(full_path)
	_docs_edit_btn.visible = can_edit and not req_vote
	_docs_delete_header_btn.visible = can_edit and not req_vote
	_docs_archive_suggest_btn.visible = can_edit and req_vote
	_docs_suggest_btn.visible = not full_path.is_empty() and (not can_edit or req_vote)
	_docs_perm_btn.visible = can_edit and not full_path.is_empty()
	var pending := _docs_pending_suggestions(full_path)
	var show_review := not full_path.is_empty() and (can_edit or (req_vote and pending > 0))
	_docs_review_btn.visible = show_review
	if show_review:
		_docs_review_btn.text = ("📬 " + str(pending)) if pending > 0 else "📬"

func _docs_enter_suggest() -> void:
	_docs_in_suggest_mode = true
	_docs_editor.text = _docs_loaded_content
	_docs_view_scroll.visible = false
	_docs_editor.visible = true
	_docs_suggest_btn.visible = false
	_docs_perm_btn.visible = false
	_docs_suggest_submit_btn.visible = true
	_docs_cancel_btn.visible = true

func _docs_suggest_submit() -> void:
	if _docs_sel_path.is_empty():
		return
	var me: String = _current_user.get("username", "?")
	var sugg: Dictionary = {
		"id": str(Time.get_unix_time_from_system()) + "_" + me,
		"doc_path": _docs_sel_path,
		"author": me,
		"timestamp": Time.get_datetime_string_from_system(),
		"content": _docs_editor.text,
		"status": "pending"
	}
	if _docs_requires_vote(_docs_sel_path):
		var perm: Dictionary = _docs_permissions.get(_docs_sel_path, {})
		sugg["vote_required"] = true
		sugg["vote_threshold"] = perm.get("vote_threshold", "1/2")
		sugg["votes"] = {"yes": [], "no": []}
		sugg["original_content"] = _docs_loaded_content
	_docs_suggestions.append(sugg)
	_save_doc_suggestions()
	var doc_name := _docs_sel_path.get_file().get_basename()
	_log_activity("doc_suggestion", '"%s" suggested edits to: "%s"' % [me, doc_name])
	_docs_exit_edit()
	if sugg.get("vote_required", false):
		_refresh_vote_list()
	_docs_status_lbl.text = "✅ Suggestion submitted"
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(_docs_status_lbl): _docs_status_lbl.text = ""
	)

func _docs_open_review_dialog() -> void:
	if _docs_sel_path.is_empty():
		return
	var title_node := _docs_review_dialog.find_child("_rev_title", true, false)
	if is_instance_valid(title_node):
		(title_node as Label).text = "Suggestions for: " + _docs_sel_path.get_file().get_basename()
	_docs_review_build(_docs_sel_path)
	_docs_review_view.text = ""
	_docs_review_dialog.popup_centered()

func _docs_review_build(full_path: String) -> void:
	for c in _docs_review_list.get_children():
		c.queue_free()
	var me: String = _current_user.get("username", "?")
	var can_edit := _docs_can_edit(full_path)
	var found := false
	for i in range(_docs_suggestions.size()):
		var s: Dictionary = _docs_suggestions[i]
		if s.get("doc_path", "") != full_path:
			continue
		found = true
		var status: String = s.get("status", "pending")
		var is_vote: bool = s.get("vote_required", false)
		var is_perm_change: bool = s.get("type", "") == "permission_change"
		var is_archive_req: bool = s.get("type", "") == "archive_request"
		var is_move_req: bool = s.get("type", "") == "move_request"
		var cap_i := i
		var card := PanelContainer.new()
		var card_vbox := VBoxContainer.new()
		card.add_child(card_vbox)
		# ── Title row ────────────────────────────────────────────────────────
		var top_row := HBoxContainer.new()
		var status_icon: String = {"pending": "⏳", "approved": "✅", "rejected": "❌"}.get(status, "?")
		var kind_icon := "🗳" if is_vote else ("🔒" if is_perm_change else ("📦" if is_archive_req else ("📁" if is_move_req else "💡")))
		var info_lbl := Label.new()
		info_lbl.text = status_icon + " " + kind_icon + " " + s.get("author", "?") + "  —  " + s.get("timestamp", "")
		info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_lbl.add_theme_color_override("font_color",
			Color(0.9, 0.9, 0.9) if status == "pending" else Color(0.5, 0.5, 0.5))
		top_row.add_child(info_lbl)
		if is_perm_change:
			var what_lbl := Label.new()
			what_lbl.text = "Permission change"
			what_lbl.add_theme_color_override("font_color", Color(0.8, 0.7, 1.0))
			top_row.add_child(what_lbl)
		elif is_archive_req:
			var what_lbl := Label.new()
			what_lbl.text = "📦 Archive request"
			what_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.4))
			top_row.add_child(what_lbl)
		elif is_move_req:
			var what_lbl := Label.new()
			var dest_rel: String = (s.get("dest_path", "") as String).get_file().get_basename()
			what_lbl.text = "📁 Move → " + dest_rel
			what_lbl.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0))
			top_row.add_child(what_lbl)
		else:
			var diff_btn := Button.new()
			diff_btn.text = "📊 Diff"
			diff_btn.flat = true
			diff_btn.pressed.connect(func(): _docs_open_diff_dialog(cap_i))
			top_row.add_child(diff_btn)
			var preview_btn := Button.new()
			preview_btn.text = "👁"
			preview_btn.flat = true
			preview_btn.tooltip_text = "Preview proposed content"
			preview_btn.pressed.connect(func():
				_docs_review_view.parse_bbcode(_md_to_bbcode(_docs_suggestions[cap_i].get("content", "")))
			)
			top_row.add_child(preview_btn)
		card_vbox.add_child(top_row)
		# ── Voting row (vote-required pending) ───────────────────────────────
		if status == "pending" and is_vote:
			var votes: Dictionary = s.get("votes", {})
			var yes_list: Array = votes.get("yes", [])
			var no_list: Array = votes.get("no", [])
			var thresh: String = s.get("vote_threshold", "1/2")
			var vote_row := HBoxContainer.new()
			var tally_lbl := Label.new()
			tally_lbl.text = "👍 %d  👎 %d  |  threshold: %s" % [yes_list.size(), no_list.size(), thresh]
			tally_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tally_lbl.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
			vote_row.add_child(tally_lbl)
			var already_yes: bool = me in yes_list
			var already_no: bool = me in no_list
			if not already_yes and not already_no:
				var yes_btn := Button.new()
				yes_btn.text = "👍 For"
				yes_btn.pressed.connect(func(): _docs_vote_cast(cap_i, true))
				var no_btn := Button.new()
				no_btn.text = "👎 Against"
				no_btn.pressed.connect(func(): _docs_vote_cast(cap_i, false))
				vote_row.add_child(yes_btn)
				vote_row.add_child(no_btn)
			else:
				var voted_lbl := Label.new()
				voted_lbl.text = "Your vote: " + ("👍" if already_yes else "👎")
				voted_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
				vote_row.add_child(voted_lbl)
				var change_btn := Button.new()
				change_btn.text = "Change"
				change_btn.flat = true
				change_btn.pressed.connect(func(): _docs_vote_cast(cap_i, not already_yes))
				vote_row.add_child(change_btn)
			card_vbox.add_child(vote_row)
		elif status == "pending" and can_edit:
			var act_row := HBoxContainer.new()
			act_row.alignment = BoxContainer.ALIGNMENT_END
			var approve_btn := Button.new()
			approve_btn.text = "✅ Approve"
			approve_btn.pressed.connect(func(): _docs_review_approve(cap_i))
			var reject_btn := Button.new()
			reject_btn.text = "❌ Reject"
			reject_btn.pressed.connect(func(): _docs_review_reject(cap_i))
			act_row.add_child(approve_btn)
			act_row.add_child(reject_btn)
			card_vbox.add_child(act_row)
		_docs_review_list.add_child(card)
	if not found:
		var hint := Label.new()
		hint.text = "No suggestions for this document."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_docs_review_list.add_child(hint)

func _docs_review_approve(idx: int) -> void:
	if _docs_thread and _docs_thread.is_started():
		return
	var sugg: Dictionary = _docs_suggestions[idx]
	sugg["status"] = "approved"
	sugg["approved_by"] = _current_user.get("username", "?")
	_docs_suggestions[idx] = sugg
	_save_doc_suggestions()
	_docs_review_dialog.hide()
	# Archive request: move doc to archive directory
	if sugg.get("type", "") == "archive_request":
		var doc_path: String = sugg["doc_path"]
		var rel := _docs_rel(doc_path)
		var dest := DOCS_PREFIX + "/" + DOCS_ARCHIVE_REL + "/" + rel
		var cache := _vault_cache
		var cap_src := doc_path
		var cap_dest := dest
		var me: String = sugg.get("approved_by", "?")
		var doc_name2 := doc_path.get_file().get_basename()
		_log_activity("doc_suggestion", '"%s" approved archive of: "%s"' % [me, doc_name2])
		_docs_status_lbl.text = "Archiving…"
		_docs_thread = Thread.new()
		_docs_thread.start(func():
			Ops.vault_move_file(cap_src, cap_dest, Callable())
			Ops.vault_refresh(cache, Callable())
			call_deferred("_docs_on_archived", cap_src, cap_dest)
		)
		return
	# Move request: move the file via vault
	if sugg.get("type", "") == "move_request":
		var doc_path: String = sugg["doc_path"]
		var dest_path: String = sugg.get("dest_path", "")
		if dest_path.is_empty():
			return
		var cache := _vault_cache
		var me2: String = sugg.get("approved_by", "?")
		_log_activity("doc_suggestion", '"%s" approved move of: "%s"' % [me2, doc_path.get_file().get_basename()])
		_docs_status_lbl.text = "Moving…"
		_docs_thread = Thread.new()
		_docs_thread.start(func():
			Ops.vault_move_file(doc_path, dest_path, Callable())
			Ops.vault_refresh(cache, Callable())
			call_deferred("_docs_on_moved", doc_path, dest_path)
		)
		return
	# Permission-change suggestion: apply new_permissions, no vault upload needed
	if sugg.get("type", "") == "permission_change":
		var doc_path: String = sugg["doc_path"]
		_docs_permissions[doc_path] = sugg.get("new_permissions", {})
		_save_doc_permissions()
		var doc_name := doc_path.get_file().get_basename()
		var me: String = _current_user.get("username", "?")
		_log_activity("doc_suggestion", '"%s" approved permission change for: "%s"' % [me, doc_name])
		if _docs_sel_path == doc_path:
			_docs_show_view_buttons(_docs_sel_path)
		_docs_status_lbl.text = "✅ Permissions updated"
		return
	var doc_path: String = sugg["doc_path"]
	var new_content: String = sugg["content"]
	var tmp_dir := OS.get_temp_dir() + "/cc_docs_save"
	DirAccess.make_dir_recursive_absolute(tmp_dir)
	var tmp_file := tmp_dir + "/" + doc_path.get_file()
	var f := FileAccess.open(tmp_file, FileAccess.WRITE)
	if not f:
		_docs_status_lbl.text = "❌ Could not write temp file."
		return
	f.store_string(new_content)
	f.close()
	var cache := _vault_cache
	var cap_path := doc_path
	var cap_content := new_content
	_docs_status_lbl.text = "Applying…"
	_docs_thread = Thread.new()
	_docs_thread.start(func():
		Ops.vault_upload_file(tmp_file, doc_path.get_base_dir(), Callable())
		Ops.vault_refresh(cache, Callable())
		call_deferred("_docs_on_saved", cap_path, cap_content)
	)

func _docs_review_reject(idx: int) -> void:
	var sugg: Dictionary = _docs_suggestions[idx]
	sugg["status"] = "rejected"
	sugg["rejected_by"] = _current_user.get("username", "?")
	_docs_suggestions[idx] = sugg
	_save_doc_suggestions()
	var doc_name: String = (sugg.get("doc_path", "") as String).get_file().get_basename()
	var me: String = _current_user.get("username", "?")
	_log_activity("doc_suggestion", '"%s" rejected suggestion for: "%s"' % [me, doc_name])
	_docs_review_build(sugg.get("doc_path", _docs_sel_path))
	if _docs_sel_path == sugg.get("doc_path", ""):
		_docs_show_view_buttons(_docs_sel_path)
	_refresh_vote_list()

func _docs_requires_vote(full_path: String) -> bool:
	return _docs_permissions.get(full_path, {}).get("require_vote", false)

func _docs_vote_threshold_met(sugg: Dictionary) -> bool:
	var votes: Dictionary = sugg.get("votes", {})
	var yes_count: int = votes.get("yes", []).size()
	var no_count: int = votes.get("no", []).size()
	var total := yes_count + no_count
	if total == 0:
		return false
	match sugg.get("vote_threshold", "1/2"):
		"1/3": return yes_count * 3 >= total
		"1/2": return yes_count * 2 > total
		"2/3": return yes_count * 3 >= total * 2
		"3/4": return yes_count * 4 >= total * 3
	return false

func _docs_vote_cast(idx: int, vote_yes: bool) -> void:
	var sugg: Dictionary = _docs_suggestions[idx]
	var me: String = _current_user.get("username", "?")
	var votes: Dictionary = sugg.get("votes", {})
	var yes_list: Array = votes.get("yes", [])
	var no_list: Array = votes.get("no", [])
	yes_list.erase(me)
	no_list.erase(me)
	if vote_yes:
		yes_list.append(me)
	else:
		no_list.append(me)
	votes["yes"] = yes_list
	votes["no"] = no_list
	sugg["votes"] = votes
	_docs_suggestions[idx] = sugg
	_save_doc_suggestions()
	var doc_name: String = (sugg.get("doc_path", "") as String).get_file().get_basename()
	_log_activity("doc_vote", '"%s" voted %s on suggestion for: "%s"' % [me, "👍" if vote_yes else "👎", doc_name])
	if _docs_vote_threshold_met(sugg):
		_docs_review_approve(idx)
	else:
		_docs_review_build(sugg.get("doc_path", _docs_sel_path))
		if _docs_sel_path == sugg.get("doc_path", ""):
			_docs_show_view_buttons(_docs_sel_path)
		_refresh_vote_list()

func _docs_open_diff_dialog(idx: int) -> void:
	var sugg: Dictionary = _docs_suggestions[idx]
	var proposed: String = sugg.get("content", "")
	var original: String = sugg.get("original_content", _docs_loaded_content)
	var result := _docs_diff_columns(original, proposed)
	_docs_diff_left.parse_bbcode(result["left"])
	_docs_diff_right.parse_bbcode(result["right"])
	var doc_name: String = (sugg.get("doc_path", "") as String).get_file().get_basename()
	_docs_diff_dialog.title = "Diff — " + doc_name + " — by " + (sugg.get("author", "?") as String)
	_docs_diff_dialog.popup_centered()

func _docs_diff_columns(old_text: String, new_text: String) -> Dictionary:
	var old_lines := Array(old_text.split("\n"))
	var new_lines := Array(new_text.split("\n"))
	var diff := _lcs_diff(old_lines, new_lines)
	var left_bb := PackedStringArray()
	var right_bb := PackedStringArray()
	var i := 0
	while i < diff.size():
		var entry: Dictionary = diff[i]
		if entry["type"] == "equal":
			var escaped: String = (entry["line"] as String).xml_escape()
			left_bb.append("  " + escaped)
			right_bb.append("  " + escaped)
			i += 1
		else:
			var removes: Array[String] = []
			var adds: Array[String] = []
			while i < diff.size() and (diff[i] as Dictionary)["type"] != "equal":
				if (diff[i] as Dictionary)["type"] == "remove":
					removes.append((diff[i] as Dictionary)["line"])
				else:
					adds.append((diff[i] as Dictionary)["line"])
				i += 1
			var max_len := max(removes.size(), adds.size())
			for k in range(max_len):
				if k < removes.size():
					left_bb.append("[color=#ff6060]- " + (removes[k] as String).xml_escape() + "[/color]")
				else:
					left_bb.append("[color=#333333]~[/color]")
				if k < adds.size():
					right_bb.append("[color=#60ff60]+ " + (adds[k] as String).xml_escape() + "[/color]")
				else:
					right_bb.append("[color=#333333]~[/color]")
	return {"left": "\n".join(left_bb), "right": "\n".join(right_bb)}

func _lcs_diff(old_lines: Array, new_lines: Array) -> Array:
	var m := old_lines.size()
	var n := new_lines.size()
	# Allocate DP table
	var dp: Array = []
	dp.resize(m + 1)
	for row in range(m + 1):
		var r: Array = []
		r.resize(n + 1)
		r.fill(0)
		dp[row] = r
	for row in range(1, m + 1):
		for col in range(1, n + 1):
			if old_lines[row - 1] == new_lines[col - 1]:
				dp[row][col] = dp[row - 1][col - 1] + 1
			else:
				dp[row][col] = max(dp[row - 1][col], dp[row][col - 1])
	# Backtrack
	var result: Array = []
	var row := m
	var col := n
	while row > 0 or col > 0:
		if row > 0 and col > 0 and old_lines[row - 1] == new_lines[col - 1]:
			result.push_front({"type": "equal", "line": old_lines[row - 1]})
			row -= 1
			col -= 1
		elif col > 0 and (row == 0 or dp[row][col - 1] >= dp[row - 1][col]):
			result.push_front({"type": "add", "line": new_lines[col - 1]})
			col -= 1
		else:
			result.push_front({"type": "remove", "line": old_lines[row - 1]})
			row -= 1
	return result

# ─── Markdown renderer ────────────────────────────────────────────────────────

func _md_to_bbcode(md: String) -> String:
	var lines := md.split("\n")
	var out: PackedStringArray = []
	var in_code_block := false

	for raw_line: String in lines:
		var line: String = raw_line

		if line.begins_with("```"):
			if in_code_block:
				out.append("[/code]")
				in_code_block = false
			else:
				in_code_block = true
				out.append("[code]")
			continue

		if in_code_block:
			out.append(line.xml_escape())
			continue

		var stripped := line.strip_edges()

		if line.begins_with("### "):
			out.append("[font_size=14][b]" + _md_inline(line.substr(4)) + "[/b][/font_size]")
			continue
		if line.begins_with("## "):
			out.append("[font_size=17][b]" + _md_inline(line.substr(3)) + "[/b][/font_size]")
			continue
		if line.begins_with("# "):
			out.append("[font_size=21][b]" + _md_inline(line.substr(2)) + "[/b][/font_size]")
			continue

		if stripped.length() >= 3 and (stripped.replace("-", "").is_empty() \
				or stripped.replace("*", "").is_empty() \
				or stripped.replace("_", "").is_empty()):
			out.append("[color=#555]" + "─".repeat(40) + "[/color]")
			continue

		if line.begins_with("> "):
			out.append("[indent][color=#aaa]" + _md_inline(line.substr(2)) + "[/color][/indent]")
			continue

		var lstripped := line.lstrip("\t ")
		if lstripped.begins_with("- ") or lstripped.begins_with("* "):
			var depth := clampi((line.length() - lstripped.length()) / 2 + 1, 1, 4)
			out.append("[indent]".repeat(depth) + "• " + _md_inline(lstripped.substr(2)) + "[/indent]".repeat(depth))
			continue

		if stripped.is_empty():
			out.append("")
			continue

		out.append(_md_inline(line))

	if in_code_block:
		out.append("[/code]")

	return "\n".join(out)

func _md_inline(text: String) -> String:
	# Inline code first so its content isn't processed for formatting
	var code_re := RegEx.new()
	code_re.compile("`([^`]+)`")
	text = code_re.sub(text, "[code]$1[/code]", true)

	# Wikilinks [[Link|Alias]] and [[Link]]
	var result := ""
	var i := 0
	while i < text.length():
		if i + 1 < text.length() and text[i] == "[" and text[i + 1] == "[":
			var end := text.find("]]", i + 2)
			if end != -1:
				var inner := text.substr(i + 2, end - i - 2)
				var pipe := inner.find("|")
				var target: String
				var label: String
				if pipe != -1:
					target = inner.substr(0, pipe).strip_edges()
					label = inner.substr(pipe + 1).strip_edges()
				else:
					target = inner.strip_edges()
					label = target
				result += "[url=wiki:" + target + "][color=#6af]" + label + "[/color][/url]"
				i = end + 2
				continue
		result += text[i]
		i += 1
	text = result

	# Standard Markdown links [text](url)
	var link_re := RegEx.new()
	link_re.compile("\\[([^\\]]+)\\]\\(([^)]+)\\)")
	text = link_re.sub(text, "[url=$2][color=#8af]$1[/color][/url]", true)

	# Bold **text**
	var bold_re := RegEx.new()
	bold_re.compile("\\*\\*(.+?)\\*\\*")
	text = bold_re.sub(text, "[b]$1[/b]", true)

	# Italic *text* (single star, no content with stars)
	var ital_re := RegEx.new()
	ital_re.compile("\\*([^*\n]+)\\*")
	text = ital_re.sub(text, "[i]$1[/i]", true)

	return text

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

	var query := ""
	if is_instance_valid(_installed_search_input):
		query = _installed_search_input.text.strip_edges().to_lower()

	var dependents: Dictionary = Ops.get_dependents(root)
	var in_dev := _get_in_dev_folders()

	for folder: String in addons:
		if folder in in_dev:
			continue
		var cfg := Ops.parse_cfg(root + "/addons/" + folder + "/plugin.cfg")
		if not query.is_empty():
			var name_lower: String = (cfg.get("name", folder) as String).to_lower()
			var desc_lower: String = (cfg.get("description", "") as String).to_lower()
			if not (query in name_lower or query in desc_lower or query in folder.to_lower()):
				continue
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
					call_deferred("_log_activity", "addon_synced", "Synced addon: " + captured_sync_name)
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
		call_deferred("_log_activity", "addon_created", "Created new addon: " + name)
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
		call_deferred("_log_activity", "addon_cloned", "Cloned addon from: " + url)
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
			[self_folder],
			func(addon_name): call_deferred("_log_activity", "addon_pushed", "Pushed addon update: " + addon_name)
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

	var search_row := HBoxContainer.new()
	search_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var search_lbl := Label.new()
	search_lbl.text = "🔍"
	_browse_search_input = LineEdit.new()
	_browse_search_input.placeholder_text = "Search addons..."
	_browse_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_browse_search_input.text_changed.connect(func(_t: String): _browse_filter_and_render())
	search_row.add_child(search_lbl)
	search_row.add_child(_browse_search_input)
	root.add_child(search_row)

	var tag_scroll := ScrollContainer.new()
	tag_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag_scroll.custom_minimum_size = Vector2(0, 32)
	tag_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_browse_tag_bar = HBoxContainer.new()
	_browse_tag_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag_scroll.add_child(_browse_tag_bar)
	root.add_child(tag_scroll)

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
	_browse_active_tag = ""
	_browse_build_tag_bar()
	_browse_filter_and_render()
	_populate_category_dropdown(entries)
	_registry_status.text = "%d addon(s) listed" % entries.size()

func _parse_registry(content: String) -> Array:
	var result := []
	var url_idx: Dictionary = {}
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
			if url in url_idx:
				var cats: Array = result[url_idx[url]].get("categories", [])
				if category not in cats:
					cats.append(category)
			else:
				url_idx[url] = result.size()
				result.append({"categories": [category], "name": name, "url": url, "desc": desc})
	return result

func _build_installed_url_map() -> void:
	_registry_installed = {}
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	for folder: String in Ops.list_addons(root):
		var url := Ops.git_remote(root + "/addons/" + folder)
		if not url.is_empty():
			_registry_installed[url] = folder

func _browse_build_tag_bar() -> void:
	for child in _browse_tag_bar.get_children():
		child.queue_free()

	var cats: Array[String] = []
	for entry: Dictionary in _registry_entries:
		for cat: String in entry.get("categories", ["Uncategorized"]):
			if cat not in cats:
				cats.append(cat)
	cats.sort()

	var all_btn := Button.new()
	all_btn.text = "All"
	all_btn.toggle_mode = true
	all_btn.button_pressed = _browse_active_tag.is_empty()
	all_btn.pressed.connect(func():
		_browse_active_tag = ""
		_browse_build_tag_bar()
		_browse_filter_and_render()
	)
	_browse_tag_bar.add_child(all_btn)

	for cat: String in cats:
		var cap_cat := cat
		var tag_btn := Button.new()
		tag_btn.text = cap_cat
		tag_btn.toggle_mode = true
		tag_btn.button_pressed = (_browse_active_tag == cap_cat)
		tag_btn.pressed.connect(func():
			_browse_active_tag = cap_cat
			_browse_build_tag_bar()
			_browse_filter_and_render()
		)
		_browse_tag_bar.add_child(tag_btn)

func _browse_filter_and_render() -> void:
	var query: String = ""
	if is_instance_valid(_browse_search_input):
		query = _browse_search_input.text.strip_edges().to_lower()
	var filtered: Array = []
	for entry: Dictionary in _registry_entries:
		if not _browse_active_tag.is_empty():
			var cats: Array = entry.get("categories", [])
			if _browse_active_tag not in cats:
				continue
		if not query.is_empty():
			var name_lower: String = (entry.get("name", "") as String).to_lower()
			var desc_lower: String = (entry.get("desc", "") as String).to_lower()
			if not (query in name_lower or query in desc_lower):
				continue
		filtered.append(entry)
	filtered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (a.get("name", "") as String).to_lower() < (b.get("name", "") as String).to_lower()
	)
	_populate_registry(filtered)

func _populate_registry(entries: Array) -> void:
	for child in _registry_list.get_children():
		child.queue_free()

	for entry: Dictionary in entries:
		var url: String = entry.get("url", "")
		var installed := url in _registry_installed

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_row := HBoxContainer.new()
		name_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_lbl := Label.new()
		name_lbl.text = entry.get("name", "")
		name_row.add_child(name_lbl)

		for cat: String in entry.get("categories", ["Uncategorized"]):
			var cat_chip := Label.new()
			cat_chip.text = " " + cat + " "
			cat_chip.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
			cat_chip.add_theme_font_size_override("font_size", 10)
			name_row.add_child(cat_chip)
		info.add_child(name_row)

		var desc_lbl := Label.new()
		desc_lbl.text = entry.get("desc", "")
		desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		desc_lbl.clip_text = true
		info.add_child(desc_lbl)
		row.add_child(info)

		if installed:
			var inst_lbl := Label.new()
			inst_lbl.text = "✓ Installed"
			inst_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
			row.add_child(inst_lbl)
		else:
			var btn := Button.new()
			btn.text = "⬇ Install"
			btn.tooltip_text = url
			btn.pressed.connect(_install_from_registry.bind(url, btn))
			row.add_child(btn)
		_registry_list.add_child(row)

func _populate_category_dropdown(entries: Array) -> void:
	var seen: Array[String] = []
	for entry: Dictionary in entries:
		for cat: String in entry.get("categories", ["Uncategorized"]):
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

	_activity_status_lbl = Label.new()
	_activity_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	_activity_status_lbl.add_theme_font_size_override("font_size", 11)
	root.add_child(_activity_status_lbl)
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
	return ProjectSettings.globalize_path("user://cc_activity.json")

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
		"timestamp": Time.get_datetime_string_from_system(),
		"user": _current_user.get("username", "?")
	})
	_save_activity()
	_refresh_activity_list()
	_activity_auto_push()

func _activity_auto_push() -> void:
	if _activity_thread and _activity_thread.is_started():
		_activity_push_pending = true
		return
	_activity_push_pending = false
	_activity_thread = Thread.new()
	_activity_thread.start(func():
		var pushed := Ops.cc_data_push(_cc_data_bundle(), Callable())
		call_deferred("_activity_on_pushed", pushed)
	)

func _activity_on_pushed(pushed: bool) -> void:
	if _activity_thread:
		_activity_thread.wait_to_finish()
	_activity_thread = null
	if is_instance_valid(_activity_status_lbl):
		_activity_status_lbl.text = "✅ Synced" if pushed else ""
		if pushed:
			get_tree().create_timer(3.0).timeout.connect(func():
				if is_instance_valid(_activity_status_lbl):
					_activity_status_lbl.text = ""
			)
	if _activity_push_pending:
		_activity_auto_push()

const _REACTION_EMOJIS := ["👍", "❤", "😄", "🔥", "🎉", "👀", "🤔", "👎"]

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

	var me: String = _current_user.get("username", "")
	var last_date := ""

	for idx in range(_activity_items.size()):
		var entry: Dictionary = _activity_items[idx]
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

		var entry_box := VBoxContainer.new()
		entry_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry_box.add_theme_constant_override("separation", 2)

		# ── Main row ──────────────────────────────────────────────────────────
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

		var user_str: String = entry.get("user", "")
		var meta_lbl := Label.new()
		meta_lbl.text = (("@" + user_str + "  ") if not user_str.is_empty() and user_str != "?" else "") \
			+ (ts.substr(11, 5) if ts.length() >= 16 else "")
		meta_lbl.add_theme_font_size_override("font_size", 11)
		meta_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		row.add_child(meta_lbl)

		if type == "task_completed":
			var undo_btn := Button.new()
			undo_btn.text = "↩"
			undo_btn.tooltip_text = "Restore to todo list"
			var cap_text: String = entry.get("text", "")
			var cap_idx := idx
			undo_btn.pressed.connect(func():
				_todo_items.insert(0, {"text": cap_text, "done": false})
				_save_todo()
				_activity_items.remove_at(cap_idx)
				_save_activity()
				_refresh_todo()
				_refresh_activity_list()
			)
			row.add_child(undo_btn)

		# Comments toggle button
		var comments: Array = entry.get("comments", [])
		var comment_count := comments.size()
		var comment_btn := Button.new()
		comment_btn.text = ("💬 %d" % comment_count) if comment_count > 0 else "💬"
		comment_btn.flat = true
		comment_btn.tooltip_text = "Toggle comments"
		comment_btn.add_theme_font_size_override("font_size", 11)
		if _activity_comments_open.get(idx, false):
			comment_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		var cap_idx2 := idx
		comment_btn.pressed.connect(func():
			_activity_comments_open[cap_idx2] = not _activity_comments_open.get(cap_idx2, false)
			_refresh_activity_list()
		)
		row.add_child(comment_btn)

		# Emoji reaction picker button
		var react_btn := Button.new()
		react_btn.text = "+"
		react_btn.flat = true
		react_btn.tooltip_text = "Add reaction"
		react_btn.add_theme_font_size_override("font_size", 11)
		var cap_idx3 := idx
		react_btn.pressed.connect(func():
			_activity_show_reaction_picker(cap_idx3)
		)
		row.add_child(react_btn)

		entry_box.add_child(row)

		# ── Reactions row ─────────────────────────────────────────────────────
		var reactions: Dictionary = entry.get("reactions", {})
		if not reactions.is_empty():
			var react_row := HBoxContainer.new()
			react_row.add_theme_constant_override("separation", 4)
			for emoji: String in reactions:
				var users: Array = reactions[emoji]
				if users.is_empty():
					continue
				var rb := Button.new()
				rb.text = emoji + " " + str(users.size())
				rb.flat = true
				rb.add_theme_font_size_override("font_size", 12)
				var tip := ", ".join(users)
				rb.tooltip_text = tip
				if me in users:
					rb.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
				var cap_emoji := emoji
				var cap_idx4 := idx
				rb.pressed.connect(func():
					_activity_toggle_reaction(cap_idx4, cap_emoji)
				)
				react_row.add_child(rb)
			if react_row.get_child_count() > 0:
				var react_indent := HBoxContainer.new()
				var spacer := Control.new()
				spacer.custom_minimum_size = Vector2(26, 0)
				react_indent.add_child(spacer)
				react_indent.add_child(react_row)
				entry_box.add_child(react_indent)

		# ── Comments section ──────────────────────────────────────────────────
		if _activity_comments_open.get(idx, false):
			var comments_box := VBoxContainer.new()
			comments_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			comments_box.add_theme_constant_override("separation", 2)
			var indent_box := HBoxContainer.new()
			indent_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var spacer2 := Control.new()
			spacer2.custom_minimum_size = Vector2(26, 0)
			indent_box.add_child(spacer2)
			indent_box.add_child(comments_box)
			entry_box.add_child(indent_box)

			for comment: Dictionary in comments:
				var c_row := HBoxContainer.new()
				c_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var c_user: String = comment.get("user", "?")
				var c_text: String = comment.get("text", "")
				var c_ts: String = comment.get("timestamp", "")
				var c_lbl := RichTextLabel.new()
				c_lbl.bbcode_enabled = true
				c_lbl.fit_content = true
				c_lbl.scroll_active = false
				c_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				c_lbl.push_color(Color(0.6, 0.6, 0.6))
				c_lbl.append_text("[b]@" + c_user + "[/b]  " + c_text)
				c_lbl.pop()
				c_row.add_child(c_lbl)
				var c_time := Label.new()
				c_time.text = c_ts.substr(11, 5) if c_ts.length() >= 16 else ""
				c_time.add_theme_font_size_override("font_size", 10)
				c_time.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
				c_row.add_child(c_time)
				comments_box.add_child(c_row)

			# Add-comment input
			var add_row := HBoxContainer.new()
			add_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var c_input := LineEdit.new()
			c_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c_input.placeholder_text = "Add a comment…"
			c_input.add_theme_font_size_override("font_size", 11)
			add_row.add_child(c_input)
			var post_btn := Button.new()
			post_btn.text = "Post"
			post_btn.add_theme_font_size_override("font_size", 11)
			var cap_idx5 := idx
			var post_fn := func():
				var text := c_input.text.strip_edges()
				if text.is_empty():
					return
				var comment_list: Array = _activity_items[cap_idx5].get("comments", [])
				comment_list.append({
					"user": me if not me.is_empty() else "?",
					"text": text,
					"timestamp": Time.get_datetime_string_from_system()
				})
				_activity_items[cap_idx5]["comments"] = comment_list
				_save_activity()
				_activity_auto_push()
				_refresh_activity_list()
			post_btn.pressed.connect(post_fn)
			c_input.text_submitted.connect(func(_t): post_fn.call())
			add_row.add_child(post_btn)
			comments_box.add_child(add_row)

		_activity_list.add_child(entry_box)

func _activity_toggle_reaction(idx: int, emoji: String) -> void:
	if idx < 0 or idx >= _activity_items.size():
		return
	var me: String = _current_user.get("username", "")
	if me.is_empty():
		return
	var reactions: Dictionary = _activity_items[idx].get("reactions", {})
	var users: Array = reactions.get(emoji, [])
	if me in users:
		users.erase(me)
	else:
		users.append(me)
	if users.is_empty():
		reactions.erase(emoji)
	else:
		reactions[emoji] = users
	_activity_items[idx]["reactions"] = reactions
	_save_activity()
	_activity_auto_push()
	_refresh_activity_list()

func _activity_show_reaction_picker(idx: int) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "React"
	dialog.size = Vector2i(280, 80)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.add_child(vbox)
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 4)
	for emoji: String in _REACTION_EMOJIS:
		var btn := Button.new()
		btn.text = emoji
		btn.custom_minimum_size = Vector2(32, 32)
		var cap_emoji := emoji
		btn.pressed.connect(func():
			_activity_toggle_reaction(idx, cap_emoji)
			dialog.hide()
		)
		grid.add_child(btn)
	vbox.add_child(grid)
	add_child(dialog)
	dialog.popup_centered()

func _activity_icon(type: String) -> String:
	match type:
		"task_completed":    return "✅"
		"addon_created":     return "✨"
		"addon_cloned":      return "📥"
		"addon_pushed":      return "🚀"
		"addon_synced":      return "↺"
		"doc_edited":        return "📝"
		"doc_suggestion":    return "💡"
		"doc_vote":          return "🗳"
		"todo_added":        return "➕"
		"vote_created":      return "🗳"
		"vote_cast":         return "🗳"
		"vote_closed":       return "🏁"
		"account_approved":  return "👤"
		"account_removed":   return "🚫"
		"asset_uploaded":    return "⬆"
		"asset_deleted":     return "🗑"
		"asset_renamed":     return "✏"
		"folder_created":    return "📁"
		"idea_suggested":    return "💡"
		"idea_rated":        return "⭐"
		"event_created":     return "📅"
		"event_deleted":     return "🗑"
		"forum_posted":      return "💬"
		"forum_deleted":     return "🗑"
		_:                   return "•"

func _activity_color(type: String) -> Color:
	match type:
		"task_completed":    return Color(0.4, 0.9, 0.4)
		"addon_created":     return Color(0.4, 0.8, 1.0)
		"addon_cloned":      return Color(0.6, 0.6, 1.0)
		"addon_pushed":      return Color(0.5, 0.9, 0.6)
		"addon_synced":      return Color(1.0, 0.85, 0.3)
		"doc_edited":        return Color(0.7, 0.85, 1.0)
		"doc_suggestion":    return Color(1.0, 0.9, 0.4)
		"doc_vote":          return Color(0.7, 0.9, 1.0)
		"todo_added":        return Color(0.75, 0.75, 0.75)
		"vote_created":      return Color(0.6, 0.8, 1.0)
		"vote_cast":         return Color(0.6, 0.8, 1.0)
		"vote_closed":       return Color(0.9, 0.75, 0.3)
		"account_approved":  return Color(0.4, 0.9, 0.5)
		"account_removed":   return Color(1.0, 0.4, 0.4)
		"asset_uploaded":    return Color(0.5, 0.9, 0.6)
		"asset_deleted":     return Color(1.0, 0.5, 0.4)
		"asset_renamed":     return Color(0.9, 0.8, 0.4)
		"folder_created":    return Color(0.7, 0.7, 1.0)
		"idea_suggested":    return Color(1.0, 0.95, 0.4)
		"idea_rated":        return Color(1.0, 0.8, 0.2)
		"event_created":     return Color(0.5, 0.85, 1.0)
		"event_deleted":     return Color(1.0, 0.5, 0.4)
		"forum_posted":      return Color(0.6, 0.85, 1.0)
		"forum_deleted":     return Color(1.0, 0.5, 0.4)
		_:                   return Color(0.6, 0.6, 0.6)

# ─── API Contracts ────────────────────────────────────────────────────────────

func _load_contracts() -> void:
	_contract_items = {}
	_deps_items = {}
	var p1 := "user://cc_contracts.json"
	if FileAccess.file_exists(p1):
		var f := FileAccess.open(p1, FileAccess.READ)
		if f:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Dictionary:
				_contract_items = parsed
	var p2 := "user://cc_deps.json"
	if FileAccess.file_exists(p2):
		var f2 := FileAccess.open(p2, FileAccess.READ)
		if f2:
			var parsed2: Variant = JSON.parse_string(f2.get_as_text())
			f2.close()
			if parsed2 is Dictionary:
				_deps_items = parsed2
	_validate_all_contracts()

func _save_contracts() -> void:
	var fw := FileAccess.open("user://cc_contracts.json", FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_contract_items, "\t") + "\n")
		fw.close()
	var fw2 := FileAccess.open("user://cc_deps.json", FileAccess.WRITE)
	if fw2:
		fw2.store_string(JSON.stringify(_deps_items, "\t") + "\n")
		fw2.close()
	_activity_auto_push()

func _contract_register(addon_name: String) -> void:
	var root := ProjectSettings.globalize_path("res://").rstrip("/")
	var addon_path := root + "/addons/" + addon_name
	if not DirAccess.dir_exists_absolute(addon_path):
		push_warning("[CC Tools] Cannot register contract for '%s' — not installed" % addon_name)
		return
	var api: Array = Ops.extract_api(addon_path)
	_contract_items[addon_name] = {
		"symbols": api,
		"registered_at": Time.get_date_string_from_system()
	}
	_save_contracts()
	_validate_all_contracts()

func _validate_all_contracts() -> void:
	var errors: Array = []
	var root := ProjectSettings.globalize_path("res://").rstrip("/")

	for addon_name: String in _contract_items:
		var contract: Dictionary = _contract_items[addon_name]
		var registered: Array = contract.get("symbols", [])
		if registered.is_empty():
			continue
		var addon_path := root + "/addons/" + addon_name
		if not DirAccess.dir_exists_absolute(addon_path):
			continue
		var current_api: Array = Ops.extract_api(addon_path)
		var cur_map: Dictionary = {}
		for sym: Dictionary in current_api:
			cur_map[sym["kind"] + ":" + sym["name"]] = sym
		for sym: Dictionary in registered:
			var kind: String = sym.get("kind", "")
			var name: String = sym.get("name", "")
			var key: String = kind + ":" + name
			if key not in cur_map:
				errors.append('[%s] "%s" (%s) removed or renamed — dependent addons will break' % [addon_name, name, kind])
			elif kind == "func":
				var old_sig: String = sym.get("signature", "")
				var new_sig: String = (cur_map[key] as Dictionary).get("signature", "")
				if old_sig != new_sig:
					errors.append('[%s] "%s" signature changed\n    was: %s\n    now: %s' % [addon_name, name, old_sig, new_sig])
			elif kind == "export_var":
				var old_type: String = sym.get("type", "")
				var new_type: String = (cur_map[key] as Dictionary).get("type", "")
				if old_type != new_type:
					errors.append('[%s] "@export var %s" type changed from %s to %s' % [addon_name, name, old_type, new_type])

	for depender: String in _deps_items:
		var requires: Dictionary = (_deps_items[depender] as Dictionary).get("requires", {})
		for provider: String in requires:
			if provider not in _contract_items:
				errors.append('[%s] Depends on "%s" which has no registered contract' % [depender, provider])
				continue
			var sym_names: Array = []
			for s: Dictionary in (_contract_items[provider] as Dictionary).get("symbols", []):
				sym_names.append(s.get("name", ""))
			for sym_name: Variant in (requires[provider] as Array):
				if sym_name not in sym_names:
					errors.append('[%s] Requires "%s.%s" which is missing from the contract' % [depender, provider, sym_name])

	_contract_errors = errors
	for err: String in errors:
		push_error("[CC Tools] " + err.replace("\n", " "))

	if is_instance_valid(_contracts_status_lbl):
		if errors.is_empty():
			_contracts_status_lbl.text = "✅ All contracts valid"
			_contracts_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		else:
			_contracts_status_lbl.text = "⚠️ %d contract violation(s)" % errors.size()
			_contracts_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
	_refresh_contracts_list()

func _sym_display(sym: Dictionary) -> String:
	var kind: String = sym.get("kind", "")
	var name: String = sym.get("name", "")
	match kind:
		"func":      return "func " + name + sym.get("signature", "()")
		"export_var": return "@export var " + name + ": " + sym.get("type", "Variant")
		"signal":    return "signal " + name + "(" + sym.get("args", "") + ")"
		_:           return name

func _build_contracts_subtab(tabs: TabContainer) -> void:
	var root := _vbox("Contracts", tabs)

	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contracts_status_lbl = Label.new()
	_contracts_status_lbl.text = "Not validated yet"
	_contracts_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var validate_btn := Button.new()
	validate_btn.text = "↺ Validate"
	validate_btn.pressed.connect(_validate_all_contracts)
	toolbar.add_child(_contracts_status_lbl)
	toolbar.add_child(validate_btn)
	root.add_child(toolbar)
	root.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contracts_scroll_list = VBoxContainer.new()
	_contracts_scroll_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contracts_scroll_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_contracts_scroll_list)
	root.add_child(scroll)

func _refresh_contracts_list() -> void:
	if not is_instance_valid(_contracts_scroll_list):
		return
	for child in _contracts_scroll_list.get_children():
		child.queue_free()

	# ── Error list ──
	if not _contract_errors.is_empty():
		var err_hdr := Label.new()
		err_hdr.text = "Contract Violations"
		err_hdr.add_theme_font_size_override("font_size", 12)
		err_hdr.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
		_contracts_scroll_list.add_child(err_hdr)
		for err: String in _contract_errors:
			var lbl := Label.new()
			lbl.text = "• " + err
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.add_theme_color_override("font_color", Color(1.0, 0.55, 0.45))
			_contracts_scroll_list.add_child(lbl)
		_contracts_scroll_list.add_child(HSeparator.new())

	# ── Registered contracts ──
	var hdr1 := Label.new()
	hdr1.text = "Registered Contracts"
	hdr1.add_theme_font_size_override("font_size", 13)
	_contracts_scroll_list.add_child(hdr1)

	if _contract_items.is_empty():
		var empty := Label.new()
		empty.text = "No contracts registered. Register an addon's public API below."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_contracts_scroll_list.add_child(empty)
	else:
		for addon_name: String in _contract_items:
			var contract: Dictionary = _contract_items[addon_name]
			var symbols: Array = contract.get("symbols", [])

			var card := VBoxContainer.new()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var title_row := HBoxContainer.new()
			title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var title_lbl := Label.new()
			title_lbl.text = addon_name
			title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var meta_lbl := Label.new()
			meta_lbl.text = "%d symbols · %s" % [symbols.size(), contract.get("registered_at", "")]
			meta_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
			meta_lbl.add_theme_font_size_override("font_size", 10)
			var cap_name: String = addon_name
			var upd_btn := Button.new()
			upd_btn.text = "⬆ Update"
			upd_btn.tooltip_text = "Re-scan addon and update registered symbols"
			upd_btn.pressed.connect(func(): _contract_register(cap_name))
			var del_btn := Button.new()
			del_btn.text = "🗑"
			del_btn.pressed.connect(func():
				_contract_items.erase(cap_name)
				_save_contracts()
				_validate_all_contracts()
			)
			title_row.add_child(title_lbl)
			title_row.add_child(meta_lbl)
			title_row.add_child(upd_btn)
			title_row.add_child(del_btn)
			card.add_child(title_row)

			for sym: Dictionary in symbols:
				var sym_lbl := Label.new()
				sym_lbl.text = "  " + _sym_display(sym)
				sym_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
				sym_lbl.add_theme_font_size_override("font_size", 10)
				card.add_child(sym_lbl)

			_contracts_scroll_list.add_child(card)
			_contracts_scroll_list.add_child(HSeparator.new())

	# ── Register new ──
	var hdr_add := Label.new()
	hdr_add.text = "Register New Contract"
	hdr_add.add_theme_font_size_override("font_size", 12)
	_contracts_scroll_list.add_child(hdr_add)

	var add_row := HBoxContainer.new()
	add_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var addon_opt := OptionButton.new()
	addon_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var project_root := ProjectSettings.globalize_path("res://").rstrip("/")
	for a: String in Ops.list_addons(project_root):
		addon_opt.add_item(a)
	var reg_btn := Button.new()
	reg_btn.text = "🔍 Scan & Register"
	reg_btn.pressed.connect(func():
		if addon_opt.selected >= 0:
			_contract_register(addon_opt.get_item_text(addon_opt.selected))
	)
	add_row.add_child(addon_opt)
	add_row.add_child(reg_btn)
	_contracts_scroll_list.add_child(add_row)

	_contracts_scroll_list.add_child(HSeparator.new())

	# ── Dependencies ──
	var hdr2 := Label.new()
	hdr2.text = "Declared Dependencies"
	hdr2.add_theme_font_size_override("font_size", 13)
	_contracts_scroll_list.add_child(hdr2)

	var dep_hint := Label.new()
	dep_hint.text = "Declare which symbols your addon requires from others. Violations are raised even if the dependent addon is not installed."
	dep_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dep_hint.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	dep_hint.add_theme_font_size_override("font_size", 10)
	_contracts_scroll_list.add_child(dep_hint)

	if _deps_items.is_empty():
		var empty2 := Label.new()
		empty2.text = "No dependencies declared."
		empty2.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_contracts_scroll_list.add_child(empty2)
	else:
		for depender: String in _deps_items:
			var requires: Dictionary = (_deps_items[depender] as Dictionary).get("requires", {})
			for provider: String in requires:
				var syms: Array = requires[provider]
				var dep_row := HBoxContainer.new()
				dep_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var dep_lbl := Label.new()
				dep_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var psa := PackedStringArray()
				for s: Variant in syms:
					psa.append(str(s))
				var syms_str: String = ", ".join(psa)
				dep_lbl.text = depender + " → " + provider + ": " + syms_str
				dep_lbl.clip_text = true
				dep_row.add_child(dep_lbl)
				var cap_d: String = depender
				var cap_p: String = provider
				var rm_btn := Button.new()
				rm_btn.text = "🗑"
				rm_btn.pressed.connect(func():
					if cap_d in _deps_items:
						var r: Dictionary = (_deps_items[cap_d] as Dictionary).get("requires", {})
						r.erase(cap_p)
						if r.is_empty():
							_deps_items.erase(cap_d)
					_save_contracts()
					_validate_all_contracts()
				)
				dep_row.add_child(rm_btn)
				_contracts_scroll_list.add_child(dep_row)

	# Add new dep form
	var dep_form := VBoxContainer.new()
	dep_form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dep_form.add_theme_constant_override("separation", 2)

	var dep_row1 := HBoxContainer.new()
	dep_row1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dep_lbl1 := Label.new()
	dep_lbl1.text = "Addon:"
	var dep_opt1 := OptionButton.new()
	dep_opt1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for a: String in Ops.list_addons(project_root):
		dep_opt1.add_item(a)
	var dep_lbl2 := Label.new()
	dep_lbl2.text = "requires from:"
	var dep_opt2 := OptionButton.new()
	dep_opt2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for a: String in _contract_items:
		dep_opt2.add_item(a)
	dep_row1.add_child(dep_lbl1)
	dep_row1.add_child(dep_opt1)
	dep_row1.add_child(dep_lbl2)
	dep_row1.add_child(dep_opt2)

	var dep_row2 := HBoxContainer.new()
	dep_row2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dep_sym_input := LineEdit.new()
	dep_sym_input.placeholder_text = "symbol1, symbol2, ..."
	dep_sym_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dep_add_btn := Button.new()
	dep_add_btn.text = "+ Add Dependency"
	dep_add_btn.pressed.connect(func():
		var d_idx := dep_opt1.selected
		var p_idx := dep_opt2.selected
		var raw_syms: String = dep_sym_input.text.strip_edges()
		if d_idx < 0 or p_idx < 0 or raw_syms.is_empty():
			return
		var depender_name: String = dep_opt1.get_item_text(d_idx)
		var provider_name: String = dep_opt2.get_item_text(p_idx)
		var syms_arr: Array[String] = []
		for s: String in raw_syms.split(","):
			var cleaned := s.strip_edges()
			if not cleaned.is_empty():
				syms_arr.append(cleaned)
		if syms_arr.is_empty():
			return
		if depender_name not in _deps_items:
			_deps_items[depender_name] = {"requires": {}}
		((_deps_items[depender_name] as Dictionary)["requires"] as Dictionary)[provider_name] = syms_arr
		dep_sym_input.text = ""
		_save_contracts()
		_validate_all_contracts()
	)
	dep_row2.add_child(dep_sym_input)
	dep_row2.add_child(dep_add_btn)

	dep_form.add_child(dep_row1)
	dep_form.add_child(dep_row2)
	_contracts_scroll_list.add_child(dep_form)

# ─── Login overlay ────────────────────────────────────────────────────────────

func _build_login_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0.08, 0.08, 0.08, 0.97)

	var wrapper := CenterContainer.new()
	wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(wrapper)

	var center := VBoxContainer.new()
	center.custom_minimum_size = Vector2(380, 0)
	center.add_theme_constant_override("separation", 8)
	wrapper.add_child(center)

	var title := Label.new()
	title.text = "🧊 ChillCube Tools"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)
	center.add_child(HSeparator.new())

	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(380, 0)
	center.add_child(tabs)

	# ── Login tab ──
	var login_vbox := VBoxContainer.new()
	login_vbox.name = "Login"
	login_vbox.add_theme_constant_override("separation", 6)
	tabs.add_child(login_vbox)

	var lg := GridContainer.new()
	lg.columns = 2
	lg.add_theme_constant_override("h_separation", 8)
	var un_lbl := Label.new(); un_lbl.text = "Username"
	var un_field := LineEdit.new(); un_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pw_lbl := Label.new(); pw_lbl.text = "Password"
	var pw_field := LineEdit.new()
	pw_field.secret = true; pw_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lg.add_child(un_lbl); lg.add_child(un_field)
	lg.add_child(pw_lbl); lg.add_child(pw_field)
	login_vbox.add_child(lg)

	var login_btn := Button.new()
	login_btn.text = "Login"
	login_vbox.add_child(login_btn)

	_login_status_lbl = Label.new()
	_login_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_login_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
	login_vbox.add_child(_login_status_lbl)

	var setup_btn := Button.new()
	setup_btn.text = "⚙ First-time setup (create auth repo)"
	setup_btn.flat = true
	setup_btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	login_vbox.add_child(setup_btn)

	# ── Register tab ──
	var reg_vbox := VBoxContainer.new()
	reg_vbox.name = "Register"
	reg_vbox.add_theme_constant_override("separation", 6)
	tabs.add_child(reg_vbox)

	var rg := GridContainer.new()
	rg.columns = 2
	rg.add_theme_constant_override("h_separation", 8)
	var run_lbl := Label.new(); run_lbl.text = "Username"
	var run_field := LineEdit.new(); run_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rgh_lbl := Label.new(); rgh_lbl.text = "GitHub user"
	var rgh_field := LineEdit.new(); rgh_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rpw_lbl := Label.new(); rpw_lbl.text = "Password"
	var rpw_field := LineEdit.new()
	rpw_field.secret = true; rpw_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rpw2_lbl := Label.new(); rpw2_lbl.text = "Confirm"
	var rpw2_field := LineEdit.new()
	rpw2_field.secret = true; rpw2_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rg.add_child(run_lbl); rg.add_child(run_field)
	rg.add_child(rgh_lbl); rg.add_child(rgh_field)
	rg.add_child(rpw_lbl); rg.add_child(rpw_field)
	rg.add_child(rpw2_lbl); rg.add_child(rpw2_field)
	reg_vbox.add_child(rg)

	var reg_btn := Button.new()
	reg_btn.text = "Register"
	reg_vbox.add_child(reg_btn)

	_reg_status_lbl = Label.new()
	_reg_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reg_vbox.add_child(_reg_status_lbl)

	# ── Wire up ──
	var submit_login := func():
		if _login_thread and _login_thread.is_started():
			return
		var u := un_field.text.strip_edges()
		var p := pw_field.text
		if u.is_empty() or p.is_empty():
			_login_status_lbl.text = "Enter username and password."
			return
		login_btn.disabled = true
		_login_status_lbl.text = "🔄 Connecting..."
		_login_thread = Thread.new()
		_login_thread.start(func():
			var result := Ops.auth_verify(u, p,
				func(msg): call_deferred("_set_login_status", msg))
			call_deferred("_on_login_done", result, login_btn)
		)

	login_btn.pressed.connect(submit_login)
	pw_field.text_submitted.connect(func(_t): submit_login.call())

	setup_btn.pressed.connect(func():
		if _login_thread and _login_thread.is_started():
			return
		login_btn.disabled = true
		setup_btn.disabled = true
		_login_status_lbl.text = "🔄 Setting up..."
		_login_thread = Thread.new()
		_login_thread.start(func():
			Ops.auth_bootstrap(func(msg): call_deferred("_set_login_status", msg))
			call_deferred("_on_setup_done", login_btn, setup_btn)
		)
	)

	reg_btn.pressed.connect(func():
		if _login_thread and _login_thread.is_started():
			return
		var u := run_field.text.strip_edges()
		var gh := rgh_field.text.strip_edges()
		var p := rpw_field.text
		var p2 := rpw2_field.text
		if u.is_empty() or gh.is_empty() or p.is_empty():
			_reg_status_lbl.text = "Fill in all fields."
			return
		if p != p2:
			_reg_status_lbl.text = "Passwords do not match."
			return
		reg_btn.disabled = true
		_reg_status_lbl.text = "🔄 Registering..."
		_login_thread = Thread.new()
		_login_thread.start(func():
			Ops.auth_register(u, gh, p, func(msg): call_deferred("_set_reg_status", msg))
			call_deferred("_on_reg_done", reg_btn)
		)
	)

	return overlay

func _set_login_status(msg: String) -> void:
	if is_instance_valid(_login_status_lbl):
		_login_status_lbl.text = msg

func _set_reg_status(msg: String) -> void:
	if is_instance_valid(_reg_status_lbl):
		_reg_status_lbl.text = msg

func _on_login_done(user: Dictionary, btn: Button) -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	if is_instance_valid(btn):
		btn.disabled = false
	if user.is_empty():
		return
	_current_user = user
	_session_save()
	if is_instance_valid(_login_overlay):
		_login_overlay.visible = false
	_refresh_account_tab()

func _on_reg_done(btn: Button) -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	if is_instance_valid(btn):
		btn.disabled = false

func _on_setup_done(login_btn: Button, setup_btn: Button) -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	if is_instance_valid(login_btn):
		login_btn.disabled = false
	if is_instance_valid(setup_btn):
		setup_btn.disabled = false

# ─── Session persistence ──────────────────────────────────────────────────────

func _session_save() -> void:
	var fw := FileAccess.open("user://cc_session.json", FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_current_user, "\t") + "\n")
		fw.close()

func _session_restore() -> void:
	if not FileAccess.file_exists("user://cc_session.json"):
		return
	var f := FileAccess.open("user://cc_session.json", FileAccess.READ)
	if not f:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary) or (parsed as Dictionary).is_empty():
		return
	_current_user = parsed
	if is_instance_valid(_login_overlay):
		_login_overlay.visible = false
	_refresh_account_tab()

func _session_logout() -> void:
	_current_user = {}
	var path := ProjectSettings.globalize_path("user://cc_session.json")
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if is_instance_valid(_login_overlay):
		_login_overlay.visible = true

# ─── Account tab ─────────────────────────────────────────────────────────────

func _build_account_tab(tabs: TabContainer) -> void:
	var root := _vbox("Account", tabs)

	var top_row := HBoxContainer.new()
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var info_lbl := Label.new()
	info_lbl.name = "InfoLbl"
	info_lbl.text = "Not logged in."
	info_lbl.add_theme_font_size_override("font_size", 13)
	info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var logout_btn := Button.new()
	logout_btn.text = "Log Out"
	logout_btn.pressed.connect(_session_logout)
	top_row.add_child(info_lbl)
	top_row.add_child(logout_btn)
	root.add_child(top_row)
	root.add_child(HSeparator.new())

	# Change password
	var cp_heading := Label.new()
	cp_heading.text = "Change Password"
	cp_heading.add_theme_font_size_override("font_size", 13)
	root.add_child(cp_heading)

	var cg := GridContainer.new()
	cg.columns = 2
	cg.add_theme_constant_override("h_separation", 8)
	var cp_cur_lbl := Label.new(); cp_cur_lbl.text = "Current"
	var cp_cur := LineEdit.new(); cp_cur.secret = true; cp_cur.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cp_new_lbl := Label.new(); cp_new_lbl.text = "New"
	var cp_new := LineEdit.new(); cp_new.secret = true; cp_new.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cp_con_lbl := Label.new(); cp_con_lbl.text = "Confirm"
	var cp_con := LineEdit.new(); cp_con.secret = true; cp_con.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cg.add_child(cp_cur_lbl); cg.add_child(cp_cur)
	cg.add_child(cp_new_lbl); cg.add_child(cp_new)
	cg.add_child(cp_con_lbl); cg.add_child(cp_con)
	root.add_child(cg)

	var cp_btn := Button.new()
	cp_btn.text = "Change Password"
	root.add_child(cp_btn)

	_account_status_lbl = Label.new()
	_account_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_account_status_lbl)

	cp_btn.pressed.connect(func():
		if _login_thread and _login_thread.is_started():
			return
		var username: String = _current_user.get("username", "")
		if username.is_empty():
			_account_status_lbl.text = "Not logged in."
			return
		var old_pw := cp_cur.text
		var new_pw := cp_new.text
		var con_pw := cp_con.text
		if old_pw.is_empty() or new_pw.is_empty():
			_account_status_lbl.text = "Fill in all fields."
			return
		if new_pw != con_pw:
			_account_status_lbl.text = "New passwords do not match."
			return
		cp_btn.disabled = true
		_account_status_lbl.text = "🔄 Changing..."
		_login_thread = Thread.new()
		_login_thread.start(func():
			var ok := Ops.auth_change_password(username, old_pw, new_pw,
				func(msg): call_deferred("_set_account_status", msg))
			call_deferred("_on_change_pw_done", cp_btn, ok)
		)
	)

	# Change username
	root.add_child(HSeparator.new())
	var cn_heading := Label.new()
	cn_heading.text = "Change Username"
	cn_heading.add_theme_font_size_override("font_size", 13)
	root.add_child(cn_heading)

	var ng := GridContainer.new()
	ng.columns = 2
	ng.add_theme_constant_override("h_separation", 8)
	var cn_lbl := Label.new(); cn_lbl.text = "New name"
	var cn_field := LineEdit.new(); cn_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ng.add_child(cn_lbl); ng.add_child(cn_field)
	root.add_child(ng)

	var cn_btn := Button.new()
	cn_btn.text = "Change Name"
	root.add_child(cn_btn)

	cn_btn.pressed.connect(func():
		if _login_thread and _login_thread.is_started():
			return
		var username: String = _current_user.get("username", "")
		if username.is_empty():
			_account_status_lbl.text = "Not logged in."
			return
		var new_name := cn_field.text.strip_edges()
		if new_name.is_empty():
			_account_status_lbl.text = "Enter a new username."
			return
		cn_btn.disabled = true
		_account_status_lbl.text = "🔄 Changing..."
		_login_thread = Thread.new()
		_login_thread.start(func():
			var result := Ops.auth_change_username(username, new_name,
				func(msg): call_deferred("_set_account_status", msg))
			call_deferred("_on_change_name_done", cn_btn, cn_field, result)
		)
	)

	# Pending approvals (shown only for leader after login — refreshed dynamically)
	root.add_child(HSeparator.new())
	var ap_heading := Label.new()
	ap_heading.name = "ApprovalHeading"
	ap_heading.text = "Account Management"
	ap_heading.add_theme_font_size_override("font_size", 13)
	ap_heading.visible = false
	root.add_child(ap_heading)

	var ap_toolbar := HBoxContainer.new()
	ap_toolbar.name = "ApprovalBar"
	ap_toolbar.visible = false
	var ap_refresh := Button.new()
	ap_refresh.text = "↺ Refresh"
	ap_refresh.pressed.connect(_refresh_pending_list)
	ap_toolbar.add_child(ap_refresh)
	root.add_child(ap_toolbar)

	var ap_scroll := ScrollContainer.new()
	ap_scroll.name = "ApprovalScroll"
	ap_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ap_scroll.visible = false
	_pending_list = VBoxContainer.new()
	_pending_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ap_scroll.add_child(_pending_list)
	root.add_child(ap_scroll)

func _set_account_status(msg: String) -> void:
	if is_instance_valid(_account_status_lbl):
		_account_status_lbl.text = msg

func _on_change_pw_done(btn: Button, _ok: bool) -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	if is_instance_valid(btn):
		btn.disabled = false

func _on_change_name_done(btn: Button, field: LineEdit, new_name: String) -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	if is_instance_valid(btn):
		btn.disabled = false
	if not new_name.is_empty():
		_current_user["username"] = new_name
		_session_save()
		if is_instance_valid(field):
			field.text = ""
		_refresh_account_tab()

func _refresh_account_tab() -> void:
	# Update info label and show/hide leader section
	var tabs: TabContainer = get_child(1) if get_child_count() > 1 else null
	if not is_instance_valid(tabs):
		return
	for i in range(tabs.get_tab_count()):
		if tabs.get_tab_title(i) == "Account":
			var root: Control = tabs.get_tab_control(i)
			var info: Label = root.get_node_or_null("InfoLbl")
			if is_instance_valid(info):
				var uname: String = _current_user.get("username", "")
				var role: String = _current_user.get("role", "member")
				info.text = "👤 %s  (%s)" % [uname, role]
			var is_leader: bool = _election_is_leader()
			for child in root.get_children():
				if child.name in ["ApprovalHeading", "ApprovalBar", "ApprovalScroll"]:
					child.visible = is_leader
			if is_leader:
				_refresh_pending_list()
			break

func _refresh_pending_list() -> void:
	if not is_instance_valid(_pending_list):
		return
	for child in _pending_list.get_children():
		child.queue_free()
	var loading_lbl := Label.new()
	loading_lbl.text = "🔄 Loading..."
	loading_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_pending_list.add_child(loading_lbl)
	if _login_thread and _login_thread.is_started():
		return
	var approver: String = _current_user.get("username", "")
	_login_thread = Thread.new()
	_login_thread.start(func():
		var all_users := Ops.auth_fetch_all(Callable())
		call_deferred("_on_pending_loaded", all_users, approver)
	)

func _on_pending_loaded(all_users: Array, approver: String) -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	if not is_instance_valid(_pending_list):
		return
	for child in _pending_list.get_children():
		child.queue_free()
	if all_users.is_empty():
		var lbl := Label.new()
		lbl.text = "No accounts found."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_pending_list.add_child(lbl)
		return
	for u: Dictionary in all_users:
		var uname: String = u.get("username", "")
		if uname.to_lower() == approver.to_lower():
			continue
		var approved: bool = u.get("approved", false)
		var u_role: String = u.get("role", "member")
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var lbl := Label.new()
		var role_tag := " [leader]" if u_role == "leader" else ""
		lbl.text = ("✅ " if approved else "⏳ ") + uname + role_tag
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not approved:
			lbl.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))
		elif u_role == "leader":
			lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		row.add_child(lbl)
		if not approved:
			var approve_btn := Button.new()
			approve_btn.text = "Approve"
			var cap_name := uname
			var cap_approver := approver
			approve_btn.pressed.connect(func():
				approve_btn.disabled = true
				if _login_thread and _login_thread.is_started():
					return
				_login_thread = Thread.new()
				_login_thread.start(func():
					Ops.auth_approve(cap_approver, cap_name, Callable())
					call_deferred("_log_activity", "account_approved",
						"%s approved account for %s" % [cap_approver, cap_name])
					call_deferred("_refresh_pending_list")
					call_deferred("_on_approve_done")
				)
			)
			row.add_child(approve_btn)
		if approved:
			var role_btn := Button.new()
			role_btn.text = "Demote" if u_role == "leader" else "Promote"
			var cap_name3 := uname
			var cap_approver3 := approver
			var cap_new_role := "member" if u_role == "leader" else "leader"
			role_btn.pressed.connect(func():
				role_btn.disabled = true
				if _login_thread and _login_thread.is_started():
					return
				_login_thread = Thread.new()
				_login_thread.start(func():
					Ops.auth_set_role(cap_approver3, cap_name3, cap_new_role, Callable())
					call_deferred("_log_activity", "role_changed",
						"%s set %s role to %s" % [cap_approver3, cap_name3, cap_new_role])
					call_deferred("_refresh_pending_list")
					call_deferred("_on_approve_done")
				)
			)
			row.add_child(role_btn)
		var remove_btn := Button.new()
		remove_btn.text = "Remove"
		remove_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		var cap_name2 := uname
		var cap_approver2 := approver
		remove_btn.pressed.connect(func():
			remove_btn.disabled = true
			if _login_thread and _login_thread.is_started():
				return
			_login_thread = Thread.new()
			_login_thread.start(func():
				Ops.auth_remove(cap_approver2, cap_name2, Callable())
				call_deferred("_log_activity", "account_removed",
					"%s removed account for %s" % [cap_approver2, cap_name2])
				call_deferred("_refresh_pending_list")
				call_deferred("_on_approve_done")
			)
		)
		row.add_child(remove_btn)
		_pending_list.add_child(row)

	# Bootstrap: sole member with no leader can claim leadership
	var only_self := true
	for u: Dictionary in all_users:
		if u.get("username", "").to_lower() != approver.to_lower():
			only_self = false
			break
	if only_self and _current_user.get("role", "member") != "leader":
		var row2 := HBoxContainer.new()
		var hint := Label.new()
		hint.text = "You are the only member."
		hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		row2.add_child(hint)
		var claim_btn := Button.new()
		claim_btn.text = "👑 Claim Leadership"
		var cap_approver4 := approver
		claim_btn.pressed.connect(func():
			claim_btn.disabled = true
			if _login_thread and _login_thread.is_started():
				return
			_login_thread = Thread.new()
			_login_thread.start(func():
				var ok := Ops.auth_set_role(cap_approver4, cap_approver4, "leader", Callable())
				if ok:
					call_deferred("_on_leadership_claimed")
				else:
					call_deferred("_on_approve_done")
			)
		)
		row2.add_child(claim_btn)
		_pending_list.add_child(row2)

func _on_leadership_claimed() -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null
	_current_user["role"] = "leader"
	_session_save()
	_log_activity("role_changed", _current_user.get("username", "") + " claimed leadership")
	_refresh_account_tab()

func _on_approve_done() -> void:
	if _login_thread:
		_login_thread.wait_to_finish()
	_login_thread = null

# ─── Elections ────────────────────────────────────────────────────────────────

func _load_elections() -> void:
	_election_data = {}
	var path := ProjectSettings.globalize_path("user://cc_elections.json")
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Dictionary:
				_election_data = parsed
	for key: String in ["roles", "holders", "holder_since", "candidates", "scores", "snapshots", "pending_takeovers"]:
		if not (key in _election_data):
			_election_data[key] = {}
	if not ("settings" in _election_data):
		_election_data["settings"] = {}
	if not ("pending_votes" in _election_data):
		_election_data["pending_votes"] = []
	_election_rebuild_role_opt()
	_refresh_vote_list()
	if not _vault_cache.is_empty() and DirAccess.dir_exists_absolute(_vault_cache):
		_election_load_members()

func _save_elections() -> void:
	var path := ProjectSettings.globalize_path("user://cc_elections.json")
	var fw := FileAccess.open(path, FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(_election_data, "\t") + "\n")
		fw.close()
	_activity_auto_push()

func _election_settings() -> Dictionary:
	var s: Variant = _election_data.get("settings", {})
	if not (s is Dictionary):
		return {}
	return s as Dictionary

func _election_setting(key: String, default_val: Variant) -> Variant:
	return _election_settings().get(key, default_val)

func _election_sorted_roles() -> Array[String]:
	var roles: Array[String] = []
	for r: String in (_election_data.get("roles", {}) as Dictionary):
		roles.append(r)
	roles.sort()
	return roles

func _election_total_members() -> int:
	var cached: int = int(_election_setting("cached_member_count", 0))
	if cached > 0:
		return cached
	return _election_members.size()

func _election_avg(role: String, target: String) -> float:
	var role_scores: Dictionary = ((_election_data.get("scores", {}) as Dictionary).get(role, {}) as Dictionary)
	var voter_map: Dictionary = role_scores.get(target, {}) as Dictionary
	if voter_map.is_empty():
		return 0.0
	var total := 0
	for v: Variant in voter_map.values():
		total += int(v)
	return float(total) / float(voter_map.size())

func _election_voter_count(role: String, target: String) -> int:
	var role_scores: Dictionary = ((_election_data.get("scores", {}) as Dictionary).get(role, {}) as Dictionary)
	return (role_scores.get(target, {}) as Dictionary).size()

func _election_meets_threshold(role: String, target: String) -> bool:
	var total := _election_total_members()
	if total == 0:
		return false
	var frac: float = float(_election_setting("min_voter_fraction", 0.333))
	return float(_election_voter_count(role, target)) >= float(total) * frac

func _election_is_holder(role: String, username: String) -> bool:
	var holders: Array = ((_election_data.get("holders", {}) as Dictionary).get(role, []) as Array)
	return username in holders

func _election_is_candidate(role: String, username: String) -> bool:
	var cands: Array = ((_election_data.get("candidates", {}) as Dictionary).get(role, []) as Array)
	return username in cands

func _election_is_leader() -> bool:
	var me: String = _current_user.get("username", "")
	if me.is_empty():
		return false
	if _current_user.get("role", "") == "leader":
		return true
	var holders: Dictionary = _election_data.get("holders", {}) as Dictionary
	for role: String in holders:
		if role.to_lower() == "leader":
			var list: Array = holders[role] as Array
			if me in list:
				return true
	# If no "Leader" role exists at all, any member can manage roles
	for role: String in (_election_data.get("roles", {}) as Dictionary):
		if role.to_lower() == "leader":
			return false
	return true

func _election_role_occupied_months(role_name: String) -> float:
	var role_since: Dictionary = ((_election_data.get("holder_since", {}) as Dictionary).get(role_name, {}) as Dictionary)
	if role_since.is_empty():
		return 0.0
	var earliest := ""
	for u: String in role_since:
		var d: String = role_since[u] as String
		if earliest.is_empty() or d < earliest:
			earliest = d
	if earliest.is_empty():
		return 0.0
	var now_unix := Time.get_unix_time_from_system()
	var since_unix := Time.get_unix_time_from_datetime_dict(
		Time.get_datetime_dict_from_datetime_string(earliest + "T00:00:00", false))
	return float(now_unix - since_unix) / (30.0 * 24.0 * 3600.0)

func _election_pending_votes() -> Array:
	var pv: Variant = _election_data.get("pending_votes", [])
	if pv is Array:
		return pv
	return []

func _election_load_members() -> void:
	if _election_thread and _election_thread.is_started():
		return
	if is_instance_valid(_election_status_lbl):
		_election_status_lbl.text = "Loading members…"
	_election_thread = Thread.new()
	_election_thread.start(func():
		var users := Ops.auth_fetch_all(Callable())
		call_deferred("_election_on_members_loaded", users)
	)

func _election_on_members_loaded(users: Array) -> void:
	if _election_thread and _election_thread.is_started():
		_election_thread.wait_to_finish()
	_election_thread = null
	_election_members = []
	for u: Dictionary in users:
		if u.get("approved", false):
			_election_members.append(u)
	var settings: Dictionary = _election_settings()
	settings["cached_member_count"] = _election_members.size()
	_election_data["settings"] = settings
	_election_seed_initial_leader(users)
	if is_instance_valid(_election_status_lbl):
		_election_status_lbl.text = ""
	_election_weekly_check()
	_election_refresh()

func _election_seed_initial_leader(users: Array) -> void:
	var roles: Dictionary = _election_data.get("roles", {}) as Dictionary
	for r: String in roles:
		if r.to_lower() == "leader":
			return  # Leader role already exists, nothing to seed
	var auth_leader := ""
	for u: Dictionary in users:
		if u.get("role", "") == "leader" and u.get("approved", true):
			auth_leader = u.get("username", "")
			break
	if auth_leader.is_empty():
		return
	var today := Time.get_date_string_from_system()
	roles["Leader"] = {"description": "Project leader.", "desc_locked": false}
	_election_data["roles"] = roles
	var holders: Dictionary = _election_data.get("holders", {}) as Dictionary
	holders["Leader"] = [auth_leader]
	_election_data["holders"] = holders
	var holder_since: Dictionary = _election_data.get("holder_since", {}) as Dictionary
	holder_since["Leader"] = {auth_leader: today}
	_election_data["holder_since"] = holder_since

func _election_weekly_check() -> void:
	var roles: Dictionary = _election_data.get("roles", {}) as Dictionary
	for role_name: String in roles:
		_election_maybe_snapshot(role_name)
		_election_eval_takeovers(role_name)
	_election_update_lock_flags()
	_save_elections()

func _election_maybe_snapshot(role: String) -> void:
	var snaps_dict: Dictionary = _election_data.get("snapshots", {}) as Dictionary
	var snaps: Array = snaps_dict.get(role, []) as Array
	var today := Time.get_date_string_from_system()
	if not snaps.is_empty():
		var last: Dictionary = snaps[snaps.size() - 1] as Dictionary
		var last_date: String = last.get("date", "") as String
		if not last_date.is_empty():
			var last_unix := Time.get_unix_time_from_datetime_dict(
				Time.get_datetime_dict_from_datetime_string(last_date + "T00:00:00", false))
			if Time.get_unix_time_from_system() - last_unix < 7 * 24 * 3600:
				return
	var avgs: Dictionary = {}
	for u: Dictionary in _election_members:
		var uname: String = u.get("username", "") as String
		if not uname.is_empty():
			avgs[uname] = _election_avg(role, uname)
	snaps.append({"date": today, "averages": avgs})
	while snaps.size() > 8:
		snaps.pop_front()
	snaps_dict[role] = snaps
	_election_data["snapshots"] = snaps_dict

func _election_eval_takeovers(role: String) -> void:
	var holders: Array = ((_election_data.get("holders", {}) as Dictionary).get(role, []) as Array)
	var snaps: Array = ((_election_data.get("snapshots", {}) as Dictionary).get(role, []) as Array)
	var weeks_to_replace: int = int(_election_setting("weeks_to_replace", 4))
	var weeks_to_announce: int = int(_election_setting("weeks_to_announce", 2))
	var first_holder_weeks: int = int(_election_setting("first_holder_weeks", 1))
	var pending_takeovers: Dictionary = _election_data.get("pending_takeovers", {}) as Dictionary
	var role_takeovers: Array = pending_takeovers.get(role, []) as Array
	var updated_takeovers: Array = []

	for holder: String in holders:
		var best_challenger := ""
		var best_avg := 0.0
		for u: Dictionary in _election_members:
			var uname: String = u.get("username", "") as String
			if uname.is_empty() or uname == holder or _election_is_holder(role, uname):
				continue
			if not _election_is_candidate(role, uname) or not _election_meets_threshold(role, uname):
				continue
			var candidate_avg := _election_avg(role, uname)
			if candidate_avg > best_avg:
				best_avg = candidate_avg
				best_challenger = uname
		var holder_avg := _election_avg(role, holder)
		if best_challenger.is_empty() or best_avg <= holder_avg:
			continue
		var snap_count := min(snaps.size(), weeks_to_replace)
		var weeks_ahead := 0
		for si: int in range(snaps.size() - snap_count, snaps.size()):
			var snap_avgs: Dictionary = (snaps[si] as Dictionary).get("averages", {}) as Dictionary
			var h_avg: float = float(snap_avgs.get(holder, 0.0))
			var c_avg: float = float(snap_avgs.get(best_challenger, 0.0))
			if c_avg > h_avg:
				weeks_ahead += 1
		if weeks_ahead >= weeks_to_replace:
			_election_execute_takeover(role, holder, best_challenger)
			return
		var today := Time.get_date_string_from_system()
		var pt: Dictionary = {}
		for prev: Dictionary in role_takeovers:
			if prev.get("holder", "") == holder and prev.get("challenger", "") == best_challenger:
				pt = prev.duplicate()
				break
		pt["holder"] = holder
		pt["challenger"] = best_challenger
		pt["weeks_ahead"] = weeks_ahead
		pt["last_snapshot"] = today
		if weeks_ahead >= weeks_to_announce and (pt.get("announced_at", "") as String).is_empty():
			pt["announced_at"] = today
			_log_activity("election_pending",
				'⚡ %s is ahead of %s for role "%s" — change in ~%d more week(s)' % [
					best_challenger, holder, role, weeks_to_replace - weeks_ahead])
		updated_takeovers.append(pt)

	if holders.is_empty() and snaps.size() >= first_holder_weeks:
		var best_first := ""
		var best_first_avg := 0.0
		for u: Dictionary in _election_members:
			var uname: String = u.get("username", "") as String
			if uname.is_empty() or not _election_is_candidate(role, uname) or not _election_meets_threshold(role, uname):
				continue
			var avg := _election_avg(role, uname)
			if avg > best_first_avg:
				best_first_avg = avg
				best_first = uname
		if not best_first.is_empty():
			_election_execute_takeover(role, "", best_first)
			return

	pending_takeovers[role] = updated_takeovers
	_election_data["pending_takeovers"] = pending_takeovers

func _election_execute_takeover(role: String, old_holder: String, new_holder: String) -> void:
	var holders: Dictionary = _election_data.get("holders", {}) as Dictionary
	var holder_list: Array = holders.get(role, []) as Array
	if not old_holder.is_empty():
		holder_list.erase(old_holder)
	if new_holder not in holder_list:
		holder_list.append(new_holder)
	holders[role] = holder_list
	_election_data["holders"] = holders
	var holder_since: Dictionary = _election_data.get("holder_since", {}) as Dictionary
	var role_since: Dictionary = holder_since.get(role, {}) as Dictionary
	role_since[new_holder] = Time.get_date_string_from_system()
	if not old_holder.is_empty():
		role_since.erase(old_holder)
	holder_since[role] = role_since
	_election_data["holder_since"] = holder_since
	var pending_takeovers: Dictionary = _election_data.get("pending_takeovers", {}) as Dictionary
	var role_takeovers: Array = pending_takeovers.get(role, []) as Array
	var filtered: Array = []
	for pt: Dictionary in role_takeovers:
		if pt.get("holder", "") != old_holder or pt.get("challenger", "") != new_holder:
			filtered.append(pt)
	pending_takeovers[role] = filtered
	_election_data["pending_takeovers"] = pending_takeovers
	_election_update_lock_flags()
	if old_holder.is_empty():
		_log_activity("election_assigned", '🏆 %s was assigned role "%s"' % [new_holder, role])
	else:
		_log_activity("election_changed", '🔄 %s replaced %s as "%s"' % [new_holder, old_holder, role])

func _election_update_lock_flags() -> void:
	var lock_months: float = float(int(_election_setting("role_lock_months", 1)))
	var roles_dict: Dictionary = _election_data.get("roles", {}) as Dictionary
	for role_name: String in roles_dict:
		var role_data: Dictionary = roles_dict[role_name] as Dictionary
		role_data["desc_locked"] = _election_role_occupied_months(role_name) >= lock_months
		roles_dict[role_name] = role_data
	_election_data["roles"] = roles_dict

func _build_elections_tab(tabs: TabContainer) -> void:
	var root := _vbox("Elections", tabs)

	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_role_opt = OptionButton.new()
	_election_role_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_role_opt.item_selected.connect(func(idx: int):
		var roles := _election_sorted_roles()
		if idx >= 0 and idx < roles.size():
			_election_sel_role = roles[idx]
			_election_refresh()
	)
	toolbar.add_child(_election_role_opt)
	var new_role_btn := Button.new()
	new_role_btn.text = "➕ Role"
	new_role_btn.tooltip_text = "Create new role"
	new_role_btn.pressed.connect(_election_prompt_create_role)
	toolbar.add_child(new_role_btn)
	var del_role_btn := Button.new()
	del_role_btn.text = "🗑 Role"
	del_role_btn.tooltip_text = "Delete current role"
	del_role_btn.pressed.connect(_election_delete_selected_role)
	toolbar.add_child(del_role_btn)
	var settings_btn := Button.new()
	settings_btn.text = "⚙"
	settings_btn.tooltip_text = "Election settings"
	settings_btn.pressed.connect(_election_show_settings)
	toolbar.add_child(settings_btn)
	root.add_child(toolbar)

	_election_status_lbl = Label.new()
	_election_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	root.add_child(_election_status_lbl)

	root.add_child(HSeparator.new())

	# Description
	var desc_box := HBoxContainer.new()
	desc_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_desc_rtl = RichTextLabel.new()
	_election_desc_rtl.bbcode_enabled = true
	_election_desc_rtl.fit_content = true
	_election_desc_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_desc_rtl.text = "[color=#888]No role selected.[/color]"
	desc_box.add_child(_election_desc_rtl)
	_election_edit_desc_btn = Button.new()
	_election_edit_desc_btn.flat = true
	_election_edit_desc_btn.visible = false
	_election_edit_desc_btn.pressed.connect(_election_start_edit_desc)
	desc_box.add_child(_election_edit_desc_btn)
	root.add_child(desc_box)

	_election_desc_edit = TextEdit.new()
	_election_desc_edit.placeholder_text = "Describe this role…"
	_election_desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_desc_edit.custom_minimum_size = Vector2(0, 60)
	_election_desc_edit.visible = false
	root.add_child(_election_desc_edit)

	var desc_btn_row := HBoxContainer.new()
	_election_save_desc_btn = Button.new()
	_election_save_desc_btn.text = "💾 Save"
	_election_save_desc_btn.visible = false
	_election_save_desc_btn.pressed.connect(_election_commit_desc)
	desc_btn_row.add_child(_election_save_desc_btn)
	_election_cancel_desc_btn = Button.new()
	_election_cancel_desc_btn.text = "Cancel"
	_election_cancel_desc_btn.visible = false
	_election_cancel_desc_btn.pressed.connect(_election_cancel_desc)
	desc_btn_row.add_child(_election_cancel_desc_btn)
	root.add_child(desc_btn_row)

	root.add_child(HSeparator.new())

	_election_candidate_btn = Button.new()
	_election_candidate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_candidate_btn.visible = false
	_election_candidate_btn.pressed.connect(_election_toggle_candidate)
	root.add_child(_election_candidate_btn)

	root.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_member_list = VBoxContainer.new()
	_election_member_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_election_member_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_election_member_list)
	root.add_child(scroll)

	_election_pending_lbl = Label.new()
	_election_pending_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_election_pending_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_election_pending_lbl.visible = false
	root.add_child(_election_pending_lbl)

	_election_settings_dialog = AcceptDialog.new()
	_election_settings_dialog.title = "Election Settings"
	_election_settings_dialog.size = Vector2i(520, 440)
	add_child(_election_settings_dialog)
	_election_settings_inner = VBoxContainer.new()
	_election_settings_inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_election_settings_dialog.add_child(_election_settings_inner)

	_election_rebuild_role_opt()

func _election_rebuild_role_opt() -> void:
	if not is_instance_valid(_election_role_opt):
		return
	_election_role_opt.clear()
	var roles := _election_sorted_roles()
	for r: String in roles:
		_election_role_opt.add_item(r)
	if _election_sel_role.is_empty() and not roles.is_empty():
		_election_sel_role = roles[0]
	var idx := roles.find(_election_sel_role)
	if idx >= 0:
		_election_role_opt.select(idx)
	elif not roles.is_empty():
		_election_sel_role = roles[0]
		_election_role_opt.select(0)
	else:
		_election_sel_role = ""
	_election_refresh()

func _election_refresh() -> void:
	if not is_instance_valid(_election_member_list):
		return
	for c in _election_member_list.get_children():
		c.queue_free()
	var role := _election_sel_role
	var me: String = _current_user.get("username", "")

	# Description area
	if is_instance_valid(_election_desc_rtl):
		if not role.is_empty():
			var role_data: Dictionary = ((_election_data.get("roles", {}) as Dictionary).get(role, {}) as Dictionary)
			var desc: String = role_data.get("description", "") as String
			_election_desc_rtl.text = desc if not desc.is_empty() else "[color=#888]No description.[/color]"
			var desc_locked: bool = role_data.get("desc_locked", false)
			var is_ldr := _election_is_leader()
			if is_instance_valid(_election_edit_desc_btn):
				_election_edit_desc_btn.visible = is_ldr
				_election_edit_desc_btn.text = "✏ (vote)" if (is_ldr and desc_locked) else "✏"
				_election_edit_desc_btn.tooltip_text = "Edit description (requires vote)" if (is_ldr and desc_locked) else "Edit description"
		else:
			_election_desc_rtl.text = "[color=#888]No role selected.[/color]"
			if is_instance_valid(_election_edit_desc_btn):
				_election_edit_desc_btn.visible = false

	# Candidate button
	if is_instance_valid(_election_candidate_btn):
		if not role.is_empty() and not me.is_empty():
			_election_candidate_btn.visible = true
			if _election_is_candidate(role, me):
				_election_candidate_btn.text = "❌ Withdraw candidacy for \"%s\"" % role
				_election_candidate_btn.modulate = Color(1.0, 0.7, 0.7)
			else:
				_election_candidate_btn.text = "👤 Declare candidacy for \"%s\"" % role
				_election_candidate_btn.modulate = Color(1.0, 1.0, 1.0)
		else:
			_election_candidate_btn.visible = false

	# Pending takeover notice
	if is_instance_valid(_election_pending_lbl):
		_election_pending_lbl.visible = false
		if not role.is_empty():
			var takeovers: Array = ((_election_data.get("pending_takeovers", {}) as Dictionary).get(role, []) as Array)
			if not takeovers.is_empty():
				var weeks_replace: int = int(_election_setting("weeks_to_replace", 4))
				var parts: PackedStringArray = []
				for pt: Dictionary in takeovers:
					parts.append("⚡ %s has been ahead of %s for %d/%d weeks" % [
						pt.get("challenger", ""), pt.get("holder", ""),
						int(pt.get("weeks_ahead", 0)), weeks_replace])
				_election_pending_lbl.text = "\n".join(parts)
				_election_pending_lbl.visible = true

	if role.is_empty():
		var hint := Label.new()
		hint.text = "No roles yet. Create one with ➕ Role."
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_election_member_list.add_child(hint)
		return
	if _election_members.is_empty():
		var hint := Label.new()
		hint.text = "Loading members… (requires vault connection)"
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_election_member_list.add_child(hint)
		return

	# Build sorted list: holders first, then candidates, then others; within each group sort by avg desc
	var rows: Array = []
	for u: Dictionary in _election_members:
		var uname: String = u.get("username", "") as String
		rows.append({
			"username": uname,
			"avg": _election_avg(role, uname),
			"votes": _election_voter_count(role, uname),
			"is_holder": _election_is_holder(role, uname),
			"is_candidate": _election_is_candidate(role, uname),
			"meets": _election_meets_threshold(role, uname)
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ah: bool = a["is_holder"]
		var bh: bool = b["is_holder"]
		var ac: bool = a["is_candidate"]
		var bc: bool = b["is_candidate"]
		if ah != bh:
			return ah
		if ac != bc:
			return ac
		return float(a["avg"]) > float(b["avg"])
	)

	var role_scores: Dictionary = ((_election_data.get("scores", {}) as Dictionary).get(role, {}) as Dictionary)

	for entry: Dictionary in rows:
		var uname: String = entry["username"]
		var avg: float = entry["avg"]
		var votes: int = entry["votes"]
		var is_hld: bool = entry["is_holder"]
		var is_cand: bool = entry["is_candidate"]
		var meets: bool = entry["meets"]
		var my_score: int = int((role_scores.get(uname, {}) as Dictionary).get(me, 0))

		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var vb := VBoxContainer.new()
		panel.add_child(vb)

		var hdr := HBoxContainer.new()
		var name_lbl := RichTextLabel.new()
		name_lbl.bbcode_enabled = true
		name_lbl.fit_content = true
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var badges := ""
		if is_hld:
			badges += " [color=#ffd700][b]🏆 Holder[/b][/color]"
		if is_cand:
			badges += " [color=#88ccff]👤 Candidate[/color]"
		name_lbl.text = "[b]%s[/b]%s" % [uname, badges]
		hdr.add_child(name_lbl)
		var score_lbl := Label.new()
		if votes > 0:
			var need_str := "" if meets else " — needs more voters"
			score_lbl.text = "%.1f/5 (%d vote%s%s)" % [avg, votes, "" if votes == 1 else "s", need_str]
		else:
			score_lbl.text = "No scores yet"
		score_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if meets else Color(0.55, 0.55, 0.55))
		score_lbl.add_theme_font_size_override("font_size", 11)
		hdr.add_child(score_lbl)
		vb.add_child(hdr)

		if uname != me:
			var vote_row := HBoxContainer.new()
			var vote_lbl := Label.new()
			vote_lbl.text = "Your score:"
			vote_lbl.add_theme_font_size_override("font_size", 11)
			vote_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
			vote_row.add_child(vote_lbl)
			for s: int in range(1, 6):
				var cap_s := s
				var cap_u := uname
				var sbtn := Button.new()
				sbtn.text = str(s)
				sbtn.flat = my_score != cap_s
				sbtn.custom_minimum_size = Vector2(28, 0)
				if my_score == cap_s:
					sbtn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
				sbtn.pressed.connect(func(): _election_set_score(role, cap_u, cap_s))
				vote_row.add_child(sbtn)
			if my_score > 0:
				var cap_u := uname
				var clear_btn := Button.new()
				clear_btn.text = "✕"
				clear_btn.flat = true
				clear_btn.custom_minimum_size = Vector2(22, 0)
				clear_btn.pressed.connect(func(): _election_set_score(role, cap_u, 0))
				vote_row.add_child(clear_btn)
			vb.add_child(vote_row)

		_election_member_list.add_child(panel)

func _election_set_score(role: String, target: String, score: int) -> void:
	var me: String = _current_user.get("username", "")
	if me.is_empty():
		return
	var scores: Dictionary = _election_data.get("scores", {}) as Dictionary
	var role_scores: Dictionary = scores.get(role, {}) as Dictionary
	var voter_map: Dictionary = role_scores.get(target, {}) as Dictionary
	if score == 0:
		voter_map.erase(me)
	else:
		voter_map[me] = score
	role_scores[target] = voter_map
	scores[role] = role_scores
	_election_data["scores"] = scores
	_save_elections()
	_election_refresh()

func _election_toggle_candidate() -> void:
	var me: String = _current_user.get("username", "")
	if me.is_empty() or _election_sel_role.is_empty():
		return
	var role := _election_sel_role
	var candidates: Dictionary = _election_data.get("candidates", {}) as Dictionary
	var cand_list: Array = candidates.get(role, []) as Array
	if me in cand_list:
		cand_list.erase(me)
		_log_activity("election_candidate", '%s withdrew candidacy for "%s"' % [me, role])
	else:
		cand_list.append(me)
		_log_activity("election_candidate", '%s declared candidacy for "%s"' % [me, role])
	candidates[role] = cand_list
	_election_data["candidates"] = candidates
	_save_elections()
	_election_refresh()

func _election_prompt_create_role() -> void:
	if not _election_is_leader():
		if is_instance_valid(_election_status_lbl):
			_election_status_lbl.text = "⚠ Only the Leader can create roles"
		get_tree().create_timer(2.5).timeout.connect(func():
			if is_instance_valid(_election_status_lbl): _election_status_lbl.text = "")
		return
	var dlg := AcceptDialog.new()
	dlg.title = "New Role"
	dlg.size = Vector2i(380, 110)
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dlg.add_child(vb)
	var lbl := Label.new()
	lbl.text = "Role name:"
	vb.add_child(lbl)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.placeholder_text = "e.g. Leader, Designer, Reviewer"
	vb.add_child(edit)
	add_child(dlg)
	dlg.confirmed.connect(func():
		var name := edit.text.strip_edges()
		if not name.is_empty():
			_election_create_role(name)
		dlg.queue_free()
	)
	dlg.canceled.connect(func(): dlg.queue_free())
	dlg.popup_centered()

func _election_create_role(name: String) -> void:
	if name.is_empty():
		return
	var roles: Dictionary = _election_data.get("roles", {}) as Dictionary
	if name in roles:
		if is_instance_valid(_election_status_lbl):
			_election_status_lbl.text = "⚠ Role already exists"
		return
	roles[name] = {
		"created_at": Time.get_date_string_from_system(),
		"created_by": _current_user.get("username", "?"),
		"description": "",
		"desc_locked": false
	}
	_election_data["roles"] = roles
	_election_sel_role = name
	_save_elections()
	_election_rebuild_role_opt()
	_log_activity("election_role", '"%s" created role: "%s"' % [_current_user.get("username", "?"), name])

func _election_delete_selected_role() -> void:
	if not _election_is_leader():
		if is_instance_valid(_election_status_lbl):
			_election_status_lbl.text = "⚠ Only the Leader can delete roles"
		get_tree().create_timer(2.5).timeout.connect(func():
			if is_instance_valid(_election_status_lbl): _election_status_lbl.text = "")
		return
	var role := _election_sel_role
	if role.is_empty():
		return
	var months := _election_role_occupied_months(role)
	var lock_months: float = float(int(_election_setting("role_lock_months", 1)))
	if months >= lock_months:
		_election_submit_pending_vote({
			"type": "delete_role",
			"role": role,
			"title": "Delete role: " + role,
			"description": 'Role "%s" has been occupied for %.1f months — a %s majority vote is required.' % [role, months, _election_setting("change_threshold", "2/3")]
		})
		if is_instance_valid(_election_status_lbl):
			_election_status_lbl.text = "⚡ Vote proposed — check Votes tab"
	else:
		_election_do_delete_role(role)

func _election_do_delete_role(role: String) -> void:
	for key: String in ["roles", "holders", "holder_since", "candidates", "scores", "snapshots", "pending_takeovers"]:
		var d: Dictionary = _election_data.get(key, {}) as Dictionary
		d.erase(role)
		_election_data[key] = d
	var roles := _election_sorted_roles()
	_election_sel_role = roles[0] if not roles.is_empty() else ""
	_save_elections()
	_election_rebuild_role_opt()
	_log_activity("election_role", '"%s" deleted role: "%s"' % [_current_user.get("username", "?"), role])

func _election_start_edit_desc() -> void:
	if _election_sel_role.is_empty() or not is_instance_valid(_election_desc_edit):
		return
	var role_data: Dictionary = ((_election_data.get("roles", {}) as Dictionary).get(_election_sel_role, {}) as Dictionary)
	_election_desc_edit.text = role_data.get("description", "") as String
	_election_desc_rtl.visible = false
	_election_edit_desc_btn.visible = false
	_election_desc_edit.visible = true
	_election_save_desc_btn.visible = true
	_election_cancel_desc_btn.visible = true

func _election_cancel_desc() -> void:
	if not is_instance_valid(_election_desc_edit):
		return
	_election_desc_edit.visible = false
	_election_save_desc_btn.visible = false
	_election_cancel_desc_btn.visible = false
	_election_desc_rtl.visible = true
	_election_edit_desc_btn.visible = _election_is_leader() and not _election_sel_role.is_empty()

func _election_commit_desc() -> void:
	var role := _election_sel_role
	if role.is_empty() or not is_instance_valid(_election_desc_edit):
		return
	var new_desc := _election_desc_edit.text.strip_edges()
	var roles_dict: Dictionary = _election_data.get("roles", {}) as Dictionary
	var role_data: Dictionary = roles_dict.get(role, {}) as Dictionary
	var desc_locked: bool = role_data.get("desc_locked", false)
	if desc_locked:
		var old_desc: String = role_data.get("description", "")
		_election_submit_pending_vote({
			"type": "edit_description",
			"role": role,
			"old_description": old_desc,
			"new_description": new_desc,
			"title": "Change description: " + role,
			"description": 'Role "%s" has been occupied ≥%d month(s) — description change requires a vote.' % [role, int(_election_setting("role_lock_months", 1))]
		})
		if is_instance_valid(_election_status_lbl):
			_election_status_lbl.text = "⚡ Vote proposed — check Votes tab"
	else:
		role_data["description"] = new_desc
		roles_dict[role] = role_data
		_election_data["roles"] = roles_dict
		_save_elections()
	_election_cancel_desc()
	_election_refresh()

func _election_submit_pending_vote(data: Dictionary) -> void:
	var pvotes: Array = _election_data.get("pending_votes", []) as Array
	var id := "elv_" + str(int(Time.get_unix_time_from_system()))
	var threshold: String = _election_setting("change_threshold", "2/3") as String
	pvotes.append({
		"id": id,
		"type": data.get("type", "unknown"),
		"role": data.get("role", ""),
		"title": data.get("title", "Election vote"),
		"description": data.get("description", ""),
		"created_by": _current_user.get("username", "?"),
		"created_at": Time.get_datetime_string_from_system(),
		"threshold": threshold,
		"closed": false,
		"result": "",
		"votes": {"yes": [], "no": []},
		"extra": data
	})
	_election_data["pending_votes"] = pvotes
	_save_elections()
	_refresh_vote_list()

func _election_cast_vote(vote_id: String, vote_yes: bool) -> void:
	var pvotes: Array = _election_data.get("pending_votes", []) as Array
	var me: String = _current_user.get("username", "")
	for i: int in range(pvotes.size()):
		var pv: Dictionary = pvotes[i] as Dictionary
		if pv.get("id", "") != vote_id or pv.get("closed", false):
			continue
		var votes: Dictionary = pv.get("votes", {"yes": [], "no": []}) as Dictionary
		var yes_list: Array = votes.get("yes", []) as Array
		var no_list: Array = votes.get("no", []) as Array
		yes_list.erase(me)
		no_list.erase(me)
		if vote_yes:
			yes_list.append(me)
		else:
			no_list.append(me)
		votes["yes"] = yes_list
		votes["no"] = no_list
		pv["votes"] = votes
		var yes_n := yes_list.size()
		var no_n := no_list.size()
		var total := yes_n + no_n
		var thresh: String = pv.get("threshold", "2/3") as String
		var passed := false
		var rejected := false
		match thresh:
			"1/2":
				passed = yes_n * 2 > total
				rejected = no_n * 2 > total
			"2/3":
				passed = yes_n * 3 >= total * 2
				rejected = no_n * 3 >= total * 2
			"3/4":
				passed = yes_n * 4 >= total * 3
				rejected = no_n * 4 >= total * 3
		if passed or rejected:
			pv["closed"] = true
			pv["result"] = "approved" if passed else "rejected"
			pv["closed_at"] = Time.get_datetime_string_from_system()
			if passed:
				_election_process_approved(pv)
			_log_activity("election_vote_closed",
				'🗳 Election vote "%s" closed: %s' % [pv.get("title", ""), pv.get("result", "")])
		pvotes[i] = pv
		break
	_election_data["pending_votes"] = pvotes
	_save_elections()
	_refresh_vote_list()

func _election_process_approved(pv: Dictionary) -> void:
	var extra: Dictionary = pv.get("extra", {}) as Dictionary
	var type: String = pv.get("type", "") as String
	match type:
		"delete_role":
			_election_do_delete_role(pv.get("role", "") as String)
		"edit_description":
			var role: String = pv.get("role", "") as String
			var new_desc: String = extra.get("new_description", "") as String
			var roles_dict: Dictionary = _election_data.get("roles", {}) as Dictionary
			var role_data: Dictionary = roles_dict.get(role, {}) as Dictionary
			role_data["description"] = new_desc
			roles_dict[role] = role_data
			_election_data["roles"] = roles_dict
			_save_elections()
		"change_setting":
			var setting: String = extra.get("setting", "") as String
			var new_val: Variant = extra.get("new_value", null)
			if not setting.is_empty() and new_val != null:
				var settings: Dictionary = _election_settings()
				settings[setting] = new_val
				_election_data["settings"] = settings
				_save_elections()
	if is_instance_valid(_election_status_lbl):
		_election_status_lbl.text = "✅ Vote passed — action applied"
	_election_rebuild_role_opt()

func _election_show_settings() -> void:
	if not is_instance_valid(_election_settings_dialog) or not is_instance_valid(_election_settings_inner):
		return
	for c in _election_settings_inner.get_children():
		c.queue_free()
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 6)
	scroll.add_child(inner)
	_election_settings_inner.add_child(scroll)
	var note := Label.new()
	note.text = "All changes require a %s majority vote to take effect." % _election_setting("change_threshold", "2/3")
	note.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inner.add_child(note)
	inner.add_child(HSeparator.new())

	var settings_def: Array = [
		{"key": "min_voter_fraction", "label": "Minimum voter fraction to count a score",
			"options": [["1/3 (default)", 0.333], ["1/2", 0.5], ["2/3", 0.667], ["3/4", 0.75]]},
		{"key": "weeks_to_replace", "label": "Consecutive weeks challenger must lead",
			"options": [["2 weeks", 2], ["3 weeks", 3], ["4 weeks (default)", 4], ["6 weeks", 6]]},
		{"key": "weeks_to_announce", "label": "Weeks ahead to announce pending change",
			"options": [["1 week", 1], ["2 weeks (default)", 2], ["3 weeks", 3]]},
		{"key": "change_threshold", "label": "Vote threshold for settings changes",
			"options": [["1/2", "1/2"], ["2/3 (default)", "2/3"], ["3/4", "3/4"]]},
		{"key": "role_lock_months", "label": "Months before role requires vote to modify",
			"options": [["1 month (default)", 1], ["2 months", 2], ["3 months", 3]]},
		{"key": "first_holder_weeks", "label": "Weeks before first holder is assigned",
			"options": [["1 week (default)", 1], ["2 weeks", 2]]}
	]

	for sdef: Dictionary in settings_def:
		var skey: String = sdef["key"] as String
		var slabel: String = sdef["label"] as String
		var sopts: Array = sdef["options"] as Array
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var lbl := Label.new()
		lbl.text = slabel
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size = Vector2(220, 0)
		row.add_child(lbl)
		var cur: Variant = _election_setting(skey, sopts[0][1])
		var opt := OptionButton.new()
		opt.custom_minimum_size = Vector2(160, 0)
		var sel_idx := 0
		for oi: int in range(sopts.size()):
			opt.add_item(sopts[oi][0] as String)
			if sopts[oi][1] == cur:
				sel_idx = oi
		opt.select(sel_idx)
		row.add_child(opt)
		var cap_key := skey
		var cap_opts := sopts
		var propose_btn := Button.new()
		propose_btn.text = "Propose"
		propose_btn.pressed.connect(func():
			var sel: int = opt.selected
			if sel < 0 or sel >= cap_opts.size():
				return
			var new_val: Variant = cap_opts[sel][1]
			var old_val: Variant = _election_setting(cap_key, cap_opts[0][1])
			if new_val == old_val:
				return
			_election_submit_pending_vote({
				"type": "change_setting",
				"setting": cap_key,
				"old_value": old_val,
				"new_value": new_val,
				"title": "Change setting: %s → %s" % [cap_key, str(new_val)],
				"description": "Change %s from %s to %s." % [cap_key, str(old_val), str(new_val)]
			})
			_election_settings_dialog.hide()
			if is_instance_valid(_election_status_lbl):
				_election_status_lbl.text = "⚡ Vote proposed — check Votes tab"
		)
		row.add_child(propose_btn)
		inner.add_child(row)
		inner.add_child(HSeparator.new())

	_election_settings_dialog.popup_centered()
