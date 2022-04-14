-- @description Yannick_Render selected pre-glued items that have active MIDI takes and source track instrument to new take without FX
-- @author Yannick
-- @version 1.8
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --------------------------------------------------------------------------------------------

    tail_for_item = 0   --- sec 
    user_inputs = true
    
    bypass_active_preFX_envelopes = true
      warn_about_active_preFX_env = true
      
    warn_about_item_and_take_volume = true
      
    warn_about_overlapping_MIDI_items_and_that_not_all_items_on_the_tracks_are_selected = true   --- without warning, the script will run faster
      overlapping_detect_sensitivity = 10    --- millisec (for ignoring overlaps associated with MIDI PPQ)
      
    after_rendering_set_the_instrument_to = 0   --- 0 = leave active
                                                --- 1 = set bypass
                                                --- 2 = set offline
                 
  --------------------------------------------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if (not tonumber(tail_for_item) or tail_for_item < 0)
  or (user_inputs ~= true and user_inputs ~= false)
  or (bypass_active_preFX_envelopes ~= true and bypass_active_preFX_envelopes ~= false)
  or (warn_about_active_preFX_env ~= true and warn_about_active_preFX_env ~= false)
  or (warn_about_item_and_take_volume ~= true and warn_about_item_and_take_volume ~= false)
  or (
    warn_about_overlapping_MIDI_items_and_that_not_all_items_on_the_tracks_are_selected ~= true
    and warn_about_overlapping_MIDI_items_and_that_not_all_items_on_the_tracks_are_selected ~= false
  )
  or (not tonumber(overlapping_detect_sensitivity) or overlapping_detect_sensitivity < 0)
  or (after_rendering_set_the_instrument_to ~= 0 and after_rendering_set_the_instrument_to ~= 1 and after_rendering_set_the_instrument_to ~= 2)
  then
    reaper.MB('Incorrect settings at the beginning of the scripts', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.MB("No items. Please select an item", "Error",0)
    nothing() return
  end
  
  local t_tracks = {}
  local t_prefx_env = {}
  local t_track_itms = {}
  local msg = false
  local msg_2 = false
  local overlap = false
  local test_instr = true
  local find_second_instr = false
  
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local item_1 = reaper.GetSelectedMediaItem(0,i)
    local track_1 = reaper.GetMediaItemTrack(item_1)
    if test_instr == true then
      for h=1, reaper.TrackFX_GetCount(track_1) do
        local retval, buf = reaper.TrackFX_GetNamedConfigParm( track_1, h-1, 'fx_type')
        if buf == "" then
          reaper.MB("For the script to check that there are no multiple instruments, you need to update REAPER to version 6.37 or higher", 
          "Error", 0)
          nothing() return
        end
        if buf == "VSTi" and find_second_instr == false
        or buf == "VST3i" and find_second_instr == false
        or buf == "AUi" and find_second_instr == false
        or buf == "DXi" and find_second_instr == false
        or buf == "LV2i" and find_second_instr == false
        then
          find_second_instr = true
        elseif buf == "VSTi" or buf == "VST3i" or buf == "AUi" or buf == "DXi" or buf == "LV2i" then
          reaper.MB("Please select items on tracks with only one instrument", "Error", 0)
          nothing() return
        end
      end
      if find_second_instr == false then
        reaper.MB("Please select items on tracks with active instruments", "Error", 0)
        nothing() return
      end
      find_second_instr = false
      test_instr = false
    end
    
    local take = reaper.GetActiveTake(item_1)
    if reaper.TakeIsMIDI(take) == false then
      reaper.MB("Please select only items with active MIDI takes", "Error", 0)
      nothing() return
    end
    if reaper.TakeFX_GetCount(take) > 0 then
      reaper.MB('Please select only takes with empty take FX chain', 'Error', 0)
      nothing() return
    end
    if reaper.CountTakeEnvelopes(take) > 0 then
      reaper.MB('Please select only takes without active take envelopes', 'Error', 0)
      nothing() return
    end
    if warn_about_item_and_take_volume == true then
      if msg_2 == false then
        if reaper.GetMediaItemInfo_Value(item_1, 'D_VOL') ~= 1 
        or reaper.GetMediaItemTakeInfo_Value(take, 'D_VOL') ~= 1 then
          local retval =
          reaper.MB('You have volume values on the selected items that change the velocity of MIDI takes. ' ..
          'After rendering, the velocity values will be applied and the new velocity values will be displayed inside the MIDI take. ' ..
          '\n\nAre you sure you want to continue?','Warning',1)
          if retval == 2 then
            nothing() return
          end
          msg_2 = true
        end
      end
    end
    if i == 0 then
      t_tracks[#t_tracks+1] = track_1
    end
    local item_2 = reaper.GetSelectedMediaItem(0,i+1)
    if item_2 then
      local track_2 = reaper.GetMediaItemTrack(item_2)
      if track_1 ~= track_2 then
        t_tracks[#t_tracks+1] = track_2
        test_instr = true
      end
    end
  end
  
  if warn_about_overlapping_MIDI_items_and_that_not_all_items_on_the_tracks_are_selected == true then
    for i=1, #t_tracks do
      for f=0, reaper.CountTrackMediaItems(t_tracks[i])-1 do
        local track_itm_1 = reaper.GetTrackMediaItem(t_tracks[i], f)
        if after_rendering_set_the_instrument_to == 1 or after_rendering_set_the_instrument_to == 2 then
          if reaper.TakeIsMIDI(reaper.GetActiveTake(track_itm_1)) == true 
          and reaper.IsMediaItemSelected(track_itm_1) == false then
            local retval = 
            reaper.MB("You haven't selected all active MIDI takes on the tracks. Because the instrument after rendering will cease to be active, " ..
            'the remaining active MIDI takes will not sound. ' ..
            '\n\nAre you sure you want to continue?', 
            'Warning', 1)
            if retval == 2 then
              nothing() return
            else
              goto OK
            end
          end
        else
          local track_itm_2 = reaper.GetTrackMediaItem(t_tracks[i], f+1)
          if track_itm_2 then
            local track_itm_end_1 = reaper.GetMediaItemInfo_Value(track_itm_1, 'D_POSITION') + 
            reaper.GetMediaItemInfo_Value(track_itm_1, 'D_LENGTH')
            local track_itm_start_2 = reaper.GetMediaItemInfo_Value(track_itm_2, 'D_POSITION')
            if track_itm_end_1 - (overlapping_detect_sensitivity/1000) > track_itm_start_2 then
              overlap = true
            else
              overlap = false
            end
            if overlap == true then
              if reaper.TakeIsMIDI(reaper.GetActiveTake(track_itm_1)) == true and reaper.TakeIsMIDI(reaper.GetActiveTake(track_itm_2)) == true
              then
                if (reaper.IsMediaItemSelected(track_itm_1) == true and reaper.IsMediaItemSelected(track_itm_2) == false)
                or (reaper.IsMediaItemSelected(track_itm_1) == false and reaper.IsMediaItemSelected(track_itm_2) == true)
                then
                  local retval = reaper.MB('Among the overlapping sets of active MIDI takes, there are selected and unselected takes at the same time. ' ..
                  'After rendering, If MIDI and AUDIO overlapping takes are mixed, the final sound may change. \n\nAre you sure you want to continue?',
                  'Warning', 1)
                  if retval == 2 then
                    nothing() return
                  else
                    goto OK
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  
  ::OK::
  
  if bypass_active_preFX_envelopes == true then
    for i=1, #t_tracks do
      for g=1, reaper.CountTrackEnvelopes(t_tracks[i]) do
        local tr_envelo = reaper.GetTrackEnvelope(t_tracks[i], g-1)
        local env_retval, env_str = reaper.GetEnvelopeStateChunk(tr_envelo, '', false)
        local type_env = env_str:match("(.-)\n")
        if type_env == "<VOLENV" 
        or type_env == "<PANENV" 
        or type_env == "<WIDTHENV" 
        then
          local active = tonumber( env_str:match("ACT (%d)") )
          if active == 1 then
            if warn_about_active_preFX_env == true then
              if msg == false then
                local retval = reaper.MB("You have active Volume Pre-FX or Pan Pre-FX or Width Pre-FX envelopes! " .. 
                "\n\nAfter rendering, the script should be set the bypass state of these envelopes, " ..
                "because they will be applied to the new audio take and the final sound may change. " ..
                "\n\nAre you sure you want to continue?", "Warning", 1)
                if retval == 2 then
                  nothing() return
                end
                msg = true
              end
            end
            t_prefx_env[#t_prefx_env+1] = {tr_envelo, t_tracks[i]}
          end
        end
      end
    end
  end
  
  if user_inputs == true then
    ::START::
    local retval, value = reaper.GetUserInputs("Render selected MIDI takes to new take", 1, 
    "Set the tail for new item:,extrawidth=40",tail_for_item)
    if not retval then
      nothing() return
    end
    if not tonumber(value) or tonumber(value) < 0 then
      reaper.MB("Incorrect value. Set the number of tail", "Error" , 0)
      goto START
    end
    tail_for_item = tonumber(value)
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local loopnewit_save = reaper.SNM_GetIntConfigVar('loopnewitems',0)
  local change_setting = false
  if loopnewit_save&32 ~= 32 then
    local loopnewit = loopnewit_save~32
    reaper.SNM_SetIntConfigVar('loopnewitems',loopnewit)
    change_setting = true
  end
  
  local apply_takes = 40209
  local t_fx, t_env, t_instr_byp = {}, {}, {}
  
  for i=1, #t_tracks do
    for s=1, reaper.TrackFX_GetCount(t_tracks[i]) do
      local num_par = reaper.TrackFX_GetNumParams(t_tracks[i], s-1)
      local env_fx = reaper.GetFXEnvelope(t_tracks[i], s-1, num_par-3, false)  --- get native Bypass FX envelope
      if env_fx ~= nil and s-1 == reaper.TrackFX_GetInstrument(t_tracks[i]) 
      and after_rendering_set_the_instrument_to == 1 then
        t_instr_byp[#t_instr_byp+1] = {s-1, t_tracks[i], num_par-3}
      elseif env_fx ~= nil and s-1 > reaper.TrackFX_GetInstrument(t_tracks[i]) then
        local env_retval, env_str = reaper.GetEnvelopeStateChunk(env_fx, '', false)
        local byp_env_active = tonumber( env_str:match("ACT (%d)") )
        t_env[#t_env+1] = { env_fx, byp_env_active}
        reaper.SetEnvelopeStateChunk( env_fx,env_str:gsub( 'ACT [%d]', 'ACT '.. 0), false)
      end
    end
    
    for j=1, reaper.TrackFX_GetCount(t_tracks[i]) do
      if j-1 > reaper.TrackFX_GetInstrument(t_tracks[i]) then
        t_fx[#t_fx+1] = { j-1, t_tracks[i], reaper.TrackFX_GetEnabled( t_tracks[i], j-1) }
        reaper.TrackFX_SetEnabled( t_tracks[i], j-1, false)
      end
    end
  end
  
  reaper.Main_OnCommand(40362,0) --Item: Glue items ignoring time selection
  
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local item_1 = reaper.GetSelectedMediaItem(0,i)
    local track_1 = reaper.GetMediaItem_Track(item_1)
    local item_2 = reaper.GetSelectedMediaItem(0,i+1)
    if item_2 then 
      local track_2 = reaper.GetMediaItem_Track(item_2)
      if track_1 == track_2 then
        goto NEXT
      end
    end
  end
  
  reaper.ApplyNudge(0, 0, 3, 1, tail_for_item, 0, 0)
   
  reaper.Main_OnCommand(apply_takes,0)
  
  ::NEXT:: 
  
  local t_undo_tracks = {}
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    if reaper.TakeIsMIDI(reaper.GetActiveTake(item)) == true then
      t_undo_tracks[#t_undo_tracks+1] = { reaper.GetMediaItem_Track(item), 1 }
    else
      t_undo_tracks[#t_undo_tracks+1] = { reaper.GetMediaItem_Track(item), 0 }
    end
  end
   
  for s=1, #t_env do 
    local b_env_retval, b_env_str = reaper.GetEnvelopeStateChunk(t_env[s][1], '', false)
    reaper.SetEnvelopeStateChunk( t_env[s][1], b_env_str:gsub( 'ACT [%d]', 'ACT '.. t_env[s][2] ), false)
  end
  
  for j=1, #t_fx do
    reaper.TrackFX_SetEnabled( t_fx[j][2], t_fx[j][1], t_fx[j][3])
  end

  for i=1, #t_instr_byp do
    local env_byp = reaper.GetFXEnvelope(t_instr_byp[i][2], t_instr_byp[i][1], t_instr_byp[i][3], false)
    local byp_env_retval, byp_env_str = reaper.GetEnvelopeStateChunk(env_byp, '', false)
    reaper.SetEnvelopeStateChunk(env_byp, byp_env_str:gsub( 'ACT [%d]', 'ACT '.. 0 ), false)
  end
  
  local count_undo_tr = 1
  local j_cn = 1
  while j_cn <= #t_prefx_env do
    if t_prefx_env[j_cn][2] ~= t_undo_tracks[count_undo_tr][1] then
      count_undo_tr = count_undo_tr + 1
    else
      if t_undo_tracks[count_undo_tr][2] == 0 then
        local prefx_env_retval, prefx_env_str = reaper.GetEnvelopeStateChunk(t_prefx_env[j_cn][1], '', false)
        reaper.SetEnvelopeStateChunk(t_prefx_env[j_cn][1], prefx_env_str:gsub( 'ACT [%d]', 'ACT '.. 0 ), false)
      end
      j_cn = j_cn + 1
    end
  end

  if after_rendering_set_the_instrument_to > 0 then
    for i=1, #t_tracks do
      if t_undo_tracks[i][2] == 0 then
        local tr_instr = reaper.TrackFX_GetInstrument(t_tracks[i])
        if after_rendering_set_the_instrument_to == 1 then
          reaper.TrackFX_SetEnabled(t_tracks[i], tr_instr, 0)
        else
          reaper.TrackFX_SetOffline(t_tracks[i], tr_instr, 1)
        end
      end
    end
  end
  
  if change_setting == true then
    reaper.SNM_SetIntConfigVar('loopnewitems', loopnewit_save)
  end
  
  reaper.Undo_EndBlock(
  'Render selected pre-glued items that have active MIDI takes and source track instrument to new take without FX',
  -1)
  reaper.PreventUIRefresh(-1)
  