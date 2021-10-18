--Generator Encounter
local Monster=setmetatable({
{'White','1d{1d3+22 Kiska-Ra;Paladin;1d3+12 Crusader;1d3+18 Winged Stallion;1d3+15 High Priest;Priestess;Cleric;1d3+20 Arch Angel;Centaur Warchief}'},
{'Blue','1d{1d3+8 Seer;1d3+10 Merfolk Shaman;1d3+16 Sea Drake;1d3+17 Thought Invoker;1d3+12 Conjurer;1d3+15 Shapeshifter;1d3+14 Mind Stealer;1d3+14 Guardian of the Tusk;1d3+17 Saltrem Tor,1d3+15 Whim}'},
{'Black','1d{1d3+17 Aga Galneer;1d3+15 Necromancer;1d3+16 Vampire Lord;1d3+14 Sedge Beast;1d3+20 Nether Fiend;1d3+12 Warlock;1d3+8 Witch;1d3+18 Lord of Fate;1d3+10 Undead Knight;1d3+22 Mandurang Dragon}'},
{'Red','1d{1d3+18 ApeLord;Dracur;1d3+14 Elementalist;1d3+20 Hydra;1d3+15 Warmage;1d3+12 Troll Shaman;1d3+8 Sorceress;1d3+10 Sorcerer;1d3+17 Queltosh;1d3+16 Goblin Warlord}'},
{'Green','1d{1d3+14 Enchantress;1d3+15 Summoner;1d3+22 Prismat;1d3+14 Fungus Master;1d3+16 Forest Dragon;1d3+8 Druid;1d3+10 Elvish Magi;1d3+18 Centaur Shaman;1d3+20 Beast Master;1d3+17 Alt-A-Kesh}'}},
{__call=function(t)return t[math.random(#t)]end})
local Deck={White='Cleric`s',Blue='Saltrem Tor`s',Black='Lord of Fate`s',Red='Goblin Warlord`s',Green='Fungus Master`s'}
local Mundane='mundane puddle;mundane lake;cardboard rectangle with a lotus on it;fantastic sunbeams;cloud in the shape of an cat;pack of wolves;empty cottage;cute bunny;storm in the distance;cute teddy bear;foul stench;tree nearby;cornicopia with nothing;useless knife;pile of fancy shirt;pile of clothing;ripped teddy bear}[/i]'
local Encounter={
Monster=function()local m=Monster()return([[ [/i]
[b][u]Life@%s[/u]:[/b] with 2e{ and ;a cute teddy bear;a foul stench;tree nearby;a cornicopia with nothing;nothing;a cornicopia of nothing;a useless knife;a pile of fancy shirt;a pile of clothing;a ripped teddy bear;a Creature in play;1d10 Extra life;Switch decks;Choice of creature in play;Copies player deck;Gives player %s deck this duel}. Party 1d{can;can;can;can;can pay 9d9+9 per monster level to;can pay 33d3+1 per monster life to;can pay 99d99+1 during the duel before turn six;can during the duel before turn six;can't;can't;can't;can't} Bribe the monster, and flee 1d{North;South;NorthEast;SouthEast;NorthWest;SouthWest}.

[b][u]REWARDS[/u]:[/b]
{numPlayers}e{,
;Start the next duel with 3d2+1 extra life;Carry your current life to the next duel;Conjure a card from Monster`s Pool;The next store has a mythic;Conjure a Duplicate Card from your pool;Conjure a random common creature card next duel;Free teleport to any location;Conjure a random common card;Conjure a random %s card;Gain 99d3-9g;Gain 100d2-99g;Gain 50d5+99g;Gain 100d4+99g;Gain 200d3-99g;Gain 500d2-300g;Gain 400d2-200g;Gain 500g;Gain a %s Amulet}]]):format(
m[2],Deck[m[1]],m[1],m[1])end,
Siege=function()local m=Monster()return([[refugees from[/i] [b]TOWN[/b] are under attack by a [b]%s Monster[/b]. They tell you that the town is under siege from the %s Wizard and will be captured in 6d3+4 days.
[i]Once captured, this town can be liberated with an ante of [b]3d2+0[/b] cards against %s this ante can be paied with %s Amulets.[/i] ]]):format(m[1],m[1],m[1],m[1])end,
Nothing=function()return'[b][u]Nothing[/u][/b] but a 3d2-1e{, a ;'..Mundane end,
Treasure=function()return'a 1d{'..Mundane..([[ and

[b][u]2e{.

[b][u];Planeswalker Merchant[/u]:[/b]
Trade amulets for cards! They don't take money;Nomad`s Bazaar[/u]:[/b]
A shop! They don`t take amulets;Gem Cutter Guild[/u]:[/b]
Buy upto 4d2-2 amulets of each color for 200d2-50g each;Theives Hideout[/u]:[/b]
Gain 400d2-100g;Theives Hideout[/u]:[/b]
Gain 500g;Theives Hideout[/u]:[/b]
1d{Gain;Gain;Lose} 1d{500;400d2-100;half your} money;Gem Caravan[/u]:[/b]
Buy upto 3d2-1 amulets of each color for 50d2+99;Planar Fissure[/u]:[/b]
Conjure a Booster of your choice;Ruined Temple[/u]:[/b]
4d2-2 %s amulets}.]]):format(Monster()[1])end,
Spectral=function()local m=Monster()
return'a 1d{'..Mundane..([[ and

[b][u]Spectral Foe[/u]:[/b] %s

[b]REWARDS:[/b]
{numPlayers}e{,
;Conjure {numPlayers}d3-{numPlayers} random Mythics;Conjure a random %s Mythic;Conjure a random %s Mythic;Conjure a random Mythic;Conjure a Booster of your choice;Gain a Mana Link;Gain a Mana Link;Teleport where ever you like;Raise a Hekma around a town;Wish [i](Yes! Conjure ANY card)[/i]}.]]):format(
m[1],m[1],m[1])end}
local Randomizer='1d{Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Monster;Monster;Monster;Monster;Monster;Monster;Monster;Monster;Spectral;Treasure;Treasure;Treasure;Treasure;Siege;Siege}'
function tn()local o=getObjectFromGUID('2d1194')
  if o then local s,n='',o.getTable('Cities')
    if not n.Current then return'FAILED'end
    for _,c in pairs(n.Current)do s=s..';'..c end s=('1d{'..s..'}'):gsub('{;','{')
    local t=RF(self,'DM',s)return t end return'FAILED'end
function Z()self.reload()end
function onLoad()self.addContextMenuItem('Reload',Z)
self.createButton({label='[b]Encounter Generator[/b]\n[i]Generate an encounter by\npulling out of the bag.\nDo this each day![/i]',font_color={1,1,1},position={0,0.01,0},font_size=250,scale={0.4,1,0.4},rotation={0,-90,0},width=0,height=0,click_function='Z',function_owner=self})end
function onObjectLeaveContainer(c,o)if c~=self then return end
  local s,k='[i]Along their journey the party encounter\n',RF(self,nil,Randomizer)
  if Encounter[k]then if type(Encounter[k])=='function'then s=s..Encounter[k]()else s=s..Encounter[k]end else s=s..k end
  s=s:gsub('TOWN',tn())
  o.setDescription(RF(self,nil,s))end
function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['{numPlayers}']=function()return math.max(2,#getSeatedPlayers())end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n,1 do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n,1 do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end