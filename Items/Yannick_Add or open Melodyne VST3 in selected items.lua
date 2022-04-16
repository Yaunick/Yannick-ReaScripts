-- @description Yannick_Add or open Melodyne VST3 in selected items
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + now you can change the name "Melodyne (Celemony)" to any other name in FX Browser
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function bla() end 
  function nothing() reaper.defer(bla)end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
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
    .. 'of the .vst3 or .dll file of the Melodyne (Celemony) plugin to another name then please return the original name!', 
    'Error', 0)
    nothing() return
  end
  ---------------------------------------------------------------------------------

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  function find_melodyne_by_hash(s, count_number)
    if s:find("{5653544D6C70676D656C6F64796E6520}") -- VST3 Melodyne
    or s:find("<5653544D6C70676D656C6F64796E6520>") -- VST2 Melodyne
    then
      local number_melodyne = count_number
      return number_melodyne
    end
  end
  
  function find_melodyne_number_in_chunk(str, count_number, number_melodyne, take_sel, takefx_bl, itemfx_bl)
    for s in str:gmatch('.-\n') do
      if s == 'TAKE SEL\n' then
        take_sel = true
      elseif s == 'TAKE\n' and take_sel == true then
        break
      end
      if take_sel == true then
        if s == '<TAKEFX\n' then
          takefx_bl = true
        end
        if takefx_bl == true then
          if s:match('<[VJALD][SUVX].-\n') then
            number_melodyne = find_melodyne_by_hash(s, count_number)
            count_number = count_number + 1
          end
        end
      end
    end
    if take_sel == false then
      for s in str:gmatch('.-\n') do
        if s == '<TAKEFX\n' then
          itemfx_bl = true
        elseif s == 'TAKE\n' then
          break
        end
        if itemfx_bl == true then
          if s:match('<[VJALD][SUVX].-\n') then
            number_melodyne = find_melodyne_by_hash(s, count_number)
            count_number = count_number + 1
          end
        end
      end
    end
    return number_melodyne
  end
  
  local t_items_with_melodyne = {}
  local count_sel_items = reaper.CountSelectedMediaItems(0)
  
  for i=0, count_sel_items-1 do
    local number_melodyne = 'no number'
    local count_number = 0
    local take_sel = false
    local takefx_bl = false
    local itemfx_bl = false
    local item = reaper.GetSelectedMediaItem(0,i)
    local retval, str = reaper.GetItemStateChunk( item, '', false)
    local number_melodyne = find_melodyne_number_in_chunk(str, count_number, number_melodyne, take_sel, takefx_bl, itemfx_bl)
    t_items_with_melodyne[#t_items_with_melodyne+1] = { item, number_melodyne }
  end
  
  local t_open_melodynes = {}
  
  for i=1, #t_items_with_melodyne do
    local number_melodyne = t_items_with_melodyne[i][2]
    if number_melodyne == 'no number' then
      local count_number = 0
      local take_sel = false
      local takefx_bl = false
      local itemfx_bl = false
      reaper.TakeFX_AddByName( reaper.GetActiveTake(t_items_with_melodyne[i][1]), user_name_melodyne, -1)
      local retval, str = reaper.GetItemStateChunk(t_items_with_melodyne[i][1], '', false)
      number_melodyne = find_melodyne_number_in_chunk(str, count_number, number_melodyne, take_sel, takefx_bl, itemfx_bl)
    end
    local tr_it_1 = reaper.GetMediaItem_Track(t_items_with_melodyne[i][1])
    if i < #t_items_with_melodyne then
      local tr_it_2 = reaper.GetMediaItem_Track(t_items_with_melodyne[i+1][1])
      if tr_it_1 ~= tr_it_2 then
        t_open_melodynes[#t_open_melodynes+1] = { t_items_with_melodyne[i][1], number_melodyne }
      end
    end
    if i == #t_items_with_melodyne then
      t_open_melodynes[#t_open_melodynes+1] = { t_items_with_melodyne[i][1], number_melodyne }
    end
  end

  for i=1, #t_open_melodynes do
    reaper.TakeFX_Show( reaper.GetActiveTake(t_open_melodynes[i][1]), t_open_melodynes[i][2], 3)
  end
  
  reaper.Undo_EndBlock('Add or open Melodyne VST3 in selected items', -1)
  reaper.PreventUIRefresh(-1)