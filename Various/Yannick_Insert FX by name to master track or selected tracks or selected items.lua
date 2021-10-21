-- @description Yannick_Insert FX by name to master track or selected tracks or selected items
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  ------------Set FX name:----------
  name = 'ReaEQ (Cockos)'
  ----------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  fxfloat = reaper.SNM_GetIntConfigVar('fxfloat_focus',0)
  change_setting = false
  if fxfloat&4 == 4 then
    local fxfloat2 = fxfloat&~(fxfloat&4)
    reaper.SNM_SetIntConfigVar('fxfloat_focus',fxfloat2)
    change_setting = true
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
 
  cursor = reaper.GetCursorContext2(true)
  master = reaper.GetMasterTrack(0)
  add_to_master = false

  if cursor == 0 and reaper.IsTrackSelected(master) == true then
    local count_bef_master = reaper.TrackFX_GetCount(master)
    reaper.TrackFX_AddByName(master, name, false, -1)
    local count_aft_master = reaper.TrackFX_GetCount(master)
    if count_bef_master < count_aft_master then
      add_to_master = true
      if reaper.TrackFX_GetOffline(master, count_aft_master-1) == false
      and reaper.CountSelectedTracks(0) == 0 then
        reaper.TrackFX_Show(master, count_aft_master-1, 3)
      end
    end
  end
  if cursor == 0 then
    if reaper.CountSelectedTracks(0) > 0 then
      for i=0, reaper.CountSelectedTracks(0)-1 do
        local track = reaper.GetSelectedTrack(0,i)
        local count_bef_track = reaper.TrackFX_GetCount(track)
        reaper.TrackFX_AddByName( track, name, false, -1)
        local count_aft_track = reaper.TrackFX_GetCount(track)
        if count_bef_track < count_aft_track
        and reaper.CountSelectedTracks(0) == 1
        and reaper.TrackFX_GetOffline(track, count_aft_track-1) == false
        and add_to_master == false
        then
          reaper.TrackFX_Show(track, count_aft_track-1, 3)
        end
      end
    end
  elseif cursor == 1 then
    if reaper.CountSelectedMediaItems(0) > 0 then
      for i=0, reaper.CountSelectedMediaItems(0)-1 do
        local item = reaper.GetSelectedMediaItem(0,i)
        local take = reaper.GetActiveTake(item)
        local count_bef_take = reaper.TakeFX_GetCount(take)
        reaper.TakeFX_AddByName( take, name, -1)
        local count_aft_take = reaper.TakeFX_GetCount(take)
        if count_bef_take < count_aft_take
        and reaper.CountSelectedMediaItems(0) == 1
        and reaper.TakeFX_GetOffline(take, count_aft_take-1) == false then
          reaper.TakeFX_Show(take, count_aft_take-1, 3)
        end
      end
    end
  end
  
  if change_setting == true then 
    reaper.SNM_SetIntConfigVar('fxfloat_focus',fxfloat)
  end
      
  reaper.Undo_EndBlock('Insert FX by name to selected tracks or items', -1)
  reaper.PreventUIRefresh(-1)
