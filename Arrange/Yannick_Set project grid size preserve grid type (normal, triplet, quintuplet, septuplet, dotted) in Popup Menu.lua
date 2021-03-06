-- @description Yannick_Set project grid size preserve grid type (normal, triplet, quintuplet, septuplet, dotted) in Popup Menu
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added setting "hide window header"
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --Menu settings----------------------------
  
    header_name = "Grid..."
    menu_header_position_x = -50 
    menu_header_position_y = 25
    menu_header_width_x = 110
    menu_header_width_y = 4
    
  --Menu header settings---------------------
  
    show_window_header = true
    
  -------------------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  if header_name ~= tostring(header_name)
  or not tonumber(menu_header_position_x)
  or not tonumber(menu_header_position_y)
  or not tonumber(menu_header_width_x)
  or not tonumber(menu_header_width_y)
  or (show_window_header ~= false and show_window_header ~= true) 
  then
    reaper.MB
    (
    'Incorrect values at the beginning of the script',
    'Error',
    0
    )
    nothing() return
  end
  
  if show_window_header == false then
    if not reaper.ReaPack_AddSetRepository then
      reaper.MB("Please install ReaPack package manager", "Error", 0)
      nothing() return
    end
    if not reaper.JS_Window_Find then
      reaper.MB("Please install 'js_ReaScriptAPI: API functions for ReaScripts then restart Reaper", "Error", 0)
      local ok, err = reaper.ReaPack_AddSetRepository
      ( "ReaTeam Extensions", "https://github.com/ReaTeam/Extensions/raw/master/index.xml", true, 1 )
      if ok then reaper.ReaPack_BrowsePackages( "js_ReaScriptAPI" )
      else reaper.MB( err, "Something went wrong...", 0)
      end
      nothing() return
    end
  end
  
  local _, division, swingmode, swingamt = reaper.GetSetProjectGrid(0, false, 0, 0, 0)
  
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
    
  local grid_one_t = {0,0,0,0,0,0,0,0,0}
  
  for i=1, #t_normal do
    if division == t_normal[i] then
      t_save_dv = t_normal
      postfix = ""
      grid_one_t[i-2] = 1
      goto NEXT
    end
  end
    
  for i=1, #t_trip do
    if division == t_trip[i] then
      t_save_dv = t_trip
      postfix = "  ---  Triplet"
      grid_one_t[i-2] = 1
      goto NEXT
    end
  end
  
  for i=1, #t_guinttup do
    if division == t_guinttup[i] then
      t_save_dv = t_guinttup
      postfix = "  ---  Quintuplet"
      grid_one_t[i-2] = 1
      goto NEXT
    end
  end
  
  for i=1, #t_suptup do
    if division == t_suptup[i] then
      t_save_dv = t_suptup
      postfix = "  ---  Septuplet"
      grid_one_t[i-2] = 1
      goto NEXT
    end
  end
  
  for i=1, #t_dott do
    if division == t_dott[i] then
      t_save_dv = t_dott
      postfix = "  ---  Dotted"
      grid_one_t[i-2] = 1
      goto NEXT
    end
  end
  
  if not t_save_dv then
    t_save_dv = t_normal
    postfix = ""
  end
  
  ::NEXT::

  local t_convert = {}
  
  for i=1, #grid_one_t do
    if grid_one_t[i] == 1 then
      t_convert[i] = "!"
    else
      t_convert[i] = ""
    end
  end
  
  string =  
    t_convert[1] .. "1" .. postfix .. '|' ..
    t_convert[2] .. "1/2" .. postfix .. '|' ..
    t_convert[3] .. "1/4" .. postfix .. '|' ..
    t_convert[4] .. "1/8" .. postfix .. '|' ..
    t_convert[5] .. "1/16" .. postfix .. '|' ..
    t_convert[6] .. "1/32" .. postfix .. '|' ..
    t_convert[7] .. "1/64" .. postfix .. '|' ..
    t_convert[8] .. "1/128" .. postfix .. '|' ..
    t_convert[9] .. "1/256" .. postfix
  
  local x, y = reaper.GetMousePosition()
  gfx.init(header_name, menu_header_width_x, menu_header_width_y, 0, x + menu_header_position_x, y + menu_header_position_y)
  if show_window_header == false then
    local hwnd = reaper.JS_Window_Find(header_name, true )
    if hwnd then
      reaper.JS_Window_Show( hwnd, "HIDE" )
    end
    gfx.x, gfx.y = gfx.mouse_x+menu_header_position_x, gfx.mouse_y+menu_header_position_y
  end
  
  local retval = gfx.showmenu(string)
  
  if retval > 0 then
    reaper.GetSetProjectGrid(0, true, t_save_dv[retval+2], swingmode, swingamt)
    gfx.quit()
    nothing()
  end
  nothing()