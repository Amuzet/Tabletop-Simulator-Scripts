--[[  9898-MTG-Design-Draft-Card-Generator  ]]

local Display=[[ [b]MTG Design Generator[/b][i]

Template text
It's Center Justified
Type anything here in the script
]]
local Prefix,Suffix='Design a ','.'

local Randomizer={
--This is the list of possible Outputs
['output_list']=[[
 [Defn_Card] card, which either [Card_with] or [Card_with].
 [Defn_Card] card or [Defn_Card] card, either which [Card_with].
 [Defn_Card] card, or a card which [Card_with].
 [Defn_Card] card or [Defn_Card] card.
 [Defn_Card] card which [Card_with].
 [Defn_Card] card.
 card which [Card_with].
 card with "[output_card_text_full]."
 card flavored: [Flavored_with]
]],
--[[User made Randomizers
 any User made will class will be replaced regardless of Square Brackets []
 Generated text will strip out all Square Brackets, so text is not bcode safe
 output_card_name give a random two-four word name
]]
['Defn_Card']=[[
 hybrid
 mono color
 [card_colors]
 [card_colors] multicolored
 [card_colors] multicolored [card_types]
 [card_types]
 [output_cardtype_subtype]
 [output_card_subtype_artifact]
 [output_card_subtype_enchantment]
 [output_card_subtype_basic_land]
 [output_card_subtype_nonbasic_land]
 planeswalker [output_card_subtype_planeswalker] flavored
 [output_card_subtype_instant]
 [output_card_subtype_sorcery]
 [output_card_subtype_creature]
 [output_card_rarity]
 [output_game_zones] matters
 [output_card_power_toughness] creature
 [output_card_text_keyword_ability]
]],
['Card_with']=[[
 is from the plane [output_card_subtype_plane]
 has a win condition
 has a new keyword action
 has "[output_card_text_full]."
 has [output_card_text_keyword_action]
 has [output_card_text_keyword_ability]
 has a [mana_generated] or [mana_generated] cost on it
 has a [mana_symbol] symbol in its casting cost
 has a [mana_symbol] symbol
 has 1d3+1 different mana symbols
 creates a 2d3-2/2d3-1 [card_colors] [output_card_subtype_creature] creature token
 cares about [short_A]
 cares about [short_B]
 cares about [card_cares]
 cares about [output_game_zones]
 cares about [whomst] [output_game_zones]
 cares about [card_colors]
 Counjures1d{ ;a duplicate}1d{ ;[whomst] [output_game_zones];a [output_game_zones]}
]],

['output_card_text_full']=[[
 [output_card_text_keys]
 [output_card_text_keyword_action]
 [output_card_text_keyword_ability]
 [output_card_text_keyword_action], [output_card_text_keyword_ability]
 When ~this dies, [output_card_text_keys]
 When ~this enters the battlefield, [output_card_text_keys]
 Whenever ~this enters the battlefield or attacks, [output_card_text_keys]
 Whenever a card from [output_game_zones] is put into [output_game_zones], [output_card_text_keyword_action]
 Whenever ~this card is put into the [output_game_zones] zone, [output_card_text_keyword_action] target 1d{[output_card_type];[output_cardtype_subtype]}
 Whenever ~this deals damage to a player, [output_card_text_keys]
 Whenever ~this deals damage to a player, create a token thats a copy of ~this.
 Whenever ~this deals damage to a player, exile target 1d{[output_card_type];[output_card_subtype]}
 Whenever [whomst] [output_card_text_keys], [output_card_text_keys]
 Whenever [whomst] lose life, create a 1/1 [card_colors] [output_card_subtype_creature] creature token
 Whenever [whomst] gain life, create a 1/1 [card_colors] [output_card_subtype_creature] creature token
 [whomst] roll a die, create a X/X [card_colors] [output_card_subtype_creature] creature token where X equals the result of the die roll
 Whenever this deals damage, create a 1/1 [card_colors] [output_card_subtype_creature] creature token
 You get a Boon with 1d{"When you cast your next creature spell, that creature enters the battlefield with an additional +1/+1 counter, reach counter, and trample counter on it;"When you cast your next creature spell, that creature enters the battlefield with a +1/+1 counter on it;"When you cast your next creature spell, that creature enters the battlefield with your choice of a +1/+1 counter, a flying counter, or a lifelink counter on it;“When you cast your next creature spell, it perpetually gets +X/+0, where X is the power of your last creature that died;"When you cast your next creature spell, it perpetually gets +1/+0;“When you cast your next creature spell without flying, it perpetually gains flying;“When you cast your next creature spell, it perpetually gets +X/+0, where X is your last excess damage dealt;“When you cast your next creature spell, it perpetually gets +2/+0}
]],

['short_B']='{[card_types];[output_cardtype_subtype];[output_card_rarity];[output_card_text_keyword_action];[output_card_text_keyword_ability];[output_game_zones] matters;[output_card_power_toughness]}',
['short_A']='{[card_types];[output_cardtype_subtype];[output_card_rarity];[output_card_text_keyword_action];[output_card_text_keyword_ability]}',
['whomst']=[[{your;target player's;an opponent's;each opponent's;each player's}]],
--['card_types']='{Basic;Boon;NonBasic;Legendary;Snow;Token;Tribal;World;Conspiracy;Creature;Artifact;Artifact Creature;Artifact Land;Enchantment;Enchantment Creature;Instant;Sorcery;Land;Planeswalker;Emblem;Phenemonom;Plane;Dungeon;Scheme;Vanguard}',
['card_cares']='{Basic;NonBasic;Legendary;Snow;Token;Tribal;World;Conspiracy;Creature;Artifact;Artifact Creature;Enchantment;Enchantment Creature;Instant;Sorcery;Land;Planeswalker;Emblem;Phenemonom;Plane;Dungeon;Scheme}',
['card_types']='{Legendary;Snow;Tribal;World;Conspiracy;Creature;Artifact;Artifact Creature;Artifact Land;Enchantment;Enchantment Creature;Instant;Sorcery;Land;Planeswalker;Phenemonom;Plane;Scheme;Vanguard}',
['card_colors']='{White;Blue;Black;Red;Green;Colorless}',
['mana_symbol']='{X;Colorless;Snow;Hybrid;2/Brid;Tribrid;Phyrexian;2d3-1}',
['mana_cost']='{[card_colors];[mana_symbol]}',
['mana_generated']='[mana_symbol]2D2-1e{;W;U;B;R;G}',
--['output_card_set_code']='RAZRAZRAZ',
['output_card_rarity']='{Common;Uncommon;Rare;Mythic Rare}',
['output_card_power_toughness']='1d13-1/1d12',

['output_cardtype_subtype']=[[
 [output_card_subtype_artifact]
 [output_card_subtype_enchantment]
 [output_card_subtype_basic_land]
 [output_card_subtype_nonbasic_land]
 [output_card_subtype_planeswalker]
 [output_card_subtype_instant]
 [output_card_subtype_sorcery]
 [output_card_subtype_creature]
]],
['output_card_text_keys']='{[output_card_text_keyword_action];[output_card_text_keyword_ability];[output_card_text_keyword_action], [output_card_text_keyword_ability]}',


--[[
 [output_card_subtype_plane]
 [output_cardtype_subtype_dungeon]
 [output_cardtype_subtype_scheme]
 [output_cardtype_subtype_vanguard]
['output_cardtype_subtype_dungeon']='Dungeon',
['output_cardtype_subtype_scheme']='Scheme',
['output_cardtype_subtype_vanguard']='Vanguard',
]]
['output_card_subtype_artifact']=[[
 Blood
 Clue
 Contraption
 Equipment
 Food
 Fortification
 Gold
 Powerstone
 Treasure
 Vehicle
]],
['output_card_subtype_enchantment']=[[
 Aura
 Background
 Cartouche
 Class
 Curse
 Rune
 Saga
 Shard
 Shrine
]],
['output_card_subtype_basic_land']=[[
 Plains
 Island
 Swamp
 Mountain
 Forest
]],
['output_card_subtype_nonbasic_land']=[[
 Desert
 Gate
 Lair
 Locus
 Mine
 Power-Plant
 Tower
 Urza’s
]],
['output_card_subtype_planeswalker']=[[
 Ajani
 Aminatou
 Angrath
 Arlinn
 Ashiok
 Bahamut
 Basri
 Bolas
 Calix
 Chandra
 Dack
 Dakkon
 Daretti
 Davriel
 Dihada
 Domri
 Dovin
 Ellywick
 Elminster
 Elspeth
 Estrid
 Freyalise
 Garruk
 Gideon
 Grist
 Huatli
 Jace
 Jaya
 Jeska
 Kaito
 Karn
 Kasmina
 Kaya
 Kiora
 Koth
 Liliana
 Lolth
 Lukka
 Minsc
 Mordenkainen
 Nahiri
 Narset
 Niko
 Nissa
 Nixilis
 Oko
 Ral
 Rowan
 Saheeli
 Samut
 Sarkhan
 Serra
 Sivitri
 Sorin
 Szat
 Tamiyo
 Tasha
 Teferi
 Teyo
 Tezzeret
 Tibalt
 Tyvar
 Ugin
 Venser
 Vivien
 Vraska
 Will
 Windgrace
 Wrenn
 Xenagos
 Yanggu
 Yanling
 Zariel
]],
['output_card_subtype_instant']=[[
 Adventure
 Arcane
 Lesson
 Trap
]],
['output_card_subtype_sorcery']=[[
 Adventure
 Arcane
 Lesson
 Trap
]],
['output_card_subtype_creature']=[[
 Advisor
 Aetherborn
 Ally
 Angel
 Antelope
 Ape
 Archer
 Archon
 Army
 Artificer
 Assassin
 Assembly-Worker
 Atog
 Aurochs
 Avatar
 Azra
 Badger
 Barbarian
 Bard
 Basilisk
 Bat
 Bear
 Beast
 Beeble
 Beholder
 Berserker
 Bird
 Blinkmoth
 Boar
 Bringer
 Brushwagg
 Camarid
 Camel
 Caribou
 Carrier
 Cat
 Centaur
 Cephalid
 Chimera
 Citizen
 Cleric
 Cockatrice
 Construct
 Coward
 Crab
 Crocodile
 Cyclops
 Dauthi
 Demigod
 Demon
 Deserter
 Devil
 Dinosaur
 Djinn
 Dog
 Dragon
 Drake
 Dreadnought
 Drone
 Druid
 Dryad
 Dwarf
 Efreet
 Egg
 Elder
 Eldrazi
 Elemental
 Elephant
 Elf
 Elk
 Eye
 Faerie
 Ferret
 Fish
 Flagbearer
 Fox
 Fractal
 Frog
 Fungus
 Gargoyle
 Germ
 Giant
 Gith
 Gnoll
 Gnome
 Goat
 Goblin
 God
 Golem
 Gorgon
 Graveborn
 Gremlin
 Griffin
 Hag
 Halfling
 Hamster
 Harpy
 Hellion
 Hippo
 Hippogriff
 Homarid
 Homunculus
 Horror
 Horse
 Human
 Hydra
 Hyena
 Illusion
 Imp
 Incarnation
 Inkling
 Insect
 Jackal
 Jellyfish
 Juggernaut
 Kavu
 Kirin
 Kithkin
 Knight
 Kobold
 Kor
 Kraken
 Lamia
 Lammasu
 Leech
 Leviathan
 Lhurgoyf
 Licid
 Lizard
 Manticore
 Masticore
 Mercenary
 Merfolk
 Metathran
 Minion
 Minotaur
 Mole
 Monger
 Mongoose
 Monk
 Monkey
 Moonfolk
 Mouse
 Mutant
 Myr
 Mystic
 Naga
 Nautilus
 Nephilim
 Nightmare
 Nightstalker
 Ninja
 Noble
 Noggle
 Nomad
 Nymph
 Octopus
 Ogre
 Ooze
 Orb
 Orc
 Orgg
 Otter
 Ouphe
 Ox
 Oyster
 Pangolin
 Peasant
 Pegasus
 Pentavite
 Pest
 Phelddagrif
 Phoenix
 Phyrexian
 Pilot
 Pincher
 Pirate
 Plant
 Praetor
 Prism
 Processor
 Rabbit
 Raccoon
 Ranger
 Rat
 Rebel
 Reflection
 Rhino
 Rigger
 Rogue
 Sable
 Salamander
 Samurai
 Sand
 Saproling
 Satyr
 Scarecrow
 Scion
 Scorpion
 Scout
 Sculpture
 Serf
 Serpent
 Servo
 Shade
 Shaman
 Shapeshifter
 Shark
 Sheep
 Siren
 Skeleton
 Slith
 Sliver
 Slug
 Snake
 Soldier
 Soltari
 Spawn
 Specter
 Spellshaper
 Sphinx
 Spider
 Spike
 Spirit
 Splinter
 Sponge
 Squid
 Squirrel
 Starfish
 Surrakar
 Survivor
 Tentacle
 Tetravite
 Thalakos
 Thopter
 Thrull
 Tiefling
 Treefolk
 Trilobite
 Triskelavite
 Troll
 Turtle
 Unicorn
 Vampire
 Vedalken
 Viashino
 Volver
 Wall
 Walrus
 Warlock
 Warrior
 Weird
 Werewolf
 Whale
 Wizard
 Wolf
 Wolverine
 Wombat
 Worm
 Wraith
 Wurm
 Yeti
 Zombie
 Zubera
]],
['output_card_subtype_plane']=[[
 Alara
 Arkhos
 Azgol
 Belenon
 Bolas’s Meditation Realm
 Dominaria
 Equilor
 Ergamon
 Fabacin
 Innistrad
 Iquatana
 Ir
 Kaldheim
 Kamigawa
 Karsus
 Kephalai
 Kinshala
 Kolbahan
 Kyneth
 Lorwyn
 Luvion
 Mercadia
 Mirrodin
 Moag
 Mongseng
 Muraganda
 New Phyrexia
 Phyrexia
 Pyrulea
 Rabiah
 Rath
 Ravnica
 Regatha
 Segovia
 Serra’s Realm
 Shadowmoor
 Shandalar
 Ulgrotha
 Valla
 Vryn
 Wildfire
 Xerex
 Zendikar
]],

['output_card_text_keyword_action']=[[
 Abandon
 Activate
 Adapt
 Amass
 Assemble
 Attach
 Bolster
 Cast
 Clash
 Conjure (A conjured card is added to the game.)
 Connive
 Counter
 Design
 Destroy
 Detain
 Discard
 Double
 Double team
 Draft
 Exchange
 Exert
 Exile
 Explore
 Fateseal
 Fight
 Goad
 Intensity (Starts at a certain value and will perpetually change based on the card's rules text)
 Investigate
 Learn
 Manifest
 Meld
 Mill
 Monstrosity
 Note
 Planeswalk
 Play
 Populate
 Proliferate
 Regenerate
 Reveal
 Sacrifice
 Scry
 Search
 Seek (To seek a card, put one at random from your library into your hand.)
 Set in Motion
 Shuffle
 Support
 Surveil
 Tap
 Transform
 Untap
 Venture into the Dungeon
 Vote
]],
['output_card_text_keyword_ability']='Deathtouch;Defender;Double Strike;Enchant;Equip;First Strike;Flash;Flying;Haste;Hexproof;Indestructible;Intimidate;Landwalk;Lifelink;Protection;Reach;Shroud;Trample;Vigilance;Ward;Banding;Rampage;Cumulative Upkeep;Flanking;Phasing;Buyback;Shadow;Cycling;Echo;Horsemanship;Fading;Kicker;Flashback;Madness;Fear;Morph;Amplify;Provoke;Storm;Affinity;Entwine;Modular;Sunburst;Bushido;Soulshift;Splice;Offering;Ninjutsu;Epic;Convoke;Dredge;Transmute;Bloodthirst;Haunt;Replicate;Forecast;Graft;Recover;Ripple;Specialize;Split Second;Suspend;Vanishing;Absorb;Aura Swap;Delve;Fortify;Frenzy;Gravestorm;Poisonous;Transfigure;Champion;Changeling;Evoke;Hideaway;Prowl;Reinforce;Conspire;Persist;Wither;Retrace;Devour;Exalted;Unearth;Cascade;Annihilator;Level Up;Rebound;Totem Armor;Infect;Battle Cry;Living Weapon;Undying;Miracle;Soulbond;Overload;Scavenge;Unleash;Cipher;Evolve;Extort;Fuse;Bestow;Tribute;Dethrone;Hidden Agenda;Outlast;Prowess;Dash;Exploit;Menace;Renown;Awaken;Devoid;Ingest;Myriad;Surge;Skulk;Emerge;Escalate;Melee;Crew;Fabricate;Partner;Undaunted;Improvise;Aftermath;Embalm;Eternalize;Afflict;Ascend;Assist;Jump-Start;Mentor;Afterlife;Riot;Spectacle;Escape;Companion;Mutate;Encore;Boast;Foretell;Demonstrate;Daybound;Nightbound;Disturb;Decayed;Cleave;Training;Compleated;Reconfigure;Blitz;Casualty;Enlist;Read Ahead;Backbone (This creature assigns combat damage equal to its toughness instead of its power.);Boon (A card with they stated criteria given with Boon as the card type.);Conjure;Draft;Doubleteam;Intensity;Perpetually (Perpetual effects and counters are not removed from cards that change zones.);Seek;Spellbook;Specialize;Unstoppable',
['output_game_zones']=[[
  Battlefield
  Command Zone
  Exile
  Graveyard
  Hand
  Library
  Outside the game
  Sideboard
  Spellbook (A card’s spellbook is a curated list of up to 15 associated, flavor-resonant cards.)
  Stack
]],
['output_card_name']=[[
  1D{[LISTadjective];[LISTverb]} 1D{[LISTword];[LISTnoun]}
  [LISTadjective] [LISTverb] 1D{[LISTword];[LISTnoun]}
  1D{[LISTadjective];[LISTverb]} [LISTword] [LISTnoun]
  [LISTadjective] [LISTverb] [LISTword] [LISTnoun]
]],
['Flavored_with']='{[LISTlong];[output_card_name];[output_card_name]}',

['choose_ammount']=[[{[card_types];[output_cardtype_subtype]} card with {two;three} of the following
  • [LISTnouns]
  • [LISTverb]
  • [LISTadjective]
  • [LISTadverb]
  • [LISTpronoun]
  • [LISTpreposition]
  • [output_card_name]
]],
--LIST@11/20/2022
['LISTword']='{[LISTnouns];demonstrate;understanding;vertical;expression;depression;refrigerator;video;compromise;motivation;auditor;intelligence;correspondence;reaction;friend;awful;overlook;context;quarrel;committee;terrace;pocket;chapter;disco;queen;investment}',
['LISTnouns']='{teacher;recording;collection;world;marriage;fact;injury;control;steak;player;republic;debt;agreement;stranger;property;ear;relation;exam;foundation;garbage;mode;wealth;union;measurement;recommendation;resolution;information;philosophy;examination;republic;society;industry;conclusion;addition;decision;grandmother;perspective;education;variety;relationship;inspector;security;refrigerator;recording;attention;competition;revolution;appointment;distribution}',
['LISTverb']='{invest;dare;justify;transmit;propose;penetrate;suggest;die;burst;race;rush;disappear;breed;register;discover;introduce;regulate;communicate;penetrate;allocate;estimate;realize;multiply;attribute;differentiate;organise;conceive;descend;compile;fine;register;remark;maintain;light;greet;campaign;protect;flood;encounter;advocate;supply;risk;sail;boil;evaluate;facilitate;pass;blossom;defend;lack;lose;intervene}',
['LISTadjective']='{rebel;disgusting;cruel;gusty;trite;tender;severe;snobbish;understood;quarrelsome;crowded;quizzical;overt;earthy;regular;electronic;wrong;chivalrous;aquatic;majestic;quickest;nimble;long-term;purple;lacking;wrathful;gaping;spiky;momentous;receptive;immediate;romantic;peaceful;green;truthful;grey;unsuitable;late;pointless;homeless;plucky;brave;false;abrupt;sweltering;boring;absent;thirsty;comprehensive;regular;endurable;obviously}',
['LISTadverb']='{meaningfully;dearly;speedily;usually;partially;kiddingly;noisily;yearningly;cleverly;vastly;wrongly;suddenly;generously;reproachfully;intensely;exactly;mockingly;loudly;absentmindedly;especially;then;repeatedly;frankly;upbeat;wetly;certainly}',
['LISTpronoun']='{my;mine;his;her;its;our;their;theirs;your;yours;I;me;you;him;he;it;she;her;we;us;they;them;you}';
['LISTpreposition']='{beneath;versus;via;round;through;against;unlike;outside;after;per;from;than;amid;minus;beside;with;following;save;excluding;outside;aboard;underneath;versus;inside;on;opposite}',
['LISTlong']='{[LISTquestion];[LISTquotes];[LISTflavor]}',
['LISTrndSent']=[[
 He found a leprechaun in his walnut shell.
 He dreamed of eating green apples with worms.
 A kangaroo is really just a rabbit on steroids.
 It must be easy to commit crimes as a snake because you don't have to worry about leaving fingerprints.
 Art doesn't have to be intentional.
 The tumbleweed refused to tumble but was more than willing to prance.
 Imagine his surprise when he discovered that the safe was full of pudding.
 The water flowing down the river didn’t look that powerful from the car
 I was starting to worry that my pet turtle could tell what I was thinking.
 For oil spots on the floor, nothing beats parking a motorbike in the lounge.
 Joyce enjoyed eating pancakes with ketchup.
 The snow-covered path was no help in finding his way out of the back-country.
 He kept telling himself that one day it would all somehow make sense.
 It had been sixteen days since the zombies first attacked.
]],
['LISTquestion']=[[
 What would be the best and worst part of being a cat in your opinion?
 What's something that you believe you'll never be able to do well?
 What's your story about being under intense pressure and how did you handle it?
 What's the story behind why you replaced the last phone you had?
 Is there anything that most people find cute that creeps you out?
 What was your most recent experience of going down the rabbit hole?
 Have you evet taken a long shot that worked out?
 What do you believe is the biggest thing that's currently holding you back from success?
 What is the assumption that people make about you that's totally wrong?
 What is the next big purchase you're currently saving for?
 If you could lock someone up and throw away the key, would you and if so, who would that be?
 What would be the best thing about losing your hearing?
 If you could remove something that exists in this world forever, what would it be?
 What did you recently learn the hard way?
]],
['LISTquotes']=[[
 “she was glad she had been scarred. She said that whoever loved her now would love her true self, and not her pretty face.” - Cassandra Clare, Clockwork Angel
 “Don't be afraid of enemies who attack you. Be afraid of the friends who flatter you.” - Dale Carnegie, How to Win Friends and Influence People
 “To accomplish great things, we must dream as well as act.” - Anatole France
 “You don't need anybody to tell you who you are or what you are. You are what you are!” - John Lennon
 “Love is too precious to be ashamed of.” - Laurell K. Hamilton, A Stroke of Midnight
 “We cannot be sure of having something to live for unless we are willing to die for it.” - Che Guevara
 “There is no passion to be found playing small - in settling for a life that is less than the one you are capable of living.” - Nelson Mandela
 “You can't go home again” - Thomas Wolfe
 “I never want to change so much that people can't recognize me.” - Taylor Swift
 “Do not let your negative thoughts have power over you because those thoughts will end up controlling your life. No one can live a positive life with a negative mind.” - Roy T. Bennett, The Light in the Heart
 “Now you people have names. That's because you don't know who you are. We know who we are, so we don't need names.” - Neil Gaiman, Coraline
]],
['LISTflavor']=[[
 It's Not Brain Surgery Meaning: A task that's easy to accomplish, a thing lacking complexity.
 All Greek To Me Meaning: When something is incomprehensible due to complexity; unintelligble.
 Happy as a Clam Meaning: The state of being happy; feeling delighted.
 Cut To The Chase Meaning: To get to the point, leaving out all of the unnecessary details.
 Right Off the Bat Meaning: Immediately, done in a hurry; without delay.
 Plot Thickens - The Meaning: A situation that has gotten way more serious or interesting due to recent complexities or developments.
 Lovey Dovey Meaning: The affectionate stuff that people do when they are in love, such as kissing and hugging.
 A Cold Day in Hell Meaning: Something that will never happen.
 Lickety Split Meaning: To go at a quick pace; no delaying!
 Not the Sharpest Tool in the Shed Meaning: Someone who isn't witty or sharp, but rather, they are ignorant, unintelligent, or senseless.
 Drive Me Nuts Meaning: To greatly frustrate someone. To drive someone crazy, insane, bonkers, or bananas.
 On the Same Page Meaning: Thinking alike or understanding something in a similar way with others.
 Son of a Gun Meaning: A person, usually one who is behaving badly.
 Back to Square One Meaning: To go back to the beginning; back to the drawing board.
 There's No I in Team Meaning: To not work alone, but rather, together with others in order to achieve a certain goal.
 Like Father Like Son Meaning: Resembling one's parents in terms of appearance or behavior.
 Knuckle Down Meaning: Getting sincere about something; applying oneself seriously to a job.
 Burst Your Bubble Meaning: To ruin someone's happy moment.
 A Few Sandwiches Short of a Picnic Meaning: Someone who's not intelligent or has questionable mental capacity.
 Long In The Tooth Meaning: Old in age. Mainly used when referring to people or horses.
 Put a Sock In It Meaning: Asking someone to be quiet or to shut up.
 A Little Bird Told Me Meaning: Used when you don't wish to divulge where you got the information.
 It's Not All It's Cracked Up To Be Meaning: Failing to meet expectations; not being as good as people say.
 Hear, Hear Meaning: A shout of agreement, or to draw attention to a speaker.
 Fight Fire With Fire Meaning: To retaliate with an attack that is similar to the attack used against you.
 Birds of a Feather Flock Together Meaning: People tend to associate with others who share similar interests or values.
]],
}

--[[
 the top card of {your;target player's;an opponent's;each opponent's;each player's} [output_game_zones]
 that Conjures to your [output_game_zones]
 that Conjures to an opponent's [output_game_zones] the top card of [whomst] [output_game_zones]."

Removed
 Design a card that says "{Conjure;Conjure a duplicate} to {{your;target player's;an opponent's;each opponent's;each player's} [output_game_zones];[output_game_zones]} the top card of {your;target player's;an opponent's;each opponent's;each player's} [output_game_zones]."
 Design a card that says "{Conjure;Conjure a duplicate} to {{your;target player's;an opponent's;each opponent's;each player's} [output_game_zones];[output_game_zones]} target {[card_types];[output_cardtype_subtype]} card.
 Design a card that says "Starting intensity {0-3}" {
  Whenever this card attacks, it deals damage equal to its intensity to any target, then perpetually;
  Whenever one or more permanents you control leave the battlefiled, perpetually increase this card's intesity and the intesnity of cards that has the same name as this card in your hand, graveyard, and library by 1. This ability only triggers once each turn.;
  Whenever enchanted land is tapped for mana, its controller adds an additional amount of the same mana that was produced equal to this card's intensity, then perpetually;
  Whenever this card deals damage to any target;
  This card deals damage equal to its intensity to any target, then perpetually increase the intensity of all cards you own that has the same name as this card}
  increase its intensity by 1."
 Design a card with "{Draft;Conjure to your hand} a card from this card's spellbook."

  Design a card that has "{import:nouns}" anywhere on the card
  Design a card that has "{import:verb}" anywhere on the card
  Design a card that has "{import:adjective}" anywhere on the card
  Design a card that has "{import:adverb}" anywhere on the card
  Design a card that has "{import:preposition}" anywhere on the card
  Design a card that has "{import:word}" anywhere on the card
  Design a card that says, "Design a card from <font color="blue"> https://perchance.org/9898-mtg-design-draft-card-generator</font>". 
  
output_card_name
  {{import:adjective};{import:verb}} {{import:word};{import:noun}}
  {import:adjective} {import:verb} {{import:word};{import:noun}}
  {{import:adjective};{import:verb}} {import:word} {import:noun}
  {import:adjective} {import:verb} {import:word} {import:noun}
output_types_of_words
  {import:word}
  {import:nouns}
  {import:verb}
  {import:adjective}
  {import:adverb}
  {import:pronoun}
  {import:preposition}

['choose_two']=
Design a [card_types] card with two of the following —
• {import:nouns}
• {import:verb}
• {import:adjective}
• {import:adverb}
• {import:pronoun}
• {import:preposition}

//• nouns       {import:nouns}
//• verb        {import:verb}
//• adjective   {import:adjective}
//• adverb      {import:adverb}
//• pronoun     {import:pronoun}
//• preposition {import:preposition}
]]

--Cleans up New Lines and readies user made substitutions for randomization
for k,s in pairs(Randomizer)do
  if s:find('^{')then
    Randomizer[k]=s:gsub('(%D){',function(a)return a..'1d{'end)
  elseif s:find('^ ')and s:find('\n')then
    local a=s:gsub('%s*\n%s*',';')
    Randomizer[k]=('1d{'..a..'}'):gsub(';}','}')
  else
    log(s,'Correctly Formated '..k)
  end
end
--Bracet Replacer
local N=1
function onObjectLeaveContainer(c,o)
  if c~=self then return end N=N+1
  local R=Randomizer.output_list
  while R:find(']')do
    R=RF(self,'DM',R)
    for k,s in pairs(Randomizer)do
      if R:find(k)then
        R=R:gsub(k,s)break
  end end end
  print(R)
  R=R:gsub('  +',' ')
  R=R:gsub('%."%.','."')
  o.setDescription(Prefix..R)
end

--Easy Dice
function Z()self.reload()end
function onLoad()self.addContextMenuItem('Reload',Z)
  self.createButton({font_color={1,1,1},position={0,0.01,0},font_size=250,scale={0.4,1,0.4},rotation={0,-90,0},width=0,height=0,click_function='Z',function_owner=self,
    label=Display})end

function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['{numPlayers}']=function()return #getSeatedPlayers()end,
['(%d+)D(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)D(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)D(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end
if #t<2 then return''end if n>#t then n=#t-1 end for i=1,n do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end