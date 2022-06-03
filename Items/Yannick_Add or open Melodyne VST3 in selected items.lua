-- @description Yannick_Add or open Melodyne VST3 in selected items
-- @author Yannick
-- @version 1.9
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + code optimization
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function bla() end
  function nothing() reaper.defer(bla)end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    nothing() return
  end
  
  if not reaper.MIDIEditor_EnumTakes then
    reaper.MB("Please update REAPER to version 6.37 or higher", "Error", 0)
    nothing() return
  end
  
  local path = reaper.GetResourcePath() .. "/reaper-vstplugins64.ini"
  if reaper.file_exists(path) == false then
    reaper.MB("You don't have the following file - 'reaper-vstplugins64.ini\n\n" ..
    "Install third party VST plugins and open FX Browser to generate these file", "Error", 0)
    nothing() return
  end
  
  ---FIND MELODYNE USER NAME-------------------------------------------------------
  local user_name_melodyne = nil
  local file = io.open(path, 'r')
  for l in file:lines() do
    if l:find("{5653544D6C70676D656C6F64796E6520,") -- VST3 Melodyne hash
    or l:find("Melodyne.vst3=") --- VST3 Melodyne name
    then
      user_name_melodyne = l:match("[^,]+,[^,]+,(.+)")
      break
    end
  end
  io.close(file)
  if user_name_melodyne == nil then
    reaper.MB('The Melodyne (Celemony) plugin was not found!\n\n' 
    .. 'Perhaps the plugin is not installed, or you have changed the original name '
    .. 'of the .vst3 file of the Melodyne (Celemony) plugin to another name then please return the original name!', 
    'Error', 0)
    nothing() return
  end
  ---------------------------------------------------------------------------------
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  function find_melodyne_number_in_item(take, number_melodyne)
    for i=0, reaper.TakeFX_GetCount(take) - 1 do
      local retval, buf = reaper.TakeFX_GetNamedConfigParm( take, i, 'fx_ident' )
      if buf:find("{5653544D6C70676D656C6F64796E6520") then
        number_melodyne = i
      end
    end
    if number_melodyne == nil then
      number_melodyne = 'no number'
    end
    return number_melodyne
  end
  
  local count_sel_items = reaper.CountSelectedMediaItems(0)
  local t_open_melodyne = {}
  local t_sel_tracks = {}
  
  for i=0, count_sel_items-1 do
    local number_melodyne = 'no number'
    local item = reaper.GetSelectedMediaItem(0,i)
    local take = reaper.GetActiveTake(item)
    if reaper.TakeIsMIDI(take) == false then
      local number_melodyne = find_melodyne_number_in_item(take, number_melodyne)
      if number_melodyne == 'no number' then
        reaper.TakeFX_AddByName( take, user_name_melodyne, -1)
        number_melodyne = find_melodyne_number_in_item(take, number_melodyne)
      end
      local tr_it_1 = reaper.GetMediaItem_Track(item)
      if i < count_sel_items-1 then
        local item_2 = reaper.GetSelectedMediaItem(0,i+1)
        local tr_it_2 = reaper.GetMediaItem_Track(item_2)
        if tr_it_1 ~= tr_it_2 then
          t_sel_tracks[#t_sel_tracks+1] = tr_it_1
        end
      else
        t_sel_tracks[#t_sel_tracks+1] = tr_it_1
      end
      last_item = item
      last_number_melodyne = number_melodyne
    else
      find_midi = true
    end
  end
  
  if find_midi == true then
    reaper.MB('Please select only audio items', 'Error', 0)
  else
    reaper.Main_OnCommand(40297,0) -- unselect all tracks
  
    for i=1, #t_sel_tracks do
      reaper.SetTrackSelected(t_sel_tracks[i], true)
    end
    
    reaper.TakeFX_Show( reaper.GetActiveTake(last_item), last_number_melodyne, 3)
  end

  reaper.Undo_EndBlock('Add or open Melodyne VST3 in selected items', -1)
  reaper.PreventUIRefresh(-1)