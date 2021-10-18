--DominionTokens
rT,oW,C2='Test','White',nil
B=setmetatable({click_function='click',function_owner=self,label=count,font_color=Color.Grey,scale={0.8,1,0.8},position={0,0.1,0},color={0,0,0},height=800,width=900,font_size=700,tooltip=''},{
  __call=function(t)self.clearButtons()
 rT,oW=self.getName(),self.getDescription()
 txt=oW..' [888888]%s %s '..rT..'.[-] |%s|'
 t.font_color=Color[oW]or Color.Purple:lerp(Color.Orange,0.5)
 t.label,t.tooltip=count,rT..'\nClick to Increase\nRight Click to Decrease'
 t.scale,t.position[2]={0.8,1,0.8},0.1
 if ('Pirate Ship CoinsVillagers'):find(rT)then
 elseif rT=='Owns Project'then t.position[2]=0.7
 else t.scale={1.1,1.1,1.1}end
 self.createButton(t)end})
function r()self.reload()end
function onload(s)self.addContextMenuItem('Reload',r)if s~=''then local ld=JSON.decode(s)count=ld.c else count=0 end B()end
function click(o,c,a)local n=1 if a then n=-n end change(o,c,n)end
function updateSave()self.script_state=JSON.encode({['c']=count})end
function wait(t)local s=os.time()repeat coroutine.yield(0)until os.time()>s+t end
function baker()count=count+1 self.editButton({index=0,label=count})updateSave()end
function getCount()return count end
function setOwner(params)
  oW,count=params[1],count+params[2]
  self.setDescription(oW)B()updateSave()end
--The Code
function change(_,__,v)
  local C3=count
  if count+v>=0 then count=count+v else count=0 end
  local C1=count
  function clickCoroutine()
    if C2==nil then C2=C3 end
    wait(3)
    if C2 and C1==count then
      local t,n='lost',math.abs(count-C2)
      if C1>C2 then t='gained'end
      if C1~=C2 then printToAll(txt:format(t,n,count),B.font_color)end
      C2=nil
    end return 1 end
  startLuaCoroutine(self,'clickCoroutine')
  self.editButton({index=0,label=count})
  updateSave()
end