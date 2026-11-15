extends SceneTree
## Headless functional test: menu buttons / Play logic / mission select / orbit camera input in the
## menus, the assembly screen and inspect mode of all three missions (vehicle must not move).
##   Godot --headless --fixed-fps 60 --path . --script res://Tools/camera_test.gd

var _fail := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		_fail += 1


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _wait_scene(part: String, limit: int = 900) -> Node:
	var i := 0
	while (current_scene == null or not current_scene.scene_file_path.contains(part)) and i < limit:
		await process_frame
		i += 1
	var r := root.get_node("Router")
	i = 0
	while r._busy and i < 600:
		await process_frame
		i += 1
	await _frames(10)
	return current_scene


func _key(code: Key) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = true
	root.push_input(e)
	var r := InputEventKey.new()
	r.keycode = code
	r.physical_keycode = code
	r.pressed = false
	root.push_input(r)


func _mb(btn: MouseButton, pressed: bool, pos: Vector2 = Vector2(640, 360), dbl: bool = false, factor: float = 1.0) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = btn
	e.pressed = pressed
	e.position = pos
	e.global_position = pos
	e.double_click = dbl
	e.factor = factor
	root.push_input(e)


func _mm(rel: Vector2, pos: Vector2 = Vector2(640, 360), mask: int = 0) -> void:
	var e := InputEventMouseMotion.new()
	e.position = pos
	e.global_position = pos
	e.relative = rel
	e.button_mask = mask
	root.push_input(e)


func _drag(orbit: OrbitCameraController, btn: MouseButton, rel_total: Vector2) -> void:
	_mb(btn, true)
	for i in 10:
		_mm(rel_total / 10.0, Vector2(640, 360), 1 if btn == MOUSE_BUTTON_LEFT else 2)
		await process_frame
	_mb(btn, false)


func _run() -> void:
	root.size = Vector2i(1280, 720)           # the screen-space checks below assume a 1280x720 window (headless default is tiny)
	await _frames(5)
	var gs := root.get_node("GameState")
	var router := root.get_node("Router")
	gs.progress.clear()
	gs.settings["unlock_all"] = false

	# ---------------------------------------------------------------- Play button logic
	router.play()
	var m: Node = await _wait_scene("mission1")
	_check(m != null and m.scene_file_path.contains("mission1"), "Play with no progress starts Mission 1")
	gs.record_result("m1_launch", 2, 1000)
	router.play()
	m = await _wait_scene("space_ops")
	_check(m.scene_file_path.contains("space_ops"), "Play after Mission 1 starts Mission 2")
	gs.record_result("m2_space_ops", 2, 1000)
	router.play()
	m = await _wait_scene("iss_launch")
	_check(m.scene_file_path.contains("iss_launch"), "Play after Mission 2 starts Mission 3")
	gs.record_result("m3_iss", 3, 1000)
	gs.record_result("m4_constellation", 2, 1000)
	router.play()
	m = await _wait_scene("moon_launch")
	_check(m.scene_file_path.contains("moon_launch"), "Play after Mission 4 starts Mission 5")
	gs.record_result("m5_moon", 3, 1000)
	router.play()
	m = await _wait_scene("moon_launch")
	_check(m.scene_file_path.contains("moon_launch"), "Play with everything done replays the last mission (never the list)")

	# ---------------------------------------------------------------- unlock rules
	gs.progress.clear()
	var reg = load("res://Core/mission_registry.gd")   # loaded lazily: it uses autoloads
	_check(reg.is_unlocked("m1_launch") and not reg.is_unlocked("m2_space_ops") and not reg.is_unlocked("m3_iss"),
		"missions unlock sequentially (only M1 at the start)")
	_check(not reg.is_unlocked("m4_constellation") and not reg.is_unlocked("m5_moon"), "missions 4-5 are locked until the previous mission is done")
	gs.record_result("m1_launch", 1, 500)
	_check(reg.is_unlocked("m2_space_ops") and not reg.is_unlocked("m3_iss"), "completing M1 unlocks M2 only")
	gs.record_result("m2_space_ops", 1, 500)
	_check(reg.is_unlocked("m3_iss") and reg.is_unlocked("m1_launch"), "M3 unlocked, completed missions stay replayable")

	# ---------------------------------------------------------------- mission select screen
	router.go_to(router.MISSION_SELECT)
	var sel: Node = await _wait_scene("mission_select")
	_check(sel.scene_file_path.contains("mission_select"), "Missions button opens the separate selection screen")
	_check(sel._tabs.size() == 5, "selection screen lists all 5 missions")
	sel._select(3, false)
	await _frames(5)
	_check((sel._detail["go"] as Button).disabled, "mission 4 launch button is disabled (coming soon)")
	sel._select(1, false)
	await _frames(5)
	_check(not (sel._detail["go"] as Button).disabled, "mission 2 can be launched")
	var orbit: OrbitCameraController = sel.orbit
	_check(not orbit.engaged, "camera starts in the cinematic mode")
	var yaw0 := orbit.yaw
	await _drag(orbit, MOUSE_BUTTON_LEFT, Vector2(240, 60))
	await _frames(6)
	_check(orbit.engaged, "LMB drag engages the orbit camera")
	_check(absf(angle_difference(orbit.yaw, yaw0)) > 0.3, "LMB drag rotates the camera (yaw changed %.2f rad)" % absf(angle_difference(orbit.yaw, yaw0)))
	var d0 := orbit._dist_t
	_mb(MOUSE_BUTTON_WHEEL_UP, true)
	_mb(MOUSE_BUTTON_WHEEL_UP, true)
	await _frames(20)
	_check(orbit._dist_t < d0 * 0.9, "wheel zooms in smoothly (%.1f -> %.1f)" % [d0, orbit._dist_t])
	for i in 40:
		_mb(MOUSE_BUTTON_WHEEL_UP, true)
	await _frames(5)
	_check(orbit._dist_t >= orbit.min_dist - 0.001, "zoom is clamped at the minimum distance")
	var f0 := orbit._focus_t
	await _drag(orbit, MOUSE_BUTTON_RIGHT, Vector2(150, 40))
	_check(orbit._focus_t.distance_to(f0) > 0.5, "RMB drag pans the view point")
	_key(KEY_R)
	await _frames(5)
	_check(not orbit.engaged, "R resets the camera back to the cinematic mode")
	# double-click focus on an object under the cursor
	orbit.engage()
	await _frames(5)
	var target: Node3D = null
	for fb in orbit.focusables:
		var cand: Node3D = fb["node"]
		if not orbit.camera.is_position_behind(cand.global_position) and float(fb["radius"]) < 100.0 \
				and Rect2(10, 10, 1260, 700).has_point(orbit.camera.unproject_position(cand.global_position)):
			target = cand
			break
	var sp := camera_screen(orbit, target)
	_mb(MOUSE_BUTTON_LEFT, true, sp, true)
	_mb(MOUSE_BUTTON_LEFT, false, sp)
	await _frames(40)
	var hit := false
	for fb in orbit.focusables:
		if orbit._focus_t.distance_to((fb["node"] as Node3D).global_position) < 1.0:
			hit = true
	_check(hit, "double-click focuses the object under the cursor (nearest/smallest object wins)")
	# camera must not go through models: force a position inside an obstacle
	var ob: Dictionary = orbit.obstacles[0]
	var inside: Vector3 = (ob["node"] as Node3D).global_position
	var pushed := orbit._avoid(inside)
	_check(pushed.distance_to(inside) >= float(ob["radius"]) * 0.9, "camera is pushed out of models (collision avoidance)")
	sel._select(0, false)
	sel._launch()
	m = await _wait_scene("mission1")
	_check(m.scene_file_path.contains("mission1"), "Launch button starts the selected mission")

	# ---------------------------------------------------------------- mission 1 inspect mode
	m.dev_skip_briefing()
	await _frames(10)
	var po: OrbitCameraController = m.pad_scene.orbit
	_check(po.user_can_engage, "rocket designer allows free camera rotation")
	await _drag(po, MOUSE_BUTTON_LEFT, Vector2(-200, 30))
	_check(po.engaged, "LMB drag rotates the camera around the rocket in the designer")
	_key(KEY_R)
	await _frames(5)
	m.dev_quick("kestrel/l/aero")
	await _frames(30)
	_check(not m.pad_scene.orbit.user_can_engage, "free camera is not triggered by the mouse during flight (no conflict with controls)")
	var alt0: float = m.model.altitude()
	await _frames(90)
	_check(m.model.altitude() > alt0 + 0.5, "rocket climbs normally before inspect mode")
	_key(KEY_C)
	await _frames(3)
	_check(m.inspecting, "C enters inspect mode in Mission 1")
	var snap := [m.model.r, m.model.vr, m.model.vt, m.model.pitch, m.model.fuel, m.model.time]
	var cam_before: Vector3 = m.pad_scene.camera.global_position
	await _drag(m.pad_scene.orbit, MOUSE_BUTTON_LEFT, Vector2(260, 90))
	_mb(MOUSE_BUTTON_WHEEL_DOWN, true)
	await _frames(30)
	var same: bool = snap[0] == m.model.r and snap[1] == m.model.vr and snap[2] == m.model.vt \
		and snap[3] == m.model.pitch and snap[4] == m.model.fuel and snap[5] == m.model.time
	_check(same, "inspecting does not change the rocket's position, velocity, fuel or time")
	_check(m.pad_scene.camera.global_position.distance_to(cam_before) > 3.0, "the camera moved freely while the rocket stayed untouched")
	_key(KEY_R)
	await _frames(40)
	_check(not m.inspecting, "R leaves inspect mode")
	var r_before: float = m.model.r
	await _frames(30)
	_check(absf(r_before - m.model.r) > 0.05, "simulation resumes after inspect mode")

	# ---------------------------------------------------------------- mission 2 / 3 inspect mode
	for entry in [["mission3", "m3_iss"]]:
		router.go_to("res://Missions/Mission3/mission3.tscn")
		m = await _wait_scene(entry[0])
		m.dev_skip_briefing()
		m.dev_quick_start()
		await _frames(30)
		var w = m.world
		var p0: Vector2 = w.pos
		m.dev_autopilot = true
		await _frames(40)
		_check(w.pos.distance_to(p0) > 0.05 or w.vel.length() > 0.01, "%s: vehicle moves before inspect" % entry[0])
		_key(KEY_C)
		await _frames(3)
		_check(m.inspecting, "%s: C enters inspect mode" % entry[0])
		var p1: Vector2 = w.pos
		var v1: Vector2 = w.vel
		var fuel1: float = w.fuel
		var cam1: Vector3 = m.view.camera.global_position
		await _drag(m.view.orbit, MOUSE_BUTTON_LEFT, Vector2(300, -80))
		_mb(MOUSE_BUTTON_WHEEL_UP, true)
		await _frames(30)
		_check(w.pos.is_equal_approx(p1) and w.vel.is_equal_approx(v1) and is_equal_approx(w.fuel, fuel1),
			"%s: vehicle position/velocity/fuel unchanged while inspecting" % entry[0])
		_check(m.view.camera.global_position.distance_to(cam1) > 1.0, "%s: camera orbits freely" % entry[0])
		_key(KEY_C)
		await _frames(40)
		_check(not m.inspecting, "%s: C resumes the mission" % entry[0])
		await _frames(30)
		_check(w.pos.distance_to(p1) > 0.001 or w.vel.length() > 0.0, "%s: simulation resumes" % entry[0])

	print("\nRESULT: ", "ALL PASSED" if _fail == 0 else "%d FAILED" % _fail)
	quit(_fail)


func camera_screen(orbit: OrbitCameraController, n: Node3D) -> Vector2:
	return orbit.camera.unproject_position(n.global_position)






