local mfl, mce = math.floor, math.ceil
local msq = math.sqrt

local img = nil
local pic = {}
local h, w, k = 500, 500, 500
local act = {}
local t = {}
local buf = {}
local gd = 10
local score = 0
local way = true

function love.load()
  img = love.graphics.newImage("marbling/input.png")
  local f = io.open("marbling/input.txt", "rb")
  f:read()
  for i = 1, h do
    pic[i] = {}
    t[i] = {}
    buf[i] = {}
    local s = f:read()
    for j = 1, w do
      pic[i][j] = s:sub(j, j) == "#"
      t[i][j] = false
    end
  end
  f:close()
end

local luaout = true
local function writewrap(f, txt)
  if luaout then
    f:write('io.write("')
    f:write(txt)
    f:write('\\n")\n')
  else
    f:write(txt .. "\n")
  end
end

local function save()
  local f = io.open("out.lua", "w")
  f:write("-- https://github.com/obakyan/atcoder_xmas2022_visualizer\n")
  writewrap(f, mfl(#act / 4))
  for i = 1, #act, 4 do
    local px, py, pw, sz = act[i], act[i + 1], act[i + 2], act[i + 3]
    if pw then
      writewrap(f, "drop " .. px .. " " .. py .. " " .. sz .. " 255 255 255")
    else
      writewrap(f, "drop " .. px .. " " .. py .. " " .. sz .. " 0 0 0")
    end
  end
  f:close()
end

local function updateScore()
  local forward = true
  for i = 1, h do for j = 1, w do
    t[i][j] = false
  end end
  for i = 1, #act, 4 do
    local px, py, pw, sz = act[i], act[i + 1], act[i + 2], act[i + 3]
    local src = forward and t or buf
    local dst = forward and buf or t
    for y = 1, h do
      for x = 1, w do
        local len = (x - px) * (x - px) + (y - py) * (y - py)
        if len <= sz * sz then
          dst[y][x] = pw
        else
          local dx = px + msq(1 - sz * sz / len) * (x - px)
          local dy = py + msq(1 - sz * sz / len) * (y - py)
          dx = mfl(dx + 0.5)
          dy = mfl(dy + 0.5)
          if 0 < dx and dx <= w and 0 < dy and dy <= h then
            dst[y][x] = src[dy][dx]
          end
        end
      end
    end
    forward = not forward
  end
  if not forward then
    for i = 1, h do for j = 1, w do
      t[i][j] = buf[i][j]
    end end
  end
  score = 0
  for i = 1, h do
    for j = 1, w do
      if t[i][j] ~= pic[i][j] then score = score + 1 end
    end
  end
end

function love.keypressed(key, scancode, rep)
  if key == "space" then
    way = not way
  end
  if key == "z" then
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
      if 0 < #act then
        table.remove(act)
        table.remove(act)
        table.remove(act)
        table.remove(act)
        updateScore()
      end
    end
  end
  if key == "s" then
    save()
  end
  if key == "up" then
    gd = math.max(3, gd - 1)
  end
  if key == "down" then
    gd = gd + 1
  end
end

function love.mousepressed(x, y, btn, _u)
  table.insert(act, x)
  table.insert(act, y)
  table.insert(act, way)
  table.insert(act, gd)
  updateScore()
end

function love.draw()
  love.graphics.setColor(0, 0.2, 0.5)
  love.graphics.rectangle("fill", 0, 0, 700, 500)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(img, 0, 0)
  for i = 1, h do
    for j = 1, w do
      if t[i][j] then
        if pic[i][j] then
          love.graphics.setColor(0, 0, 1)
        else
          love.graphics.setColor(1, 0, 0)
        end
        love.graphics.points(j, i-1)
      end
    end
  end
  local mx = love.mouse.getX()
  local my = love.mouse.getY()
  love.graphics.setColor(0.5,0.5,0.5)
  love.graphics.circle("line", mx, my, gd)
  love.graphics.setColor(1,1,1)
  love.graphics.print("SCORE " .. score, 500, 0)
  love.graphics.print("COUNT " .. mfl(#act / 4), 500, 20)
  love.graphics.print("MODE " .. (way and "Draw" or "Erase"), 500, 40)
  love.graphics.print("SIZE " .. gd, 500, 60)
  love.graphics.print("put: click", 500, 200)
  love.graphics.print("undo: ctrl+z", 500, 220)
  love.graphics.print("change draw/erase: space", 500, 240)
  love.graphics.print("save: s", 500, 260)
  love.graphics.print("size minus: up", 500, 280)
  love.graphics.print("size plus: down", 500, 300)
end

