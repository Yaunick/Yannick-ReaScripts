-- @description Yannick_Activate and set MIDI input quantize for selected tracks in Popup Menu
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ----------------------------------------------------------------
    menu_position_x = -65
    menu_position_y = 20
    menu_width_x = 170
    menu_width_y = 4
  ---------------------------------------------------------------
  
  function bla() end
  function nothing()
    reaper.defer(bla)
  end
  
  if not tonumber(menu_position_x)
  or not tonumber(menu_position_y)
  or not tonumber(menu_width_x)
  or not tonumber(menu_width_y)
  then
    reaper.MB('Incorrect values at the beginnig of the script', 'Error', 0)
    nothing() return
  end
  
  if reaper.CountSelectedTracks(0) == 0 then
    nothing()
    return
  end
  
  quan_string = ""
  
  function Zoom(num_menu)
    
    if num_menu == 1 then
      reaper.Main_OnCommand(42043,0)  -- 1/4
      quan_string = ' to 1/4 '
    elseif num_menu == 2 then
      reaper.Main_OnCommand(42041,0)  -- 1/8
      quan_string = ' to 1/8 '
    elseif num_menu == 3 then
      reaper.Main_OnCommand(42039,0)  -- 1/16
      quan_string = ' to 1/16 '
    elseif num_menu == 4 then
      reaper.Main_OnCommand(42037,0)  -- 1/32
      quan_string = ' to 1/32 '
    elseif num_menu == 5 then
      reaper.Main_OnCommand(42036,0)  -- 1/64
      quan_string = ' to 1/64 '
    
    elseif num_menu == 6 then
      reaper.Main_OnCommand(42042,0)  -- 1/4 triplet
      quan_string = ' to 1/4 triplet '
    elseif num_menu == 7 then
      reaper.Main_OnCommand(42040,0)  -- 1/8 triplet
      quan_string = ' to 1/8 triplet '
    elseif num_menu == 8 then
      reaper.Main_OnCommand(42038,0)  -- 1/16 triplet
      quan_string = ' to 1/16 triplet '
    elseif num_menu == 9 then
      reaper.Main_OnCommand(42064,0)  -- disable input quantize
      quan_string = 'disable'
    end
    
  end
  
  local x, y = reaper.GetMousePosition()
  gfx.init("Set input quintize...",menu_width_x,menu_width_y,0,x+menu_position_x,y+menu_position_y)
  
  table_menu = {
      
    'to  1/4|',
    'to  1/8|',
    'to  1/16|',
    'to  1/32|',
    'to  1/64||',
    
    'to  1/4 triplet|',
    'to  1/8 triplet|',
    'to  1/16 triplet||',
    'Disable input quintize',

  }
  
  local check = '!'

  if reaper.GetToggleCommandState(42043) == 1 then
    table_menu[1] = check .. table_menu[1]
  elseif reaper.GetToggleCommandState(42041) == 1 then
    table_menu[2] = check .. table_menu[2]
  elseif reaper.GetToggleCommandState(42039) == 1 then
    table_menu[3] = check .. table_menu[3]
  elseif reaper.GetToggleCommandState(42037) == 1 then
    table_menu[4] = check .. table_menu[4]
  elseif reaper.GetToggleCommandState(42036) == 1 then
    table_menu[5] = check .. table_menu[5]
  elseif reaper.GetToggleCommandState(42042) == 1 then
    table_menu[6] = check .. table_menu[6]
  elseif reaper.GetToggleCommandState(42040) == 1 then 
    table_menu[7] = check .. table_menu[7]
  elseif reaper.GetToggleCommandState(42038) == 1 then
    table_menu[8] = check .. table_menu[8]
  end
  
  local retval = gfx.showmenu(table.concat(table_menu))
  
  if retval == 0 then
    nothing()
  else
    reaper.Main_OnCommand(42063,0)
    for i=1, #table_menu do
      if retval == i then
        reaper.Undo_BeginBlock()
        gfx.quit()
        Zoom(i)
        if quan_string == 'disable' then
          undo_string_quan = 'Disable MIDI input quantize for selected tracks'
        else
          undo_string_quan = 'Activate and set MIDI input quantize' .. quan_string .. 'for selected tracks'
        end
        reaper.Undo_EndBlock(undo_string_quan, -1)
        break
      end
    end
  end

  