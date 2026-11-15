extends CanvasLayer
## Autoload "Router": scene changes with a fade.
##
## REPLACING THE TEMPORARY MENU: point MAIN_MENU (below) and the project's
## "run/main_scene" to the finished menu scene (e.g. res://GameMenu/MainMenu/main_menu.tscn).
## The finished menu only needs to call Router.go_to(Router.MISSION_SELECT),
## Router.go_to(Router.SETTINGS), Router.play() and get_tree().quit().

const MAIN_MENU := "res://Menus/TempMenu/temp_main_menu.tscn"
const MISSION_SELECT := "res://Menus/TempMenu/mission_select.tscn"
const SETTINGS := "res://Menus/TempMenu/settings.tscn"
const NASA := "res://Menus/TempMenu/nasa_resources.tscn"

var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)


func go_to(path: String) -> void:
	if _busy:
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, 0.22)
	await tw.finished
	get_tree().paused = false
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Router: cannot open scene %s (error %d)" % [path, err])
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(_rect, "color:a", 0.0, 0.3)
	await tw2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func start_mission(id: String) -> void:
	var m := MissionRegistry.find(id)
	if m.is_empty() or not MissionRegistry.is_unlocked(id):
		return
	go_to(str(m["scene"]))


## "Play" = launch the next available mission straight away (Mission 1 when there is no
## progress). When every available mission is already completed it replays the last one.
## It never opens the mission list - that is what the "Missions" button is for.
func play() -> void:
	# Demo Mode (all missions unlocked): the player chooses which mission to start - nothing starts by surprise.
	if bool(GameState.settings["unlock_all"]):
		go_to(MISSION_SELECT)
		return
	var id := GameState.next_mission_id()
	if id == "":
		id = MissionRegistry.last_playable_id()
	start_mission(id)
