local mats={}
local K='UNINTERACTABLE'

function changeState(o,c,a)
  --ChessBoard States
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

MFUNC="\nfunction m%d(c)f('Moves%s',{{%s}},c)end\nself.addContextMenuItem('%s',m%d)"
function setScript(obj,c)
--Name,TblOfMoves,colorPlayer
  local script,n=[[function f(a,b,c)local l=self.getColorTint():lerp(Color(0,0,0,0),0.2)N()for i,t in pairs(b)do
self.createButton({position={t[1]*4.5,0.2,-t[2]*4.5},tooltip=a,click_function='N',function_owner=self,width=700,height=700,color=l})end
Player[c].broadcast(a,l)end
function onLoad()N=self.clearButtons]],obj.getGMNotes()
  local i,allMoves,allMovesDescribed,t,r=0,'','','','},{'
  for move in n:gmatch('M.-=(%b{})')do
    i=i+1
    local m,p,s=parseMove(move,i)
    if i>1 then m=r..m end
    allMovesDescribed=allMovesDescribed..p..'\\nMoves'
    allMoves=allMoves..m
    t=t..s
  end
  if i>1 then
    local name=allMovesDescribed:sub(1,-8)
  --script=script:gsub('then m1','then m0') function onHover(c)if not self.getButtons() then m1(c)end end
    script=script..MFUNC:format(0,name,allMoves,'All Possible Moves',0)
  end
  script=script..t..'\nend'
  obj.setLuaScript(script:gsub(',{}',''))
  obj.setDescription(n..'\nMoves'..allMovesDescribed:gsub('\\nMoves','\nMoves'))
  Player[c].print(n)
end
function createCopy(obj,r,a)
  local c=r or'White'
  if a then Player[c].print(obj.getName()..obj.getDescription())return end
  local h=Player[c].getHandTransform()or{position={1.7,2,34}}
  h.position[3]=h.position[3]/42.5
  local dup=obj.clone({position=h.position})
  dup.setLock(false)
  dup.setColorTint(Color[c])
  setScript(dup,c)
end

replacement={
  hipogonally='P',
  hippogonally='P',
  forwardP='*>',
  backwardP='*<',
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
  vertical='<>',
  [';']='/',
  [',']='/',
  ['and']='.',
  ['then']='.',
  --NonStandardNotation
  ['Coup.againstRoyalunit.:']='R',
  wide='W',
  narrow='N',
  outward='',
  repeatedly='',
  inenemyterritory='E',
  infriendlyterritory='F',
  ['pastboard\'shalf']='H',
  P='',
  ['Xor%+']='*',
  ['%+orX']='*',
  ['<or>']='<>',
  ['or']='',
  ['%*>%*<']='*<>',
  ['%*<%*>']='*<>',
  ['W=']='W'}

function stringToMove(str,o)
  if str:find('Hop')then o.highlightOn(Color.Green)end
  local s=str:gsub('[%s&]+','')
  for k,v in pairs(replacement)do
    s=s:gsub(k,v)end
  if s:find('[aeiou]')then
    o.highlightOn(Color.Purple)end
  --reformat NarrowWide modifier to end
  if s:find('[NW][^(]')then
    s=s:gsub('([NW])([^(]+)','%2%1')end
  
  return'Move={'..s..'}'end

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
  if self.getDescription():find('CreateAll')then
    createCopy(o)else
  o.createButton({
      function_owner=self,click_function='createCopy',
      color={0,0,0,0},width=900,height=900,
      tooltip='Right Click to get Descriptive moveset for '..info})
end end

notationParlett={
{',','or'},
{'%.','\\n  then'},
{'>=','forward or sideways','-1,0},{0,1},{1,0'},
{'<=','backward or sideways','-1,0},{0,-1},{1,0'},
{'=','sideways','-1,0},{1,0'},
{'X>','diagonally forwards','-1,1},{1,1'},
{'X<','diagonally backwards','-1,-1},{1,-1'},
{'X','diagonally','-1,-1},{-1,1},{1,1},{1,-1'},
{'%*<>','forward, backward and diagonally','-1,-1},{-1,1},{0,1},{1,1},{1,-1},{0,-1'},
{'%*>','forward including diagonally','-1,1},{0,1},{1,1'},
{'%*<','backward including diagonally','-1,-1},{1,-1},{0,-1'},
{'%*','orthogonally or diagonally','-1,-1},{-1,0},{-1,1},{0,1},{1,1},{1,0},{1,-1},{0,-1'},
{'%+','orthogonally','-1,0},{0,1},{1,0},{0,-1'},
{'<>','forward or backwards','0,1},{0,-1'},
{'>','forwards','0,1'},
{'<','backwards','0,-1'},
{'~','leaps'},
{'%^','must hop over another piece'},
{'C','must capture'},
{'O','cannot capture'},
{'I','from starting position'},
{'R','must capture a Royal unit'},
{'W','wide'},
{'N','narrow'},
{'E','from enemy territory'},
{'F','from friendly territory'},
{'H','from past board`s half'}}

Q='%d,%d},{%d,%d},{'
function Z(i,j)return(Q..Q):format(i,j,-i,-j, -i,j,i,-j)end

knightParlett={--x,y,a,b
{'%((%d)%-(%d)/(%d)%-(%d)%)',function(t)local s=''
  for i=t.x,t.y do for j=t.a,t.b do s=s..Z(i,j)end end return s end},
{'(%d)%-(%d)/(%d)',
 function(t)local s=''for i=t.x,t.y do s=s..Z(i,t.a)end return s end},
{'(%d)/(%d)%-(%d)',
 function(t)local s=''for i=t.y,t.a do s=s..Z(t.x,i)end return s end},
{'[^<]+([<>])([WN])%((%d)/(%d)%)', --This is Either ><
 function(t)local n=1 if t.x=='<'then n=-1 end
  if t.y=='N'then
    return Q:format(t.a,n*t.b,-t.a,n*t.b)else
    return Q:format(t.b,n*t.a,-t.b,n*t.a)end end},
{'N%((%d)/(%d)',function(t)return Z(t.x,t.y)end},
{'W%((%d)/(%d)',function(t)return Z(t.y,t.x)end},
{'[^<]*([<>])%((%d)/(%d)%)',function(t)local n=1 if t.x=='<'then n=-1 end
 return(Q..Q):format(t.y,n*t.a,t.a,n*t.y,-t.y,n*t.a,-t.a,n*t.y)end},
{'%((%d)/(%d)%)',function(t)return Z(t.x,t.y)..Z(t.y,t.x)end}}

function parseMove(h,i)
  local n=h:match('%d+')or 1
  local m=h:match('%(%d+%-(%d+)%)')or(h:match('∞')and 7)or n
  local s=h:gsub('[}{]','')
  local p=''
  
  for _,v in pairs(notationParlett)do
    s=s:gsub(v[1],function(b)
      if v[3]then
        for i=n,m do
          p=p..v[3]:gsub('%d',function(c)return c*i end)
          if n~=m then p=p..'},{'end
        end
      end return' '..v[2]
    end)
  end
  
  for _,v in pairs(knightParlett)do
    if h:match(v[1])then local t={}
      t.x,t.y,t.a,t.b=h:match(v[1])
      p=v[2](t)break
  end end
  
  if p==''then p='0.5,0.5'end
  return p,s,MFUNC:format(i,s,p,h,i)
end


function onChat(m)if m:lower():find('customchess:')then
  local t,d={},''
  --customchess:New Pawn:2:
  for s in m:gmatch(':([^:]+)')do
    table.insert(t,s)end
  
  t[2]='CURV: '..t[2]
  
  for _,v in pairs(t)do
    d=d..'- '..v..'\n'end
  
  local obj=spawnObject({
    type='Custom_Token',position={0,3,0},scale={0.36,1,0.36},
    callback_function=function(o)o.setDescription(d)o.setName(t[1])parseValues(d,o)end})
  obj.setCustomObject({thickness=0.1,merge_distance=15,stackable=false,
image='http://cloud-3.steamusercontent.com/ugc/1628571207900218122/74A391A0E2668A3DF598683ADEF674F953E4700C/'})
end end

function onLoad()
  if not self.getDescription():find('%WON%W')then
    print('Chess parser is off, type :ON: into descrption then respawn it for it to do things onLoad.')return end
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