
function setButtons( pos )
  self.clearButtons()
  local Button=setmetatable({
    click_function = 'AddDeck',
    function_owner = self,
    position = pos,
    tooltip = 'Spawns an copy that is linked to and changes as this one does.',
    label = 'Spawn Linked',
    font_size=100,
    width = 1250,
    height= 200,
    itr =0.3},
  {__call=function(t,cf,l,z)
      t.click_function = cf or 'AddDeck'
      t.label= l or t.label
      t.tooltip = l or t.tooltip
      t.position[3] = z or t.position[3]+t.itr
      self.createButton(t)end})
  Button()
  local tbl=JSON.decode(self.script_state)
  for k,v in pairs( tbl.Name ) do
    if v then v.name='[b]Effect '..i..'[/b]' end
    
    Button('Effect'..tostring(v.index),v.name)
  end
end

function onLoad(d)if d==''then self.script_state=JSON.encode({
      Name={'Modular Marchesa'},
      Url={'https://deckstats.net/decks/99237/1048189-modular-marchesa/en'}})end end

function AddDeck(o,pc,a)
  local tbl,k,url=JSON.decode(self.script_state),self.getName(),self.getDescription()
  for _,v in pairs({'tappedout.net','deckstats.net','cubecobra'}) do
  if url:find(v) then
    tbl[k]=url
    self.script_state=JSON.encode(tbl)
  end
end