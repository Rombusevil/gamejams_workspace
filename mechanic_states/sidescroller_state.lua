
function init_globals()
    camx=0
    camy=0
end

-- direction: 1 right, -1 left
function bullet(x,y, type, dir)
    local anim_obj=anim()
    
    -- configure bullet according to type
    local tspr=1
    local speed=2
    local dmg=1
    if type == 0 then
        tspr=2
        speed=3
        dmg=2
    elseif type == 1 then
        tspr=3
        speed=1
        dmg=3
    end
    anim_obj:add(tspr,1,0.1,1,1)

    local e=entity(anim_obj)
    e:setpos(x,y)
    e:set_anim(1)
    e:alive=true
    e:dir=dir 
    e:speed=speed
    e:dmg=dmg

    local bounds_obj=bbox(8,8)
    e:set_bounds(bounds_obj)
    -- e.debugbounds=true

    function e:update()
        if self.alive then
            self.setx(self.getx()+(self.dir * self.speed))
            local xx = self.getx()
            if(xx > camx+127 or xx < camx) self.alive=false
        end
    end

    function e:hit(entity)
        self.alive=false
        entity:hurt(self.dmg)
    end

    -- overwrite entity's draw() function
    -- e._draw=e.draw
    -- function e:draw()
    --     self:_draw()
    --     ** your code here **
    -- end

    return e
end

function hero(x,y, bullets)
    local anim_obj=anim()
    anim_obj:add(1,1,0.1,1,1)

    local e=entity(anim_obj)
    e:setpos(x,y)
    e:set_anim(1)
    e:bullets=bullets
    e:health=100
    e:alive=true
    e:lives=3

    local bounds_obj=bbox(8,8)
    e:set_bounds(bounds_obj)
    -- e.debugbounds=true

    function e:update()
        if(self.health<0) self.alive=false
        if self.alive then
            if(btn(0))then     --left

            elseif(btn(1))then --right
            
            end
            
            if(btn(2))then          --up
            
            elseif(btn(3))then  --down
            
            end
            
            if(btnp(4))then -- "O"
            
            end
            
            if(btnp(5))then -- "X"
                
            end
        else
            self.lives-=1
            if self.lives<0 then
                -- gameover
            end
        end
    end

    function e:hurt(dmg)
        self.health-=dmg
    end

    -- comment this override and use sprites
    -- overwrite entity's draw() function
    e._draw=e.draw
    function e:draw()
        --self:_draw()
        rectfill(self.x, self.y, self.x+8, self.y-16, 8)
    end

    return e
end

-- state
function sidescroller_state()
    local s={}
    local updateables={}
    local drawables={}
    local bullets={}
    local enemies={}

    init_globals()

    local h=hero(58,62)
    add(updateables, h)
    add(drawables, h)

    s.update=function()
        -- bullets logic
        for b in all(bullets) do
            if not b.alive then
                -- remove dead bullets
                del(b, bullets)
            else
                -- check for enemy collision
                b:update()
                for e in all(enemies) do
                    if collides(b, e) then
                        b:hit(e)
                    end
                end
            end
        end

        for u in all(updateables) do
            u:update()
        end

        
    end

    s.draw=function()
        cls()
        for d in all(drawables) do
            d:draw()
        end

        for b in all(bullets) do
            b:draw()
        end
    end

    return s
end