pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- made with super-fast-framework

------------------------- start imports
function bbox(w,h,xoff1,yoff1,xoff2,yoff2)
    local bbox={}
    bbox.offsets={xoff1 or 0,yoff1 or 0,xoff2 or 0,yoff2 or 0}
    bbox.w=w
    bbox.h=h
    bbox.xoff1=bbox.offsets[1]
    bbox.yoff1=bbox.offsets[2]
    bbox.xoff2=bbox.offsets[3]
    bbox.yoff2=bbox.offsets[4]
    function bbox:setx(x)
        self.xoff1=x+self.offsets[1]
        self.xoff2=x+self.w-self.offsets[3]
    end
    function bbox:sety(y)
        self.yoff1=y+self.offsets[2]
        self.yoff2=y+self.h-self.offsets[4]
    end
    function bbox:printbounds()
        rect(self.xoff1, self.yoff1, self.xoff2, self.yoff2, 8)
    end
    return bbox
end
function anim()
    local a={}
	a.list={}
	a.current=false
	a.tick=0
    function a:_get_fr(one_shot, callback)
		local anim=self.current
		local aspeed=anim.speed
		local fq=anim.fr_cant		
		local st=anim.first_fr
		local step=flr(self.tick)*anim.w
		local sp=st+step
		self.tick+=aspeed
		local new_step=flr(flr(self.tick)*anim.w)		
		if st+new_step >= st+(fq*anim.w) then 
		    if one_shot then
		        self.tick-=aspeed  
		        callback()
		    else
		        self.tick=0
		    end
		end
		return sp
    end
    function a:set_anim(idx)
        if (self.currentidx == nil or idx != self.currentidx) self.tick=0 
        self.current=self.list[idx]
        self.currentidx=idx
    end
	function a:add(first_fr, fr_cant, speed, zoomw, zoomh, one_shot, callback)
		local a={}
		a.first_fr=first_fr
		a.fr_cant=fr_cant
		a.speed=speed
		a.w=zoomw
        a.h=zoomh
        a.callback=callback or function()end
        a.one_shot=one_shot or false
		add(self.list, a)
	end
	function a:draw(x,y,flipx,flipy)
		local anim=self.current
		if( not anim )then
			rectfill(0,117, 128,128, 8)
			print("err: obj without animation!!!", 2, 119, 10)
			return
		end
		spr(self:_get_fr(self.current.one_shot, self.current.callback),x,y,anim.w,anim.h,flipx,flipy)
    end
	return a
end
function entity(anim_obj)
    local e={}
    e.x=0
    e.y=0
    e.anim_obj=anim_obj
    e.debugbounds, e.flipx, e.flipy = false
    e.bounds=nil
    e.flickerer={}
    e.flickerer.timer=0
    e.flickerer.duration=0          
    e.flickerer.slowness=3
    e.flickerer.is_flickering=false 
    function e.flickerer:flicker()
        if(self.timer > self.duration) then
            self.timer=0 
            self.is_flickering=false
        else
            self.timer+=1
        end
    end
    function e:setx(x)
        self.x=x
        if(self.bounds != nil) self.bounds:setx(x)
    end
    function e:sety(y)
        self.y=y
        if(self.bounds != nil) self.bounds:sety(y)
    end
    function e:setpos(x,y)
        self:setx(x)
        self:sety(y)
    end
    function e:set_anim(idx)
		self.anim_obj:set_anim(idx)
    end
    function e:set_bounds(bounds)
        self.bounds = bounds
        self:setpos(self.x, self.y)
    end
    function e:flicker(duration)
        if(not self.flickerer.is_flickering)then
            self.flickerer.duration=duration
            self.flickerer.is_flickering=true
            self.flickerer:flicker()
        end
        return self.flickerer.is_flickering
    end
    function e:draw()
        if(self.flickerer.timer % self.flickerer.slowness == 0)then
            self.anim_obj:draw(self.x,self.y,self.flipx,self.flipy)
        end
        if(self.flickerer.is_flickering) self.flickerer:flicker()        
		if(self.debugbounds) self.bounds:printbounds()
    end
    return e
end

function tutils(args)
	local s={}
	s.private={}
	s.private.tick=0
	s.private.blink_speed=1
	s.height=10 
	s.text=args.text or ""
	s._x=args.x or 2
	s._y=args.y or 2
	s._fg=args.fg or 7
	s._bg=args.bg or 2
	s._sh=args.sh or 3 	
	s._bordered=args.bordered or false
	s._shadowed=args.shadowed or false
	s._centerx=args.centerx or false
	s._centery=args.centery or false
	s._blink=args.blink or false
	s._blink_on=args.on_time or 5
	s._blink_off=args.off_time or 5
	function s:draw()
		if self._centerx then self._x =  64-flr((#self.text*4)/2) end
		if self._centery then self._y = 64-(4/2) end
		if self._blink then 
			self.private.tick+=1
			local offtime=self._blink_on+self._blink_off 
			if(self.private.tick>offtime) then self.private.tick=0 end
			local blink_enabled_on = false
			if(self.private.tick<self._blink_on)then
				blink_enabled_on = true
			end
			if(not blink_enabled_on) then
				return
			end
		end
		local yoffset=1
		if self._bordered then 
			yoffset=2
		end
		if self._bordered then
			local x=max(self._x,1)
			local y=max(self._y,1)
			if(self._shadowed)then
				for i=-1, 1 do	
					print(self.text, x+i, self._y+2, self._sh)
				end
			end
			for i=-1, 1 do
				for j=-1, 1 do
					print(self.text, x+i, y+j, self._bg)
				end
			end
		elseif self._shadowed then
			print(self.text, self._x, self._y+1, self._sh)
		end
		print(self.text, self._x, self._y, self._fg)
    end
	return s
end

function raw_btn(x,y, w,h, fg,bg, callback)
    local b={}
    b.bounds=bbox(w,h)
    b.bounds:setx(x)
    b.bounds:sety(y)
    b.debounce = true
    function b:draw()
        local colfg=fg
        if point_collides(mousex, mousey, self) then
            if(lclick)then
                if(self.debounce)then
                    self.debounce = false
                    callback()
                end
            else
                self.debounce = true
            end
            colfg=bg
        end
        rectfill(x,y, x+w,y+h+2, bg)
        rectfill(x,y, x+w,y+h, colfg)
    end
    return b
end
function text_btn(tutils, x,y, fg, bg, callback)
    local w= (#tutils.text * 4)+2 
    local h= 8
    tutils._x=x+2
    tutils._y=y+2
    local rbtn=raw_btn(x,y,w,h,fg,bg,callback)
    rbtn._draw=rbtn.draw
    function rbtn:draw()
        self:_draw()
        tutils:draw()
    end
    return rbtn
end

function collides(ent1, ent2)
    local e1b=ent1.bounds
    local e2b=ent2.bounds
    if  ((e1b.xoff1 <= e2b.xoff2 and e1b.xoff2 >= e2b.xoff1)
    and (e1b.yoff1 <= e2b.yoff2 and e1b.yoff2 >= e2b.yoff1)) then 
        return true
    end
    return false
end
function point_collides(x,y, ent)
    local eb=ent.bounds
    if  ((eb.xoff1 <= x and eb.xoff2 >= x)
    and (eb.yoff1 <= y and eb.yoff2 >= y)) then 
        return true
    end
    return false
end

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
        for i=0, width do
            line(obj.x0,obj.y0+i, obj.x1,obj.y1+i, c)
        end
    else
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
    states.idle=0  
    states.init=1  
    s.curlinestate=states.idle
    s.lines={}
    s.curline={}
    local undo = text_btn(tutils({text="undo"}), 100, 2, 9, 8, 
        function() 
            s.curlinestate = states.idle 
            del(s.lines, s.lines[#s.lines]) 
        end
    )
    local export = text_btn(tutils({text="export"}), 100, 15, 9, 8, 
        function() 
            s.curlinestate = states.idle 
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
        if s.curlinestate == states.idle and btnp(5) and #s.lines > 0 then 
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
        if s.curlinestate == states.init then
            line(s.curline.x0, s.curline.y0, mousex, mousey, 6)
        end
        for l in all(s.lines) do
            drawline(l)
        end
    end
    return s
end
--------------------------- end imports

-- to enable mouse support uncomment all of the following commented lines:
poke(0x5f2d, 1) -- enables mouse support
function _init()
    curstate=game_state()
end

function _update()
    -- mouse utility global variables
    mousex=stat(32)
    mousey=stat(33)
    lclick=stat(34)==1
    rclick=stat(34)==2
    mclick=stat(34)==4
	curstate.update()
end

function _draw()
    curstate.draw()
    pset(mousex,mousey, 12) -- draw your pointer here
end
