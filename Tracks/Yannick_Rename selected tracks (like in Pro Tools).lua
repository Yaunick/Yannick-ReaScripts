-- @description Yannick_Rename selected tracks (like in Pro Tools)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --------------------
  input_width = 120
  --------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  
  if not tonumber(input_width)
  or input_width < 0 then
    reaper.MB('Incorrect value for "input width" parameter. Look at the beginning of the script','Error',0)
    nothing() return
  end
    

  ---Test---How many selected tracks?---------------------------------------------------
  count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks == 0 then
    reaper.MB('No tracks. Please select tracks', 'Error', 0) 
    nothing() return
  end
  --------------------------------------------------------------------------------------
    
  local j = 1
  while j <= count_sel_tracks do
    local get_track = reaper.GetSelectedTrack(0,j-1)
    local retval_tr_name, stringNeedBig = reaper.GetSetMediaTrackInfo_String(get_track, 'P_NAME', 0, false)
    retval, retvals_csv = reaper.GetUserInputs('Rename '..j..' of '..count_sel_tracks..' tracks - "ESC" for out', 
    1, 'Set the '..j..' track name:,extrawidth=' .. input_width, stringNeedBig)
    retvals_csv = tostring(retvals_csv)
    if retval then 
      if string.upper(retvals_csv) == 'ESC' then
        nothing() return
      else
        reaper.Undo_BeginBlock()
        reaper.GetSetMediaTrackInfo_String(get_track, 'P_NAME', retvals_csv, true)
        reaper.Undo_EndBlock('Set name "'..retvals_csv..'" for '..j..' track of '..count_sel_tracks..' selected tracks', -1)
        j = j+1
      end
    elseif not retval then
      if j == 1 then
        nothing() return
      else
        j = j-1
      end
    end
  end
  