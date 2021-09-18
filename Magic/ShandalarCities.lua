local Offsets={
{-1.5,0},{-1.5,0.43},
{-1.13,-1.09},{-1.13,-0.65},{-1.13,-0.22},{-1.13,0.21},{-1.13,0.65},
{-0.75,-1.3},{-0.75,-0.87},{-0.75,-0.44},{-0.75,0.86},{-0.75,1.29},{-0.75,0.43},{-0.75,0},
{-0.38,-1.09},{-0.38,-0.65},{-0.38,-0.22},{-0.38,1.08},{-0.38,1.51},{-0.38,0.21},{-0.38,0.65},
{0,-1.3},{0,-0.87},{0,-0.44},{0,0.42},{0,0.86},{0,1.29},{0.38,-1.09},{0.38,-1.52},{0.38,-0.65},{0.38,-0.22},{0.38,0.65},{0.38,0.21},{0.38,1.08},
{0.75,-1.3},{0.75,-0.87},{0.75,-0.44},{0.75,0},{0.75,0.86},{0.75,0.43},{0.75,1.29},
{1.13,-0.65},{1.13,-0.22},{1.13,0.21},{1.13,0.65},{1.13,1.08},
{1.5,-0.44},{1.5,0}}
local Tiles={'7d1157','6d5a70','cce324','08f103','3abfb3','2a4449','a2c820','78e9b6','dc0a98','a5f478','e38b1d','d86c20','f0667e','d69c85','c09cac','0b8b47','ce60fd','f0a144','954a59','7b43ad','87fb74','6f9366','8cd457','8ccdde','690784','2b710e','9d5780','b2cc06','01b384','9a2729','f0ec51','560c11','d55d3b','c65062'}
local Cities={'Zephir Oasis','Windlass Tavern','Nevermoon Bazaar','Celestine Sanctum','Andor Bazaar','Celestine Shrine','Bloodsand Tavern','Windlass Temple','Pyreanian Temple','Amanixis Keep','Hornwall Steading','Kraag Haven','Shalecliff Tower','Hornwall Keep','Amanixis Mill','Hornwall Mill','Shalecliff Steading','Celestine Oasis','Nevermoon Hold','Andor Shrine','Shalecliff Forge','Mandrake Mill','Coldsnap Tavern','Kraag Shrine','Nevermoon Spire','Unicorn Spire','Coldsnap Mill','Eloren Hold','Pyrenian mill','Hornwall Glade','Zephir Spire','Nevermoon Oasis','Amanixis Tower','Zephir Sanctum'}
local Seeder={'Starting City','An Additional Haggle','One less Haggle','Shop Price Double','Shop Price Half','Conjurer`s Will','Leap of Fate','Quickening','Thunderstaff','Sword of Restance','Slight of Hand','Tome of Knowledge','Haggler`s Coin','Fruit of Sustance','Dwarven`s Pick','Ring of the Guardian','Dungeon Red','Dungeon Green','Dungeon White','Dungeon Blue','Dungeon Black'}
local Copy={}
function onLoad(s)
  self.createButton({click_function='generatePositions',function_owner=self,scale={4,1,4},
        tooltip=self.getName()..'\n'..self.getDescription()})
  if s~=''then Copy=JSON.decode(s)end end
function onDestroy()for i,g in pairs(Copy)do destroyObject(getObjectFromGUID(g))end end
--function onDrop()generatePositions()end
function generatePositions()
  if #Cities<1 then
    self.script_state=''
    self.reload()end
  self.setLock(true)
  local s=#Tiles
  for i=s,1,-1 do if not getObjectFromGUID(Tiles[i])then table.remove(Tiles,i)end end
  for i=s,#Cities do table.insert(Tiles,Tiles[math.random(s)])end
  for i=#Cities,1,-1 do
    if Cities[i]then
    local pos=getObjectFromGUID(getExclusive(Tiles)).getPosition()
    local offset=getExclusive(Offsets)
    
    local new=self.clone({position={pos[1]+offset[1],1,pos[3]+offset[2]}})
    new.setLuaScript('')
    new.setName(Cities[i])
    new.setDescription(getExclusive(Seeder))
    table.remove(Cities,i)
    table.insert(Copy,new.getGUID())
    else print('ERROR:Generate Positions For loop went to far!')
  end end
  Wait.time(init,2)
end
Color.Add('Note',Color.new(1,150/255,100/255))
function init()
  for _,g in pairs(Copy)do
    local o=getObjectFromGUID(g)
    local l=o.getName()..'\n'..o.getDescription()
    local c=l:match('%a+$')
    if Color[c]then o.setColorTint(Color[c])end
    o.createButton({function_owner=self,click_function='N',width=7100,height=2500,font_size=900,scale={0.1,0.1,0.1},rotation={-30,0,0},position={0,0.2,0},color=o.getColorTint(),
        label=l,tooltip=l})
    local p=o.getPosition()
    p[2]=1
    o.setPosition(p)
  end
  self.script_state=JSON.encode(Copy)
end
function N(o)
local l=o.getName()..'\n'..o.getDescription()
local c=l:match('%a+$')
if Color[c]then o.setColorTint(Color[c])end
o.editButton({index=0,label=l,tooltip=l,color=o.getColorTint()})
end
function getExclusive(tbl)
  if #tbl==0 then return'Nothing of Note'end
  local r=math.random(#tbl)
  local result=tbl[r]
  table.remove(tbl,r)
  return result end