local n,btn={},setmetatable({function_owner=Global,position={0,-0.1,0},width=600,height=600,font_size=300},{__call=function(b,o,l,t,p,f)
  b.position,b.label,b.tooltip,b.click_function=p or b.position,l,t or'',f or'none'o.createButton(b)end})
function none()end
T={Red={'409503'},Yellow={'2365d0'},White={'166036'},Green={'c04462'},Purple={'033b34'},Blue={'60bfe2'}}
--Discord Table Rewrite
function onload()
  for k,g in pairs(T)do
    self.setVar('Draw'..k,function()T[k][2].deal(1,k)end)
    self.setVar('Scry'..k,function()T[k][2].takeObject({index=0}).setPosition(Player[k].getHandTransform(2))end)
  end
  local t={}
  btn.font_size,btn.scale=1200,{0.5,1,0.5}
  for i,o in pairs(getAllObjects())do
    if o.getName()==''then table.insert(t,o.getGUID())o.interactable=false
    --if o.tag=='Block'then local c=o.getColorTint()o.setColorTint({c.r/2,c.g/2,c.b/2})end
    elseif o.getName():find('%w+ Draw')then a(o,'Draw')
    elseif o.getName():find('%w+ Scry')then a(o,'Scry')
    elseif o.getName()=='Commander Zone'then
      btn.color,btn.font_color,btn.width,btn.height=o.getColorTint(),o.getColorTint(),1200,300
      btn(o,'0\n\n','Times Cast\nRight Click to set to Zero',{0,0.21,0.8},'edh')
    elseif o.getName():find('%d+ %w')then
      local n=o.getName():match('%d+')
      btn.font_color,btn.scale,btn.width,btn.height={0,0,0},{1,1,1},0,0
      btn(o,n,nil,{0,0.1,0})
      btn.scale,btn.width,btn.height={0.5,1,0.5},1200,1200
      btn(o,'@','Right-click to Decrease',{0,-0.1,0},'cdi')
    end
end end
function edh(o,c,a)if a then o.editButton({index=0,label='0\n\n'})else o.editButton({index=0,label=tostring(tonumber(o.getButtons()[1].label)+1)..'\n\n'})end end
function dec(o,c,a)cng(o,a,-1,-5)end
function inc(o,c,a)cng(o,a,1,5)end
function cdi(o,c,a)cng(o,a,1,-1)end
function cng(o,a,x,y)local b=x if a then b=y end o.editButton({index=0,label=tonumber(o.getButtons()[1].label)+b})end
function a(o,s)
  local k=o.getName():match('%w+')
  o.setColorTint(stringColorToRGB(k))
  btn.font_color,btn.width,btn.height=o.getColorTint(),600,600
  btn(o,'@',s,{0,-0.1,0},s..k)
  btn.width,btn.height=0,0
  btn(o,k..'\n'..s,nil,{0,0.1,0})end
function createDrawScry() end
function onObjectEnterScriptingZone(z, o)
  if o.tag=='Deck'and o.is_face_down then
    for k,g in pairs(T)do
      if z.getGUID()==g[1] then T[k][2]=o end end
end end