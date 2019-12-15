--By Amuzet
mod_name = 'Scryfall Drafter Updater'
version = 1
author = '76561198045776458'
self.setName(mod_name..' '..version)

local Sets = {}

function Set( c , s , x , y )
  local nilout = {}
  local tbl = s
  if type(tbl) == 'string' then tbl = {s} end
  local xml = '\n <VerticalScrollView id="%s" offsetXY="%d %d"><VerticalLayout color="#%s" height="'
  xml = xml:format(tbl[1],270*x,270*y,c) .. '%d">'
  for _,st in ipairs(tbl)do
    for k,set in pairs(Sets.data)do
      if set.set_type == st then
        table.insert(nilout,1,k)
        xml = xml .. string.format(
          '\n  <Button id="%s" tooltip="%d">%s</Button>',
          set.code, set.card_count, set.name)
  end end end
  xml = xml:format(#nilout*100)
  for _,v in ipairs(nilout)do table.remove(Sets.data,v)end
  return xml .. '\n </VerticalLayout></VerticalScrollView>'
end

function onDrop()
  WebRequest.get('https://api.scryfall.com/sets',function(wr)
      Sets = JSON.decode( wr.text )
      local XML = [[<!-- By Amuzet -->
<Defaults>
 <Button onClick="onChoice" resizeTextForBestFit="true" fontSize="30" fontStyle="Bold"/>
 <VerticalScrollView scrollSensitivity="25" hight="520" width="520"/>
</Defaults>
<Panel scale="0.7 0.7" position="0 0 -51">]]..Set('CFBA56', 'masters',1,-1)..Set('CF5656', 'core',-1,1)..Set('56458E', {'draft_innovation','funny'},-1,-1)..Set('45A545', 'expansion',1,1)..'</Panel>'--Green,Yellow,Red,Purple
      
      editNotebookTab({ index=1, title='DraftXML', body=XML})
      
      self.setLuaScript([[--By Amuzet
mod_name = 'Scryfall Drafter'
version = ]]..version..[[ 
author = '76561198045776458'
self.setName(mod_name..' '..version)]])
      self.reload()
    end
  )
end
--EOF