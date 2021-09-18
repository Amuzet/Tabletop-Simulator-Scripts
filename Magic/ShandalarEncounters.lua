--Generator Encounter
local Monster=setmetatable({
{'White','1d{Kiska-Ra lvl 10;Paladin lvl 6;Crusader lvl 3;Winged Stallion lvl 8;High Priest lvl 5;Priestess lvl 2;Cleric lvl 1;Arch Angel lvl 9;Centaur Warchief lvl 8}'},
{'Blue','1d{Seer lvl 1;Merfolk Shaman lvl 2;Sea Drake lvl 6;Thought Invoker lvl 5;Conjurer lvl 3;Shapeshifter lvl 5;Mind Stealer lvl 4;Guardian of the Tusk lvl 4;Saltrem Tor lvl 7, Whim lvl 5}'},
{'Black','1d{Aga Galneer lvl 7;Necromancer lvl 5;Vampire Lord lvl 6;Sedge Beast lvl 4;Nether Fiend lvl 9;Warlock lvl 3;Witch lvl 1;Lord of Fate 8;Undead Knight lvl 2;Mandurang Dragon lvl 10}'},
{'Red','1d{ApeLord lvl 8;Dracur lvl 10;Elementalist lvl 4;Hydra lvl 9;Warmage lvl 5;Troll Shaman lvl 3;Sorceress lvl 1;Sorcerer lvl 2;Queltosh lvl 7;Goblin Warlord lvl 6}'},
{'Green','1d{Enchantress lvl 3;Summoner lvl 5;Prismat lvl 10;Fungus Master lvl 4;Forest Dragon lvl 6;Druid lvl 1;Elvish Magi lvl 2;Centaur Shaman lvl 8;Beast Master lvl 9;Alt-A-Kesh lvl 7}'}},
{__call=function(t)return t[math.random(#t)]end})
local Deck={White='Cleric`s',Blue='Saltrem Tor`s',Black='Lord of Fate`s',Red='Goblin Warlord`s',Green='Fungus Master`s'}
local Mundane='mundane puddle;mundane lake;cardboard rectangle with a lotus on it;fantastic sunbeams;cloud in the shape of an cat;pack of wolves;empty cottage;cute bunny;storm in the distance;cute teddy bear;foul stench;tree nearby;cornicopia with nothing;useless knife;pile of fancy shirt;pile of clothing;ripped teddy bear}[/i]'
local Encounter={
Monster=function()local m=Monster()return([[ [/i]
[b][u]%s[/u]:[/b] with 2e{ and ;a cute teddy bear;a foul stench;tree nearby;a cornicopia with nothing;nothing;a cornicopia of nothing;a useless knife;a pile of fancy shirt;a pile of clothing;a ripped teddy bear;a Creature in play;1d10 Extra life;Switch decks;Choice of creature in play;Copies player deck;Gives player %s deck this duel}. Party 1d{can;can;can;can;can;can pay 9d9-9 per monster level to;can pay 33d3-1 per monster level to;can pay 99d2+1 during the duel before losing;can during the duel before losing;can't;can't;can't;can't} Bribe the monster.

[b][u]REWARDS[/u]:[/b]
%de{,
;Start the next duel with 3d2+1 extra life;Carry your current life to the next duel;Conjure a card from Monster`s Pool;The next store has a mythic;Conjure a Duplicate Card from your pool;Conjure a random common creature card next duel;Free teleport to any location;Conjure a random common card;Conjure a random %s card;Gain 99d3-9g;Gain 100d2-99g;Gain 50d5+99g;Gain 100d4+99g;Gain 200d3-99g;Gain 500d2-300g;Gain 400d2-200g;Gain 500g;Gain a %s Amulet}]]):format(
m[2],Deck[m[1]],players(),m[1],m[1])end,
Siege=function()local m=Monster()return([[refugees from[/i] [b]1d{Zephir Oasis;Windlass Tavern;Nevermoon Bazaar;Celestine Sanctum;Andor Bazaar;Celestine Shrine;Bloodsand Tavern;Windlass Temple;Pyreanian Temple;Amanixis Keep;Hornwall Steading;Kraag Haven;Shalecliff Tower;Hornwall Keep;Amanixis Mill;Hornwall Mill;Shalecliff Steading;Celestine Oasis;Nevermoon Hold;Andor Shrine;Shalecliff Forge;Mandrake Mill;Coldsnap Tavern;Kraag Shrine;Nevermoon Spire;Unicorn Spire;Coldsnap Mill;Eloren Hold;Pyrenian mill;Hornwall Glade;Zephir Spire;Nevermoon Oasis;Amanixis Tower;Zephir Sanctum}[/b] are under attack by a [b]1d{Lord of Fate;Undead Knight;Summoner;Forest Dragon;Warlock;Witch;Seer;Sorceress;Elvish Magi;Fungus Master;Goblin Warlord;Winged Stallion;Druid;Merfolk Shaman;Nether Fiend;Beast Master;Paladin;Centaur Shaman;Sorcerer;High Priest;Priestess;Hydra;Cleric;Sea Drake;Sedge Beast;Vampire Lord;Arch Angel;War Mage;Thought Invoker;Conjurer;Troll Shaman;Enchantress;Shapeshifter;Crusader;Mind Stealer;Necromancer;Elementalist;Guardian of the Tusk;Alt-A-Kesh;Aga Galneer;Ape Lord;Queltosh;Saltrem Tor;Centaur Warchief;Mandurang Dragon;Whim;Prismat;Dracur;Kiska-Ra}[/b]. They tell you that the town is under siege from the %s Wizard and will be captured in 6d3+1 days.
[i]Once captured, this town can be liberated with an ante of [b]4d2-2[/b] cards against %s this ante can be paied with %s Amulets.[/i] ]]):format(m[1],m[2],m[1])end,
Nothing=function()return'[b][u]Nothing[/u][/b] but a 3d2-1e{, a ;'..Mundane end,
Treasure=function()local thief=RF(self,nil,'1d{Gain 500 gold;Gain 400d2-100g;Lose half your gold}')
return'a 1d{'..Mundane..([[ and

[b][u]2e{.

[b][u];Planeswalker Merchant[/u]:[/b]
Trade amulets for cards! They don't take money;Nomad`s Bazaar[/u]:[/b]
A shop! They don`t take amulets;Gem Cutter Guild[/u]:[/b]
Buy upto 4d2-2 amulets of each color for 200d2-50g each;Theives Hideout[/u]:[/b]
Gain 400d2-100g;Theives Hideout[/u]:[/b]
Gain 500g;Theives Hideout[/u]:[/b]
%s;Gem Caravan[/u]:[/b]
Buy upto 3d2-1 amulets of each color for 50d2+99;Planar Fissure[/u]:[/b]
Conjure a random Booster;Ruined Temple[/u]:[/b]
4d2-2 %s amulets}.]]):format(thief,Monster()[1])end,
Spectral=function()return'a 1d{'..Mundane..([[ and

[b][u]Spectral Foe[/u]:[/b] 1d{Prismat;Dracur;Mandurang;Sea Dragon;Kiska-Ra}

[b]REWARDS:[/b]
%de{,
;Conjure %dd3-%d random Mythics;Conjure a random %s Mythic;Conjure a random %s Mythic;Conjure a random Mythic;Conjure your choice of Booster;Gain a Mana Link;Gain a Mana Link;Wish [i](Yes! Conjure ANY card)[/i]}.]]):format(
players(),players(),players(),Monster()[1],Monster()[1])end}
local Randomizer='1d{Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Monster;Monster;Monster;Monster;Monster;Monster;Monster;Spectral;Treasure;Treasure;Treasure;Treasure;Siege}'
function players()return math.max(2,#getSeatedPlayers())end
function Z()self.reload()end
function onLoad()self.setPosition({-6.75,1,1.73})
self.createButton({label='[b]Encounter Generator[/b]\n[i]Generate an encounter by\npulling out of the bag.\nDo this each day![/i]',font_color={1,1,1},position={0,0.01,0},font_size=250,scale={0.4,1,0.4},rotation={0,-90,0},width=0,height=0,click_function='Z',function_owner=self})end
function onObjectLeaveContainer(c,o)if c~=self then return end
  local s,k='[i]Along their journey the party encounter\n',RF(self,nil,Randomizer)
  if Encounter[k]then if type(Encounter[k])=='function'then s=s..Encounter[k]()else s=s..Encounter[k]end else s=s..k end
  o.setDescription(RF(self,nil,s))end
function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['{numPlayers}']=function()return #getSeatedPlayers()end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n,1 do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n,1 do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end