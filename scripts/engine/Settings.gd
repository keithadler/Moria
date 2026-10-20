extends Node

# Player settings, kept in user:// so they survive between runs.
# Fullscreen can be toggled with F11 or Alt+Enter, everything else is in the options menu (Esc).

const PATH = "user://settings.cfg"
const WINDOW_SIZE = Vector2(1280, 720)

var fullscreen: bool = false
var effects: bool = true
var musicVolume: float = 0.4
var sfxVolume: float = 0.8

func _ready():
	loadSettings()
	applyWindow()

func _input(event):
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var isAltEnter = event.alt and (event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER)
	if event.scancode == KEY_F11 or isAltEnter:
		get_tree().set_input_as_handled()
		setFullscreen(not fullscreen)

func loadSettings():
	var file = ConfigFile.new()
	if file.load(PATH) != OK:
		return
	fullscreen = bool(file.get_value("display", "fullscreen", fullscreen))
	effects = bool(file.get_value("display", "effects", effects))
	musicVolume = clamp(float(file.get_value("audio", "music", musicVolume)), 0.0, 1.0)
	sfxVolume = clamp(float(file.get_value("audio", "sfx", sfxVolume)), 0.0, 1.0)

func saveSettings():
	var file = ConfigFile.new()
	file.set_value("display", "fullscreen", fullscreen)
	file.set_value("display", "effects", effects)
	file.set_value("audio", "music", musicVolume)
	file.set_value("audio", "sfx", sfxVolume)
	file.save(PATH)

func setFullscreen(value: bool):
	fullscreen = value
	applyWindow()
	saveSettings()

func setEffects(value: bool):
	effects = value
	saveSettings()

func setMusicVolume(value: float):
	musicVolume = clamp(value, 0.0, 1.0)
	Sfx.applyVolumes()
	saveSettings()

func setSfxVolume(value: float):
	sfxVolume = clamp(value, 0.0, 1.0)
	Sfx.applyVolumes()
	saveSettings()

# The game draws at 1920x1080 and the stretch mode scales it, so a window of any size works
func applyWindow():
	OS.window_fullscreen = fullscreen
	if fullscreen:
		return
	OS.window_borderless = false
	OS.window_resizable = true
	var screen = OS.get_screen_size()
	var factor = min(1.0, min(screen.x * 0.9 / WINDOW_SIZE.x, screen.y * 0.85 / WINDOW_SIZE.y))
	OS.window_size = WINDOW_SIZE * factor
	OS.center_window()
