extends CanvasLayer

# Small visual feedback so fights feel like something: floating damage numbers, a white flash on
# the sprite that was hit, a short screen shake and a red flash when the player is hurt.
# All of it can be switched off in the options menu (Settings.effects).

const RISE = 70.0
const LIFETIME = 0.8

var font: DynamicFont
var flashRect: ColorRect
var tween: Tween
var levelBase = null
var shaking = false
var strengthNow = 1.0
var lowHealth = false
var warnBars = []
var warnLabel: Label
var warnTime = 0.0

func _ready():
	layer = 60
	font = preload("res://fonts/normalFont.tres").duplicate()
	font.size = 36
	font.outline_size = 3
	font.outline_color = Color(0, 0, 0)
	flashRect = ColorRect.new()
	flashRect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	flashRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flashRect.color = Color(0.8, 0.05, 0.05, 0.0)
	add_child(flashRect)
	tween = Tween.new()
	add_child(tween)
	# A calm pulsing red frame and a short label while health is low
	for anchor in [[0, 0, 1, 0, 0, 14], [0, 1, 1, 1, -14, 0], [0, 0, 0, 1, 0, 14], [1, 0, 1, 1, -14, 0]]:
		var bar = ColorRect.new()
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.color = Color(0.85, 0.1, 0.1, 0.0)
		bar.anchor_left = anchor[0]
		bar.anchor_top = anchor[1]
		bar.anchor_right = anchor[2]
		bar.anchor_bottom = anchor[3]
		if anchor[1] == anchor[3]:
			bar.margin_top = anchor[4]
			bar.margin_bottom = anchor[5]
		else:
			bar.margin_left = anchor[4]
			bar.margin_right = anchor[5]
		add_child(bar)
		warnBars.append(bar)
	warnLabel = Label.new()
	warnLabel.add_font_override("font", font)
	warnLabel.text = "LOW HEALTH"
	warnLabel.modulate = Color(1, 0.35, 0.35, 0.0)
	warnLabel.anchor_left = 0.5
	warnLabel.anchor_right = 0.5
	warnLabel.margin_left = -120
	warnLabel.margin_right = 120
	warnLabel.margin_top = 12
	warnLabel.align = Label.ALIGN_CENTER
	add_child(warnLabel)
	set_process(false)

func isOn() -> bool:
	return Settings.effects and not GeneralEngine.isFaking

# A monster or an ally took damage
func hit(entity, amount: int):
	if not isOn() or not is_instance_valid(entity):
		return
	number(entity, str(amount), Color(1, 1, 1))
	flash(entity)

# The player took damage
func hurt(entity, amount: int):
	if not isOn():
		return
	number(entity, str(amount), Color(1, 0.3, 0.3))
	flash(entity)
	shake(0.9, 0.25)
	tween.interpolate_property(flashRect, "color:a", 0.35, 0.0, 0.35)
	tween.start()

func heal(entity, amount: int):
	if not isOn() or amount <= 0:
		return
	number(entity, "+" + str(amount), Color(0.4, 1, 0.5))

func number(entity, text: String, color: Color):
	var label = Label.new()
	label.add_font_override("font", font)
	label.text = text
	label.modulate = color
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The map is scaled, so convert the entity's cell into screen coordinates. The cell is used
	# instead of the sprite position, which lags behind while the sprite slides to its new cell
	var origin = Ref.currentLevel.get_global_transform_with_canvas().xform(entity.pos * 9.0)
	label.rect_position = origin + Vector2(10 + randi() % 20, -30)
	add_child(label)
	var t = Tween.new()
	label.add_child(t)
	t.interpolate_property(label, "rect_position:y", label.rect_position.y, label.rect_position.y - RISE, LIFETIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	t.interpolate_property(label, "modulate:a", 1.0, 0.0, LIFETIME * 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, LIFETIME * 0.5)
	t.start()
	yield(get_tree().create_timer(LIFETIME + 0.05), "timeout")
	if is_instance_valid(label):
		label.queue_free()

func flash(entity):
	var sprite = entity.get_node_or_null("BodySprite")
	if sprite == null:
		return
	sprite.modulate = Color(3, 3, 3)
	tween.interpolate_property(sprite, "modulate", Color(3, 3, 3), Color(1, 1, 1), 0.18)
	tween.start()

func shake(strength: float, duration: float):
	if not isOn() or shaking or Ref.currentLevel == null:
		return
	shaking = true
	strengthNow = strength
	if levelBase == null:
		levelBase = Ref.currentLevel.position
	tween.interpolate_method(self, "shakeStep", 1.0, 0.0, duration)
	tween.interpolate_callback(self, duration, "shakeDone")
	tween.start()

func shakeStep(amount: float):
	Ref.currentLevel.position = levelBase + Vector2(rand_range(-1, 1), rand_range(-1, 1)) * strengthNow * amount

func shakeDone():
	Ref.currentLevel.position = levelBase
	shaking = false

# Called whenever the player's hit points change (Stats.updateHp)
func refreshHealth():
	if Ref.character == null or Ref.character.stats == null:
		return
	var low = Settings.effects and Ref.character.stats.hp > 0 and Ref.character.stats.hpPercent() < 0.3
	setWarning(low)

func setWarning(on: bool):
	if on == lowHealth:
		return
	lowHealth = on
	set_process(on)
	if on:
		Sfx.play("low_hp")
		warnTime = 0.0
	else:
		for bar in warnBars:
			bar.color.a = 0.0
		warnLabel.modulate.a = 0.0

func clearWarning():
	setWarning(false)

func _process(delta):
	warnTime += delta
	var pulse = 0.5 + 0.5 * sin(warnTime * 2.6)
	for bar in warnBars:
		bar.color.a = 0.18 + 0.32 * pulse
	warnLabel.modulate.a = 0.45 + 0.5 * pulse
