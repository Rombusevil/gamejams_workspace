-- state
function vertigo_state(prev_state)
    local s={}
    local ctr=0
    local prevCtr=0

    local pat1=0b0001000000000000
    local pat2=0b1111110111111111
    local pat=pat1

    local text=tutils({text="press ❎ to go back", centerx=true, y=110, fg=7, bg=2, sh=3, shadowed=true})
    
    s.update=function()
        ctr+=0.1
        if( (flr(ctr)%3)==0 )then
            -- prevent insane flashing
            if ctr-prevCtr > 1 then
                if pat==pat1 then
                    pat=pat2
                else
                    pat=pat1
                end
            end

            prevCtr=ctr
        end

        if ctr > 2 then
            if(btn(5)) curstate=prev_state
        end
    end

    s.draw=function()
        cls()
        local width = sin(ctr)*20+50
        local height= sin(ctr)*20+50

        fillp(pat)
        rectfill(0,0,127,127,2)
        fillp()

        -- paints an 8x8 sprite on position 1
        sspr(8,0, 8,8, 64-(width/2),64-(height/2), width, height)

        if(ctr > 2) text:draw()
    end

    return s
end