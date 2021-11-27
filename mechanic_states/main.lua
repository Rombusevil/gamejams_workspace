pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- made with super-fast-framework

------------------------- start imports
--<*sff/entity.lua
--<*sff/tutils.lua
--<*sff/collision.lua
-- --<*sff/timer.lua
--  --<*sff/explosions.lua
--  --<*sff/buttons.lua

--<*cabin_state.lua
--<*vertigo_state.lua
--<*rhythm_state.lua
--<*sidescroller_state.lua
--------------------------- end imports

-- to enable mouse support uncomment all of the following commented lines:
-- poke(0x5f2d, 1) -- enables mouse support
function _init()
    --curstate=haunted_state()
    --curstate=cabin_state()
    
    --local musheet={} -- music sheet
    --musheet.notes={0,3,0,0,1,2} -- 0 left, 1 right, 2 up, 3 down
    --musheet.speed=1.5
    --curstate=rhythm_state(musheet, cabin_state())

    curstate=sidescroller_state()
end

function _update()
    -- mouse utility global variables
    -- mousex=stat(32)
    -- mousey=stat(33)
    -- lclick=stat(34)==1
    -- rclick=stat(34)==2
    -- mclick=stat(34)==4
	curstate.update()
end

function _draw()
    curstate.draw()
    -- pset(mousex,mousey, 12) -- draw your pointer here
end

