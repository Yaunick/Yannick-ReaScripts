-- @description Yannick_Insert VSTi by name to new track
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  -----------------------------------------------------------------------------------
    name = "ReaSynth (Cockos)"
  -----------------------------------------------------------------------------------
  
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
  
  function bla() end
  function nothing()
    reaper.defer(bla)
  end
  
  if name ~= tostring(name)
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
  
  reaper.Undo_BeginBlock()
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
  local count_bef_track = reaper.TrackFX_GetCount(track)
  reaper.TrackFX_AddByName( track, name, false, -1)
  local count_aft_track = reaper.TrackFX_GetCount(track)
  if count_bef_track < count_aft_track
  and reaper.TrackFX_GetOffline(track, count_aft_track-1) == false
  then
    if R == 0 and B == 0 and G == 0 then
      nothing()
    else
      reaper.SetTrackColor(track, reaper.ColorToNative(R,G,B)|0x1000000)
    end
  
    if monitor_rec_for_new_track == true then
      reaper.SetMediaTrackInfo_Value( track, 'I_RECMON', 1)
    else
      reaper.SetMediaTrackInfo_Value( track, 'I_RECMON', 0)
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
    
    reaper.TrackFX_Show(track, count_aft_track-1, 3)
  else
    reaper.DeleteTrack(track)
    for i=1, #t_tracks_save do
      reaper.SetTrackSelected(t_tracks_save[i], true)
    end
  end
  
  reaper.Undo_EndBlock('Insert VSTi by name to new track',-1)
  reaper.PreventUIRefresh(-1)