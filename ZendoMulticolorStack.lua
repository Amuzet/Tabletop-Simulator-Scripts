--[[ Zendo Multicolor Pyramid Spawner ]]--
--[[             by Sound             ]]--

HEIGHT_SCL = 2.85

-- 1 : EQUAL HEIGHT
-- 2 : EQUAL AREA
-- 3 : STACK
currentDistribution = 0
distributionNames = { 'EQUAL\nHEIGHT', 'EQUAL\nAREA', 'STACK' }

function changeDistribution(obj, color, alt_click)
  currentDistribution = currentDistribution + IF(alt_click, -1, 1)
      if currentDistribution < 1                  then currentDistribution = #distributionNames
  elseif currentDistribution > #distributionNames then currentDistribution = 1 end

  self.editButton({
    index = 0,
    label = distributionNames[currentDistribution]
  })
end
function spawn()
  local pos = self.getPosition()
  local linesArrArr = self.getDescription():split('\n')
  for i=1, #linesArrArr, 1 do linesArrArr[i] = IF(linesArrArr[i] == '', {}, linesArrArr[i]:split(' ')) end

  local scale = getScaleForSize(#linesArrArr)

  spawnObjectData({
    data = getPyramidObject(linesArrArr),
    position = { x = pos.x, y = pos.y + 1, z = pos.z },
    rotation = { x = 0, y = 0, z = 0 },
    scale = { x = scale, y = scale, z = scale }
  })
end

function nop() end
function onLoad()
  --0
  self.createButton({
    click_function = 'changeDistribution',
    function_owner = self,
    label = '',
    position = {-0.36, 5, 0.25},
    rotation = {0, 180, 0},
    scale = {0.3, 0.3, 0.3},
    width = 400,
    height = 300
  })
  --1
  self.createButton({
    click_function = 'spawn',
    function_owner = self,
    label = 'Spawn',
    position = {-0.36, 5, 0.10},
    rotation = {0, 180, 0},
    scale = {0.3, 0.3, 0.3},
    width = 350,
    height = 200
  })

  changeDistribution()
end

pyramidSizes = {
  -- 1 : EQUAL HEIGHT
  function(k, N) return k/N end,
  -- 2 : EQUAL AREA
  function(k, N) return math.sqrt(k/N) end,
  -- 3 : STACK
  function(k, N) return getScaleForSize(k) / getScaleForSize(N) end
}
function getPyramidSize(k, N)
  if k == N then return 1 end
  return pyramidSizes[currentDistribution](k, N)
end

function getPyramidTransform(k, N)
  local size = getPyramidSize(k, N)
  return {
    posX = 0, posY = HEIGHT_SCL * (1 - size), posZ = 0,

    rotX = 0, rotY = 0, rotZ = 0,

    scaleX = size, scaleY = size, scaleZ = size
  }
end

function getPyramidObjectK(k, N, linesArr)
  local obj = {
    Name         = 'Custom_Model',
    Transform    = getPyramidTransform(k, N),
    ColorDiffuse = getColorDiffuse(linesArr),
    CustomMesh   = getCustomMesh(linesArr)
  }
  return obj
end
function getPyramidObject(linesArrArr)
  local N = #linesArrArr
  local base = getPyramidObjectK(N, N, linesArrArr[N])
  base.ChildObjects = {}
  for k=1,N-1,1 do if #linesArrArr[k] > 0 then
    table.insert(base.ChildObjects, getPyramidObjectK(k, N, linesArrArr[k]))
  end end
  return base
end

function getScaleForSize(size) return 0.630865 * math.sqrt((math.abs(size) ^ 0.929212) + 1.14529) end

function getColorDiffuse(linesArr)
  local color = linesArr[1]:lower()

  if(color == 'rainbow') then
    return { r = 255, g = 255, b = 255, a = 255 }
  end

  local ColorDiffuse = stringColorToRGB(color:sub(1,1):upper() .. color:sub(2))
  if(ColorDiffuse ~= nil) then return ColorDiffuse end

  ColorDiffuse = {}
  if(color:sub(1, 1) == '#') then
    ColorDiffuse.r = tonumber(QQ(color:sub(2, 3), '0'  ), 16) / 255
    ColorDiffuse.g = tonumber(QQ(color:sub(4, 5), '0'  ), 16) / 255
    ColorDiffuse.b = tonumber(QQ(color:sub(6, 7), '0'  ), 16) / 255
    ColorDiffuse.a = tonumber(QQ(color:sub(8, 9), '255'), 16) / 255
  else
    local rgb = string.split(color, ',')
    ColorDiffuse.r = tonumber(QQ(rgb[1], '0'  ), 10) / 255
    ColorDiffuse.g = tonumber(QQ(rgb[2], '0'  ), 10) / 255
    ColorDiffuse.b = tonumber(QQ(rgb[3], '0'  ), 10) / 255
    ColorDiffuse.a = tonumber(QQ(rgb[4], '255'), 10) / 255
  end

  return ColorDiffuse
end

DIFFUSE_URL = {
  ['-3'] = 'https://www.dropbox.com/s/glazz0wwfnyasto/httpsdldropboxusercontentcomu109809395icehousepaper3vertpng.png?dl=1',
  ['-2'] = 'https://www.dropbox.com/s/04oulbmj7rcqxu8/httpsdldropboxusercontentcomu109809395icehousepaper2vertpng.png?dl=1',
  ['-1'] = 'https://www.dropbox.com/s/75e6ur3nv8rezp3/httpsdldropboxusercontentcomu109809395icehousepaper1vertpng.png?dl=1',
    ['-0'] = 'https://www.dropbox.com/s/65wuenlvjr8ecpr/httpsdldropboxusercontentcomu109809395icehousepaper0vertpng.png?dl=1',
  ['0']  = '',
  ['1']  = '',
  ['2']  = '',
  ['3']  = '',
}
NORMAL_URL = {
  ['-3'] = '',
  ['-2'] = '',
  ['-1'] = '',
  ['-0'] = '',
  ['0']  = 'https://www.dropbox.com/s/77graglsf9tgcjo/httpsdldropboxusercontentcomu109809395icehouselelpng.png?dl=1',
  ['1']  = 'https://www.dropbox.com/s/r3akp3i9pnmk51g/httpsdldropboxusercontentcomu109809395icehouserebump1png.png?dl=1',
  ['2']  = 'https://www.dropbox.com/s/gyd012et1yqbvzm/httpsdldropboxusercontentcomu109809395icehouserebump2png.png?dl=1',
  ['3']  = 'https://www.dropbox.com/s/0tma3n89rmfq2tk/httpsdldropboxusercontentcomu109809395icehouserebump3png.png?dl=1'
}
function getCustomMesh(linesArr)
  local pips = Q(QQ(linesArr[2], 0), '', 0)
  return {
    MeshURL       = 'https://www.dropbox.com/s/j4tkgvyfscrbp76/httpsdldropboxusercontentcomu109809395icehousePyrRemapobj.obj?dl=1',
    DiffuseURL    = IF(linesArr[1]:lower() == 'rainbow',
              'https://slm-assets.secondlife.com/assets/15565068/lightbox/RAINBOW_TEXTURE.jpg?1479167310',
              QQ(DIFFUSE_URL[pips], pips)
            ),
    NormalURL     = QQ(NORMAL_URL[pips], pips),
    ColliderURL   = 'https://www.dropbox.com/s/sb35cjjf7bbfatt/httpsdldropboxusercontentcomu109809395icehousePyrTest2obj.obj?dl=1',
    Convex        = true,
    MaterialIndex = 0,
    TypeIndex     = 0,
    CastShadows   = true
  };
end

function IF(bool, a, b)
  if bool then return a end
  return b
end
function Q(a, b, c) return IF(a == b, c, a) end
function QQ(a, b)   return Q(a, nil, b)     end

--[ https://www.codegrepper.com/code-examples/lua/lua+split+string+into+table ]--
string.split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch('(.-)'..delimiter) do
        table.insert(result, match);
    end
    return result;
end