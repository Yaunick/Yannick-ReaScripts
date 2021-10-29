-- @description Yannick_Horizontal zoom center settings in Popup Menu
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added protection against incorrect user settings
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  ----------------------------------------------------------------
    menu_position_x = -65
    menu_position_y = 25
    menu_width_x = 245
    menu_width_y = 4
  ---------------------------------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if not tonumber(menu_position_x)
  or not tonumber(menu_position_y)
  or not tonumber(menu_width_x)
  or not tonumber(menu_width_y)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
 
  function Zoom(num_menu)
    
    if num_menu == 1 then
      reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SETHZOOMC_EDITPLAYCUR"),0)
    elseif num_menu == 2 then
      reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SETHZOOMC_MOUSECUR"),0)
    elseif num_menu == 3 then
      reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SETHZOOMC_CENTERVIEW"),0)
    elseif num_menu == 4 then
      reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SETHZOOMC_EDITCUR"),0)
    end
    
  end
  
  function Main()

    table_menu = {
    
    'Edit cursor or play cursor (default)|',
    'Mouse cursor|',
    'Center of view|',
    'Edit cursor|',
    
    }
    
    if reaper.SNM_GetIntConfigVar("zoommode",0) == 0 then
      table_menu[1] = "!" .. table_menu[1]
    elseif reaper.SNM_GetIntConfigVar("zoommode",0) == 1 then
      table_menu[4] = "!" .. table_menu[4]
    elseif reaper.SNM_GetIntConfigVar("zoommode",0) == 2 then
      table_menu[3] = "!" .. table_menu[3]
    elseif reaper.SNM_GetIntConfigVar("zoommode",0) == 3 then
      table_menu[2] = "!" .. table_menu[2]
    end
    
    
    local retval = gfx.showmenu(table.concat(table_menu))
    
    if retval == 0 then
      nothing()
    else
      for i=1, #table_menu do
        if retval == i then
          gfx.quit()
          Zoom(i)
          nothing()
          break
        end
      end
    end
    
  end
  
  local x, y = reaper.GetMousePosition()
  gfx.init("Set horizontal zoom center to...",menu_width_x,menu_width_y,0,x+menu_position_x,y+menu_position_y)
  Main()