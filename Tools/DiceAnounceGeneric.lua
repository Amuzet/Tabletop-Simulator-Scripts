local side , text , plr = '' , '' , 'Black'
local timesRolled , randomized = 0 , false

function onObjectRandomize( Object , player_color )
 if Object.getGUID() == self.getGUID() then
  if player_color ~= plr then
   changePlayer(player_color)
  end
  if not randomized then
   randomized = true
   startLuaCoroutine(self, 'whileDrop')
  end
 end
end

function whileDrop()
 while not self.resting do
  coroutine.yield(0) -- Always yield 0 to resume
 end
 randomized = false
 printDiceFace()
 coroutine.yield(1) -- Yield anything other than 0 to break out
end

function printDiceFace()
 local value = self.getValue()
 --You can customize the message per Value
 if value == 6 then
  side = ' Is a HIGH ROLLER!'
 else
 --Or Remove the If block to make a generic message about what value they rolled
  side = ' rolled '..value
 end
 text = plr..side
 printToAll(text, self.getColorTint())
 --For if you need to know how many times a player has rolled the dice (optional)
 timesRolled = timesRolled + 1
end

function changePlayer(new)
 plr = new
 timesRolled = 0
 --This changes the color of the Dice to whom ever rolled it
 local rgb = stringColorToRGB(plr)
 local color = {rgb["r"], rgb["g"], rgb["b"]}
 self.setColorTint(color)
end