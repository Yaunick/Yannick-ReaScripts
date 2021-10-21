-- @description Yannick_Set project grid type (normal, triplet, quintuplet, septuplet, dotted) in Popup Menu
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  --Menu settings----------------------------
  
    header_name = "Set grid type to..."
    menu_header_position_x = -60 
    menu_header_position_y = 25
    menu_header_width_x = 170
    menu_header_width_y = 4
    
  -------------------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  local _, division, swingmode, swingamt = reaper.GetSetProjectGrid(0, false, 0, 0, 0)
  save_div = 0
  
  local t_normal = {
    4,
    2,
    1,
    1/2,
    1/4,
    1/8,
    1/16,
    1/32,
    1/64,
    1/128,
    1/256
    }
  local t_trip = {
    8/3,
    4/3,
    2/3,
    1/3,
    1/6,
    1/12,
    1/24,
    1/48,
    1/96,
    1/192,
    1/384
    }
  local t_guinttup = {
    16/5,
    8/5,
    4/5,
    2/5,
    1/5,
    1/10,
    1/20,
    1/40,
    1/80,
    1/160,
    1/320,
    }
  local t_suptup = {
    16/7,
    8/7,
    4/7,
    2/7,
    1/7,
    1/14,
    1/28,
    1/56,
    1/112,
    1/224,
    1/448,
    }
    
  local t_dott = {
    4 * 1.5,
    2 * 1.5,
    1 * 1.5,
    1/2 * 1.5,
    1/4 * 1.5,
    1/8 * 1.5,
    1/16 * 1.5,
    1/32 * 1.5,
    1/64 * 1.5,
    1/128 * 1.5,
    1/256 * 1.5
    }
  
  local normal_grid_state = 0
  local triplet_grid_state = 0
  local quintuplet_grid_state = 0
  local septuplet_grid_state = 0
  local dotted_grid_state = 0
  
  for i=1, #t_normal do
    if division == t_normal[i] then
      normal_grid_state = 1
      save_div = i
      goto NEXT
    end
  end
    
  for i=1, #t_trip do
    if division == t_trip[i] then
      triplet_grid_state = 1
      save_div = i
      goto NEXT
    end
  end
  
  for i=1, #t_guinttup do
    if division == t_guinttup[i] then
      quintuplet_grid_state = 1
      save_div = i
      goto NEXT
    end
  end
  
  for i=1, #t_suptup do
    if division == t_suptup[i] then
      septuplet_grid_state = 1
      save_div = i
      goto NEXT
    end
  end
  
  for i=1, #t_dott do
    if division == t_dott[i] then
      dotted_grid_state = 1
      save_div = i
      goto NEXT
    end
  end
  
  if save_div == 0 then
    for i=1, #t_normal do
      if division > t_normal[i] then
        save_div = i
        goto NEXT
      end
      if i == #t_normal then
        save_div = i
      end
    end
  end
  
  ::NEXT::
  
  local t_numbers = {normal_grid_state, triplet_grid_state, quintuplet_grid_state, septuplet_grid_state, dotted_grid_state}
  local t_convert = {}
  
  for i=1, #t_numbers do
    if t_numbers[i] == 1 then
      t_convert[i] = "!"
    else
      t_convert[i] = ""
    end
  end
  
  string = 
    t_convert[1] .. "Normal Grid" .. '|' ..
    '|' .. t_convert[2] .. "Triplet Grid (3)" .. '|' ..
    t_convert[3] .. "Quintuplet Grid (5)" .. '|' ..
    t_convert[4] .. "Suptuplet Grid (7)" .. '|' ..
    '|' .. t_convert[5] .. "Dotted Grid"
  
  local x, y = reaper.GetMousePosition()
  gfx.init(header_name, menu_header_width_x, menu_header_width_y, 0, x + menu_header_position_x, y + menu_header_position_y)
  
  local retval = gfx.showmenu(string)
  
  if retval > 0 then
    
    reaper.PreventUIRefresh(1)
    
    if retval == 1 then
      new_grid = t_normal[save_div]
    elseif retval == 2 then
      new_grid = t_trip[save_div]
    elseif retval == 3 then
      new_grid = t_guinttup[save_div]
    elseif retval == 4 then
      new_grid = t_suptup[save_div]
    elseif retval == 5 then
      new_grid = t_dott[save_div]
    end
    
    reaper.GetSetProjectGrid(0, true, new_grid, swingmode, swingamt)
    gfx.quit()
    nothing()
    reaper.PreventUIRefresh(-1)
  else
    nothing()
  end


