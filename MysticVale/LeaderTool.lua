--MysticValeLeaderTool

function onLoad()
self.createButton({tooltip='Your Color Back',width=150*7,height=250,position={0,0,1.98},click_function = 'Clicked',function_owner=self})
  DecalZone=getObjectFromGUID('4ad455')
  URL=Global.getVar('URL')
  Upgrade=false
  LeaderSTAUrls=Global.getTable('LeaderSTAUrls')
  LeaderUPUrls =Global.getTable('LeaderUPUrls')
end
--XML
function UpgradeOnOff()Upgrade=not Upgrade end

Back={
Red   ='1835785070117636843/BB2E163FC3FE63A5C64468A2F77755BD4D6EBE14/',
Green ='1835785070117636032/798CABAD5A879C1BE944E43CE0BA98AB24437B82/',
Blue  ='1835785070117634334/521A285321D49C4DF20075F61475DE7DCBDD3C3E/',
Yellow='1835785246686965260/F14D36C1AD0185C26E89023E5F9E0FE89E269241/',
Purple='1835786036379853517/49BB605E6B68F808BA9EFD1AB5FE467AFB4D0592/',
White ='1835786036379852826/36C0D6C73FB3CC5C115F41426CB6F9778375F9A9/',
}

function Clicked(o,c,a)
  for _, Card in ipairs(DecalZone.getObjects()) do
    if Card.type=='Card' then

      local CardName = Card.getName()
      if CardName==''then print('Failed')break end
      --Images
      local Front=LeaderSTAUrls[CardName]
      if Front==nil then print('Undifined STA for Card in GLOBAL')break end
      if Upgrade then Front=LeaderUPUrls[CardName]
        if Front==nil then
        --Unsleaved Leaders
          Player[c].braodcast('Leader becomes Unsleaved and stays out of deck. Copy a New Blank in your deck to replace it.')break end
      end
      Front=URL..Front
      
      Card.clone().setCustomObject({type=0,face=Front,back=URL..Back[c]})
end end end 
--EOF