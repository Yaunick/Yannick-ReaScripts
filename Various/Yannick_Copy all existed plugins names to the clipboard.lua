-- @description Yannick_Copy all existed plugins names to the clipboard
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
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
  
  local count = 0
  local count_symb = 0
  local count_q = 0
  local count_save = 0
  local t_vst, t_vsti = {}, {}
  
  local path = reaper.GetResourcePath() .. "/reaper-vstplugins64.ini"
  local file = io.open(path, 'r')
  
  for l in file:lines() do
    count = count + 1
    if count > 1 then
      for s in string.gmatch(l, ".") do
        count_symb = count_symb + 1
        if s == ',' then
          count_q = count_q + 1
          if count_q == 2 then
            count_save = count_symb
            break
          end
        end
      end
      
      if count_save == 0 then
        vst_i_str = ""
        vst_str = ""
      else
        vst_i_str = l:sub(count_save+1, l:len()-7)
        vst_str = l:sub(count_save+1, l:len())
      end
      
      if l:find("!!!VSTi") then
        if vst_i_str ~= "" and vst_i_str ~= "<SHELL>" then
          t_vsti[#t_vsti+1] = '"' .. vst_i_str .. '",' .. '\n'
        end
      else
        if vst_str ~= "" and vst_str ~= "<SHELL>" then
          t_vst[#t_vst+1] = '"' .. vst_str .. '",' .. '\n'
        end
      end
      count_symb = 0
      count_save = 0
      count_q = 0
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
  
  local new_str = table.concat(t_vst) .. '\n\n' .. table.concat(t_vsti)
  
  reaper.CF_SetClipboard(new_str)
  
  if show_window == true then
    reaper.MB("Success! All plugins names have been copied to the clipboard!\n" .. 
    '\nPaste the text into a text editor to see the list of names ("Notepad++" for example)', "Warning", 0)
  end
  
  nothing()