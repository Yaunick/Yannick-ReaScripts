-- @description Yannick_Insert =START marker, then =END marker at edit cursor
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  ---//////---COLOR---\\\\\---
    R = 186   ----Red
    G = 0     ----Green
    B = 0     ----Blue
  ---\\\\\\\\\\||//////////---
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
    local cur_pos = reaper.GetCursorPosition()
    local color = reaper.ColorToNative(R,G,B)|0x1000000
    local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
    local t = {}
    local count = 1
    local t_name
    
    for i=1, num_markers+num_regions do
      local _, _, _, _, name, number, _ = reaper.EnumProjectMarkers3(0,i-1)
      if name == '=START' then
        t[count] = number
        t_name = '=START'
        count = count + 1
      end
      if name == '=END' then
        t[count] = number
        t_name = '=END'
        count = count + 1
      end
    end
    
    if #t >= 2 then
      for i=1, #t do
        reaper.DeleteProjectMarker(0, t[i], false)
      end
      reaper.AddProjectMarker2(0, false, cur_pos, 0, '=START', -1, color)
    elseif #t == 1 then
      if t_name == '=START' then
        reaper.AddProjectMarker2(0, false, cur_pos, 0, '=END', -1, color)
      elseif t_name == '=END' then
        reaper.AddProjectMarker2(0, false, cur_pos, 0, '=START', -1, color)
      end
    elseif #t == 0 then
      reaper.AddProjectMarker2(0, false, cur_pos, 0, '=START', -1, color)
    end
    
  reaper.Undo_EndBlock('Insert =START marker, then =END marker at edit cursor position',-1)
  reaper.PreventUIRefresh(-1)