-- @description Yannick_Add envelope points at gridlines within Razor Edit (no automation items support - faster)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU 
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountTracks(0) == 0 then
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  for i=0, reaper.CountTracks(0)-1 do
    local track = reaper.GetTrack(0,i)
    local retval, string_razor = reaper.GetSetMediaTrackInfo_String( track, "P_RAZOREDITS", '', false)
    if string_razor ~= "" then
      local string_razor = string_razor .. ' '
      local table_razor = {}
      for s in string_razor:gmatch(".-%s.-%s.-%s") do
        table_razor[#table_razor+1] = { s:match("(.-)%s.-%s.-%s"), s:match(".-%s(.-)%s.-%s"), s:match('.-%s.-%s(.-)%s') }
      end
      for i=0, reaper.CountTrackEnvelopes(track)-1 do
        local t_points = {}
        local env = reaper.GetTrackEnvelope(track,i)
        local retval, str = reaper.GetEnvelopeStateChunk( env, '', false)
        local GUIDenv = '"' .. str:match("EGUID (.+})") .. '"'
        for i2=1, #table_razor do
          if GUIDenv == table_razor[i2][3] then
            local point_pos = tonumber(table_razor[i2][1])
            local is_first_step = 0
            local retval_en, value_en,_,_,_ = reaper.Envelope_Evaluate( env, point_pos, 0, 0)
            t_points[#t_points+1] = 'PT '..tostring(point_pos)..' '..tostring(value_en)..' 0'..'\n'
            local bool_find_end = false
            while bool_find_end == false do
              point_pos = reaper.BR_GetNextGridDivision(point_pos)
              retval_en, value_en,_,_,_ = reaper.Envelope_Evaluate( env, point_pos, 0, 0)
              if point_pos >= tonumber(table_razor[i2][2])-0.000001 then
                bool_find_end = true
                t_points[#t_points+1] = 'PT '..table_razor[i2][2]..' '..tostring(value_en)..' 0'
              else
                t_points[#t_points+1] = 'PT '..tostring(point_pos)..' '..tostring(value_en)..' 0'..'\n'
              end
            end
          end
        end
        reaper.SetEnvelopeStateChunk(env, str:sub(1, str:len()-2) .. table.concat(t_points) .. '\n>', false)
      end
    end
  end
  
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Add envelope points at gridlines within Razor Edit (no automation items support - faster)", -1)