-- @description Yannick_Switch previous grid (alternation of straight and triplet)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function main()
  
    function number(nmbr)
      local t = 
      {
      4,
      8/3,
      2,
      4/3,
      1,
      2/3,
      1/2,
      1/3,
      1/4,
      1/6,
      1/8,
      1/12,
      1/16,
      1/24,
      1/32,
      1/48,
      1/64,
      1/96,
      1/128,
      1/192,
      1/256
      }
      
      function nu(n)
        if n < 0 then
          n = n * (-1)
        end
        return n
      end
      
      local cnt = nil
      local save_table = nil
      
      for i=#t, 1,-1 do
        if cnt == nil or nu(t[i]-nmbr) < cnt then
          cnt = nu(t[i]-nmbr)
        else
          save_table = t[i]
          break
        end
      end
        
      return save_table
    end
  
    local retval, div, _ , _ = reaper.GetSetProjectGrid(0, false, 0,0,0)
    local grid = number(div, val)
    if grid ~= nil then
      reaper.SetProjectGrid(0, grid)
    end
    
  end  
  
  reaper.defer(main)