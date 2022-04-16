-- @description Yannick_Move volume envelope points from active takes of selected items into volume envelope (pre-fx) from parent tracks
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # fixed typos in code
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  reaper.PreventUIRefresh(1)
  
  local t_str_summa = {}
  local t_str_summa_in_tr = {}
  local clear_table = false
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local t_str = {}
    local item_1 = reaper.GetSelectedMediaItem(0,i)
    local tr_1 = reaper.GetMediaItem_Track(item_1)
    local item_2 = reaper.GetSelectedMediaItem(0,i+1)
    if item_2 then
      local tr_2 = reaper.GetMediaItem_Track(item_2)
      if tr_1 ~= tr_2 then
        clear_table = true
      end
    end
    if i == reaper.CountSelectedMediaItems(0)-1 then
      clear_table = true
    end
    local take = reaper.GetActiveTake(item_1)
    for j=0, reaper.CountTakeEnvelopes(take)-1 do
      local env = reaper.GetTakeEnvelope( take, j)
      local retval, str = reaper.GetEnvelopeStateChunk( env, '', false)
      if str:sub(1,8) == "<VOLENV\n" then
        local start_item = reaper.GetMediaItemInfo_Value(item_1, 'D_POSITION')
        for s in str:gmatch(".-\n") do
          if s:sub(1,3) == "PT " then
            local number = tonumber(s:match("PT ([%d.]+)")) + start_item
            t_str[#t_str+1] = s:gsub("PT ([%d.]+)", "PT " .. tostring(number))
          end
        end
        reaper.SetEnvelopeStateChunk( env, str:gsub("\n", "¤¤"), false)
        break
      end
    end
    
    if #t_str > 0 then
      t_str_summa[#t_str_summa+1] = table.concat(t_str)
    end
    if clear_table == true then
      if #t_str_summa > 0 then
        t_str_summa_in_tr[#t_str_summa_in_tr+1] = { tr_1 , table.concat(t_str_summa)}
        t_str_summa = {}
      end
      clear_table = false
    end
  end
  
  if #t_str_summa_in_tr == 0 then
    reaper.MB("No active volume envelopes from active takes on selected items!", "Error", 0)
    reaper.PreventUIRefresh(-1)
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  
  local t_sel_tracks = {}
  for i=0, reaper.CountSelectedTracks(0)-1 do
    t_sel_tracks[#t_sel_tracks+1] = reaper.GetSelectedTrack(0,i)
  end
  
  for j=1, #t_str_summa_in_tr do
    reaper.SetOnlyTrackSelected(t_str_summa_in_tr[j][1],true)
    reaper.Main_OnCommand(41865,0) -- select pre-fx track envelope
    for i=0, reaper.CountTrackEnvelopes(t_str_summa_in_tr[j][1])-1 do
      local env_tr = reaper.GetTrackEnvelope(t_str_summa_in_tr[j][1], i )
      local retval, str_env = reaper.GetEnvelopeStateChunk( env_tr, '', false)
      if str_env:sub(1,8) == "<VOLENV\n" then
        reaper.SetEnvelopeStateChunk( env_tr, str_env:match("(.+\n)>") .. t_str_summa_in_tr[j][2] .. ">", false)
      end
    end 
  end
  
  reaper.Main_OnCommand(40297,0) -- unselect all tracks
  for i=1, #t_sel_tracks do
    reaper.SetTrackSelected(t_sel_tracks[i], true)
  end
    
  reaper.Undo_EndBlock("Move volume envelope points from active takes of selected items into volume envelope (pre-fx) from parent tracks", -1)
  reaper.PreventUIRefresh(-1)