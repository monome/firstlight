-- first light: call to edit
-- 1.0.0 @tehn
-- l.llllllll.co/firstlight
--
-- see norns study zero!
--
-- E1 set sequence length
-- E2 change edit position
-- E3 change step value
--
-- K2 toggle sequence
-- K3 toggle chimes

-- lines starting with "--" are comments, they don't get executed

-- find the --[[ o_o ]]-- for good places to edit!

engine.name = 'PolyPerc'

g = grid.connect()


-- make a table of numbers, along with variables
-- to track length and current position
numbers = {3,0,8,5,1,2,3,4,0,7,2,1,8,6,4,2}
length = 6
pos = 0

edit = 1 -- which number we're editing

-- on/off for stepped sequence and chimes
sequence = true
chimes = true


-- system clock tick
-- this function is started by init() and loops forever
-- if the sequence is on, it steps forward on each tick
-- tempo is controlled via the global clock, which can be set in the PARAM menu 
tick = function()
  while true do
    clock.sync(1)
    if sequence then step() end
  end
end

-- sequence step forward
-- advance the position and do something with the number
step = function()
  pos = util.wrap(pos+1,1,length)
  --[[ 0_0 ]]--
  softcut.loop_end(1,numbers[pos]/8)
end

-- wind blows chimes play
-- this funcion plays all of the notes in a table, in a random order and
-- with random delay in between each. a new pattern is played periodically.
wind = function()
  while(true) do
    light = 15
    --[[ 0_0 ]]--
    notes = {400,451,525,555}
    while chimes and #notes > 0 do
      if math.random() > 0.2 then
        engine.hz(table.remove(notes,math.random(#notes)))
      end
      clock.sleep(0.1)
    end
    clock.sleep(math.random(3,9))
  end
end


--------------------------------------------------------------------------------
-- init runs first!
function init()
  -- configure the synth
  engine.release(1)

  -- configure the delay
	audio.level_cut(1.0)
	audio.level_adc_cut(1)
	audio.level_eng_cut(1)
  softcut.level(1,1.0)
  softcut.level_slew_time(1,0.25)
	softcut.level_input_cut(1, 1, 1.0)
	softcut.level_input_cut(2, 1, 1.0)
	softcut.pan(1, 0.0)
  softcut.play(1, 1)
	softcut.rate(1, 1)                    
  softcut.rate_slew_time(1,0.25)
	softcut.loop_start(1, 0)
	softcut.loop_end(1, 0.5)
	softcut.loop(1, 1)
	softcut.fade_time(1, 0.1)
	softcut.rec(1, 1)
	softcut.rec_level(1, 1)
	softcut.pre_level(1, 0.85)            --[[ o_o ]]--
	softcut.position(1, 0)
	softcut.enable(1, 1)
	softcut.filter_dry(1, 0);
	softcut.filter_bp(1, 1.0);
	softcut.filter_fc(1, 300);
	softcut.filter_rq(1, 2.0);

  clock.run(tick)       -- start the sequencer
  clock.run(wind)       -- start the wind

  clock.run(function()  -- redraw the screen and grid at 15fps
      while true do
        clock.sleep(1/15)
        redraw()
        gridredraw()
      end
    end)

  norns.enc.sens(1,8)   -- set the knob sensitivity
  norns.enc.sens(2,4)
end


--------------------------------------------------------------------------------
-- encoder
function enc(n, delta)
  if n==1 then
    -- E1 change the length of the sequence
    length = util.clamp(length+delta,1,16)
    edit = util.clamp(edit,1,length)
  elseif n==2 then
    -- E2 change which step to edit
    edit = util.clamp(edit+delta,1,length)
  elseif n==3 then
    -- E3 change the step value
    numbers[edit] = util.clamp(numbers[edit]+delta,0,8)
  end
end


--------------------------------------------------------------------------------
-- key
function key(n,z)
  if n==3 and z==1 then
    -- K3, on key down toggle chimes true/false
    chimes = not chimes
  elseif n==2 and z==1 then
    --[[ 0_0 ]]--
    sequence = not sequence
  end
end


--------------------------------------------------------------------------------
-- screen redraw
function redraw()
  screen.clear()
  screen.line_width(1)
  screen.aa(0)
  draw_wind()

  -- draw bars for numbers
  offset = 64 - length*2
  for i=1,length do
    screen.level(i==pos and 15 or 1)
    screen.move(offset+i*4,60)
    screen.line_rel(0,numbers[i]*-4+-1)
    screen.stroke()
  end

  -- draw edit position
  screen.level(10)
  screen.move(offset+edit*4,62)
  screen.line_rel(0,2)
  screen.stroke()

  screen.update()
end

--------------------------------------------------------------------------------
-- grid key
function g.key(x, y, z)
  if z > 0 then
    if numbers[x] == 9-y then   -- if pushing a lit key, toggle off
      numbers[x] = 0
    else                        -- else set new valu
      numbers[x] = 9-y
    end
  end
end

-- grid redraw
function gridredraw()
  g:all(0)
  for i=1,length do
    g:led(i,9-numbers[i],i==pos and 15 or 3)
  end
  g:refresh()
end

--------------------------------------------------------------------------------
-- initial delay values
function init_delay()
end

--------------------------------------------------------------------------------
-- wind (values and draw function)
x={}
y={}
for i=1,16 do
  x[i] = math.random(256)
  y[i] = math.random(128)
end
vx,vy = math.random(10), math.random(10)
ax,ay = 0,0
light = 1

function draw_wind()
  screen.level(light)
  if light > 1 then light = light - 1 end
  if chimes then
    for i=1,16 do
      screen.move(x[i],y[i])
      screen.line_rel(vx,vy)
      screen.stroke()
      x[i] = (x[i] + (vx*math.random(9,11)/10)) % 256
      y[i] = (y[i] + (vy*math.random(9,11)/10)) % 128
    end
    vx = math.cos(ax)*10
    vy = math.cos(ay)*10
    ax = ax+0.01
    ay = ay+0.004
  end
end

