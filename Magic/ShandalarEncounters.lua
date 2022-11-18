--Generator Encounter
local Monster=setmetatable({
{'[B39E36]White[-]','[B39E36]1d{Kiska-Ra 1d3+22;Paladin 1d3+18;Crusader 1d3+12;Winged Stallion 1d3+18;High Priest 1d3+15;Arch Angel 1d3+20;Priestess 1d3+10;Cleric 1d3+8;Centaur Warchief 1d3+18}[-]'},
{'[2191BB]Blue[-]','[2191BB]1d{Seer 1d3+8;Merfolk Shaman 1d3+10;Sea Drake 1d3+16;Thought Invoker 1d3+17;Conjurer 1d3+12;Shapeshifter 1d3+15;Mind Stealer 1d3+14;Guardian of the Tusk 1d3+14;Saltrem Tor 1d3+17;1d3+15 Whim}[-]'},
{'[503082]Black[-]','[503082]1d{Aga Galneer 1d3+17;Necromancer 1d3+15;Vampire Lord 1d3+16;Sedge Beast 1d3+14;Nether Fiend 1d3+20;Warlock 1d3+12;Witch 1d3+8;Lord of Fate 1d3+18;Undead Knight 1d3+10;Mandurang Dragon 1d3+22}[-]'},
{'[B33B36]Red[-]','[B33B36]1d{ApeLord 1d3+18;Elementalist 1d3+14;Dracur 1d3+22;Hydra 1d3+20;Warmage 1d3+15;Troll Shaman 1d3+12;Sorceress 1d3+8;Sorcerer 1d3+10;Queltosh 1d3+17;Goblin Warlord 1d3+16}[-]'},
{'[22661E]Green[-]','[22661E]1d{Enchantress 1d3+14;Summoner 1d3+15;Prismat 1d3+22;Fungus Master 1d3+14;Forest Dragon 1d3+16;Druid 1d3+8;Elvish Magi 1d3+10;Centaur Shaman 1d3+18;Beast Master 1d3+20;Alt-A-Kesh 1d3+17}[-]'}},
{__call=function(t)return t[math.random(#t)]end})

--local Deck={White='Cleric`s',Blue='Saltrem Tor`s',Black='Lord of Fate`s',Red='Goblin Warlord`s',Green='Fungus Master`s'}
--local Objects='a cute teddy bear;a foul stench;tree nearby;a cornicopia with nothing;nothing;a cornicopia of nothing;a useless knife;a pile of fancy shirt;a pile of clothing;a ripped teddy bear'
local Mundane='mundane puddle;mundane lake;cardboard rectangle with a lotus on it;fantastic sunbeams;cloud in the shape of an cat;pack of wolves;empty cottage;cute bunny;storm in the distance;cute teddy bear;foul stench;tree nearby;cornicopia with nothing;useless knife;pile of fancy shirt;pile of clothing;ripped teddy bear}[/i]'


local Encounter={
  Monster=function()local m=Monster()return([[ [/i]
[b][u]%s[/u] starting life[/b] with 1D2+1e{ and ;a %s Creature in play;3d3+1 Extra life;a conspiracy;a scheme;a clue token;a Copy of a player`s deck;not much}. Bribing them costs [b]1d{9d9+99g per monster life;100g per monster life;99d99-9g during the duel before turn 1d3+3;a %s amulet per monster life}.[/b]

[b][u]REWARDS[/u]:[/b]{numPlayers}e{,;
Start the next duel with 3d2+1 extra life;
Carry your current life to a future duel;
The next store has an additional mythic;
Start next duel with a common creature;
Duplicate a Card in your collection;
Conjure a card from Monster`s Pool;
Conjure a random common card;
Conjure a random %s card;
Gain 1d{99d9-9;99d3D3+1+9D9+1}g;
Gain 1d3+1 %s Amulets;
Teleport to TOWN;
Duplicate a reward}.]]):format(
m[2],m[1],m[1],m[1],m[1])end,

  Siege=function()local m=Monster()return([[refugees from[/i] [b]%s. It's under siege by the %s Wizard and their minion a %s.[/b] They will succeed in capturing in 6d1D3+1+2D3+1 days.

Once captured, this town can be liberated with an ante of [b]2d2+1[/b] cards against a %s this ante can be paied with %s Amulets. ]]):format(notUnderSiege(),m[1],m[2],m[2],m[1])end,

  Treasure=function()return'a 1d{'..Mundane..([[ and
[b][u]2D2+0e{.[b][u];
Planar Fissure[/u]:[/b] Choose and Draft a Booster;
Mystic Archway[/u]:[/b] Teleport to TOWN;
Planeswalker Merchant[/u]:[/b] Shop that only takes amulets!;
Nomad`s Bazaar[/u]:[/b] A shop that does not take amulets!;
Gem Caravan[/u]:[/b] 3d2-1 amulets of COLOR} at 99d9+99g each;
Gem Cutters` Guild[/u]:[/b] 4d2+1 amulets of COLOR;each color} at 99d9+9g each;
Ruined Temple[/u]:[/b] Gain 4d2-2 COLOR} amulets;
Theives Hideout[/u]:[/b] 1d{Gain;Gain;Lose} 9d99+99g;
Theives Hideout[/u]:[/b] 1d{Gain;Gain;Lose} 99d9+99g;
Theives Hideout[/u]:[/b] 1d{Gain;Gain;Lose} 9d99+99g;
Theives Hideout[/u]:[/b] 1d{Gain;Gain;Lose} 99d9+99g}.]]):gsub('COLOR',function()return '1d{'..Monster()[1]..';Current Hex'end)end,

  Spectral=function()local m1,m2=Monster(),Monster()
    local c=m1[1]..' or '..m2[1]
    return'a 1d{'..Mundane..([[ and

[b][u]Spectral Foes[/u]:[/b] %s and %s with 1d{shared;seperate} life total.

[b]REWARDS:[/b] 1d{Draft a Spectral Booster;Gain a Mana Link},
{numPlayers}e{,
;Conjure {numPlayers}d3-1 random Uncommons;Conjure a random %s Mythic;Conjure a random %s Mythic;Conjure a random Mythic;Conjure a Booster of your choice;Gain a Mana Link;Gain a Mana Link;Teleport where ever you like;Raise a Hekma around TOWN;Raise a Hekma around a town;Wish [i](Yes! Conjure ANY card)[/i]}.]]):format(
m1[2],m2[2],c,c)end,

Nothing=function()return'a 3D2-1e{, and ;'..Mundane end}

local Randomizer='1d{Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Nothing;Monster;Monster;Monster;Monster;Monster;Monster;Monster;Monster;Spectral;Treasure;Treasure;Siege;Siege}'
local recentSieges={}

function tn()local o=getObjectFromGUID('2d1194')
  if o then local s,n='',o.getTable('Cities')
    if not n.Current then return'FAILED'end
    for _,c in pairs(n.Current)do s=s..';'..c end s=('1d{'..s..'}'):gsub('{;','{')
    local t=RF(self,'DM',s)return t end return'FAILED'end

function notUnderSiege()
  if #recentSieges<1 then return tn()end
  local o=getObjectFromGUID('2d1194')
  if o then local s,t='',o.getTable('Cities')
    if not t.Current then return'FAILED'
    else t=t.Current end
    
    for _,r in pairs(recentSieges)do
      for i,c in pairs(t)do
        if r==c then
          table.remove(t,i)
          break end end end
    
    if #recentSieges>9 then table.remove(recentSieges,1)end
    local choice=math.random(1,#t)
    table.insert(recentSieges,t[choice])
    return t[choice]end
  return'FAILED'end

function onObjectLeaveContainer(c,o)if c~=self then return end
  local s,k='[i]Along their journey the party encounter\n',RF(self,nil,Randomizer)
  if Encounter[k]then if type(Encounter[k])=='function'then s=s..Encounter[k]()else s=s..Encounter[k]end else s=s..k end
  s=s:gsub('TOWN',t)
  o.setName(k)
  o.setDescription(RF(self,nil,s))
end

function Z()self.reload()end
function onLoad()self.addContextMenuItem('Reload',Z)
self.createButton({label='[b]Encounter Generator[/b]\n[i]Generate an encounter by\npulling out of the bag.\nDo this each move![/i]',font_color={1,1,1},position={0,0.01,0},font_size=250,scale={0.4,1,0.4},rotation={0,-90,0},width=0,height=0,click_function='Z',function_owner=self})end
function onSave()
  --Store Towns Sieged
end
--DICE
function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['{numPlayers}']=function()return math.max(2,#getSeatedPlayers())end,
['(%d+)D(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)D(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
--CommaSeperatedChoices
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n,1 do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
--ExclusiveChoices
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n,1 do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end