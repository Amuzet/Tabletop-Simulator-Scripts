obj,n,b=nil,0,setmetatable({
label='',click_function='DCoin',function_owner=self,scale={0.6,0.6,0.6},
position={0,0.3,0},height=300,width=2400,font_size=200},{
__call=function(t,c,l,z)t.click_function,t.label,t.position[3]=c,l,z self.createButton(t)end})
function onSave()return 0 end
function onLoad(d)if d~=''then n=d end display()end
function display()self.clearButtons()self.createButton({
label=n,color={0.9,0.9,0.3},click_function='PCoin',function_owner=self,position={1.1,0.2,0},height=500,width=400,font_size=500})obj=nil end

function PCoin()printToAll('Trade Route makes '..n..' Money!',{0.9,0.9,0.3})end
function DCoin()obj.destruct()obj=nil;n=n+1 display()end
function SCoin()obj=nil display()end
function onCollisionEnter(info)
  if not obj then
    obj=info.collision_object
    if obj.getName()=='Coin Token'then
b('DCoin','Add Money to Trade Route',-0.7)
b('SCoin','Skip Coin to Trade Route',0.7)
end end end