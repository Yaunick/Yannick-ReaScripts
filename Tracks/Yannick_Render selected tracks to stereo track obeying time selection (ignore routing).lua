-- @description Yannick_Render selected tracks to stereo track obeying time selection (ignore routing)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  
  --////////---\\\\\\\---////////---\\\\\\\\---///////---\\\\\\\-- 
  
      ----------------enter some parameters----------------
      
        adjusting_the_render_bounds = 1
        -- 0 = ignore loop points and time selection
        -- 1 = ignore only loop points (like default)
        -- 2 = ignore only time selection
        mute_original_tracks = true
        old_name_for_one_stem_track = true
        name_for_new_track = 'stem'  ---enter the name
            
      -----------------------------------------------------
      
      ----------------Color for new track------------------
      ----enter 0 for R and G and B to disable coloring----
      
        R = 0   ----Red
        G = 0   ----Green
        B = 0   ----Blue
      
      -----------------------------------------------------
      -----------------------------------------------------
        
  --////////---\\\\\\\---////////---\\\\\\\\---///////---\\\\\\\--    
  
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if (adjusting_the_render_bounds ~= 0 and adjusting_the_render_bounds ~= 1 and adjusting_the_render_bounds ~= 2)
  or (mute_original_tracks ~= true and mute_original_tracks ~= false)
  or (old_name_for_one_stem_track ~= true and old_name_for_one_stem_track ~= false)
  or name_for_new_track ~= tostring(name_for_new_track)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect value for "adjusting_the_render_bounds" or "old_name_for_one_stem_track" ' ..
    'or "mute_original_tracks" or "name_for_new_track" or "RGB" parameters. Look at the beginning of the script',
    'Error',0)
    nothing() return
  end  
    
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
    
  if reaper.CountSelectedTracks(0) == 0 then 
    reaper.MB('No tracks. Please select tracks', 'Error',0)
    nothing() return 
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local tra = reaper.GetSelectedTrack(0,0)
  local number_tra = reaper.GetMediaTrackInfo_Value(tra,'IP_TRACKNUMBER')
  new_take_name = false
  if reaper.CountSelectedTracks(0) == 1 then
    _, old_name_track = reaper.GetSetMediaTrackInfo_String(tra, 'P_NAME', '', false)
    if old_name_track ~= '' then
      old_name_track = old_name_track .. ' - '
    end
  else
    old_name_track = ''
  end
  
  reaper.InsertTrackAtIndex(number_tra-1,false)
  get_new_track = reaper.GetTrack(0,number_tra-1)
  
  local t = {}
  for i=0, reaper.CountSelectedTracks(0)-1 do
    local get_track = reaper.GetSelectedTrack(0,i)
    local send_index = reaper.CreateTrackSend( get_track, reaper.GetTrack(0,number_tra-1))
    t[i+1] = get_track
    reaper.SetTrackSendInfo_Value(get_track, 0, send_index, 'I_SRCCHAN', 0) ---set source send channel
    reaper.SetTrackSendInfo_Value(get_track, 0, send_index, 'I_DSTCHAN', 0) ---set dest send channel
    reaper.BR_GetSetTrackSendInfo(get_track, 0, send_index, 'I_MIDI_SRCCHAN', true, -1) ---disable default midi send
  end
  
  reaper.SetOnlyTrackSelected(get_new_track,true)

  restore = 1
  if adjusting_the_render_bounds == 2 then
     start_point, end_point = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
     if end_point - start_point > 0 then
       save_ts_start, save_ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
       reaper.GetSet_LoopTimeRange2(0, true, false, start_point, end_point, false)
       restore = 2
     end
  elseif adjusting_the_render_bounds == 0 then
    save_ts_start, save_ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
    reaper.Main_OnCommand(40635,0) --remove time selection
    restore = 0
  end
  
  local count_tr_br = reaper.CountTracks(0)
  reaper.Main_OnCommand(41719, 0) -- Render stereo
  local count_tr_ar = reaper.CountTracks(0)
      
  if count_tr_ar > count_tr_br then 
    reaper.DeleteTrack(reaper.GetTrack(0,number_tra))
    if mute_original_tracks == true then
      for i=1, #t do
        reaper.SetMediaTrackInfo_Value(t[i],'B_MUTE',1)
      end
    end
  elseif count_tr_br == count_tr_ar then
    reaper.DeleteTrack(reaper.GetTrack(0,number_tra-1))
    for i=1, #t do
      reaper.SetTrackSelected(t[i],true)
    end
  end
  
  set_new_track = reaper.GetSelectedTrack(0,0)
  if old_name_for_one_stem_track == true then
    prefix_old = old_name_track
  else
    prefix_old = ''
  end
    
  reaper.GetSetMediaTrackInfo_String(set_new_track, 'P_NAME', prefix_old .. name_for_new_track, true)

  local item = reaper.GetTrackMediaItem(set_new_track, 0)
  local take = reaper.GetActiveTake(item)
  reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', prefix_old .. name_for_new_track, true)
    
  if R == 0 and G == 0 and B == 0 then
    nothing()
  else
    reaper.SetTrackColor(set_new_track, reaper.ColorToNative(R,G,B)|0x1000000)
  end
  
  if restore == 2 or restore == 0 then
    reaper.GetSet_LoopTimeRange2(0, true, false, save_ts_start, save_ts_end, false)
  end
      
  reaper.Undo_EndBlock('Render selected tracks to stereo track (obeing time selection)',-1)
  reaper.PreventUIRefresh(-1)

