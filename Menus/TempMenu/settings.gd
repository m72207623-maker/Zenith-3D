extends Node3D
## Settings over the 3D launch pad. The ONLY place where the language can be changed.

var _reset_armed := false
var _reset_btn: Button


func _ready() -> void:
	var bg := MenuBackdrop3D.new()
	bg.view_name = "settings"
	add_child(bg)
	var layer := CanvasLayer.new()
	add_child(layer)
	var screen := Control.new()
	screen.theme = UIKit.get_ui_theme()
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(screen)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	margin.add_theme_constant_override("margin_right", 700)
	screen.add_child(margin)
	var p := UIKit.panel()
	margin.add_child(p)
	var outer := UIKit.vbox(8)
	p.add_child(outer)
	var sc := ScrollContainer.new()          # small windows: the options scroll, Back stays pinned
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(sc)
	var v := UIKit.vbox(9)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(v)
	v.add_child(UIKit.label("SET_TITLE", 34, Color.WHITE))
	v.add_child(HSeparator.new())

	# Language
	v.add_child(UIKit.label("SET_LANGUAGE", 20, UIKit.C_ACCENT))
	var lang_row := UIKit.hbox(12)
	v.add_child(lang_row)
	var group := ButtonGroup.new()
	for code in Loc.LOCALES:
		var b := Button.new()
		b.text = str(Loc.LOCALE_NAMES[code])
		b.toggle_mode = true
		b.button_group = group
		b.custom_minimum_size = Vector2(190, 48)
		b.focus_mode = Control.FOCUS_NONE
		b.button_pressed = (Loc.current() == code)
		b.pressed.connect(_on_lang.bind(code))
		lang_row.add_child(b)

	# Volume
	v.add_child(UIKit.label("SET_VOLUME", 20, UIKit.C_ACCENT))
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(GameState.settings["volume"])
	slider.custom_minimum_size = Vector2(0, 26)
	slider.value_changed.connect(func(val: float): GameState.set_setting("volume", val))
	v.add_child(slider)

	v.add_child(UIKit.label("SET_MUSIC_VOL", 20, UIKit.C_ACCENT))
	v.add_child(_slider("music_volume", 0.0, 1.0, 0.05))
	v.add_child(_toggle("SET_MUSIC_ON", "music_on"))
	v.add_child(UIKit.label("SET_SFX_VOL", 20, UIKit.C_ACCENT))
	var sfx := _slider("sfx_volume", 0.0, 1.0, 0.05)
	sfx.drag_ended.connect(func(_c): Sfx.play("click"))
	v.add_child(sfx)

	v.add_child(UIKit.label("SET_SENS", 20, UIKit.C_ACCENT))
	var sens := HSlider.new()
	sens.min_value = 0.5
	sens.max_value = 1.5
	sens.step = 0.1
	sens.value = float(GameState.settings["sens"])
	sens.custom_minimum_size = Vector2(0, 26)
	sens.value_changed.connect(func(val: float): GameState.set_setting("sens", val))
	v.add_child(sens)

	v.add_child(UIKit.label("SET_DISPLAY", 20, UIKit.C_ACCENT))
	v.add_child(_choice_row([["SET_WINDOWED", "windowed"], ["SET_FULLSCREEN", "fullscreen"]], str(GameState.settings["display_mode"]),
		func(id: String): GameState.set_setting("display_mode", id)))
	var dh := UIKit.label("SET_DISPLAY_HINT", 12, UIKit.C_MUTED)
	v.add_child(dh)
	v.add_child(UIKit.label("SET_FLIGHT_MODE", 20, UIKit.C_ACCENT))
	v.add_child(_choice_row([["FM_AUTO", "auto"], ["FM_ASSISTED", "assisted"], ["FM_MANUAL", "manual"]], str(GameState.settings["flight_mode"]),
		func(id: String): GameState.set_flight_mode(id)))
	v.add_child(_toggle("SET_SHAKE", "shake"))
	v.add_child(_toggle("SET_UNLOCK_ALL", "unlock_all"))

	v.add_child(UIKit.label("CREDITS_TITLE", 20, UIKit.C_ACCENT))
	var credits := UIKit.label("CREDITS_MUSIC", 15, UIKit.C_MUTED)
	credits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits.custom_minimum_size.x = 380
	v.add_child(credits)

	_reset_btn = UIKit.button("SET_RESET", Vector2(0, 46))
	_reset_btn.pressed.connect(_on_reset)
	v.add_child(_reset_btn)

	var nasa := UIKit.button("MENU_NASA", Vector2(0, 44))
	nasa.pressed.connect(func(): Router.go_to(Router.NASA))
	outer.add_child(nasa)
	var back := UIKit.button("BTN_BACK", Vector2(200, 48))
	back.pressed.connect(func(): Router.go_to(Router.MAIN_MENU))
	outer.add_child(back)
	var cam_hint := CameraHint.new()
	screen.add_child(cam_hint)
	cam_hint.setup(false, -1.0, true)


## Row of exclusive toggle buttons: items = [[caption key, id], ...].
func _choice_row(items: Array, current: String, on_pick: Callable) -> Control:
	var row := UIKit.hbox(10)
	var group := ButtonGroup.new()
	for it in items:
		var b := Button.new()
		b.text = str(it[0])
		b.toggle_mode = true
		b.button_group = group
		b.custom_minimum_size = Vector2(150, 44)
		b.focus_mode = Control.FOCUS_NONE
		b.button_pressed = str(it[1]) == current
		b.pressed.connect(on_pick.bind(str(it[1])))
		row.add_child(b)
	return row


func _slider(setting: String, lo: float, hi: float, step: float) -> HSlider:
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.value = float(GameState.settings[setting])
	s.custom_minimum_size = Vector2(0, 26)
	s.value_changed.connect(func(val: float): GameState.set_setting(setting, val))
	return s


func _toggle(key: String, setting: String) -> CheckButton:
	var c := CheckButton.new()
	c.text = key
	c.focus_mode = Control.FOCUS_NONE
	c.button_pressed = bool(GameState.settings[setting])
	c.toggled.connect(func(on: bool): GameState.set_setting(setting, on))
	return c


func _on_lang(code: String) -> void:
	GameState.set_setting("locale", code)


func _on_reset() -> void:
	if not _reset_armed:
		_reset_armed = true
		_reset_btn.text = "SET_RESET_CONFIRM"
		return
	_reset_armed = false
	GameState.reset_progress()
	_reset_btn.text = "SET_RESET"

