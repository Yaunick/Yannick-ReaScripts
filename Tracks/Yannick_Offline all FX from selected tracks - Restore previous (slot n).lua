-- @description Yannick_Offline all FX from selected tracks - Restore previous (slot n)
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
 
  --===============
    slot = 1   
  --===============
  ---------------------------------
    show_warning_window = true
  ---------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if tostring(slot) ~= tostring(slot):match("%d+")
  or tonumber(slot) < 1
  or (show_warning_window ~= false and show_warning_window ~= true) 
  then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local count_tracks = reaper.CountSelectedTracks(0)
  if count_tracks == 0 then
    reaper.MB("No tracks selected", "Error",0)
    nothing() return
  end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1) 
  
  local t_tracks = {}
  for i=0, count_tracks-1 do
    t_tracks[#t_tracks+1] = reaper.GetSelectedTrack(0,i)
  end
  
  local i_ext = 0
  local bool_ext = false
  local exist_ext = false
  
  while bool_ext == false do
  
    local retval, key, val = reaper.EnumProjExtState(0, "Selected_tracks_fx_yannick_reasc" .. slot, i_ext)
    if retval == false then
      bool_ext = true
    else
      exist_ext = true
      local t_dual = {}
      
      for s in val:gmatch("[^,]+,[^,]+,") do
        if s:match("[^,]+,([^,]+),") == '0' then
          bl_string = false
        else
          bl_string = true
        end
        t_dual[#t_dual+1] = { s:match("([^,]+),[^,]+,"), bl_string }
      end

      for i_sel_tracks=1, #t_tracks do
        local tr_GUID = reaper.GetTrackGUID(t_tracks[i_sel_tracks])
        if tr_GUID == key then
          for i_fx=0, reaper.TrackFX_GetCount(t_tracks[i_sel_tracks])-1 do
            local GUID = reaper.TrackFX_GetFXGUID(t_tracks[i_sel_tracks], i_fx)
            for i_fx_guid=1, #t_dual do
              if GUID == t_dual[i_fx_guid][1] then
                reaper.TrackFX_SetOffline(t_tracks[i_sel_tracks], i_fx, t_dual[i_fx_guid][2])
                table.remove(t_dual, i_fx_guid)
                break
              end
            end
          end
          table.remove(t_tracks, i_sel_tracks)
          break
        end
      end
    end
    i_ext = i_ext + 1
  end
  
  if exist_ext == false then
    if show_warning_window == true then
      reaper.MB("No saved online states of tracks FX! (slot " .. slot .. ")", "Error",0)
    end
    nothing() return
  end
  
  reaper.Undo_EndBlock('Offline all FX from selected tracks - Restore previous (slot ' .. slot .. ')', -1)
  reaper.PreventUIRefresh(-1)

