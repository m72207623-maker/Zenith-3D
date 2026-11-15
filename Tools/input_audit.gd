extends SceneTree
## REAL-INPUT audit (events go through Input.parse_input_event = the same path as OS mouse events):
## for every screen, is the free 3D area really free (no invisible full-screen Control eating the mouse),
## and does a real LMB drag / wheel / RMB drag / R actually move the camera?
##   Godot --headless --fixed-fps 60 --path . --script res://Tools/input_audit.gd --quit-after 30000

var _fail := 0
var _router: Node
var _gs: Node


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		_fail += 1


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _idle() -> void:
	var i := 0
	while _router._busy and i < 900:
		await process_frame
		i += 1


func _open(path: String, part: String) -> Node:
	_router.go_to(path)
	var n := 0
	while (current_scene == null or not current_scene.scene_file_path.contains(part)) and n < 900:
		await process_frame
		n += 1
	await _idle()
	await _frames(30)
	return current_scene


func _mouse_move(pos: Vector2, rel: Vector2 = Vector2.ZERO, mask: int = 0) -> void:
	var e := InputEventMouseMotion.new()
	e.position = pos
	e.global_position = pos
	e.relative = rel
	e.button_mask = mask
	Input.parse_input_event(e)


func _mouse_btn(btn: MouseButton, pressed: bool, pos: Vector2) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = btn
	e.pressed = pressed
	e.position = pos
	e.global_position = pos
	e.button_mask = (1 << (btn - 1)) if pressed else 0
	Input.parse_input_event(e)


func _key(code: Key) -> void:
	var d := InputEventKey.new()
	d.keycode = code
	d.physical_keycode = code
	d.pressed = true
	Input.parse_input_event(d)
	await process_frame
	var u := InputEventKey.new()
	u.keycode = code
	u.physical_keycode = code
	u.pressed = false
	Input.parse_input_event(u)
	await process_frame


## What would receive a click at `pos`? (null = nothing: the click reaches the 3D scene / camera)
func _blocker(pos: Vector2) -> String:
	_mouse_move(pos)
	await _frames(3)
	var c := root.gui_get_hovered_control()
	# a PASS control forwards the event to its parent; the first STOP control swallows it
	while c != null:
		if c.mouse_filter == Control.MOUSE_FILTER_STOP:
			return str(c.get_path())
		c = c.get_parent() as Control
	return ""


func _drag(orbit: OrbitCameraController, btn: MouseButton, total: Vector2, pos: Vector2 = Vector2(640, 360)) -> void:
	_mouse_move(pos)
	await process_frame
	_mouse_btn(btn, true, pos)
	await process_frame
	var mask := 1 if btn == MOUSE_BUTTON_LEFT else 2
	for i in 12:
		pos += total / 12.0
		_mouse_move(pos, total / 12.0, mask)
		await process_frame
	_mouse_btn(btn, false, pos)
	await process_frame


func _test_camera(tag: String, orbit: OrbitCameraController, camera: Camera3D, pos: Vector2 = Vector2(640, 360), dx: float = 260.0) -> void:
	var blk := await _blocker(pos)
	_check(blk == "", tag + ": free 3D area is not covered by UI (hovered: %s)" % (blk if blk != "" else "nothing"))
	var yaw0 := orbit.yaw
	var cam0 := camera.global_position
	await _drag(orbit, MOUSE_BUTTON_LEFT, Vector2(dx, 40), pos)
	await _frames(8)
	_check(orbit.engaged, tag + ": real LMB drag engages the camera")
	_check(camera.global_position.distance_to(cam0) > 1.0, tag + ": camera actually moved (%.1f m)" % camera.global_position.distance_to(cam0))
	_check(absf(angle_difference(orbit.yaw, yaw0)) > dx * 0.0055 * 0.5, tag + ": drag rotated it %.0f deg" % rad_to_deg(absf(angle_difference(orbit.yaw, yaw0))))
	var d0 := orbit._dist_t
	_mouse_btn(MOUSE_BUTTON_WHEEL_UP, true, pos)
	_mouse_btn(MOUSE_BUTTON_WHEEL_UP, false, pos)
	await _frames(20)
	_check(orbit._dist_t < d0, tag + ": wheel zooms in (%.1f -> %.1f)" % [d0, orbit._dist_t])
	var f0 := orbit._focus_t
	await _drag(orbit, MOUSE_BUTTON_RIGHT, Vector2(120, 30), pos)
	_check(orbit._focus_t.distance_to(f0) > 0.2, tag + ": RMB drag pans the view point")
	await _key(KEY_R)
	await _frames(5)
	_check(not orbit.engaged, tag + ": R resets the camera")
	await _frames(90)


func _run() -> void:
	await _frames(5)
	_router = root.get_node("Router")
	_gs = root.get_node("GameState")
	root.size = Vector2i(1280, 720)
	_gs.progress.clear()
	_gs.settings["unlock_all"] = true

	var m := await _open("res://Menus/TempMenu/temp_main_menu.tscn", "temp_main_menu")
	for c in m.get_children():
		if c.get("scene") != null and c.scene.get("orbit") != null:
			await _test_camera("main menu", c.scene.orbit, c.scene.camera, Vector2(900, 360))
	m = await _open("res://Menus/TempMenu/settings.tscn", "settings")
	for c in m.get_children():
		if c.get("scene") != null and c.scene.get("orbit") != null:
			await _test_camera("settings", c.scene.orbit, c.scene.camera, Vector2(900, 360))
	m = await _open("res://Menus/TempMenu/mission_select.tscn", "mission_select")
	await _test_camera("mission select", m.orbit, m.camera, Vector2(640, 300))

	m = await _open("res://Missions/Mission1/mission1.tscn", "mission1")
	m.dev_skip_briefing()
	await _frames(30)
	await _test_camera("M1 satellite design", m.pad_scene.orbit, m.pad_scene.camera, Vector2(560, 360), 150.0)
	m._on_design_done(m.design_view.design.duplicate())
	await _frames(30)
	await _test_camera("M1 rocket designer", m.pad_scene.orbit, m.pad_scene.camera, Vector2(560, 360), 150.0)

	print("\nRESULT: ", "ALL PASSED" if _fail == 0 else "%d FAILED" % _fail)
	quit(_fail)
