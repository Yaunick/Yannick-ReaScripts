-- @description Yannick_Offline all Monitoring FX - Restore previous
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ---------------------------------
    show_warning_window = false
  ---------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_warning_window ~= false and show_warning_window ~= true then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local retval, val = reaper.GetProjExtState(0, "Monitoring_fx_yannick_reasc", "monit_fx")
  
  if retval == 1 and val ~= "" then
  
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1) 
    
    local t_dual = {}
    
    for s in val:gmatch("[^,]+,[^,]+,") do
      if s:match("[^,]+,([^,]+),") == '0' then
        bl_string = false
      else
        bl_string = true
      end
      t_dual[#t_dual+1] = { s:match("([^,]+),[^,]+,"), bl_string }
    end
    
    local master_track = reaper.GetMasterTrack(0)
    
    local bool = false
    local i = 0
    while bool == false do
      local GUID = reaper.TrackFX_GetFXGUID(master_track, 0x1000000 + i)
      if GUID == nil then
        bool = true
      else
        for j=1, #t_dual do
          if GUID == t_dual[j][1] then
            reaper.TrackFX_SetOffline(master_track, 0x1000000 + i, t_dual[j][2])
            table.remove(t_dual, j)
            break
          end
        end
      end
      i = i + 1
    end
    
    reaper.Undo_EndBlock('Offline all Monitoring FX - Restore previous', -1)
    reaper.PreventUIRefresh(-1)
  
  else
    if show_warning_window == true then
      reaper.MB("No saved online states of monitoring FX!", "Error",0)
    end
    nothing()
  end