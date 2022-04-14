-- @description Yannick_Add envelope points at gridlines within Razor Edit (automation items support)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

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
  
  for j=0, reaper.CountTracks(0)-1 do
    local track = reaper.GetTrack(0,j)
    local retval, string_razor = reaper.GetSetMediaTrackInfo_String( track, "P_RAZOREDITS", '', false)
    if string_razor ~= "" then
      local string_razor = string_razor .. ' '
      local table_razor = {}
      for s in string_razor:gmatch(".-%s.-%s.-%s") do
        table_razor[#table_razor+1] = { s:match("(.-)%s.-%s.-%s"), s:match(".-%s(.-)%s.-%s"), s:match('.-%s.-%s(.-)%s') }
      end
      for i=0, reaper.CountTrackEnvelopes(track)-1 do
        local env = reaper.GetTrackEnvelope(track,i)
        local retval, str = reaper.GetEnvelopeStateChunk( env, '', false)
        local GUIDenv = '"' .. str:match("EGUID (.+})") .. '"'
        for i2=1, #table_razor do
          if GUIDenv == table_razor[i2][3] then
            local t_autom_items = {}
            local start_razor = tonumber(table_razor[i2][1])
            local end_razor = tonumber(table_razor[i2][2])
            for i3=0,  reaper.CountAutomationItems(env)-1 do
              local ai_start = reaper.GetSetAutomationItemInfo( env, i3, 'D_POSITION', 0, false)
              local ai_end = ai_start + reaper.GetSetAutomationItemInfo( env, i3, 'D_LENGTH', 0, false)
              if start_razor >= ai_start - 0.00001 and start_razor <= ai_end + 0.00001
              or end_razor >= ai_start - 0.00001 and end_razor <= ai_end + 0.00001
              or start_razor < ai_start - 0.00001 and end_razor > ai_end + 0.00001
              then
                t_autom_items[#t_autom_items+1] = { ai_start, ai_end, i3 }
              end
            end
            local t_insert_points = {}
            local point_pos = start_razor
            local save_next_grid_step = 0
            local bool_find_end, change_count = false, false
            local count_autom_items = 1
            while bool_find_end == false do
              if #t_autom_items > 0 
              and point_pos >= t_autom_items[count_autom_items][1] - 0.00001
              and point_pos <= t_autom_items[count_autom_items][2] + 0.00001
              then
                change_count = true
                env_idx = t_autom_items[count_autom_items][3]
              else
                if change_count == true then 
                  if t_autom_items[count_autom_items+1] then
                    count_autom_items = count_autom_items + 1
                  end
                  change_count = false
                end
                env_idx = -1
              end
              if point_pos >= tonumber(table_razor[i2][2])-0.00001 then
                bool_find_end = true
                point_pos = end_razor
              end
              t_insert_points[#t_insert_points+1] = { point_pos, env_idx }
              point_pos = reaper.BR_GetNextGridDivision(point_pos)
            end
            local t_insert_points_with_evaluate_offset = {}
            for i3=1, #t_insert_points do
              local offset_evaluate = 0
              local offset_point = 0
              if t_insert_points[i3+1] 
              and 
              (t_insert_points[i3][2] >= 0 and t_insert_points[i3+1][2] == -1) 
              then
                offset_evaluate = -0.02
                offset_point = -0.0000000001
              elseif (t_insert_points[i3][2] >= 0 and i3 == 1)
              or (t_insert_points[i3-1]
              and 
              t_insert_points[i3][2] >= 0 and t_insert_points[i3-1][2] == -1)
              then
                offset_evaluate = 0.02
                offset_point = 0.0000000001
              end
              t_insert_points_with_evaluate_offset[#t_insert_points_with_evaluate_offset+1] = {
                t_insert_points[i3][1] + offset_point, 
                t_insert_points[i3][2], 
                offset_evaluate
              }
            end
            for i3=1, #t_insert_points_with_evaluate_offset do
              local retval, value, _, _, _ = 
              reaper.Envelope_Evaluate( 
              env, t_insert_points_with_evaluate_offset[i3][1]+t_insert_points_with_evaluate_offset[i3][3], 0, 0
              )
              reaper.InsertEnvelopePointEx( 
                env, t_insert_points_with_evaluate_offset[i3][2], t_insert_points_with_evaluate_offset[i3][1], value, 0, 0, 0, 0
              )
            end
          end
        end
      end
    end
  end        
            
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Add envelope points at gridlines within Razor Edit (automation items support)", -1)