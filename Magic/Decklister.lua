--By Amuzet
mod_name='Deck Lister'
version=0.4
self.setName(mod_name..' '..version)

Button = setmetatable({
    click_function='click',
    function_owner=self,
    label='Place on a Deck',
    position={0,0.5,-0.7},
    scale={0.2,0.2,0.2},
    width=4000,
    height=400,
    font_size=380,
    tooltip=''},
  {
    __call=function(t,tbl)
      self.createButton(t)
    end})
Button()

function lister(obj,pColor)
  local pc = pColor or 'White'
  if obj.shuffle then
    local list = ''
    for _,v in pairs(obj.getObjects())do
      local name = v.name:gsub('[\n].*','')
      list = list..'1 '..name..'\n'
    end
    
    addNotebookTab({ title=self.getDescription() , body=list })
    Player[pc].broadcast('Deck list in NotebookTab: '..obj.getGUID())
  end
end

function click(o,pc,a)
  lister(getObjectFromGUID(self.getDescription()),pc)
end

function onCollisionEnter(info)
  if info.collision_object.shuffle() then
    local g = info.collision_object.getGUID()
    self.setDescription(g)
    self.editButton({
      index=0,
      label='Get '..g..' Card List'
    })
  end
end