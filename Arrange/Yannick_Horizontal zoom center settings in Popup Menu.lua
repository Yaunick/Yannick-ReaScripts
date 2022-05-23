-- @description Yannick_Horizontal zoom center settings in Popup Menu
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added setting "hide window header"
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --Menu settings------------------------------------------------
  
    menu_position_x = -65
    menu_position_y = 25
    menu_width_x = 245
    menu_width_y = 4
    
  --Menu header settings-----------------------------------------
  
    show_window_header = true
  
  ---------------------------------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if not tonumber(menu_position_x)
  or not tonumber(menu_position_y)
  or not tonumber(menu_width_x)
  or not tonumber(menu_width_y)
  or (show_window_header ~= true and show_window_header ~= false)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
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
    
    if retval > 0 then
      gfx.quit()
      Zoom(retval)
    end
    
    nothing()
  end
  
  local x, y = reaper.GetMousePosition()
  gfx.init("Set horizontal zoom center to...",menu_width_x,menu_width_y,0,x+menu_position_x,y+menu_position_y)
  if show_window_header == false then
    local hwnd = reaper.JS_Window_Find("Set horizontal zoom center to...", true )
    if hwnd then
      reaper.JS_Window_Show( hwnd, "HIDE" )
    end
    gfx.x, gfx.y = gfx.mouse_x+menu_position_x, gfx.mouse_y+menu_position_y
  end
  
  Main()