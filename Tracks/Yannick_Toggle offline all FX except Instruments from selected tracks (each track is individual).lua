-- @description Yannick_Toggle offline all FX except instruments from selected tracks (each track is individual)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + added VST3 Melodyne to exclusions (identification by hash)
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU 

  --------------------------------------
    one_instrument_limit = true
    vst3_melodyne_offline = false
  --------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end

  if (one_instrument_limit ~= false and one_instrument_limit ~= true) 
  or (vst3_melodyne_offline ~= false and vst3_melodyne_offline ~= true)
  then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local count_tracks = reaper.CountSelectedTracks(0)
  if count_tracks == 0 then
    reaper.MB("No tracks selected", "Error", 0)
    nothing() return
  end
  
  if one_instrument_limit == true then
    for a=0, count_tracks-1 do
      local tr = reaper.GetSelectedTrack(0,a)
      local count_instr = 0
      local count_tra_fx = reaper.TrackFX_GetCount(tr)
      for af = 0, count_tra_fx-1 do
        local retval, buf = reaper.TrackFX_GetNamedConfigParm( tr, af, 'fx_type')
        if buf == "VSTi"
        or buf == "AUi"
        or buf == "VST3i"
        then
          count_instr = count_instr + 1
        end
      end
      if count_instr > 1 then
        reaper.MB("Please select tracks with only one instrument", "Error", 0)
        nothing() return
      end
    end
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  function Offline_all_fx(tr)
    local save_count_hash = -10
    if vst3_melodyne_offline == false then
      local retval, str = reaper.GetTrackStateChunk( tr, '', false)
      local count_hash = 0
      for s in str:gmatch("<VST.-\n") do -- find ARA2 Melodyne hash
        if s:find("5653544D6C70676D656C6F64796E6520") then
          save_count_hash = count_hash
        end
        count_hash = count_hash + 1
      end
    end
    local offline_str = ""
    local count_tra_fx = reaper.TrackFX_GetCount(tr)
    local instr = reaper.TrackFX_GetInstrument( tr ) + 1
    while instr <= count_tra_fx-1 do
      if instr ~= save_count_hash then
        if reaper.TrackFX_GetOffline(tr, instr) == true then
          offline_state = 0
        else
          offline_state = 1
        end
        local GUID = reaper.TrackFX_GetFXGUID(tr, instr)
        offline_str = offline_str .. GUID .. ',' .. offline_state .. ','
        reaper.TrackFX_SetOffline(tr, instr, true)
      end
      instr = instr + 1
    end
    return offline_str
  end
  
  function Online_all_fx(tr, val)
    local t_dual = {}
    for s in val:gmatch("[^,]+,[^,]+,") do
      if s:match("[^,]+,([^,]+),") == '0' then
        bl_string = true
      else
        bl_string = false
      end
      t_dual[#t_dual+1] = { s:match("([^,]+),[^,]+,"), bl_string }
    end
    local count_tra_fx = reaper.TrackFX_GetCount(tr)
    local instr = reaper.TrackFX_GetInstrument( tr ) + 1
    while instr <= count_tra_fx-1 do
      local GUID = reaper.TrackFX_GetFXGUID(tr, instr)
      for i_fx_guid=1, #t_dual do
        if GUID == t_dual[i_fx_guid][1] then
          reaper.TrackFX_SetOffline(tr, instr, t_dual[i_fx_guid][2])
          table.remove(t_dual, i_fx_guid)
          break
        end
      end
      instr = instr + 1
    end
  end
  
  local idx = 0
  local find_end = false
  local t_key_tracks = {}
  local t_key_tracks_restore = {}
  while find_end == false do
    local retval, key, val = reaper.EnumProjExtState(0, "Selected_tracks_fx_yannick_reasc_toggle_offline_tracks_ind", idx )
    if retval == false then
      find_end = true
    else
      t_key_tracks[#t_key_tracks+1] = { key, val }
    end
    idx = idx + 1
  end
 
  for j=0, count_tracks-1 do
    local find_tr_for_rest = false
    local tr = reaper.GetSelectedTrack(0,j)
    local tr_GUID = reaper.GetTrackGUID( tr )
    for l=1, #t_key_tracks do
      if tr_GUID == t_key_tracks[l][1] then
        find_tr_for_rest = true
        if t_key_tracks[l][2] == '0' then
          local bypass_res_str = Offline_all_fx(tr)
          t_key_tracks_restore[#t_key_tracks_restore+1] = { tr_GUID, bypass_res_str }
        else
          Online_all_fx(tr, t_key_tracks[l][2])
          t_key_tracks_restore[#t_key_tracks_restore+1] = { tr_GUID, '0' }
        end
        table.remove(t_key_tracks,l)
        break
      end
    end
    if find_tr_for_rest == false then
      local bypass_res_str = Offline_all_fx(tr)
      t_key_tracks_restore[#t_key_tracks_restore+1] = { tr_GUID, bypass_res_str }
    end
  end

  for i=1, #t_key_tracks_restore do
    reaper.SetProjExtState(0, "Selected_tracks_fx_yannick_reasc_toggle_offline_tracks_ind", t_key_tracks_restore[i][1], t_key_tracks_restore[i][2])
  end

  reaper.Undo_EndBlock('Toggle offline all FX except instruments from selected tracks (each track is individual)', -1)
  reaper.PreventUIRefresh(-1)

