--ShandalarDecks
local T={position={0,2,4},guid='',callback_function=function(spawned)
  Wait.Time(function()spawned.clone({position={4,2,0},callback_function=function(cloned)Wait.frames(function()self.putObject(spawned)end,1)end})end,1)end}
local B=setmetatable({label='U',click_function='Z',function_owner=self,height=200,width=2000,font_size=120,scale={0.5,0.5,0.5},position={1.3,-1.8,-0.1},rotation={0,270,90},font_color=self.getColorTint(),color={0,0,0}},
  {__call=function(t,o)
      t.label,t.tooltip,t.click_function,t.position[2]=o.name,o.description,'cf_'..o.guid,t.position[2]+0.2
      self.setVar(t.click_function,function(_,p,a)
          tkObj(o.guid)end)
        self.createButton(t)end})
function tkObj(g)T.guid=g
  self.takeObject(T)end
function Z()self.reload()end
function buttons()for i,o in pairs(self.getObjects())do B(o)end end
function onLoad()
  self.addContextMenuItem('Reload',Z)
  Wait.condition(buttons,
    function()return not self.loading_custom end,
    30,function()return self.isDestroyed()end)end