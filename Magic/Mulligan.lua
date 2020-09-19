function onload()
  self.createButton({
    label="Mulligan", click_function="Mulligan", function_owner=self,
    position={0,0.1,0}, rotation={0,0,0}, height=800, width=2000, font_size=250
  })
  --getObjectFromGUID(CommanderPlank).registerCollisions(true)
end

Owner='White'
ZoneDeck='4fde42'
ZoneCommander='c57672'
--CommanderPlank='d4cffb'
savedCommanderName='-'

function onObjectEnterScriptingZone(zone,obj)
  if zone==getObjectFromGUID(ZoneCommander)and obj.tag=='Card' and obj.getName() ~= savedCommanderName then
    triggerCommanderSave=true
  end

  if zone==getObjectFromGUID(ZoneCommander)and obj.tag=='Card' and triggerCommanderSave then
    --temp Container
    local tblCards = { obj }
    table.insert( tblCards , obj.clone() )
    savedCommanderName = obj.getName()
        broadcastToAll(Owner..' My commander is now : '..savedCommanderName,self.getColorTint())
    Timer.create({
        identifier='group'..self.getGUID(),
        function_name='groupNow',
        function_owner=self,
        delay=1.1,
        parameters=tblCards
        })
        
    triggerCommanderSave=false
  end
end

function groupNow(t)
  local gResult=group(t)
  Timer.create({
      identifier='removeOldCard'..self.getGUID(),
      function_name='removeOldCard',
      function_owner=self,
      delay=1.5,
      parameters=gResult
      })
end

function removeOldCard(gResult)
  gResult[1].takeObject({
    callback_function=function(o)
      o.destruct()end})
end

function Mulligan(me, player)
  if player ~= Owner then
    return 1
  end
  local zoneobjects = getObjectFromGUID(ZoneDeck).getObjects()

  for i, v in ipairs(zoneobjects) do
    if v.tag == "Deck" then
      v.reset()
      v.shuffle()
      --Lua Table assignment, works unless you need to reference itself. In those cases use the other method.
      Timer.create({
        identifier = 'mulligan'..self.getGUID(),
        function_name = 'mulliganNow',
        function_owner = self,
        delay = 1.1,
        parameters = v
        })
    end
  end
end

function mulliganNow(d)d.dealToColor(7, Owner)end