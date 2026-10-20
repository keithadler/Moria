# Moria: player manual

You are an adventurer going down through a dungeon that is generated again for every run. You explore, fight,
loot, and keep going until you die or reach the end. There is no going back up.

## The title screen

- **New game** starts a run.
- **Load game** continues a saved game. With several saves it shows a list, newest first.
- **Options** has fullscreen, the volumes and the screen effects switch.
- **Morgue** lists your finished runs: character, floor, level, enemies slain, what killed you and when.
- **Manual** is this manual.
- **Exit** closes the game.

## Starting

1. Choose a class (arrow keys, Enter).
2. Type a name.
3. Choose your first feats and spells if your class has any.

| Class | Starts with | Good at |
|---|---|---|
| Fighter | 10 HP | Combat, armor, physics |
| Paladin | 10 HP | Combat, armor, willpower, divine spells |
| Ranger | 10 HP | Combat, physics, perception, nature spells |
| Thief | 8 HP | Combat, perception, thievery |
| Bard | 8 HP | Enchantment, willpower, thievery |
| Cleric | 8 HP | Evocation, willpower, divine spells |
| Druid | 8 HP | Divination, abjuration, perception, nature spells |
| Mage | 6 HP | Evocation, willpower |

Each class starts with its own kit of weapon, armor, potions and a few other items.

## The screen

- **The map** in the middle. You only see what is near you and in line of sight. Floors are bigger than the
  screen, the view scrolls with you.
- **The log** at the bottom left tells you what happens, turn by turn.
- **The side panel** on the right: level and experience, **HP** (health), **Stam** (stamina), **CA** (armor class,
  how hard you are to hit), **Prot** (damage taken off every hit), **Dmg** and **Hit** (your weapon's damage dice and your attack roll), **Lock**
  (lockpicks), **Gold**, and your resistances.
- A red frame and the words LOW HEALTH appear when you are under 30% health.

## Controls

The game shows the real list on the **H** screen. The usual ones:

| Key | Does |
|---|---|
| Arrow keys | Move one step, walk into an enemy to attack it. **Hold** a key to keep walking (it stops at walls, doors, items and when an enemy is in view) |
| Left click | Walk to a visible cell (stops if an enemy appears) |
| S | Search for hidden doors and traps around you |
| P | Pick up loot under you |
| I | Inventory (equip, wear, drop) |
| K | Character sheet (spend skill points and feats) |
| M / C | Spell list / cast a spell |
| A | Drink a potion |
| R | Read a scroll |
| T | Throw a knife, axe, bomb... |
| D | Drop an item |
| Z | Rest |
| O | Auto-explore (any key stops it) |
| Q | Give an item a quick slot, then press 1 to 0 to use it |
| F1 / F5 | Save / load |
| Esc | Options menu |
| F11 or Alt+Enter | Fullscreen |
| H | Controls |
| L | Message history (scroll back through the log) |
| F12 | Save a screenshot |

## Gamepad

D-pad or left stick move (hold to keep walking), A confirms, B or Start goes back and opens the menu, X picks up,
Y opens the inventory, LB the character sheet, RB searches, Select the map. Left trigger drinks a potion and
right trigger casts a spell.

## Exploring

- Doors open when you walk into them. Some are **locked** and need a lockpick (you can fail, and picks run out).
- **Hidden doors and traps** are found by searching (S), and sometimes by luck as you walk. Searching costs a turn.
- **Chests** hold loot. Some are locked and need lockpicks.
- **Stairs**: the game asks if you want to go to the next floor. After you do, a shadow force blocks the way back.
  The game saves for you on every new floor, and when you close the window. The next floor's title card tells
  you what you did on the last one.
- **Gold and lockpicks** are picked up when you walk onto them.
- **Seeds**: every run has a seed (Esc shows it). Start the game with `--seed=12345` to play the same dungeon
  again, or `--seed=daily` for the one everybody gets that day.
- **Merchants** sell things for gold.
- Floors are 10 deep in the dungeon, then 10 in the caverns, then a floor with a troll. Past the troll the dungeon
  starts again, harder.

## Fighting

- Monsters are asleep until they come into your view, then they wake up and come for you.
- Armor class (CA) decides if you get hit, Prot reduces the damage that gets through. A hit always does at least 1.
- Fighting, casting and searching spend stamina (Stam).
- Monsters will also attack the creatures you summon, not only you.
- Killing monsters gives experience. A level up gives **skill points** and **feat points**: open the character
  sheet (K) to spend them.

## Magic, scrolls and potions

- Spells come in schools: Evocation, Enchantment, Divination, Abjuration and Conjuration. Your class decides
  which school you are good at and which spell list you use (arcane, divine or nature).
- A spell has a few uses until you rest.
- Scrolls are single-use spells and potions are drunk once. Both are listed in your inventory.
- Throwing items (knives, axes, javelins, bombs, holy water) hit from a distance. Pick a target with the left and
  right arrow keys, Enter to throw, Esc to cancel.

## Resting

You start with **2 rests**. Resting (Z) restores your health, stamina and spell uses and clears statuses, but it
sends your summoned allies away, and you cannot rest while hostile creatures are on the floor.

## Death

When your health reaches zero the game shows what killed you and how far you got (floor, level, enemies slain, turns,
gold), adds the run to the **Morgue**, and returns to the title screen. Your last save is still there: choose
**Load game** on the title screen.

## Options (Esc)

Fullscreen, music volume, sound effects volume, screen effects (damage numbers, hit flash, screen shake, low health
frame: turn them off if you prefer calm), controls, save, and quit to title (asks twice).
