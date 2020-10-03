function updateSave()self.script_state=JSON.encode({['c']=count})end
function wait(t)local s=os.time()repeat coroutine.yield(0)until os.time()>s+t end
function baker()count=1 self.editButton({index=0,label=count})updateSave()end
function getCount()return count end
function setOwner(params)oW,count=params[1],count+params[2]
  txt=oW..' [888888]%s %s '..rT..'.[-] |%s|'
  self.editButton({index=0,label=count})self.setDescription(oW)updateSave()end
function onload(s)
  if s~=''then local ld=JSON.decode(s)count=ld.c else count=0 end
  rT,oW=self.getName(),self.getDescription()
  txt=oW..' [888888]%s %s '..rT..'.[-] |%s|'
  if stringColorToRGB(oW)then clr=stringColorToRGB(oW)end
  local a,b=0.9,{click_function='click',function_owner=self,label=count,font_color=clr,position={0,0.1,0},color={0,0,0,0.7},scale={0.8,1,0.8},height=600,width=600,font_size=1500,tooltip=rT..'\nClick to Increase\nRight Click to Decrease'}
  if rT=='Owns Project'then b.position[2]=0.7
  elseif ('Pirate Ship CoinsVillagers'):find(rT)then b.position[2]=0.1
  else a,b.scale=1.3,{1.1,1.1,1.1}end


  self.createButton(b)
  b.position[2],b.font_size=0,1000
  self.createButton(b)
end
function click(o,c,a)local n=1 if a then n=-n end change(o,c,n)end
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
      if C1~=C2 then printToAll(txt:format(t,n,count),clr)end
      C2=nil
    end return 1 end
  startLuaCoroutine(self,'clickCoroutine')
  self.editButton({index=0,label=count})
  updateSave()
end
rT,oW,clr,C2='Test','White',{1,1,1},nil