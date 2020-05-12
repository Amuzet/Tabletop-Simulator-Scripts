function onLoad(d)local n=tonumber(d:match('%d+'))
  self.createButton({rotation={0,261+18*n,0},tooltip=n,label=d,function_owner=self,click_function='click',width=2500,height=200,position={0,0.2,0},scale={0.5,0.5,0.5},color={0,1,0}})end
function onPlayerTurn(c)
  if self.script_state:match('%w+')==c then asdf(1)
  elseif self.script_state:match('%w+')=='Black'then
    self.script_state=self.script_state:gsub('%w+',c)
end end
function click(o,p,a)if a then asdf(-1)else asdf(1)end end
function asdf(a)
  local n=tonumber(self.script_state:match('%-?%d+'))+a
  self.script_state=self.script_state:gsub('%-?%d+',n)
  self.editButton({index=0,rotation={0,261+18*n,0},color=c[math.floor((n-1)/5)%4+1],
      tooltip=self.script_state,label=('      >->    >->  %s  >->    >->    >>'):format(self.script_state)})
end
c={{0,1,0},{1,1,0},{1,0,0},{0,0,1}}