tbl = {"bb0b4f", "8cf7ae", "7ba0bf",
  "25756f", "d8a850", "de9a73",
  "1e113a", "3ba1c2", "61ae8d",
  "2ea60a","d5f986", "f7a574",
  "811c7b", "f0bd83", "fa020b",
  "5bd468", "a96aef", "e6fed4",
  "fb0663", "5e6695", "755720",
  "b6ce05", "bf7652", "4733fe",
  "7fb923", "a6f52e", "bf9dda",
  "7535f5", "eaf95e", "adb237"}
data = {
{pos = {-14.3, 1.1, 18.3}, guid = "bb0b4f"},
{pos = {-14.3, 1.1, 13.45}, guid = "8cf7ae"},
{pos = {-14.3, 1.1, 23.15}, guid = "7ba0bf"},
{pos = {-17.7, 1.1, 18.3}, guid = "25756f"},
{pos = {-17.7, 1.1, 13.45}, guid = "d8a850"},
{pos = {-17.7, 1.1, 23.15}, guid = "de9a73"},
{pos = {-21.1, 1.1, 18.3}, guid = "1e113a"},
{pos = {-21.1, 1.1, 13.45}, guid = "3ba1c2"},
{pos = {-21.1, 1.1, 23.15}, guid = "61ae8d"},
{pos = {-24.5, 1.1, 18.3}, guid = "2ea60a"},
{pos = {-24.5, 1.1, 13.45}, guid = "d5f986"},
{pos = {-24.5, 1.1, 23.15}, guid = "f7a574"},
{pos = {-27.9, 1.1, 18.3}, guid = "811c7b"},
{pos = {-27.9, 1.1, 13.45}, guid = "f0bd83"},
{pos = {-27.9, 1.1, 23.15}, guid = "fa020b"},
{pos = {-31.3, 1.1, 18.3}, guid = "5bd468"},
{pos = {-31.3, 1.1, 13.45}, guid = "a96aef"},
{pos = {-31.3, 1.1, 23.15}, guid = "e6fed4"},
{pos = {-34.7, 1.1, 18.3}, guid = "fb0663"},
{pos = {-34.7, 1.1, 13.45}, guid = "5e6695"},
{pos = {-34.7, 1.1, 23.15}, guid = "755720"},
{pos = {-38.1, 1.1, 18.3}, guid = "b6ce05"},
{pos = {-38.1, 1.1, 13.45}, guid = "bf7652"},
{pos = {-38.1, 1.1, 23.15}, guid = "4733fe"},
{pos = {-41.5, 1.1, 18.3}, guid = "7fb923"},
{pos = {-41.5, 1.1, 13.45}, guid = "a6f52e"},
{pos = {-41.5, 1.1, 23.15}, guid = "bf9dda"},
{pos = {-44.9, 1.1, 18.3}, guid = "2ea60a"},
{pos = {-44.9, 1.1, 13.45}, guid = "d5f986"},
{pos = {-44.9, 1.1, 23.15}, guid = "f7a574"},
{pos = {-48.3, 1.1, 18.3}, guid = "7535f5"},
}
Scale = {0.34,0.35,0.34}
PD = {3.4,1.1,4.85}
StartPosition = {-14.5,1.1,23.15}

function onDrop()
  local text,form = "", '{pos = {%s, %s, %s}, guid = "%s"}\n'
  for i,v in ipairs(tbl) do
    local pos = {
      StartPosition[1]-PD[1]*((math.ceil(i/3)-1)),
      PD[2],
      StartPosition[3]-PD[3]*(i%3)}
    local obj = getObjectFromGUID(v)
    obj.setLock(true)
    obj.interactable = false
    obj.setScale(Scale)
    obj.setRotation({0,0,0})
    obj.setPosition(pos)
    text = text .. form:format(tostring(pos[1]),tostring(pos[2]),tostring(pos[3]),v)
  end
  addNotebookTab({
      title = 'Extra Piles',
      body = text})
end
function onCollisionEnter(info) print(info.collision_object.getGUID()) end