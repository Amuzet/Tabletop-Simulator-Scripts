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
]],
--[[User made Randomizers
 any User made will class will be replaced regardless of Square Brackets []
 Generated text will strip out all Square Brackets, so text is not bcode safe
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
 has a [mana_generated] symbols on it
 has a [mana_symbol] symbol in its casting cost
 has a [mana_symbol] symbol
 has 1d3+1 different mana symbols
 creates a 2d3-2/2d3-1 [card_colors] [output_card_subtype_creature] creature token
 cares about [short_A]
 cares about [short_B]
 cares about [card_cares]
 cares about [output_game_zones]
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
 Whenever you [output_card_text_keys], [output_card_text_keys]
 Whenever you lose life, create a 1/1 [card_colors] [output_card_subtype_creature] creature token
 Whenever you gain life, create a 1/1 [card_colors] [output_card_subtype_creature] creature token
 Whenever you roll a die, create a X/X [card_colors] [output_card_subtype_creature] creature token where X equals the result of the die roll
 Whenever this deals damage, create a 1/1 [card_colors] [output_card_subtype_creature] creature token
 You get a Boon with 1d{"When you cast your next creature spell, that creature enters the battlefield with an additional +1/+1 counter, reach counter, and trample counter on it;"When you cast your next creature spell, that creature enters the battlefield with a +1/+1 counter on it;"When you cast your next creature spell, that creature enters the battlefield with your choice of a +1/+1 counter, a flying counter, or a lifelink counter on it;“When you cast your next creature spell, it perpetually gets +X/+0, where X is the power of your last creature that died;"When you cast your next creature spell, it perpetually gets +1/+0;“When you cast your next creature spell without flying, it perpetually gains flying;“When you cast your next creature spell, it perpetually gets +X/+0, where X is your last excess damage dealt;“When you cast your next creature spell, it perpetually gets +2/+0}
]],

 --that says "{Conjure;Conjure a duplicate} to {{your;target player's;an opponent's;each opponent's;each player's} [output_game_zones];[output_game_zones]} the top card of {your;target player's;an opponent's;each opponent's;each player's} [output_game_zones]."
['short_B']='{[card_types];[output_cardtype_subtype];[output_card_rarity];[output_card_text_keyword_action];[output_card_text_keyword_ability];[output_game_zones] matters;[output_card_power_toughness]}',
['short_A']='{[card_types];[output_cardtype_subtype];[output_card_rarity];[output_card_text_keyword_action];[output_card_text_keyword_ability]}',
['whomst']=[[{your;target player's;an opponent's;each opponent's;each player's}]],
--['card_types']='{Basic;Boon;NonBasic;Legendary;Snow;Token;Tribal;World;Conspiracy;Creature;Artifact;Artifact Creature;Artifact Land;Enchantment;Enchantment Creature;Instant;Sorcery;Land;Planeswalker;Emblem;Phenemonom;Plane;Dungeon;Scheme;Vanguard}',
['card_cares']='{Basic;NonBasic;Legendary;Snow;Token;Tribal;World;Conspiracy;Creature;Artifact;Artifact Creature;Enchantment;Enchantment Creature;Instant;Sorcery;Land;Planeswalker;Emblem;Phenemonom;Plane;Dungeon;Scheme}',
['card_types']='{Legendary;Snow;Tribal;World;Conspiracy;Creature;Artifact;Artifact Creature;Artifact Land;Enchantment;Enchantment Creature;Instant;Sorcery;Land;Planeswalker;Phenemonom;Plane;Scheme;Vanguard}',
['card_colors']='{White;Blue;Black;Red;Green;Colorless}',
['mana_symbol']='{X;Colorless;Snow;Hybrid;2/Brid;Tribrid;Phyrexian;2d3-1}',
['mana_cost']='{[card_colors];[mana_symbol]}',
['mana_generated']='[mana_symbol]2D2-1e{W;U;B;R;G}',
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
['output_card_text_keyword_ability']=[[
  Deathtouch
  Defender
  Double Strike
  Enchant
  Equip
  First Strike
  Flash
  Flying
  Haste
  Hexproof
  Indestructible
  Intimidate
  Landwalk
  Lifelink
  Protection
  Reach
  Shroud
  Trample
  Vigilance
  Ward
  Banding
  Rampage
  Cumulative Upkeep
  Flanking
  Phasing
  Buyback
  Shadow
  Cycling
  Echo
  Horsemanship
  Fading
  Kicker
  Flashback
  Madness
  Fear
  Morph
  Amplify
  Provoke
  Storm
  Affinity
  Entwine
  Modular
  Sunburst
  Bushido
  Soulshift
  Splice
  Offering
  Ninjutsu
  Epic
  Convoke
  Dredge
  Transmute
  Bloodthirst
  Haunt
  Replicate
  Forecast
  Graft
  Recover
  Ripple
  Specialize
  Split Second
  Suspend
  Vanishing
  Absorb
  Aura Swap
  Delve
  Fortify
  Frenzy
  Gravestorm
  Poisonous
  Transfigure
  Champion
  Changeling
  Evoke
  Hideaway
  Prowl
  Reinforce
  Conspire
  Persist
  Wither
  Retrace
  Devour
  Exalted
  Unearth
  Cascade
  Annihilator
  Level Up
  Rebound
  Totem Armor
  Infect
  Battle Cry
  Living Weapon
  Undying
  Miracle
  Soulbond
  Overload
  Scavenge
  Unleash
  Cipher
  Evolve
  Extort
  Fuse
  Bestow
  Tribute
  Dethrone
  Hidden Agenda
  Outlast
  Prowess
  Dash
  Exploit
  Menace
  Renown
  Awaken
  Devoid
  Ingest
  Myriad
  Surge
  Skulk
  Emerge
  Escalate
  Melee
  Crew
  Fabricate
  Partner
  Undaunted
  Improvise
  Aftermath
  Embalm
  Eternalize
  Afflict
  Ascend
  Assist
  Jump-Start
  Mentor
  Afterlife
  Riot
  Spectacle
  Escape
  Companion
  Mutate
  Encore
  Boast
  Foretell
  Demonstrate
  Daybound
  Nightbound
  Disturb
  Decayed
  Cleave
  Training
  Compleated
  Reconfigure
  Blitz
  Casualty
  Enlist
  Read Ahead
  Backbone (This creature assigns combat damage equal to its toughness instead of its power.)
  Boon (A card with they stated criteria given with Boon as the card type.)
  Conjure
  Draft
  Doubleteam
  Intensity
  Perpetually (Perpetual effects and counters are not removed from cards that change zones.)
  Seek
  Spellbook
  Specialize
  Unstoppable
]],
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
}
--Cleans up New Lines and readies user made substitutions for randomization
for k,s in pairs(Randomizer)do
  if s:find('^{')and s:find('}$')then
    Randomizer[k]='1d'..s
  elseif s:find('^ ')and s:find('\n')then
    local asdf=s:gsub('%s*\n%s*',';')
    Randomizer[k]=('1d{'..asdf..'}'):gsub(';}','}')
  else
    log(s,'Correctly Formated '..k)
  end
end

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

--Specific
local N=1
function onObjectLeaveContainer(c,o)
  if c~=self then return end N=N+1
  local R=Randomizer.output_list
  for i=0,9 do
    R=RF(self,'DM',R)
    for k,s in pairs(Randomizer)do
      if R:find(k)then
        print(R)
        R=R:gsub(k,s)
        break
      end
    end
  end
  print(R)
  R=R:gsub('  +',' ')
  R=R:gsub(']',''):gsub('%[','')
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
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end