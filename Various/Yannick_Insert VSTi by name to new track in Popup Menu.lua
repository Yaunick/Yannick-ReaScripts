-- @description Yannick_Insert VSTi by name to new track in Popup Menu
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added new record mode settings
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
 
    table_fx = {  --- table beginning (do not erase it!)
    
  --\\\\\\\\\\\\\\--------Customize_fx_names_here--------//////////////---------------
  
    -- Use quotes (" or ') for plugin names 
    -- Use guotes (" or ') and # for tags to group plugins by type
    -- Use guotes (" or ') and > + name for submenu start
    -- Use guotes (" or ') and < for submenu end
    -- Be sure to put a comma after each string!!!
    
    "#SAMPLERS",
    
    "ReaSamplOmatic5000 (Cockos)",
    
    "#SYNTHESIZERS",
  
    "ReaSynth (Cockos)",
    
  --//////////////---------------------------------------\\\\\\\\\\\\\\---------------
  
    }  --- table end (do not erase it!)
  
  --Menu coordinate settings---------------------------------------------------------

    number_of_spaces = 3           
    menu_header_position_x = -70 
    menu_header_position_y = 25
    menu_header_width_x = 180
    menu_header_width_y = 4
  
  --Instrument settings--------------------------------------------------------------
    
    defaults_for_new_track = false
    -- if false then --------------------
      monitor_rec_for_new_track = true
      
      record_mode = 1      -- 1 = Record: input (audio or MIDI)
      
                           -- 2 = Record: MIDI overdub
                           -- 3 = Record: MIDI replace
                           -- 4 = Record: MIDI touch-replace
                           -- 5 = Record: MIDI latch-replace
                           
                           -- 6 = Record: output (MIDI)
                           
                           -- 7 = Record: input (force MIDI)
                           
                           -- 8 = Record: disable (input monitoring only)
                             
    -- end ------------------------------
  
    
    
    set_exclusive_rec_arm = 2      -- 0 = no rec arm 
                                   -- 1 = auto rec arm (works in REAPER 6.30 or higher)
                                   -- 2 = normal rec arm
  
  -----------------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------------
  --[[--set color for new track (enter 0 for R and G and B to disable coloring---]]--
  
    R = 0 ---- Red
    G = 0 ---- Green
    B = 0 ---- Blue
  
  --[[---------------------------------------------------------------------------]]--
  -----------------------------------------------------------------------------------
  
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
  or not tonumber(menu_header_position_x)
  or not tonumber(menu_header_position_y)
  or not tonumber(menu_header_width_x)
  or not tonumber(menu_header_width_y)
  or (#table_fx == 0 or find_number(table_fx) == true)
  or (defaults_for_new_track ~= true and defaults_for_new_track ~= false)
  or (monitor_rec_for_new_track ~= true and monitor_rec_for_new_track ~= false)
  or (record_mode ~= 1 and record_mode ~= 2 and record_mode ~= 3 and record_mode ~= 4 
    and record_mode ~= 5 and record_mode ~= 6 and record_mode ~= 7 and record_mode ~= 8)
  or (set_exclusive_rec_arm ~= 0 and set_exclusive_rec_arm ~= 1 and set_exclusive_rec_arm ~= 2)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or B < 0 or B < 0)
  then
    reaper.MB
    (
    'Incorrect values at the beginning of the script',
    'Error',
    0
    )
    nothing() return
  end
 
  function Add_VSTi(name)
  
   reaper.PreventUIRefresh(1)
   
   local t_tracks_save = {}
   for i=0, reaper.CountSelectedTracks(0)-1 do
     t_tracks_save[#t_tracks_save+1] = reaper.GetSelectedTrack(0,i)
   end
   
   if reaper.CountSelectedTracks(0) == 0 then
     reaper.InsertTrackAtIndex( reaper.CountTracks(0), defaults_for_new_track)
     track = reaper.GetTrack(0,reaper.CountTracks(0)-1)
     reaper.SetOnlyTrackSelected(track, true)
     reaper.ReorderSelectedTracks( reaper.CountTracks(0), 0)
   else
     local prev_track = reaper.GetSelectedTrack(0,reaper.CountSelectedTracks(0)-1)
     local number = reaper.GetMediaTrackInfo_Value(prev_track, 'IP_TRACKNUMBER')
     reaper.InsertTrackAtIndex(number, defaults_for_new_track)
     track = reaper.GetTrack(0,number)
     reaper.SetOnlyTrackSelected(track, true)
     reaper.ReorderSelectedTracks(number+1, 2)
   end
   
   reaper.GetSetMediaTrackInfo_String( track, 'P_NAME', name, true)
   if reaper.TrackFX_AddByName( track, name, false, -1) ~= -1 then
     if reaper.TrackFX_GetOffline(track, reaper.TrackFX_GetCount(track)-1) == false then
       if R == 0 and B == 0 and G == 0 then
         nothing()
       else
         reaper.SetTrackColor(track, reaper.ColorToNative(R,G,B)|0x1000000)
       end
     
       if set_exclusive_rec_arm == 2 then
         reaper.Main_OnCommand(40491,0) -- unarm all tracks
         reaper.SetMediaTrackInfo_Value( track, 'I_RECARM', 1)
       elseif set_exclusive_rec_arm == 1 then
         reaper.Main_OnCommand(40491,0) -- unarm all tracks
         reaper.SetMediaTrackInfo_Value( track, 'I_RECARM', 1)
         reaper.SetMediaTrackInfo_Value( track, 'B_AUTO_RECARM', 1)
       end
       
       if defaults_for_new_track == false then
         
         if monitor_rec_for_new_track == true then
           reaper.SetMediaTrackInfo_Value( track, 'I_RECMON', 1)
         else
           reaper.SetMediaTrackInfo_Value( track, 'I_RECMON', 0)
         end
       
         reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', 4096+(63<<5))
         
         if record_mode == 1 then
           record_mode = 0
         elseif record_mode == 2 then
           record_mode = 7
         elseif record_mode == 3 then
           record_mode = 8
         elseif record_mode == 4 then
           record_mode = 9
         elseif record_mode == 5 then
           record_mode = 16
         elseif record_mode == 6 then
           record_mode = 4
         elseif record_mode == 7 then
           record_mode = 15
         elseif record_mode == 8 then
           record_mode = 2
         end
       
         reaper.SetMediaTrackInfo_Value( track, 'I_RECMODE', record_mode)
         
       end
       
       reaper.TrackFX_Show(track, reaper.TrackFX_GetCount(track)-1, 3)
     end
   else
     reaper.DeleteTrack(track)
     for i=1, #t_tracks_save do
       reaper.SetTrackSelected(t_tracks_save[i], true)
     end
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
          gfx.quit()
          reaper.Undo_BeginBlock()
          Add_VSTi(count_table[i])
          reaper.Undo_EndBlock('Insert "' .. count_table[i] .. '" Instrument to new track', -1)
          break
        end
      end
    end
  
  end
  
  local x, y = reaper.GetMousePosition()
  gfx.init("Select Instrument...", menu_header_width_x, menu_header_width_y, 0, x + menu_header_position_x, y + menu_header_position_y)
  Main()