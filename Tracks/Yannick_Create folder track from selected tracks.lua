-- @description Yannick_Create folder track from selected tracks
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   added new settings
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ----------------------------------------------------------------------------------------------------------------------------------
  
    number_of_custom_layouts = 0          ---- enter from 0 to 20 number of layouts for new folder track, 0 = disable layout
    icon_name = ""                        ---- enter the track icon name in REAPER conf folder, "" or '' = disable track icon
    name_for_folder_track = ''            ---- '' or "" is no name for new folder track, 'Bass' or "Bass" as example for new name  
    
    user_input = 0                        ---- 0 = no input
                                          ---- 1 = show user input to entering new folder name
                                          ---- 2 = highlight the folder name in TCP
                                          
    defaults_for_folder_track = false     ---- set default parameters for new folder track from global prefs
    rec_input_none = false                ---- set the record input to "none" (regardless of default settings)
    
  ----------------------------------------------------------------------------------------------------------------------------------  
  
  ------------------------Set the color for new folder track---------------------------
      --------------enter 0 for R and G and B to disable coloring------------------  
    
    R = 0   ---- Red
    G = 0   ---- Green
    B = 0   ---- Blue
    
      -----------------------------------------------------------------------------  
  -------------------------------------------------------------------------------------  
  
  function bla() end function nothing() reaper.defer(bla) end
  
  function Find(n)
    local j = 0
    local bool = false
    while j <= 20 do
      if j == n then
        bool = true
        break
      end
      j = j + 1
    end
    return bool
  end
  
  if Find(number_of_custom_layouts) == false
  or name_for_folder_track ~= tostring(name_for_folder_track)
  or (user_input ~= 0 and user_input ~= 1 and user_input ~= 2)
  or (defaults_for_folder_track ~= true and defaults_for_folder_track ~= false)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  or (rec_input_none ~= true and rec_input_none ~= false)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  if reaper.CountSelectedTracks(0) == 0 then 
    reaper.MB('No tracks. Please select tracks', 'Error', 0)
    nothing()return 
  end
  
  if user_input == 1 then
    retval, name = 
    reaper.GetUserInputs
    (
    'Create new folder track from selected tracks', 1, 
    'Set the folder track name:,extrawidth=120', name_for_folder_track
    )
    if not retval then 
      nothing() return
    end
  else
    name = name_for_folder_track
  end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local folder_mcp = 0
  local folder_tcp = 0
  for i=1, reaper.CountSelectedTracks(0) do
    local track = reaper.GetSelectedTrack(0,i-1)
    if reaper.GetMediaTrackInfo_Value( track, 'B_SHOWINTCP') == 0 then
      folder_mcp = folder_mcp + 1
    end
    if reaper.GetMediaTrackInfo_Value( track, 'B_SHOWINMIXER') == 0 then
      folder_tcp = folder_tcp + 1
    end
  end

  local g_track = reaper.GetSelectedTrack(0,0)
  local cnt_tracks = reaper.CountSelectedTracks(0)
  local numb = reaper.GetMediaTrackInfo_Value(g_track,"IP_TRACKNUMBER")
  reaper.InsertTrackAtIndex(numb-1, defaults_for_folder_track)
  reaper.ReorderSelectedTracks(numb,1)
  
  local tr = reaper.GetTrack(0,numb-1)
  
  if folder_mcp == cnt_tracks then
    reaper.SetMediaTrackInfo_Value(tr,'B_SHOWINTCP',0)
  end
  if folder_tcp == cnt_tracks then
    reaper.SetMediaTrackInfo_Value(tr,'B_SHOWINMIXER',0)
  end
  
  reaper.SetOnlyTrackSelected(tr, true)
  
  if R == 0 and G == 0 and B == 0 then
    nothing()
  else
    reaper.SetTrackColor(tr, reaper.ColorToNative(R,G,B)|0x1000000)
  end
  
  if number_of_custom_layouts > 0 then
    reaper.Main_OnCommand(number_of_custom_layouts+41695,0)
  end
  
  if icon_name ~= "" then
    reaper.GetSetMediaTrackInfo_String( tr, "P_ICON", icon_name .. ".png", true)
  end
  
  reaper.GetSetMediaTrackInfo_String(tr, 'P_NAME', name, true)
  
  if rec_input_none == true then
    reaper.SetMediaTrackInfo_Value( tr, 'I_RECINPUT', -1 )
  end
  
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Create folder track from selected tracks", -1)
  
  if user_input == 2 then
    reaper.Main_OnCommand(40914,0)
    reaper.Main_OnCommand(40696,0)
  end
  