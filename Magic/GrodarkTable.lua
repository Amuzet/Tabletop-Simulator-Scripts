local mats={}
function changeState(o,c,a)
  local name=o.getName()
  local n=mats[name]
  if a then n=n-1 else n=n+1 end
  
  if n<1 then n=#o.getStates()+1
  elseif n>1+#o.getStates()then n=1 end
  
  local m=o.setState(n)
  m.setLock(true)
  mats[name]=n
  m.setName(name)
  m.interactable=false
  
  if m.getButtons()then
    m.editButton({index=0,label='Current State: '..mats[name]})
  else B(m,name)end
end

function B(o)
  o.createButton({
    label='Current Image: '..mats[o.getName()],
    function_owner=self,
    click_function='changeState',
    width=1500,height=300,font_size=200,
    scale={0.2,0.2,0.2},position={0,0,-1.2},
    font_color={1,1,1},color={0,0,0},
    tooltip='Change current mat image!'
  })end

local K='UNINTERACTABLE'
function onLoad(d)
  for _,o in ipairs(getAllObjects())do
    if o.getName():find(K)then
      o.interactable=false
      local s=o.getStates()
      if s then
        local n=1
        while mats[K..n]do n=n+1 end
        local k=K..n
        o.setName(k)
        mats[k]=1
        B(o)
end end end end