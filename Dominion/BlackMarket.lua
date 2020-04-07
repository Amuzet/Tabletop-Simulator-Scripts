z={r='fd0b1d',m='21406d',p={0,1.5,22},25,29,33}
function display(l)self.clearButtons()self.createButton({
 label=l,color={0,0.3,1},click_function=l:gsub(' ',''),function_owner=self,
 position={0,0.2,1},scale={0.6,0.6,0.6},height=300,width=2000,font_size=300})end

function RevealBlackMarket()
 for _,d in pairs(getObjectFromGUID(z.r).getObjects())do
  if d.tag=='Deck'and d.getQuantity()<4 then
   for i=d.getQuanity(),2,-1 do z.p[1]=z[i] d.takeObject({position=z.p,index=i,flip=true})end
   for _,c in pairs(getObjectFromGUID(z.r))do if d.tag=='Card'then
    z.p[1]=z[2] d.setRotation({0,0,0})d.setPositionSmooth(p,false,true)
   end end
  elseif d.tag=='Deck'then
   local q=d.getQuantity()+1
   for i=1,3 do z.p[1]=z[i] d.takeObject({position=z.p,index=q-i,flip=true})end
  elseif d.tag=='Card'then
   z.p[1]=z[2] d.setRotation({0,0,0})d.setPositionSmooth(p,false,true)
  end
 end
 display('Put Cards Away')
end

function PutCardsAway()
 for _,d in pairs(getObjectFromGUID(z[1]).getObjects())do
  if d.tag=='Deck'or d.tag=='Card'then
   for _,c in pairs(getObjectFromGUID(z[2]).getObjects())do
    if c.tag=='Card'then d.putObject(c)end
   end
  end
 end
 display('Reveal Black Market')
end