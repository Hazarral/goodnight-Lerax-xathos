# Goodnight, Lerax-xathos

## Overview (Short)
This is a turn-based, text-based fantasy RPG where you are a Warlock of Death looking to kill a parasitic eldritch god.

**NOTE**: The game is not exported to a build yet, only played in the editor right now.

In more details, you are The Drächen (also spelled Draechen), a male dragon, a Warlock of Death, and Evernight's lover. Evernight is the Primordial Void, Death, The Axiom of Loss, he goes by many names. Your enemy is Lerax-xathos die Traumpest (aka The Plague of Dreams), who has been tainting 8 worlds. You only have 7 days to live initially, but killing will grant you more time, and there is a 1 centillion years reward from Evernight on slaying Lerax-xathos.

## Pitch (Text trailer, basically)
You are The Drächen, a proud, old, battle-hardened dragon, who soars the sky as well as he scales mountains with his strides.

You have long abandoned your name, as your new name is given to you by your dear Patron and lover: Evernight, Death, The Primordial Void.

And you are his Warlock of Death.

As a natural perk, you are told about the moment you'd die. That moment draws near, only 7 days left. 7 days left, after undecillions of eons. And yet, Evernight has told you one thing.

"Mein Drächen, how many dreams can you recount?"

"Seven million," you respond.

"And how many nightmares?"

"Two hundred thirty five," you remember very well.

"Lerax-xathos die Traumpest has come to plague several worlds, he has ruined some of the finest charred cheese of World With No Name and viruous ice cream of Eranian Levoticus. You do not know them, but I frequently descend upon those realms."

You watch him.

"And my dear, would you be so kind as to clean up this little pest for me? A feast, I'd say, to add more to your mortal time. And perhaps, at the end, I can prepare a gift for you. One centillion years, how about it? And a special good time, one that lasts days. But first, chew his eyes in Folasso."

And so, you set off to chase Lerax-xathos die Traumpest, crossing paths with 8 worlds tainted by him, before confronting him in Folasso. A new chapter awaits you, and your darling does not let you go unprepared. He has introduced a little about the 8 worlds:
- World With No Name (Fire): The God of Fire and Ash slumbers, the world plummeted into Eternal Fire, and The tragic God of Lust and Flesh seeks to spread eternal bliss.
- Vasseon (Water): The Rain falls upon the world, granting wishes as it mutates the physical form of its receivers, and the strange Prophets are chosen by The Rain to seek the center of this blessing.
- The Meadows Out of Time (Wind): The demon Remeny Maelstrom has expanded his theatrical stage upon the whole realm, putting everyone behind a mask, all to slay and defile him, The Ravenous Storm.
- EAX-7228 (Lightning): A technocratic world like any other under The Rena Corporation. The artificial sun has been snuffed out, a relentless magnetic storm in the land where machine and flesh have long merged.
- Sia (Poison): the exalted forests have withered as the air reeks of The Heraticans and gluttonous fungi, seeking to breed more spores to all life, a reminiscence of an endlessly sprouting pre-Void era.
- Denos En (Physical): The favorite beast of Depths, B'urlyth, has gone feral. It swarms the world with its spawns, with strange mating rituals and breed more armies to assimilate all that are different in search of a bloody hivemind of unity. 
- Grierfard (Earth): The infinite caverns and tunnels have collapsed as Mother Earth herself is in torment by her nightmares. The soil is your nemesis, Darkness, Havador, is your ally, as the white sun on the surface now turns all to ashes.
- Eranian Veloticus (Ice): The elusive secret organization of Strange Society has announced its own presence, stepping from the shadows as the world faces an eternal blizzard. An "artist", an exhibitionist artist who obsess over death, has come to paint the white snow in new shades.

And at the end of your journey, a crude mockery of Nonexistence: Folasso, the home of the Plague of Dreams, die Traumpest. There, Lerax-xathos cowers in fear, as he is nothing more than a parasite.

There, you shall wish him, "Goodnight, Lerax-xathos"

## Features
Combat 1.0:
- 8 Elements as damage type: Fire, Water, Wind, Poison, Lightning, Physical, Earth, Ice
- 8 elemental DoT: Burn, Current, Wind Shear, Poison, Shock, Bleed, Crumble, Frostbite. Every DoT has a special effect (TODO: will be documented)
- Void damage type
- Void DoT (just raw infinitely scaling damage per turn)
- Shield Cascade: the core of the combat, where if a shield of matching element exists on the target you hit that shield for 100% damage before hitting Health on shield depletion. If the element you use has no matching shield, it deals 50% damage to shield and must chew through all shields before hitting Health.
- Heal: the ability to recover Health exists
- Action Points economy: everyone has some maximum action points, and all actions cost 0 or more action points. The action point (AP) regeneration rate of each entity is different
- Combat logging: 3 modes (basic, advanced, developer) with an option to export raw text and parsed text to machine.

## Upcoming features
- Status effects
- Buffs and debuffs (Stat modifiers, though the code says BuffAndDebuff)
- Actual encounters and content (enemies, recruits, actions)
- Runes (Will be considered, they are implemented as status effects or stat modifiers)
