-- @description Yannick_Transport - Off or On toolbar button - Stop or Pause (save state after REAPER reboot)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  local sla = package.config:sub(1,1)
  local res_path = reaper.GetResourcePath()
  local path_for_script = res_path .. sla .. 'Scripts'
  local _,filename,_,_,_,_,_ = reaper.get_action_context()
  if filename ~= path_for_script .. sla .. 'Yannick-ReaScripts' .. sla .. 'Scripts with config files' .. sla ..
  'Transport' .. sla .. 'Yannick_Transport - Off or On toolbar button - Stop or Pause (save state after REAPER reboot).lua'
  then
    reaper.MB('Please install this script in the same directory as from my repository. ' ..
    'To do this, use the ReaPack script manager. Read more in the README.md file', 
    'Error', 0) 
    return
  end
  local f_str = '\nreaper.Main_OnCommand( reaper.NamedCommandLookup("_RSc14726b85f94706b39bf8c97429fd5d6ad8d410f"), 0) ' ..
  '-- Yannick_Transport\n'
  
  if reaper.file_exists( path_for_script .. sla .. '__startup.lua' ) == false then
    local f = io.open(path_for_script .. sla .. '__startup.lua', "w")
    f:write(f_str)
    f:close()
  else 
    local f = io.open(path_for_script .. sla .. '__startup.lua', "r") 
    local find_str = false
    local t_str = {}
    for l in f:lines() do
      if l == 'reaper.Main_OnCommand( reaper.NamedCommandLookup("_RSc14726b85f94706b39bf8c97429fd5d6ad8d410f"), 0) ' ..
      '-- Yannick_Transport'
      then
        find_str = true
      end
      t_str[#t_str+1] = l
    end
    if find_str == false then
      f:close()
      f = io.open(path_for_script .. sla .. '__startup.lua', "w")
      f:write( table.concat(t_str, '\n') .. f_str)
    end
    f:close()
  end
  
  local _,_,sectionID,cmdID,_,_,_ = reaper.get_action_context()
  local state = reaper.GetExtState("YannickReaScr_Transp_button_play_pause_state_SECTION", "YannickReaScr_Transp_button_play_pause_state_KEY")
  
  local state_is_not_startup = reaper.GetExtState("YannickReaScr_Transp_button_play_pause_state_SECTION_is_not_startup", 
  "YannickReaScr_Transp_button_play_pause_state_KEY_is_not_startup")
  
  if state_is_not_startup == "" and state ~= "" then
    reaper.SetToggleCommandState(sectionID,cmdID, tonumber(state) )
  else
    if state == "" or state == "0" then
      reaper.SetToggleCommandState(sectionID,cmdID,1)
      reaper.SetExtState("YannickReaScr_Transp_button_play_pause_state_SECTION", "YannickReaScr_Transp_button_play_pause_state_KEY", 1, true)
    else
      reaper.SetToggleCommandState(sectionID,cmdID,0)
      reaper.SetExtState("YannickReaScr_Transp_button_play_pause_state_SECTION", "YannickReaScr_Transp_button_play_pause_state_KEY", 0, true)
    end
  end
  reaper.SetExtState("YannickReaScr_Transp_button_play_pause_state_SECTION_is_not_startup", "YannickReaScr_Transp_button_play_pause_state_KEY_is_not_startup", 1, false)
  reaper.RefreshToolbar2(sectionID, cmdID)
