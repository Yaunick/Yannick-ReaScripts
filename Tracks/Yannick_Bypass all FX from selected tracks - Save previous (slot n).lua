-- @description Yannick_Bypass all FX from selected tracks - Save previous (slot n)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU 
    
  --===============
    slot = 1
  --===============
  --------------------------------------
    bypass_all_fx_before_saving = true
  --------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if tostring(slot) ~= tostring(slot):match("%d+")
  or tonumber(slot) < 1
  or (bypass_all_fx_before_saving ~= true and bypass_all_fx_before_saving ~= false)
  then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local count_tracks = reaper.CountSelectedTracks(0)
  if count_tracks == 0 then
    reaper.MB("No tracks selected", "Error", 0)
    nothing() return
  end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  for j=0, count_tracks-1 do
    local bypass_str = ""
    local tr = reaper.GetSelectedTrack(0,j)
    tr_guid = reaper.GetTrackGUID(tr)
    for i=0, reaper.TrackFX_GetCount(tr)-1 do
      if  reaper.TrackFX_GetEnabled(tr, i) == true then
        bypass_state = 0
      else
        bypass_state = 1
      end
      local GUID = reaper.TrackFX_GetFXGUID(tr, i)
      bypass_str = bypass_str .. GUID .. ',' .. bypass_state .. ','
      if bypass_all_fx_before_saving == true then
        reaper.TrackFX_SetEnabled(tr, i, false)
      end
    end
    reaper.SetProjExtState(0, "Selected_tracks_fx_yannick_reasc_bypassver" .. slot, tr_guid, bypass_str)
  end
  
  reaper.Undo_EndBlock('Bypass all FX from selected tracks - Save previous (slot ' .. slot .. ')', -1)
  reaper.PreventUIRefresh(-1)

  


