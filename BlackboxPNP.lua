DECK_ZONE='8cf2f1'
RAND_ZONE='ed593d'
PLY5_ZONE='ace2f5'
EXTR_ZONE='599184'
RULE_ZONE='8c2fb4'
SPLY_ZONE='a03134'

Bag={
['6d6f39']='Brown',
['378c50']='Purple',
['08eb52']='Green',
['b3fd43']='Pink',
['1f75bb']='Orange',
}
STORAGE='c5027a'

function onLoad()
	print('onLoad!')
	rndZ=getObjectFromGUID(RAND_ZONE)
	rndZ.randomize()
	
	updateSupplyUI(getObjectFromGUID(SPLY_ZONE),{getDescription=function()return' cube'end})
	
	for g,c in pairs(Bag)do
		local b=getObjectFromGUID(g)
		updateBagUI(b)
		b.addContextMenuItem('Grab Cube Red'   ,grabRC)
		b.addContextMenuItem('Grab Cube Blue'  ,grabUC)
		b.addContextMenuItem('Grab Cube Yellow',grabYC)
		b.addContextMenuItem('Grab Cube Black' ,grabBC)
	end
	
	addContextMenuItem('Start Game',Setup)
end

function Setup()
  local deckZone=getObjectFromGUID(DECK_ZONE)
  local decks=deckZone.getObjects()

  for _,o in ipairs(rndZ.getObjects())do
    if o.type=='Deck'then
			o.shuffle()
			InstantModule(o)
      table.insert(decks,o)
    end
  end

  rDeck=group(decks)[1]
  Wait.time(function()rDeck.randomize()end,1)
  Wait.time(DealCards,2)
end

function DealCards()
	rDeck.setName('Grid card draw pile')
	rDeck.dealToAll(3)
	Player5(rDeck)
	for _,o in ipairs(getObjectFromGUID(SPLY_ZONE).getObjects())do
		if o.type=='Block'then o.setLock(false)end
	end
end

function onObjectEnterZone(z,o)updateSupplyUI(z,o)end
function onObjectLeaveZone(z,o)updateSupplyUI(z,o)end

function onObjectEnterContainer(container, obj)
  if container.type=='Deck'then return true end

  if Bag[container.guid]then
    updateBagUI(container)
		container.shuffle()
  end
end

function grabRC(c,pos,o)grabCube(o,c,'red')end
function grabUC(c,pos,o)grabCube(o,c,'blue')end
function grabYC(c,pos,o)grabCube(o,c,'yellow')end
function grabBC(c,pos,o)grabCube(o,c,'black')end

function grabCube(o,c,cube)
	if not Bag[o.guid]==c then
		broadcastToAll(Player[c].steam_name..' Attempted to take from another`s bag!')
  end
	
end

function NA()end
ButtonBag={font_size=400,click_function='NA',function_owner=self,label='',width=0,height=0}
SupplyBtn={font_size=900,click_function='NA',function_owner=self,label='',widht=0,height=0,position={0,0,-24},scale={2,0,2}}

CubeList=[[ [b]
[881111]%s
[111188]%s
[aaaa11]%s
[555555]%s
[/b] ]]

function countCubes(obj)
  local r,u,y,b=0,0,0,0

  for _,o in ipairs(obj.getObjects())do
		local d=(o.getDescription and o.getDescription())or o.description
    if d==   'red cube'then r=r+1 end
    if d==  'blue cube'then u=u+1 end
    if d=='yellow cube'then y=y+1 end
    if d== 'black cube'then b=b+1 end
  end
	return CubeList:format(r,u,y,b)
end

function updateSupplyUI(z,o)
	if not(o.getDescription():find(' cube')and z.getGUID()==SPLY_ZONE)then
	  return end
	
  local btnHst=getObjectFromGUID(STORAGE)
	btnHst.clearButtons()
	
	SupplyBtn.label=countCubes(z):gsub('\n','   ')
	btnHst.createButton(SupplyBtn)
end


function updateBagUI(bag)
  local out=countCubes(bag)
  bag.clearButtons()

  ButtonBag.label=out:gsub('%b[]','')
  ButtonBag.position={0.02,0.86,0.02}
  bag.createButton(ButtonBag)

  ButtonBag.label='[b]'..out..'[/b]'
  ButtonBag.position={-0.02,0.87,-0.02}
  bag.createButton(ButtonBag)
end

function Player5(deck)
	if #getSeatedPlayers()>5 then return end
	deck.takeObject({flip=true, position=getObjectFromGUID(PLY5_ZONE).getPosition()})
end
function InstantModule(deck)
	local instant={}
	for _,o in ipairs(getObjectFromGUID(EXTR_ZONE).getObjects())do
		if o.getName():match('Instant %d')then
			o.setLock(true)
			table.insert(instant,o)
	end end
	if not instant[1] then return end
	
	local HRCD_CUBES={'1345ba','cfaf91','aa94c8','c63b11','378fa1','2f56c1','c4dbbb'}
	
	--Translations
	local tposCube={0.4,1,0.5}
	
	for j,o in ipairs(instant)do
		local ogPos=o.getPosition()
		o.translate({0,0.2,0})
		
		for i=1,2 do
			local rng=math.random(i,#HRCD_CUBES)
			local cube=getObjectFromGUID(HRCD_CUBES[rng])
			
			cube.setPosition(o.getPosition())
			
			for ii=1,j+i do
				deck.takeObject({flip=true,position=ogPos})
			end
		
			cube.translate(tposCube)
			table.remove(HRCD_CUBES,rng)
			tposCube[1]=-tposCube[1]
			cube.setRotation({0,0,0})
			
			Wait.time(function()cube.setLock(false)end,2)
		end
	
		
	end
end


--EOF