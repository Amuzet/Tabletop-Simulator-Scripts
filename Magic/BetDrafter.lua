--By Amuzet
mod_name='Deck Lister'
version=0.4
self.setName(mod_name..' '..version)

Button = setmetatable({
    click_function='click',
    function_owner=self,
    label='Place Deck',
    position={0,1.5,0},
    scale={0.2,0.2,0.2},
    color={0,0,0},
    width=4000,
    height=400,
    font_size=380,
    tooltip=''},
  {__call=function(t,tbl)
      self.createButton(t)
    end})
Button()
local Bid='White'
local Bet={}
local Col={White='ffffff',Brown='703A16',Red='DA1917',Orange='F3631C',Yellow='E6E42B',Green='30B22A',Teal='20B09A',Blue='1E87FF',Purple='9F1FEF',Pink='F46FCD',Grey='7F7F7F',Black='3F3F3F'}

function pta(p,text)printToAll(Player[p].steam_name..text,stringColorToRGB(p))end

function click(o,p,a)
  if p == 'Grey' or p == 'Black' then
    pta(p,' Sit Down at a Color before Beginning the Draft.')
	elseif a then
    Bet[p] = 'Pass'
    pta(p,' Passes!')
  elseif Bid ~= p then
    pta(p,' Raised their Bid to '..Bet[p])
  elseif Bet[p] == 'Pass' then
    pta(p,' has passed already.')
	end
  local b = ' '
  for k,v in pairs(Bet) do b = b..'['..Col[k]..']'..v..'[-] ' end
  Button.label = b
  self.clearButtons()
  Button()
end

function onCollisionEnter(info)
  if info.collision_object.shuffle() then
    local g = info.collision_object.getGUID()
    self.setDescription(g)
    self.editButton({
      index=0,
      label='Bet Draft'
    })
  end
end