-- @description Yannick_Offline all FX from Master track - Restore previous
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added new option "show warning window" - false by default
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  ---------------------------------
    show_warning_window = false
  ---------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_warning_window ~= false and show_warning_window ~= true then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local retval, val = reaper.GetProjExtState(0, "Master_fx_yannick_reasc", "master_track")
  
  if val ~= "" then
  
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1) 
    
    local t = {}
    local t_2 = {}
    local count = 0
    local string_bool = ""
    
    for s in string.gmatch(val, "[^,]+") do
      if count == 0 then
        table.insert(t,s)
        count = 1
      else
        if s == '0' then
          string_bool = false
        else
          string_bool = true
        end
        table.insert(t_2,string_bool)
        count = 0
      end
    end
    
    local t_dual = {}
    
    for i=1, #t do
      t_dual[#t_dual+1] = { t[i], t_2[i] }
    end
    
    local master_track = reaper.GetMasterTrack(0)
    for i=0, reaper.TrackFX_GetCount(master_track)-1 do
      local GUID = reaper.TrackFX_GetFXGUID(master_track, i)
      for j=1, #t_dual do
        if GUID == t_dual[j][1] then
          reaper.TrackFX_SetOffline(master_track, i, t_dual[j][2])
          table.remove(t_dual, j)
          break
        end
      end
    end
    
    reaper.Undo_EndBlock('Offline all FX from Master track - Restore previous', -1)
    reaper.PreventUIRefresh(-1)
  
  else
    if show_warning_window == true then
      reaper.MB("No saved online states of master FX!", "Error",0)
    end
    nothing()
  end