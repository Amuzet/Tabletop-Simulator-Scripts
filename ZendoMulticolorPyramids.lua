--size
ObjectJSON=[[{"Name":"Custom_Model",
"Transform":{"posX":0.0,"posY":1.0,"posZ":0.0,"rotX":0.0,"rotY":0.0,"rotZ":0.0,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},
"Nickname":"%d",
"ColorDiffuse":{"r":1.0,"g":1.0,"b":1.0,"a":0.0},
"CustomMesh":{
"MeshURL":"https://www.dropbox.com/s/j4tkgvyfscrbp76/httpsdldropboxusercontentcomu109809395icehousePyrRemapobj.obj?dl=1",
"DiffuseURL":"",
"NormalURL":"https://www.dropbox.com/s/77graglsf9tgcjo/httpsdldropboxusercontentcomu109809395icehouselelpng.png?dl=1",
"ColliderURL":"https://www.dropbox.com/s/sb35cjjf7bbfatt/httpsdldropboxusercontentcomu109809395icehousePyrTest2obj.obj?dl=1",
"Convex":true,"MaterialIndex":0,"TypeIndex":0,"CastShadows":true},
"XmlUI": "<Defaults>\n<Text fontSize=\"30\" color=\"#000000\"/>\n<Text class=\"L\" color=\"Grey\"/>\n</Defaults>\n<Text id=\"T1\" text=\".\" class=\"L\" rotation=\"75 0 180\" position=\"0 85 -14\"/>\n<Text id=\"T2\" text=\".\" class=\"L\" rotation=\"-75 0 0\" position=\"0 -85 -14\"/>\n<Text id=\"T3\" text=\".\" class=\"L\" rotation=\"0 -75 90\" position=\"85 0 -14\"/>\n<Text id=\"T4\" text=\".\" class=\"L\" rotation=\"0 75 270\" position=\"-85 0 -14\"/>\n<Text id=\"T5\" text=\".\" rotation=\"75 0 180\" position=\"0 85 -16\"/>\n<Text id=\"T6\" text=\".\" rotation=\"-75 0 0\" position=\"0 -85 -16\"/>\n<Text id=\"T7\" text=\".\" rotation=\"0 -75 90\" position=\"85 0 -16\"/>\n<Text id=\"T8\" text=\".\" rotation=\"0 75 270\" position=\"-85 0 -16\"/>",
"ChildObjects":[
]]
--x,y,r,g,b,
SideJSON=[[{"Name":"Custom_Model",
"Transform":{"posX":%s,"posY":0.01,"posZ":%s,
"rotX":0.0,"rotY":0.0,"rotZ":0.0,"scaleX":1.1,"scaleY":1.1,"scaleZ":1.1},
"ColorDiffuse":{"r":%s,"g":%s,"b":%s},"Locked":true,"CustomMesh":{
"MeshURL":"https://www.dropbox.com/s/j4tkgvyfscrbp76/httpsdldropboxusercontentcomu109809395icehousePyrRemapobj.obj?dl=1","DiffuseURL":"",
"NormalURL":"https://www.dropbox.com/s/77graglsf9tgcjo/httpsdldropboxusercontentcomu109809395icehouselelpng.png?dl=1",
"ColliderURL":"https://www.dropbox.com/s/sb35cjjf7bbfatt/httpsdldropboxusercontentcomu109809395icehousePyrTest2obj.obj?dl=1",
"Convex":true,"MaterialIndex":0,"TypeIndex":0,"CastShadows":true}},]]

--Player UI
T='PyramidTag'
Options={
  Max=200,Min=0,Cur=1,
  Color={3,8,3,8}}
--store chosen colors as a table of numbers
--use those numbers to grab the color name in Color.list
function pieceColor(n)local l=Color.list
  return Color[l[Options.Color[n]]]end

function setPips(o)local n,s=o.getName(),''
  if type(tonumber(n))=='number'and tonumber(n)<21 then
    for i=1,tonumber(n) do s=s..'.'end else s=n end
  for i=1,8 do o.UI.setAttribute('T'..i,'text',s)end end
function getScaleForSizePrecise(size)  return 0.630865 * math.sqrt((size ^ 0.929212) + 1.14529) end -- Doesn't work for size < 0 unfortunately
--function getScaleForSizeNegative(size) return 0.609549 * math.sqrt( size             + 1.24765) end -- Less accurate curve that works for size > -2
function giveContextMenu(o)
  o.addContextMenuItem('Set Pips',function()setPips(o)end)
  Wait.time(function()setPips(o)end,1)
end

function spawnPyramid(size)
  local s=getScaleForSizePrecise(size)
  local t={json=ObjectJSON:format(size),scale={s,s,s},callback_function=giveContextMenu}
  
  for i,v in ipairs({{0,-0.01},{-0.01,0},{0,0.01},{0.01,0}})do
    local c=pieceColor(i)
    --x,z,r,g,b,
    t.json=t.json..SideJSON:format(v[1],v[2],c[1],c[2],c[3])
  end
  
  t.json=t.json..']}'
  spawnObjectJSON(t).addTag(T)
end

function incrementSize(o,c,a)
  local n=1
  if a then n=-1 end
  Options.Cur=Options.Cur+n
  
  if Options.Cur>Options.Max then Options.Cur=Options.Max
  elseif Options.Cur<Options.Min then Options.Cur=Options.Min end
  
  self.editButton({index=1,label=Options.Cur})
end

B=setmetatable({position={0,0,1},color={0,0,0},font_color={1,1,1},
    click_function='onDrop',function_owner=self,
    label='Spawn Pyramid',width=900,height=100,font_size=90},{
    __call=function(b,l,cf)
      b.label,b.click_function=l,cf or l:gsub('%s','')
      self.createButton(b)
      b.position[3]=b.position[3]+0.3
    end})
function btnColor(i,a)
  local l,c,n=Color.list,Options.Color[i],1
  if a then n=-1 end c=c+n
  if c>#l then c=1
  elseif c<1 then c=#l end
  Options.Color[i]=c
  self.editButton({index=i+1,font_color=pieceColor(i),label=l[c]})
end
function SpawnPyramid()spawnPyramid(Options.Cur)end
function onSave()self.script_state=JSON.encode(Options)end
function onObjectSpawn(o)
  if o.hasTag(T)then
  giveContextMenu(o)
end end
function onLoad(d)if d~=''then Options=JSON.decode(d)end
  B.position={0,0,1}
  B('Spawn Pyramid')
  B(Options.Cur,'incrementSize')
  for i=1,4 do
    self.setVar('Color'..i,function(o,c,a)btnColor(i,a)end)
    local c=pieceColor(i)
    B.font_color=c
    B(c:toString(),'Color'..i)
  end
end
--EOF