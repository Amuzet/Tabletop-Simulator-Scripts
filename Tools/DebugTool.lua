--GetJSON Block
local s,Obj,toggle=0.2,self,true;
self.addContextMenuItem('Test',function(a)Player[a].broadcast(a)log(a,'Player')self.clearContextMenu()end)
B=setmetatable({click_function='B',function_owner=self,position={0,0.51,0},scale={s,1,s},height=400,width=1000,font_size=150},{__call=function(b,l,p,t,f)b.label,b.position,b.tooltip=l,p,t or l;if f then b.click_function=f;else b.click_function='c_'..l:gsub('[%w ]+\n',''):gsub('%s','');end self.createButton(b)end});
function onDestroy()if Obj then Obj.highlightOff()end end
function onPlayerTurnStart(p)if Obj then Obj.highlightOff()self.setColorTint(stringColorToRGB(p))Obj.highlightOn(self.getColorTint())end end
function onCollisionEnter(o)log(o)if Obj then Obj.highlightOff()end Obj=o.collision_object;Obj.highlightOn(self.getColorTint())end
function onLoad()self.clearButtons()for i,v in pairs({'Get\nTag','Get\nBounds','Get\nJSON','Get\nSteamIDs','Toggle\nInteractable'})do B(v,{(math.floor((i-1)/5)-0.5)*2.1*s,0.51,((i-1)%5-2)*s})Obj.addContextMenuItem(v:gsub('\n',' '),self.getVar(B.click_function:gsub('c_','m_')))end end

function m_Tag(a)c_Tag(nil,a)end
function m_JSON(a)c_JSON(nil,a)end
function m_SteamIDs(a)c_SteamIDs(nil,a)end
function m_Bounds(a)c_Bounds(nil,a)end
function m_Interactable(a)c_Interactable(nil,a)end

function c_Tag(o,c,a)if Obj then Player[c].broadcast(Obj.tag,{1,1,1})end end
function c_JSON(o,c,a)if Obj then addNotebookTab({title=info.collision_object.getGUID(),body=info.collision_object.getJSON()})end end
function c_SteamIDs(o,c,a)for _,v in pairs(Player.getPlayers())do Player[c].broadcast(v.steam_id..' '..v.steam_name,stringColorToRGB(v.color))end end
function c_Bounds(o,c,a)if Obj then self.setGMNotes(JSON.encode(Obj.getBounds()))Player[c].broadcast(self.getGMNotes(),{1,1,1})end end
function c_Interactable(o,c,a)if Obj then if Obj.interactable then Obj.interactable=false else Obj.interactable=true end end end

function hkTest(a,b,c,d)log(a)log(b)log(c)log(d)Obj=b;end
addHotkey('TestHotkey',hkTest)
