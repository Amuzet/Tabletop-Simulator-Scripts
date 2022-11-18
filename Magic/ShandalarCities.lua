--Generator Cities
Offsets={{0,0},{-1.13,0.65},{-0.75,0.43},{-0.75,0.87},{-0.75,1.3},{-0.38,0.22},{-1.13,0.22},{-0.38,0.65},{-0.38,1.08},{-0.75,0},{0,0.43},{0,0.87},{0,1.3},{-1.5,0},{0.38,0.22},{-0.38,-0.22},{0.38,-0.22},{-1.13,-0.22},{0.38,1.08},{0.38,0.65},{-0.75,-0.43},{0,-0.43},{0.75,-0.43},{0.75,0.43},{0.75,0.87},{0.73,1.3},{0.75,0},{-1.13,-0.65},{-0.4,-0.65},{1.13,-0.65},{1.13,0.65},{1.13,-0.22},{1.13,0.22},{0.38,-0.65},{0.01,-0.87},{0.75,-0.87},{-0.75,-0.87},{-0.38,-1.08},{1.5,0},{0.38,-1.08},{-0.75,-1.3},{0,-1.3},{0.75,-1.3}}
Tiles={self.getGUID(),'7d1157','6d5a70','cce324','08f103','3abfb3','2a4449','a2c820','78e9b6','dc0a98','a5f478','e38b1d','d86c20','f0667e','d69c85','c09cac','0b8b47','ce60fd','f0a144','954a59','7b43ad','87fb74','6f9366','8cd457','8ccdde','690784','2b710e','9d5780','b2cc06','01b384','9a2729','f0ec51','560c11','d55d3b','c65062'}
Cities={
Shandalar={'Zephir Oasis','Windlass Tavern','Nevermoon Bazaar','Celestine Sanctum','Andor Bazaar','Celestine Shrine','Bloodsand Tavern','Windlass Temple','Pyreanian Temple','Amanixis Keep','Hornwall Steading','Kraag Haven','Shalecliff Tower','Hornwall Keep','Amanixis Mill','Hornwall Mill','Shalecliff Steading','Celestine Oasis','Nevermoon Hold','Andor Shrine','Shalecliff Forge','Mandrake Mill','Coldsnap Tavern','Kraag Shrine','Nevermoon Spire','Unicorn Spire','Coldsnap Mill','Eloren Hold','Pyrenian Mill','Hornwall Glade','Zephir Spire','Nevermoon Oasis','Amanixis Tower','Zephir Sanctum'},
Innistrad={'Gavony','High City of Thraben','Tree of Redemption','The Helvault','Moorland','Trostad','Nearheath','Videns','Wittal','Effalen','Estwald','Hanweir','Kessig','Ulvenwald','Lambholt','Hollowhenge','Devils` Breach','Stensia','Somberwald','Ashmouth','Needle`s Eye','Nephalia','Drunau','Havengul','Selhoff'}}
Seeder={'Nothing of Note','Starting City Pink','Conjure a Conspiracy','An Additional Haggle','One less Haggle','Shop Price Double','Shop Price Half','Conjurer`s Will','Leap of Fate','Quickening','Thunderstaff','Sword of Restance','Slight of Hand','Tome of Knowledge','Haggler`s Coin','Fruit of Sustance','Dwarven`s Pick','Ring of the Guardian','Dungeon Red','Dungeon Green','Dungeon White','Dungeon Blue','Dungeon Black'}
Copy,Gen={},'Shandalar'
Terra={'Wastes','Plains','Water','Swamp','Mountain','Forest'}
Color.Add('Plains',  Color.new(0.70,0.62,0.21))
Color.Add('Water',   Color.new(0.13,0.69,0.61))
Color.Add('Swamp',   Color.new(0.25,0.12,0.51))
Color.Add('Mountain',Color.new(0.70,0.23,0.21))
Color.Add('Forest',  Color.new(0.13,0.40,0.12))
Color.Add('Wastes',Color.new(0.6,0.6,0.6))
function getExclusive(tbl,del)
  --FirstElementDefault
  if #tbl==1 then return tbl[1]end
  local r=math.random(2,#tbl)
  local result=tbl[r]
  --deleteElement
  if not del then table.remove(tbl,r)end
  return result end
local Names={'The','Zephir','Windlass','Nevermoon','Celestine','Andor','Bloodsand','Pyreanian','Amanixis','Hornwall','Kraag','Shalecliff',
  'Mandrake','Coldsnap','Eloren','Gavony','Thraben','Moorland','Trostad','Nearheath','Videns','Wittal','Effalen','Estwald','Hanweir','Kessig',
  'Ulvenwald','Lambholt','Hollowhenge','Stensia','Somberwald','Ashmouth','Nephalia','Drunau','Havengul','Selhoff'}
local Place={'Area','Oasis','Tavern','Bazaar','Sanctum','Shrine','Temple','Keep','Steading','Haven','Tower','Mill','Hold','Forge','Glade','Spire'}
local Nouns={'blood','cliff','cold','drake','hearth','henge','hollow','holt','lass','moon','sand','stone','wald','wind',''}

function randomCities(tbl,min,max,each,emin)
  Cities[tbl]={}
  for j=1,math.random(min,max)do
    local t,name={},getExclusive(Names)
    for i=1,math.random(emin or 2,each or 3)do table.insert(t,getExclusive(Place))end
    for _,s in pairs(t)do table.insert(Place,s)end
    for i=1,#t do table.insert(Cities[tbl],name..' '..getExclusive(t))end end end

function changeGenerator(k)Gen=k
  printToAll('Generating '..k)
  generatePositions()
  self.clearContextMenu()
  self.addContextMenuItem('Reload',generatePositions)
end

function onDestroy()for i,g in pairs(Copy)do destroyObject(getObjectFromGUID(g))end end
function onLoad(s)
  --Add Buttons to Party Piece
  randomCities('Normal',math.floor(#Names/3),math.floor(#Names/2))
  randomCities('Many City',math.floor(#Names/2),#Names-1,6)
  if #Names>1 then randomCities('Wilds',#Names-1,#Names,#Place,#Place/2)end
  self.setName('City Generator')
  self.addContextMenuItem('Change Generator',function()printToAll('Click a context menu item to change the names the City Generator will use, this can increase the number of cities on the map by changing it after generation and clicking the button.')end)
  for k,t in pairs(Cities)do
    self.addContextMenuItem('Cities:'..#t..' '..k,function()changeGenerator(k)end)end
  if s~=''then Copy=JSON.decode(s)
    init()
end end

function generatePositions()
  --CheckAlreadyGenerated
  if #Copy>1 then
    self.script_state=''
    return self.reload()end
  self.setLock(true)
  --RemoveNonexistantTiles
  for i=#Tiles,1,-1 do if not getObjectFromGUID(Tiles[i])then table.remove(Tiles,i)end end
  --Add to Terra upto Tiles
  local s,b=#Tiles,#Terra-1
  for i=1,math.floor(s/b)do for j=2,b+1 do table.insert(Terra,Terra[j])end end
  --RecolorTilesAndGeneratePositions
  local location,loops,y={{0,0,0}},math.floor(#Cities[Gen]/#Tiles)+1,self.getPosition()[2]+0.1
  for _,g in pairs(Tiles)do
    local o=getObjectFromGUID(g)
    local n=getExclusive(Terra)
    o.setColorTint(Color[n])
    o.setName(n)
    o.grid_projection=true
    if o~=self then o.interactable=false end
    local p=o.getPosition()
    local f={}
    --Set amount of towns variable to Biome
    for i=1,loops do
      table.insert(f,getExclusive(Offsets))
      table.insert(location,{p[1]+f[i][1],y,p[3]+f[i][2]})
    end
    for _,t in pairs(f)do
      table.insert(Offsets,t)
    end
  end
  --SpawnCities
  for i=#Cities[Gen],1,-1 do
    if Cities[Gen][i]then
    local new=self.clone({scale={0.4,1,0.4},position=getExclusive(location)})
    new.setLuaScript('')
    new.setName(Cities[Gen][i])
    new.setDescription(getExclusive(Seeder))
    
    table.insert(Copy,new.getGUID())
    else print('ERROR:Generate Positions For loop went to far!')
  end end
  Grid.type=2
  Grid.snapping=3
  Grid.sizeX=0.5
  Grid.sizeY=0.5
  local p=self.getPosition()
  Grid.offsetX=p[1]
  Grid.offsetY=p[3]
  Grid.show_lines=true
  Wait.time(init,2)
end

Color.Add('Note',Color.new(1,0.6,0.4))
local B={function_owner=self,click_function='N',width=7600,height=2500,font_size=900,scale={0.1,0.1,0.2},rotation={0,0,75},position={0,0.8,0}}
function init()
  Cities.Current={}
  local y=self.getPosition()[2]+0.1
  for _,g in pairs(Copy)do
    local o=getObjectFromGUID(g)
    if o then
    local l=o.getName()..'\n'..o.getDescription()
    table.insert(Cities.Current,o.getName())
    local c=l:match('%a+$')
    if Color[c]then o.setColorTint(Color[c])else o.setColorTint(Color.Yellow)end
    B.color,B.label,B.tooltip=o.getColorTint(),l,l..'\n\nChange the description and name of the object?\nClick to update button text.\nColor at the end of description'
    o.alt_view_angle={0,0,81}
    o.createButton(B)
    local p=o.getPosition()
    p[2]=y
    o.setPosition(p)
  end end
  self.script_state=JSON.encode(Copy)
end
function N(o)
  local l=o.getName()..'\n'..o.getDescription()
  local c=l:match('%a+$')
  if Color[c]then o.setColorTint(Color[c])else o.setColorTint(Color.Yellow)end
  o.editButton({index=0,label=l,tooltip=l,color=o.getColorTint()})
end