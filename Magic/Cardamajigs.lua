--Cardamajigs

Card = setmetatable({type='Card',rotation={x=0, y=180, z=0}},{
    __call = function(t,url,name)
      print(name..' '..url)
      local c = spawnObject(t)
      c.setCustomObject({
          face=url,
          back='https://i.stack.imgur.com/787gj.png',
        })
      c.setName(name)
      c.reload()
    end
  })

function onChat(m)
  if m:find('cardamajigs') then
    WebRequest.get(m, function(wr)
        for _,v in ipairs({'jpg','png'}) do
          string.gmatch()
          wr.text:gsub('img src="(//cdn.shopify.com/s/files/%S+'..v..')%?%d+" alt="(.+)"',function(a,b)
              print(v,a,b)
              Card('https:'..a,b)
            end)
        end
      end)
  end
end
--https://cdn.shopify.com/s/files/1/0790/8591/products/Butzbo_Servo01_305x.jpg?v=1527072623