extends CanvasLayer

# Options / pause menu, opened with Esc while exploring. It builds its own controls, so there is
# no scene file. Up and Down choose, Left and Right change a value, Enter activates, Esc closes.

const ITEMS = ["Resume", "Fullscreen", "Music volume", "Sound effects", "Screen effects", "Controls", "Save game", "Quit to title"]
const RESUME = 0
const FULLSCREEN = 1
const MUSIC = 2
const SFX = 3
const EFFECTS = 4
const CONTROLS = 5
const SAVE = 6
const QUIT = 7
const STEP = 0.1

# Bigger than the in-game text, the menu is read at a glance
var font: DynamicFont
var panel: PanelContainer
var rows = []
var hint: Label
var index = 0
var isOpen = false
var message = ""
var confirmQuit = false

func _ready():
	font = preload("res://fonts/normalFont.tres").duplicate()
	font.size = 34
	layer = 100
	set_process_input(false)
	visible = false
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	add_child(dim)
	var center = CenterContainer.new()
	center.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	add_child(center)
	panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08)
	style.border_color = Color(1, 1, 1)
	style.set_border_width_all(3)
	for margin in [MARGIN_LEFT, MARGIN_RIGHT, MARGIN_TOP, MARGIN_BOTTOM]:
		style.set_default_margin(margin, 36)
	panel.add_stylebox_override("panel", style)
	center.add_child(panel)
	var box = VBoxContainer.new()
	box.add_constant_override("separation", 14)
	panel.add_child(box)
	var title = makeLabel("OPTIONS")
	title.align = Label.ALIGN_CENTER
	box.add_child(title)
	for _i in range(ITEMS.size()):
		var row = makeLabel("")
		row.rect_min_size = Vector2(780, 0)
		box.add_child(row)
		rows.append(row)
	hint = makeLabel("")
	hint.modulate = Color(1, 1, 1, 0.6)
	hint.align = Label.ALIGN_CENTER
	box.add_child(hint)

func makeLabel(text: String) -> Label:
	var label = Label.new()
	label.add_font_override("font", font)
	label.text = text
	return label

func open():
	index = 0
	message = ""
	confirmQuit = false
	isOpen = true
	visible = true
	GLOBAL.currentMode = GLOBAL.MODE_OPTIONS
	MasterInput.setMaster(self)
	refresh()

func close():
	isOpen = false
	visible = false
	GLOBAL.currentMode = GLOBAL.MODE_NORMAL
	MasterInput.setMaster(Ref.game)

func _input(event):
	if event.is_action_pressed("ui_up"):
		move(-1)
	elif event.is_action_pressed("ui_down"):
		move(1)
	elif event.is_action_pressed("ui_left"):
		change(-1)
	elif event.is_action_pressed("ui_right"):
		change(1)
	elif event.is_action_released("ui_accept"):
		activate()
	elif event.is_action_released("ui_cancel"):
		Sfx.play("ui_back")
		close()
	get_tree().set_input_as_handled()

func move(direction: int):
	index = posmod(index + direction, ITEMS.size())
	message = ""
	confirmQuit = false
	Sfx.play("ui_move")
	refresh()

func change(direction: int):
	match index:
		FULLSCREEN:
			Settings.setFullscreen(not Settings.fullscreen)
		MUSIC:
			Settings.setMusicVolume(stepVolume(Settings.musicVolume, direction))
		SFX:
			Settings.setSfxVolume(stepVolume(Settings.sfxVolume, direction))
			Sfx.play("pickup")
		EFFECTS:
			Settings.setEffects(not Settings.effects)
		_:
			return
	refresh()

func activate():
	match index:
		RESUME:
			Sfx.play("ui_back")
			close()
		FULLSCREEN:
			Sfx.play("ui_accept")
			change(1)
		CONTROLS:
			Sfx.play("ui_accept")
			close()
			Ref.game.helpMenu.open()
		SAVE:
			Sfx.play("ui_accept")
			Ref.game.saveSystem.saveGame()
			message = "Game saved."
			refresh()
		QUIT:
			# One slip of the finger must not lose the game
			if not confirmQuit:
				confirmQuit = true
				message = "Press Enter again to quit. Unsaved progress is lost."
				Sfx.play("ui_move")
				refresh()
				return
			Sfx.play("ui_accept")
			Fx.clearWarning()
			close()
			get_tree().change_scene("res://scenes/UI/TitleScreen.tscn")
		_:
			change(1)

func stepVolume(value: float, direction: int) -> float:
	return stepify(clamp(value + direction * STEP, 0.0, 1.0), STEP)

func refresh():
	for i in range(ITEMS.size()):
		var text = ITEMS[i]
		match i:
			FULLSCREEN:
				text += ":  " + ("On" if Settings.fullscreen else "Off (windowed)")
			MUSIC:
				text += ":  " + volumeBar(Settings.musicVolume)
			SFX:
				text += ":  " + volumeBar(Settings.sfxVolume)
			EFFECTS:
				text += ":  " + ("On (numbers, flash, shake)" if Settings.effects else "Off")
		rows[i].text = ("> " if i == index else "  ") + text
		rows[i].modulate = Color(1, 0.85, 0.3) if i == index else Color(1, 1, 1)
	hint.text = message if message != "" else "F11 or Alt+Enter: fullscreen"

func volumeBar(value: float) -> String:
	var filled = int(round(value * 10.0))
	return "[" + "#".repeat(filled) + "-".repeat(10 - filled) + "] " + String(int(round(value * 100.0))) + "%"
