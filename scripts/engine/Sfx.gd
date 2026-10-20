extends Node

# Sound effects and music, all made with the SID model in tools/sidsynth.py.
# Sound effects play for the events the game already announces in the diary (the write* names
# in UI.gd), music follows the biome. Volumes come from Settings through two audio buses.

const EVENTS = {
	"writeCharacterStrike": "sword_hit",
	"writeCharacterMiss": "swing_miss",
	"writeMonsterMiss": "swing_miss",
	"writeCharacterTakeHit": "player_hurt",
	"writeMonsterStrike": "player_hurt",
	"writeMonsterTakeHit": "monster_hurt",
	"writeMonsterDie": "monster_death",
	"writePickupLoot": "pickup",
	"writeDoorUnlocked": "unlock",
	"writeChestUnlocked": "unlock",
	"writeLockpickSuccess": "unlock",
	"writeLockpickFailure": "lockpick_fail",
	"writeTriggerTrap": "trap",
	"writeHiddenDoorDetected": "discover",
	"writeHiddenTrapDetected": "discover",
	"writeCastSpell": "spell_cast",
	"writeMonsterCastSpell": "spell_cast",
	"writeQuaffedPotion": "quaff",
	"writeCharacterHeal": "heal",
	"writeLevelUp": "level_up",
	"writeCharacterShoot": "throw",
	"writeMonsterShoot": "throw",
}

# Played directly, they have no diary line
const DIRECT = ["door_open", "chest_open", "player_death", "descend", "ui_move", "ui_accept", "ui_back"]

const MUSIC = ["dungeon", "cavern", "boss"]

const VOICES = 6
const MIN_GAP_MS = 70          # the same sound is not retriggered faster than this
const FADE = 1.2
const SFX_FOLDER = "res://sounds/sfx/"
const MUSIC_FOLDER = "res://sounds/music/"

var cache = {}
var voices = []
var nextVoice = 0
var lastPlayed = {}
var musicPlayers = []
var nextMusic = 0
var currentMusic = ""
var tween: Tween

func _ready():
	for busName in ["Music", "SFX"]:
		if AudioServer.get_bus_index(busName) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, busName)
	for _i in range(VOICES):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		voices.append(player)
	for _i in range(2):
		var player = AudioStreamPlayer.new()
		player.bus = "Music"
		add_child(player)
		musicPlayers.append(player)
	tween = Tween.new()
	add_child(tween)
	applyVolumes()

func applyVolumes():
	setBus("Music", Settings.musicVolume)
	setBus("SFX", Settings.sfxVolume)

func setBus(busName: String, volume: float):
	var idx = AudioServer.get_bus_index(busName)
	AudioServer.set_bus_mute(idx, volume <= 0.0)
	AudioServer.set_bus_volume_db(idx, linear2db(max(volume, 0.0001)))

func playEvent(event: String):
	if EVENTS.has(event):
		play(EVENTS[event])

func play(sound: String):
	# The test harness fakes dice and drives the game headless, keep it silent
	if GeneralEngine.isFaking:
		return
	var now = OS.get_ticks_msec()
	if lastPlayed.has(sound) and now - lastPlayed[sound] < MIN_GAP_MS:
		return
	var stream = getStream(SFX_FOLDER, sound)
	if stream == null:
		return
	lastPlayed[sound] = now
	var player = voices[nextVoice]
	nextVoice = (nextVoice + 1) % VOICES
	player.stream = stream
	player.play()

func playMusic(track: String):
	if GeneralEngine.isFaking or track == currentMusic:
		return
	var stream = getStream(MUSIC_FOLDER, track)
	if stream == null:
		return
	stream.loop = true
	currentMusic = track
	var incoming = musicPlayers[nextMusic]
	nextMusic = (nextMusic + 1) % 2
	var outgoing = musicPlayers[nextMusic]
	incoming.stream = stream
	incoming.volume_db = -60.0
	incoming.play()
	tween.remove_all()
	tween.interpolate_property(incoming, "volume_db", incoming.volume_db, 0.0, FADE)
	tween.interpolate_property(outgoing, "volume_db", outgoing.volume_db, -60.0, FADE)
	tween.start()
	yield(get_tree().create_timer(FADE + 0.1), "timeout")
	if currentMusic == track:
		outgoing.stop()

func stopMusic():
	currentMusic = ""
	for player in musicPlayers:
		tween.interpolate_property(player, "volume_db", player.volume_db, -60.0, FADE)
	tween.start()

func playMusicForBiome(biome: int):
	match biome:
		Data.BIOME_CAVERN:
			playMusic("cavern")
		Data.BIOME_TROLL_BOSS:
			playMusic("boss")
		_:
			playMusic("dungeon")

func getStream(folder: String, sound: String):
	var key = folder + sound
	if not cache.has(key):
		var path = folder + sound + ".ogg"
		cache[key] = load(path) if ResourceLoader.exists(path) else null
	return cache[key]
