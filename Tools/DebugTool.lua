--GetJSON Block
local s,Obj,toggle=0.5,self,true
Stuff={'Get\nTag','Get\nBounds','Get\nJSON','Get\nSteamIDs','Notebook To\nScript_State','Toggle\nInteractable','Script State\nTo_Notebook'}
self.addContextMenuItem('Test',function(a)Player[a].broadcast(a)self.clearContextMenu()end)
B=setmetatable({click_function='B',function_owner=self,position={0,0.51,0},scale={s,1,s},height=400,width=1000,font_size=150},{__call=function(b,l,p,t,f)b.label,b.position,b.tooltip=l,p,t or l;if f then b.click_function=f;else b.click_function='c_'..l:gsub('[%w ]+\n',''):gsub('%s','');end self.createButton(b)end});
function onDestroy()if Obj then Obj.highlightOff()end end
function onPlayerTurnStart(p)if Obj then Obj.highlightOff()self.setColorTint(stringColorToRGB(p))Obj.highlightOn(self.getColorTint())end end
function onCollisionEnter(o)if Obj then Obj.highlightOff()end Obj=o.collision_object;Obj.highlightOn(self.getColorTint())end
function onLoad()
  addContextMenuItem('Clear Context',function(c)if Player[c].admin then clearContextMenu()end end)
  self.clearButtons()
  for i,v in pairs(Stuff)do
    B(v,{(math.floor((i-1)/5)-0.5)*2.1*s,0.51,((i-1)%5-2)*s})
    local m=B.click_function:gsub('c_','m_')
    self.setVar(m,function(c)self.getVar(B.click_function)(nil,c)end)
    Obj.addContextMenuItem(v:gsub('\n',' '),self.getVar(m))end end
--[[
function m_Tag(a)c_Tag(nil,a)end
function m_JSON(a)c_JSON(nil,a)end
function m_SteamIDs(a)c_SteamIDs(nil,a)end
function m_Bounds(a)c_Bounds(nil,a)end
function m_Interactable(a)c_Interactable(nil,a)end
]]
function c_Tag(o,c,a)if Obj then Player[c].broadcast(Obj.tag,{1,1,1})end end
function c_JSON(o,c,a)if Obj then addNotebookTab({title=Obj.getGUID(),body=Obj.getJSON()})end end
function c_SteamIDs(o,c,a)for _,v in pairs(Player.getPlayers())do Player[c].broadcast(v.steam_id..' '..v.steam_name,stringColorToRGB(v.color))end end
function c_Bounds(o,c,a)if Obj then self.setGMNotes(JSON.encode(Obj.getBounds()))Player[c].broadcast(self.getGMNotes(),{1,1,1})end end
function c_Interactable(o,c,a)if Obj then Obj.interactable=not Obj.interactable end end

function c_Script_State(o,c,a)if Obj then local n=getNotebookTabs(); Obj.script_state=n[#n].body end end
function c_To_Notebook(o,c,a)if Obj then addNotebookTab({title=Obj.getName(),body=Obj.script_state})end end

function hkTest(a,b,c,d)log({A=a,B=b,C=c,D=d})Obj=b;end
addHotkey('TestHotkey',hkTest)
