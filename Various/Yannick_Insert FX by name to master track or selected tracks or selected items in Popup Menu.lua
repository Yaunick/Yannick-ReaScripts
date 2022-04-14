-- @description Yannick_Insert FX by name to master track or selected tracks or selected items in Popup Menu
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
    table_fx = {  --- table beginnig (do not erase it!)
  
  --\\\\\\\\\\\\\\--------Customize_fx_names_here--------//////////////--
  
    -- Use quotes (" or ') for plugin names 
    -- Use guotes (" or ') and # for tags to group plugins by type
    -- Use guotes (" or ') and > + name for submenu start
    -- Use guotes (" or ') and < for submenu end
    -- Be sure to put a comma after each string!!!
    
    "#COCKOS",
    
    "ReaEq (Cockos)",
    "ReaComp (Cockos)",
    "ReaDelay (Cockos)",
    
  --//////////////---------------------------------------\\\\\\\\\\\\\\--
  
    }  --- table end (do not erase it!)
    
  --Menu settings-------------------------------------
  
    number_of_spaces = 3
    header_name = "Select FX..."
    menu_header_position_x = -70 
    menu_header_position_y = 25
    menu_header_width_x = 140
    menu_header_width_y = 4
  
  ---------------------------------------------------------------
  
  --FX settings--------------------------------------------------
  
    add_fx_to_track = true  --- to master track and normal track
    add_fx_to_item = true
  
  ---------------------------------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  function find_number(table_func)
    bool_find_number = false
    for i=1, #table_func do
      if tonumber(table_func[i]) == table_func[i] then
        bool_find_number = true
      end
    end
    return bool_find_number
  end
  
  if (not tonumber(number_of_spaces) or number_of_spaces < 0)
  or header_name ~= tostring(header_name)
  or not tonumber(menu_header_position_x)
  or not tonumber(menu_header_position_y)
  or not tonumber(menu_header_width_x)
  or not tonumber(menu_header_width_y)
  or (add_fx_to_track ~= true and add_fx_to_track ~= false)
  or (add_fx_to_item ~= true and add_fx_to_item ~= false)
  or (add_fx_to_track == false and add_fx_to_item == false)
  or (#table_fx == 0 or find_number(table_fx) == true) 
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) 
    nothing() return
  end
 
  function Add_FX(name)
    
    local fxfloat = reaper.SNM_GetIntConfigVar('fxfloat_focus',0)
    local change_setting = false
    if fxfloat&4 == 4 then
      local fxfloat2 = fxfloat&~(fxfloat&4)
      reaper.SNM_SetIntConfigVar('fxfloat_focus',fxfloat2)
      change_setting = true
    end
    
    reaper.PreventUIRefresh(1)
    
    local cursor = reaper.GetCursorContext2(true)
    local master = reaper.GetMasterTrack(0)
    local add_to_master = false
    insert_string = ""
    
    if (add_fx_to_item == false and add_fx_to_track == true and reaper.IsTrackSelected(master) == true)
    or (add_fx_to_item == true and add_fx_to_track == true and cursor == 0 and reaper.IsTrackSelected(master) == true)
    then
      if reaper.TrackFX_AddByName(master, name, false, -1) ~= -1 then
        add_to_master = true
        if reaper.TrackFX_GetOffline(master, reaper.TrackFX_GetCount(master)-1) == false
        and reaper.CountSelectedTracks(0) == 0 then
          reaper.TrackFX_Show(master, reaper.TrackFX_GetCount(master)-1, 3)
        end
      end
      insert_string = "to master track"
    end
    if (add_fx_to_item == false and add_fx_to_track == true)
    or (add_fx_to_item == true and add_fx_to_track == true and cursor == 0)
    then
      if reaper.CountSelectedTracks(0) > 0 then
        for i=0, reaper.CountSelectedTracks(0)-1 do
          local track = reaper.GetSelectedTrack(0,i)
          if reaper.TrackFX_AddByName( track, name, false, -1) ~= -1 then
            if reaper.CountSelectedTracks(0) == 1
            and reaper.TrackFX_GetOffline(track, reaper.TrackFX_GetCount(track)-1) == false
            and add_to_master == false
            then
              reaper.TrackFX_Show(track, reaper.TrackFX_GetCount(track)-1, 3)
            end
          end
        end
        insert_string = "to selected tracks"
      end
    elseif (add_fx_to_track == false and add_fx_to_item == true)
    or (add_fx_to_track == true and add_fx_to_item == true and cursor == 1)
    then
      if reaper.CountSelectedMediaItems(0) > 0 then
        for i=0, reaper.CountSelectedMediaItems(0)-1 do
          local item = reaper.GetSelectedMediaItem(0,i)
          local take = reaper.GetActiveTake(item)
          if reaper.TakeFX_AddByName( take, name, -1) ~= -1 then
            if reaper.CountSelectedMediaItems(0) == 1
            and reaper.TakeFX_GetOffline(take, reaper.TakeFX_GetCount(take)-1) == false then
              reaper.TakeFX_Show(take, reaper.TakeFX_GetCount(take)-1, 3)
            end
          end
        end
        insert_string = "to selected items"
      end
    end
    
    if change_setting == true then 
      reaper.SNM_SetIntConfigVar('fxfloat_focus',fxfloat)
    end
      
    reaper.PreventUIRefresh(-1)
    
  end
  
  function Main()
    if number_of_spaces > 0 then
      space = string.rep(" ", number_of_spaces)
    else
      space = ""
    end
    local string_fx = ""
    local count_table = {}
    local find_start = 0
    local find_end = 0
    for i=1, #table_fx do
      save_rts = ""
      for s in string.gmatch(table_fx[i],'.') do
        if s ~= '>'
        and s ~= '<'
        and s ~= '#'
        and s ~= '!'
        and s ~= '|'
        then
          break
        end
        save_rts = s
      end

      if save_rts == '!' or save_rts == '|' then
        gfx.quit()
        reaper.MB("Don't use ! or | for menu items", "Error",0)
        nothing() return
      elseif save_rts == '#' and i == 1 then
        string_fx = string_fx .. table_fx[i] .. '||'
        count_table[#count_table+1] = table_fx[i]
      elseif save_rts == '#' then
        string_fx = string_fx .. '|' .. table_fx[i] .. '||'
        count_table[#count_table+1] = table_fx[i]
      elseif save_rts == '>' then
        string_fx = string_fx .. '>' .. space .. table_fx[i]:sub(2,table_fx[i]:len()) .. '|'
        if not table_fx[i+1] or table_fx[i+1] == '<' then
          count_table[#count_table+1] = table_fx[i]:sub(2,table_fx[i]:len())
        end
        find_start = find_start + 1
      elseif table_fx[i] == '<' then
        string_fx = string_fx .. '<' .. '|'
        find_end = find_end + 1
      elseif save_rts == '<' then
        string_fx = string_fx .. '<' .. space .. table_fx[i]:sub(2,table_fx[i]:len()) .. '|'
        count_table[#count_table+1] = table_fx[i]:sub(2,table_fx[i]:len())
        find_end = find_end + 1
      else
        string_fx = string_fx .. space .. table_fx[i] .. '|'
        count_table[#count_table+1] = table_fx[i]
      end
    end
    
    if find_end > find_start then
      gfx.quit()
      reaper.MB("Specify the beginning of the line!", "Error",0)
      nothing() return
    end
      
    local retval = gfx.showmenu(string_fx)
    
    if retval == 0 then
      nothing()
    else
      for i=1, #count_table do
        if retval == i then
          find_ret = true
          gfx.quit()
          reaper.Undo_BeginBlock()
          Add_FX(count_table[i])
          reaper.Undo_EndBlock('Insert "' .. count_table[i] .. '" FX ' .. insert_string, -1)
          break
        end
      end
    end
  end
  
  local x, y = reaper.GetMousePosition()
  gfx.init(header_name, menu_header_width_x, menu_header_width_y, 0, x + menu_header_position_x, y + menu_header_position_y)
  Main()
  