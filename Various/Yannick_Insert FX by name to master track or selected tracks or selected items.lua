-- @description Yannick_Insert FX by name to master track or selected tracks or selected items
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added new settings
--   + Added protection against incorrect user settings
--   + FX name and loading location (master track or track or item) fit into Undo history
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  ------------Set FX name:----------
  
    name = 'ReaEQ (Cockos)'
    
  ----------------------------------
  
  ------------FX settings----------------------------------------
  
    add_fx_to_track = true  --- to master track and normal track
    add_fx_to_item = true

  ---------------------------------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if name ~= tostring(name)
  or add_fx_to_track ~= true and add_fx_to_track ~= false
  or add_fx_to_item ~= true and add_fx_to_item ~= false
  or add_fx_to_track == false and add_fx_to_item == false
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  fxfloat = reaper.SNM_GetIntConfigVar('fxfloat_focus',0)
  change_setting = false
  if fxfloat&4 == 4 then
    local fxfloat2 = fxfloat&~(fxfloat&4)
    reaper.SNM_SetIntConfigVar('fxfloat_focus',fxfloat2)
    change_setting = true
  end
 
  cursor = reaper.GetCursorContext2(true)
  master = reaper.GetMasterTrack(0)
  add_to_master = false
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
  or (add_fx_to_item == true and add_fx_to_track == true and cursor == 1) 
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
      
  reaper.Undo_EndBlock('Insert "' .. name .. '" FX ' .. insert_string, -1)
  reaper.PreventUIRefresh(-1)