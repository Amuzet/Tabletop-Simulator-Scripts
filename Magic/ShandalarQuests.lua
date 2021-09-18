--Generator Quest
local Randomizer={[[
[b]FIGHT TARGETS:[/b] 1d2e{, or ;a White Monster;a Blue Monster;a Black Monster;a Red Monster;a Green Monster;Lord of Fate;Undead Knight;Summoner;Forest Dragon;Warlock;Witch;Seer;Sorceress;Elvish Magi;Fungus Master;Goblin Warlord;Winged Stallion;Druid;Merfolk Shaman;Nether Fiend;Beast Master;Paladin;Centaur Shaman;Sorcerer;High Priest;Priestess;Crag Hydra;Cleric;Sea Drake;Sedge Beast;Vampire Lord;Arch Angel;War Mage;Thought Invoker;Conjurer;Troll Shaman;Enchantress;Shapeshifter;Crusader;Mind Stealer;Necromancer;Elementalist;Guardian of the Tusk;Alt-A-Kesh;Aga Galneer;Ape Lord;Queltosh;Saltrem Tor;Centaur Warchief;Mandurang Dragon;Whim;Prismat;Dracur;Kiska-Ra}.

[b]FOREFIT:[/b] When you 1d{do something impossible;flee from any monster;flee from a target;bribe a target;dismiss this quest;leave a town without purchasing anything;purchace anything;leave this region;change terrain type}, then 1d{just dismiss this quest;don't sweat it;there is no penalty;your honor is bruised, but nothing else;lose 3d2-1 amulets;lose 2d2-1 amulets;lose 1{numPlayers}d9+9 gp;lose {numPlayers}1d9-9 gp;mana link;next duel you ante an additional card;next duel you mill a card;next duel discard a card;next duel you lose 3d2-2 life;lose a Mana Link}.
]],[[
[b]FERRY:[/b] Upto 4d2-1 1d{Red;Blue;Green;White;Black;Colorless;Multicolored} 1d{;non;non;or;or;or} 1d{Creature;Enchantment;Sorcery;Instant;Common;Uncommon;Rare} cards.

[b]DESTINATION:[/b]
1d{A town under siege;Next closest town;A town 6d2+0 days away;A town 6d2+1 days away;The closest town;The closest town;TOWN;TOWN or TOWN}.
]]}
local Towns='{Zephir Oasis;Windlass Tavern;Nevermoon Bazaar;Celestine Sanctum;Andor Bazaar;Celestine Shrine;Bloodsand Tavern;Windlass Temple;Pyreanian Temple;Amanixis Keep;Hornwall Steading;Kraag Haven;Shalecliff Tower;Hornwall Keep;Amanixis Mill;Hornwall Mill;Shalecliff Steading;Celestine Oasis;Nevermoon Hold;Andor Shrine;Shalecliff Forge;Mandrake Mill;Coldsnap Tavern;Kraag Shrine;Nevermoon Spire;Unicorn Spire;Coldsnap Mill;Eloren Hold;Pyrenian mill;Hornwall Glade}'
local Reward=('\n[b]REWARD:[/b] Gain 1d{1d2+{numPlayers} amulets;{numPlayers}d2-1 amulets;{numPlayers}0d{numPlayers}0+9 money;31d1{numPlayers}+99 money;21d2{numPlayers}+99 money;a Mana Link;an Evolving Wilds tokenB;1d2+0 food tokenB;3d3-1 lifeB;1d3+2 lifeB}.'):gsub('B',' at the start of the next duel [i](First Upkeep)[/i]')
function tn()local t=RF(self,'DM','1d'..Towns)return t end
local N=1
function Z()self.reload()end
function onLoad()self.setPosition({-14.5,1,-2.17})
self.createButton({label='[b]Quest Generator[/b]\n\n[i]pull 2 when entering\ntown the party can have\nat most 3 quests dismissing\nthem for 99g at anytime.',font_color={1,1,1},position={0,0.01,0},font_size=250,scale={0.4,1,0.4},rotation={0,-90,0},width=0,height=0,click_function='Z',function_owner=self})end
function onObjectLeaveContainer(c,o)if c~=self then return end N=N+1 if N>#Randomizer then N=1 end
local q=Randomizer[N]:gsub('TOWN',tn())
o.setDescription(RF(self,'DM',q..Reward))end
function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['{numPlayers}']=function()return #getSeatedPlayers()end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end