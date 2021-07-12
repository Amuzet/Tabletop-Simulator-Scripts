local mats={}
local K='UNINTERACTABLE'

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
  o.clearButtons()
  o.createButton({
    label='Current Board '..mats[o.getName()],
    function_owner=self,click_function='changeState',
    width=1500,height=300,font_size=200,rotation={0,90,0},
    scale={0.4,0.4,0.4},position={2.1,0,0},
    font_color={1,1,1},color={0,0,0},
    tooltip='Change current mat image!'})end
function setScript(obj,c)
  local script,n=[[function N()self.clearButtons()end
function f(a,b,c)N()for i,t in pairs(b)do
  self.createButton({position={t[1]*4.5,0.2,-t[2]*4.5},tooltip=a,click_function='N',function_owner=self,width=700,height=700,color={0.5,0.5,0.5,0.7}})end
 Player[c].broadcast(a,self.getColorTint())end
function onLoad()]],obj.getGMNotes()
  local i=0
  for move in n:gmatch('M.-=(%b{})')do
    i=i+1
    script=script..parseMove(move,i)
  end
  script=script..'\nend'
  obj.setLuaScript(script)
  obj.setDescription(n)
  Player[c].print(n)
end
function createCopy(obj,c,a)
  if a then Player[c].print(obj.getName()..obj.getDescription())return end
  local h=Player[c].getHandTransform()or{position={0,2,0}}
  local dup=obj.clone({position=h.position})
  dup.setLock(false)
  dup.setColorTint(Color[c])
  setScript(dup,c)
end

replacement={
  forwarddiagonally='X>',
  backwarddiagonally='X<',
  forwardorthogonally='>',
  backwardorthogonally='<',
  --MoveAttackforward='*>',
  RepeatedLeapAttack='~∞',
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
  forward='*>',
  backward='*<',
  orthogonally='+',
  horizontally='=',
  sideways='=',
  vertically='<>',
  outward='',
  vertical='<>',
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
  ['<or>']='<>',
  ['or']=''
}

function stringToMove(str,o)
  if str:find('Hop')then o.highlightOn(Color.Green)end
  local s=str:gsub('[%s&]+','')
  for k,v in pairs(replacement)do
    s=s:gsub(k,v)end
  if s:find('[aeiou]')then
    o.highlightOn(Color.Purple)end
  return 'Move={'..s..'}' end

doFunction={
  CURV=function(s,o)
    local c=s:match('CURV:(.*)'):gsub(',','.')
    return'CURV:'..c end,
  Class=function(s,o)
    local c=s:match('Class: (.*)')
    if o.getDescription():find('Type: Pawn')then
      o.setColorTint(Color.Brown)
      c='[713B17]PAWN[-]'
    elseif c=='BOSS'then
      o.setColorTint(Color.Red)
      c='[DA1918]BOSS[-]'
    elseif c=='Null'then
      o.setColorTint(Color.Pink)
      c='[F570CE]NULL[-]'
    else 
      o.setColorTint(Color.White)
      c='[FFFFFF]NORM[-]'
    end
    return'Class: '..c end,
  ROYAL=function(s,o)
    if o.getColorTint()==Color.White then
      o.setColorTint(Color.Yellow)end
    return'[E6E42B]ROYAL[-]'end,
  Initial=function(s,o)
    if s:find('double%-step')then
      return'Move={IO>(2)}'else print(s)return s end
    end,
  Promotion=function(s,o)return s end,
  Hop   =function(s,o)return stringToMove(s,o)end,
  Move  =function(s,o)return stringToMove(s,o)end,
  Leap  =function(s,o)return stringToMove(s,o)end,
  Attack=function(s,o)return stringToMove(s,o)end
}

function parseValues(s,o)
  local info='[b]'..o.getName()..'[/b]'
  for string in s:gmatch('%- ([^\n]+)')do
    for k,v in pairs(doFunction)do
      if string:find(k)then
        local d=v
        if type(v)=='function'then d=v(string,o)end
        if d:len()>2 then info=info..'\n'..d end
        break
      end
    end
  end
  o.setGMNotes(info)
  o.clearButtons()
  o.createButton({
      function_owner=self,click_function='createCopy',
      color={0,0,0,0},width=900,height=900,
      tooltip='Right Click to get Descriptive moveset for '..info})
end

notationParlett={
  [',']='or',
  ['%.']='then',
  ['>=']='forward or sideways',
  ['<=']='backward or sideways',
  ['=']='sideways',
  ['X>']='diagonally forwards',
  ['X<']='diagonally backwards',
  ['X']='diagonally',
  ['%*']='orthogonally or diagonally',
  ['%+']='orthogonally',
  ['<>']='forward or backwards',
  ['>']='forwards',
  ['<']='backwards',
  ['~']='leaps',
  ['%^']='hop',
  ['C']='must capture',
  ['O']='cannot capture',
  ['I']='from starting position',
  ['W']='wide',
  ['N']='narrow',
  ['E']='from enemy territory',
  ['F']='from friendly territory',
  ['H']='from past board`s half',
}
funcyParlett={
  ['>=']='-1,0},{0,1},{1,0',
  ['<=']='-1,0},{0,-1},{1,0',
  ['='] ='-1,0},{1,0',
  ['X>']='-1,1},{1,1',
  ['X<']='-1,-1},{1,-1',
  ['X'] ='-1,-1},{-1,1},{1,1},{1,-1',
  ['%*']='-1,-1},{-1,0},{-1,1},{0,1},{1,1},{1,0},{1,-1},{0,-1',
  ['%+']='-1,0},{0,1},{1,0},{0,-1',
  ['<>']='0,1},{0,-1',
  ['>'] ='0,1',
  ['<'] ='0,-1'}
knightParlett={
  {'(%d)%-(%d)/(%d)','-a,-c},{-c,-a},{-c,a},{-a,c},{a,c},{c,a},{c,-a},{a,-c},{-b,-c},{-c,-b},{-c,b},{-b,c},{b,c},{c,b},{c,-b},{b,-c'},
  {'(%d)/(%d)%-(%d)','-a,-b},{-b,-a},{-b,a},{-a,b},{a,b},{b,a},{b,-a},{a,-b},{-a,-c},{-c,-a},{-c,a},{-a,c},{a,c},{c,a},{c,-a},{a,-c'},
  {'W%((%d)/(%d)'   ,'-b,-a},{-b,a},{b,a},{b,-a'},
  {'N%((%d)/(%d)'   ,'-a,-b},{-a,b},{a,b},{a,-b'},
  {'(%d)/(%d)'      ,'-a,-b},{-b,-a},{-b,a},{-a,b},{a,b},{b,a},{b,-a},{a,-b'}}
function parseMove(m,i)
  local n=m:match('%d+')or 1
  local s=m:gsub('[}{]','')
  local p=''
  for k,v in pairs(notationParlett)do
    s=s:gsub(k,function(b)
        if funcyParlett[k]then
          p=funcyParlett[k]:gsub('%d',function(c)return c*n end)
      end return' '..v end)end
  for _,v in pairs(knightParlett)do
    local a,b,c=m:match(v[1])
    if m:match(v[1])then
      p=v[2]:gsub('a',a):gsub('b',b)
      if c then p=p:gsub('c',c)end break
  end end
  if p==''then p='0,0'end
  return("\nfunction m%d(c)f('Moves%s',{{%s}},c)end\nself.addContextMenuItem('%s',m%d)"):format(i,s,p,m,i)
end

function onLoad()
  for _,o in pairs(getAllObjects())do
    if o.tag=='Tile'and o.getLock()then
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