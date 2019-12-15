function onPlayerTurn(player)
  local color = player.color
  if not Player[color] then color = 'Black' end
  previousTurn = color
  --Set Play Mat tint darker
  color = stringColorToRGB(color)
  for k,v in pairs( color ) do color[k] = (v * 0.6) + 0.1 end
  color.a = 1
  self.setColorTint( color )
end

function onChat(msg)
  if msg == 'DELETE' then
    self.destroy()
  elseif msg == 'INTERACTBACKGROUND' then
    self.interactable = not self.interactable
  elseif msg == 'HELP' then
    print('Background: DELETE , INTERACTBACKGROUND')
  end
end

function onLoad(object_spawned)
  self.lock()
  self.setName('Chry\'s Background')
  self.interactable = false
  self.setColorTint({0.5,0.2,0.5})
end
--EOF