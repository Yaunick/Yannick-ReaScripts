-- @description Yannick_Toggle bypass all envelopes from selected tracks (each track is individual)
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + some code improvements
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU 
  
  function bla() end function nothing() reaper.defer(bla) end
  
  local count_tracks = reaper.CountSelectedTracks(0)
  if count_tracks == 0 then
    reaper.MB("No tracks selected", "Error", 0)
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)

  function Bypass_all_envelopes(tr)
    local bypass_str = {}
    local i = 0
    local find_end = false
    while find_end == false do
      local env = reaper.GetTrackEnvelope( tr, i)
      if env == nil then
        find_end = true
      else
        local retval, str = reaper.GetEnvelopeStateChunk( env, "", true)
        bypass_str[#bypass_str+1] = str:match("EGUID (.+})") .. ',' .. str:match("ACT (%d)") .. ','
        reaper.SetEnvelopeStateChunk( env, str:gsub('ACT [%d]', 'ACT ' .. '0'), false)
      end
      i = i + 1
    end
    return table.concat(bypass_str)
  end

  function Unbypass_all_envelopes(tr, val)
    local t_dual = {}
    for s in val:gmatch("[^,]+,[^,]+,") do
      t_dual[#t_dual+1] = { s:match("([^,]+),[^,]+,"), s:match("[^,]+,([^,]+),") }
    end
    local i = 0
    local find_end = false
    while find_end == false do
      local env = reaper.GetTrackEnvelope( tr, i)
      if env == nil then
        find_end = true
      else
        local retval, str = reaper.GetEnvelopeStateChunk( env, "", false)
        local GUIDenv = str:match("EGUID (.+})")
        for i_en_guid=1, #t_dual do
          if GUIDenv == t_dual[i_en_guid][1] then
            reaper.SetEnvelopeStateChunk( env, str:gsub('ACT [%d]', 'ACT '..t_dual[i_en_guid][2]), false)
            table.remove(t_dual, i_en_guid)
            break
          end
        end
      end
      i = i + 1
    end
  end
  
  local idx = 0
  local find_end = false
  local t_key_tracks = {}
  local t_key_tracks_restore = {}
  while find_end == false do
    local retval, key, val = reaper.EnumProjExtState(0, "Selected_tracks_active_envelopes_yannick_reasc_toggle_bypass_ind", idx )
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
          local bypass_res_str = Bypass_all_envelopes(tr)
          if bypass_res_str ~= "" then
            t_key_tracks_restore[#t_key_tracks_restore+1] = { tr_GUID, bypass_res_str }
          end
        else
          Unbypass_all_envelopes(tr, t_key_tracks[l][2])
          t_key_tracks_restore[#t_key_tracks_restore+1] = { tr_GUID, '0' }
        end
        table.remove(t_key_tracks,l)
        break
      end
    end
    if find_tr_for_rest == false then
      local bypass_res_str = Bypass_all_envelopes(tr)
      if bypass_res_str ~= "" then
        t_key_tracks_restore[#t_key_tracks_restore+1] = { tr_GUID, bypass_res_str }
      end
    end
  end

  for i=1, #t_key_tracks_restore do
    reaper.SetProjExtState(0, "Selected_tracks_active_envelopes_yannick_reasc_toggle_bypass_ind", t_key_tracks_restore[i][1], t_key_tracks_restore[i][2])
  end

  reaper.Undo_EndBlock('Toggle bypass all envelopes from selected tracks (each track is individual)', -1)
  reaper.PreventUIRefresh(-1)

  
