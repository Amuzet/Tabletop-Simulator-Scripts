--By Amuzet
mod_name = 'Scryfall Drafter MTGBPG'
version = 1.1
author = '76561198045776458'
self.setName(mod_name..' '..version)

local Sets={}
function Set(c,s,x,y)
  local nilout={}
  local tbl=s
  if type(tbl)=='string'then tbl={s}end
  local xml="\n <VerticalScrollView id='%s' offsetXY='%d %d'><VerticalLayout color='#%s' height='%d'>"
  for _,st in ipairs(tbl)do
    for k,set in pairs(Sets)do
      if set.set_type == st then
        table.insert(nilout,1,k)
        xml = xml..string.format(
"\n  <Button class='%s' id='%s' tooltip='%s'>%s</Button>",
set.set_type,set.code,set.card_count,set.name)end end end
  xml = xml:format(tbl[1],270*x,270*y,c,#nilout*100)
  for _,v in ipairs(nilout)do table.remove(Sets,v)end
  return xml .. '\n </VerticalLayout></VerticalScrollView>'
end

function parseList(url,tbl,check,keep)
  WebRequest.get(url,function(wr)
      if not wr.text:find('"object":"list"')then
        return printToAll('Scryfall returned: '..wr.text:match('"details":.+'))end
      local text=wr.text:sub(2)
      local previousSet=''
      for set in text:gmatch('%b{}')do
        if set:find('parent_set_code:"'..previousSet)and set:find('Token')then
          
        end
        for s in check:gmatch('%S+')do
        --check='Un%a+ Jumpstart core expansion masters draft_innovation'
          if set:find('"'..s)or set:find(s..'"')then
            --ElementsToKeep
            local t={}
            for f in keep:gmatch('%S+')do
              --'code name set_type card_count icon_svg_uri'
              t[f]=set:match('"'..f..'":.+,')
            end
            break
          end
        end
      end
      if wr.text:match('has_more":true,')then
        parseList(wr.text:match('next_page":"([^"]+)'),tbl,check,keep)end
    end)
end
--[[What is needed for this to work for card list?
parseList('https://scryfall.com/search?order=set&q=set%3A'..SETCODE..'+is%3Abooster&unique=cards',
  CARDS,'common uncommon rare mythic',
  'name cmc rarity highres_image small normal type_line colors oracle_text power toughness loyalty')
  ]]
function updateSets()
  parseList('https://api.scryfall.com/sets',Sets,
    'Un%a+ Jumpstart core expansion masters draft_innovation',
    'code name set_type card_count icon_svg_uri')
  local XML = [[<!-- By Amuzet -->
<Defaults>
 <Button onClick='onChoice' color='#AAAAAA33' resizeTextForBestFit='true' fontSize='30' fontStyle='Bold'/>
 <VerticalScrollView scrollSensitivity='45' hight='620' width='520'/>
</Defaults>
<Panel rotation='0 0 0' position='-777 -700'>]]..
Set('CFBA56','masters')..
Set('CF5656','core')..
Set('56458E',{'draft_innovation','funny'})..
Set('45A545','expansion')..'</Panel>'
  editNotebookTab({index=1,title='DraftXML',body=XML})
  printToAll('New XML pasted into NotebookTab: DraftXML\nCopy and paste it onto this object`s UI tab in `Modding>Scripting`')
  self.reload()
end
function context()
  if #getSeatedPlayers()>1 then return printToAll('Update is restricted to single player only. It Will crash connected players.')end
  updateSets()
end
function onLoad()
self.addContextMenuItem('Single Player:Update',context)
end
--Variables
local Pos = self.getPosition()
local Count = 0
local Basic = false
local TAG  = ''
local Back = ''
--CardClass
local Card = setmetatable({
    n = 1,
    --TTS
    json = '',
    position = self.getPosition(),
    snap_to_grid = true,
    callback = 'INC',
    callback_owner = self,
    },{
    __call = function(t,nametype,oracle,face,p)
      t.position = p
      t.json = string.format(
        '{"Name":"Card","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":0,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},"Nickname":"%s","Description":"%s","CardID":%i00,"CustomDeck":{"%i":{"FaceURL":"%s","BackURL":"%s","NumWidth":1,"NumHeight":1,"BackIsHidden":true}}}',
        nametype , oracle , t.n , t.n , face , Back
        )
      
      spawnObjectJSON(t)
    end
  })

function INC(obj)
  Card.n = Card.n + 1
end

function onChoice(p, _, id)
  local name = self.UI.getAttribute(id, 'text')
  self.setRotation({0,0,0})
  if p.host and TAG ~= id then
    if TAG == '' then
      self.setLock(true)
    end
    TAG = id
    Count = self.UI.getAttribute(id, 'tooltip'):match('%d+')
    broadcastToAll('Type `Load '..id..' Draft` to Load '..name..'\n[dc143c]Warning: [4682b4]Server may Lag loading [ffffff]'..Count..' Cards')
  else
    printToAll(p.steam_name .. ' Voted for ' .. name)
  end end

function onChat(m,p) if p.host and m == 'Load '..TAG..' Draft' then setSet() end end

function setOracle(card)
  local n=''
  if card.power then
    n = card.power ..'/'.. card.toughness
  else
    n = card.loyalty or ' '
  end
  return string.format(--Name ManaCost\nType\nOracle\nNumbers
    '[b]%s[/b] %s\n%s\n%s\n[b]%s[/b]',
    card.name, card.mana_cost, card.type_line, card.oracle_text, n):gsub('\"',"'")
end

function setSet()
  Back = self.getDescription()
  broadcastToAll('Loading Cards',{0,0.6,0.6})
  for i=1, Count do
    Wait.time(function()
        WebRequest.get('https://api.scryfall.com/cards/'..TAG..'/'..i,self,'cardPosition')
        end,i*0.15)
  end
end

function zonePos(a)
  local guid = Global.getVar('ZONE_'..a)
  Pos = getObjectFromGUID( guid ).getPosition()
end

function cardPosition(b)
  local tx=b.text:gsub(',"prices":.*','}')
  local card = JSON.decode(b.text)
  if card.type_line:find('Basic') then --Basic
    zonePos('LANDS')
    Basic = true
  elseif card.type_line:find('Token') then
    zonePos('TOKENS')
  elseif not card.booster then --ESCAPES cards not in boosters
    --check if user wants foil
    if false then
      
    end
    INC() return false
  elseif card.rarity == 'common'   then
    local color = card.colors or false
    
    if not color then color = card.card_faces[0].colors end
    
    if card.type_line:find('Gate') then
      zonePos('LANDS')
    elseif color[2] or color[1] == nil then
      zonePos('OTHER_COMMONS')
    elseif color[1] == 'W' then
      zonePos('WHITE_COMMONS')
    elseif color[1] == 'U' then
      zonePos('BLUE_COMMONS')
    elseif color[1] == 'B' then
      zonePos('BLACK_COMMONS')
    elseif color[1] == 'R' then
      zonePos('RED_COMMONS')
    elseif color[1] == 'G' then
      zonePos('GREEN_COMMONS')
    end
  else zonePos(card.rarity:upper()..'S') end

  local face,name,oracle = '',card.name..'\n'..card.type_line,''
  if card.card_faces then
    for _,f in ipairs(card.card_faces)do
      oracle = oracle ..'\n'.. setOracle(f)
    end
  else
    oracle = setOracle(card)
    if (card.watermark and card.watermark=='conspiracy')
    -- (card.frame_effects and card.frame_effects[1]=='draft')
    or (TAG == 'war' and card.type_line == 'Planeswalker') then
      zonePos('SPECIAL')
    end
  end
  
  if card.image_uris then
    face = card.image_uris.normal:gsub('%?.*','')
  else
    face = card.card_faces[1].image_uris.normal:gsub('%?.*','')
  end
  
  if not card.highres_image then
    --Change quality to small if no Highres Image is avaliable
    face = face:gsub('normal','small')
  end
  
  Card( name, oracle, face, Pos)
  if not card.image_uris then
    zonePos('SPECIAL')
    Card( name, oracle, face, Pos)
  end
end
--EOF