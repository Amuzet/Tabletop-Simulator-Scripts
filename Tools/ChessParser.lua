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
    label='Current Board '..mats[o.getName()],
    function_owner=self,click_function='changeState',
    width=1500,height=300,font_size=200,rotation={0,90,0},
    scale={0.4,0.4,0.4},position={2.1,0,0},
    font_color={1,1,1},color={0,0,0},
    tooltip='Change current mat image!'})end

local K='UNINTERACTABLE'
function onLoad()
  for _,o in pairs(getAllObjects())do
    if o.tag=='Tile'and o.getLock()==true then
      o.clearButtons()
      local d=o.getDescription()
      o.highlightOff()
      if d:find('CURV: %d+')then
        parseValues(d,o)
      elseif o.getName():find(K)then
        o.interactable=false
        if o.getStates()then
          local n=1
          while mats[K..n]do n=n+1 end
          local k=K..n
          o.setName(k)
          mats[k]=1
          B(o)end
      --elseif d:find('CURV')then
      --  print('_NA_ '..o.getName())
      --  o.setColorTint(Color.Teal)
      end
    end
  end
end
function createCopy(o,c,a)
  if a then Player[c].print(o.getName()..o.getDescription())return end
  local h=Player[c].getHandTransform()
  local l=o.clone({position=h.position,snap_to_grid=true})
  l.setLock(false)
  l.setRotation(h.rotation)
  l.setColorTint(Color[c])
  local s,m,n='',{},o.getGMNotes()
  
  for move in n:gmatch('M=%b{}')do
    table.insert(m,parseMoves(move:sub(2,-2)))
  end
  for i,v in pairs(m)do
    s=s..'function move'..i..'()'..v..' end\n'
  end
  l.setLuaScript(s)
  l.setDescription(n)
  Player[c].print(n)
end
replacement={
  forwarddiagonally='>X',
  backwarddiagonally='<X',
  forwardorthogonally='>',
  backwardorthogonally='<',
  --MoveAttackforward='*>',
  RepeatedLeapAttack='∞',
  RepeatedLeap='O~∞',
  LeapAttack='~',
  MoveAttack='',
  MoveCapture='C',
  Move='O',
  Leap='O~',
  Attack='C',
  Hopoveraunit='O^',
  anenemyunitbeyondit='+(1)',
  Hop='^',
  diagonally='X',
  forward='>',
  backward='<',
  orthogonally='+',
  horizontally='=',
  sideways='=',
  vertically='<>',
  outward='',
  vertical='',
  hipogonally='',
  hippogonally='',
  [';']='/',
  ['and']='.',
  ['then']='.',
  --NonStandardNotation
  wide='W',
  narrow='N',
  inenemyterritory='E',
  infriendlyterritory='F',
  ['pastboard\'shalf']='H',
  ['Xor+']='*',
  ['+orX']='*',
  ['or']=','
  }
function stringToMove(str,o)
  if str:find('Hop')then o.highlightOn(Color.Green)end
  local s=str:gsub('[%s&]+','')
  for k,v in pairs(replacement)do
    s=s:gsub(k,v)end
  if s:find('[aeiou]')then
    o.highlightOn(Color.Purple)end
  return 'M={'..s..'}' end
doFunction={
  CURV=function(s,o)
    local c=s:match('CURV:(.*)'):gsub(',','.')
    return'CURV:'..c end,
  Class=function(s,o)
    local c=s:match('Class: (.*)')
    if o.getDescription():find('Type: Pawn')then c='Pawn'--o.setColorTint(Color.Brown)
    elseif c=='BOSS'then o.setColorTint(Color.Red)c='BOSS'
    --elseif c=='Major'then o.setColorTint(Color.White)
    elseif c=='Null'then o.setColorTint(Color.Pink)end
    return'Class: '..c end,
  --Color=function(s,o)return s end,
  ROYAL=function(s,o)
    if o.getColorTint()==Color.Red then
      o.setColorTint(Color.Orange)
    elseif o.getColorTint()==Color.Pink then
    else o.setColorTint(Color.Yellow)end
    return'[E6E42B]ROYAL[-]'end,
  Initial=function(s,o)
    if s:find('double%-step')then
      return'M={io>(2)}'else print(s)return s end
    end,
  Promotion=function(s,o)return s end,
  Hop=function(s,o)return stringToMove(s,o)end,
  Move=function(s,o)return stringToMove(s,o)end,
  Leap=function(s,o)return stringToMove(s,o)end,
  Attack=function(s,o)return stringToMove(s,o)end
  }
function parseValues(s,o)
  local info='[b]'..o.getName()..'[/b]'
  for string in s:gmatch('%- ([^\n]+)')do
    for k,v in pairs(doFunction)do
      if string:find(k)then
        local d=v
        if type(v)=='function'then d=v(string,o)end
        info=info..'\n'..d
        break
      end
    end
  end
  o.setGMNotes(info)
  o.createButton({
      function_owner=self,click_function='createCopy',
      color={0,0,0,0},scale={3,3,3},width=500,height=500,
      tooltip='Right Click to get Descriptive moveset for '..info})
end

function parseMoves(m)
  for step in m:gmatch('[%.]+')do
    local dir,pat=m:match('(.-)(%b())')
    if pat:len()>3 then
      pat=pat:sub(2,-2)
      first,second=pat:match('(.-)/(.-)')
      string.find(first)
    elseif pat:find('∞')
      
    else
      
    end
  end
end
direction={'Orthognal','Diagonal','Triagonal'}

for x=-1,1 do
  for y=-1,1 do
    for z=-1,1 do

      local vec=Vector(math.abs(x),math.abs(y),math.abs(z))
      local current='Orthognal'
      if direction[vec:magnitude()] then
        
      end
end end end