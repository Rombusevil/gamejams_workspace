function lineobj(x0,y0)
    local l={}
    l.x0 = x0
    l.y0 = y0
    l.x1 = 0
    l.y1 = 0

    return l
end

function drawline(obj)
    local width = 3
    local c=7

    if abs(obj.x1 - obj.x0) > abs(obj.y0 - obj.y1) then
        -- horizontal
        for i=0, width do
            line(obj.x0,obj.y0+i, obj.x1,obj.y1+i, c)
        end
    else
        -- vertical
        for i=0, width do
            line(obj.x0+i,obj.y0, obj.x1+i,obj.y1, c)
        end
    end
end


function game_state()
    local s={}
    local debounce=true
    local i1 = tutils({text="❎ continue line", x=1, y=2, fg=6})
    local i2 = tutils({text="right click clears line", x=1, y=8, fg=6})

    local states={}
    states.idle=0  -- waiting for click
    states.init=1  -- already have x0,y0 waiting for click

    s.curlinestate=states.idle
    s.lines={}
    s.curline={}


    local undo = text_btn(tutils({text="undo"}), 100, 2, 9, 8, 
        function() 
            s.curlinestate = states.idle -- avoid starting a line
            del(s.lines, s.lines[#s.lines]) -- removes last line added
        end
    )

    local export = text_btn(tutils({text="export"}), 100, 15, 9, 8, 
        function() 
            s.curlinestate = states.idle -- avoid starting a line
            
            local toppadding="\n\n\n"
            local output ="local c=7\n"
            for l in all(s.lines) do
                output=output.."line("..l.x0..","..l.y0..",  "..l.x1..","..l.y1..", c)\n"
            end
            printh(toppadding..output)
            printh(output, '@clip')
        end
    )

    s.update=function()
        if lclick  then
            if debounce then
                if s.curlinestate == states.idle then
                    s.curline = lineobj(mousex,mousey)
                    s.curlinestate = states.init
                elseif s.curlinestate == states.init then
                    s.curline.x1 = mousex
                    s.curline.y1 = mousey
                    s.curlinestate = states.idle

                    add(s.lines, s.curline)
                end
            end
            debounce = false
        else
            debounce = true
        end

        if s.curlinestate == states.idle and btnp(5) and #s.lines > 0 then -- x button
            s.curlinestate = states.init
            local prevl = s.lines[#s.lines]
            s.curline = lineobj(prevl.x1, prevl.y1)
        elseif s.curlinestate == states.init and rclick then
            s.curlinestate = states.idle
        end
    end

    
    s.draw=function()
        cls()
        print(mousex, 72, 2, 8)
        print(mousey, 88, 2, 8)
        i1:draw()
        i2:draw()
        undo:draw()
        export:draw()

        -- draw helper line
        if s.curlinestate == states.init then
            line(s.curline.x0, s.curline.y0, mousex, mousey, 6)
        end
        
        -- draw all finished lines
        for l in all(s.lines) do
            drawline(l)
        end

    end

    return s
end