-- @description Yannick_Copy all existed plugins names to the clipboard
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + some code improvements
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  -----------------------------------------------------
    show_window = true
  -----------------------------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_window ~= true and show_window ~= false then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end

  local t_vst, t_vsti = {}, {}
  
  local path = reaper.GetResourcePath() .. "/reaper-vstplugins64.ini"
  local file = io.open(path, 'r')
  
  for l in file:lines() do
    if l:find("!!!VSTi") then
      local vst_i_str = l:match("[^,]+,[^,]+,([^+]+)!!!VSTi")
      if vst_i_str ~= nil and vst_i_str ~= "<SHELL>" then
        t_vsti[#t_vsti+1] = '"' .. vst_i_str .. '",' .. '\n'
      end
    else
      local vst_str = l:match("[^,]+,[^,]+,([^+]+)")
      if vst_str ~= nil and vst_str ~= "<SHELL>" then
        t_vst[#t_vst+1] = '"' .. vst_str .. '",' .. '\n'
      end
    end
  end
  
  io.close(file)
  
  local insrt_str = 
  "=============================================================================================\n" ..
  "    All INSTRUMENTS            All INSTRUMENTS            All INSTRUMENTS\n" .. 
  "=============================================================================================\n\n"
  
  local vst_str = 
  "=============================================================================================\n" ..
  "    All FX              All FX              All FX              All FX\n" ..
  "=============================================================================================\n\n"
  
  if #t_vsti > 0 then
    table.insert(t_vsti, 1, insrt_str)
  end
  if #t_vst > 0 then
    table.insert(t_vst, 1, vst_str)
  end
  
  local new_str = table.concat(t_vst) .. '\n' .. table.concat(t_vsti)
  
  reaper.CF_SetClipboard(new_str)
  
  if show_window == true then
    reaper.MB("Success! All plugins names have been copied to the clipboard!\n" .. 
    '\nPaste the text into a text editor to see the list of names ("Notepad++" for example)', "Warning", 0)
  end
  
  nothing()