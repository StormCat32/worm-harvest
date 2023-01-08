Points = {
	pos = {
		x = 0,
		y = 0,
		dirx = 0,
		diry = 0,
	},
	posB = {
		x = 0,
		y = 0,
	},
	locked = false,
	w = 20,
}

Sticks = {
	pA = {},
	pB = {},
	h = 4,
}

function Points:new(x,y,locked,w)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.pos = {}
	o.posB = {}
	o.pos.x = x
	o.posB.x = x
	o.pos.y = y
	o.posB.y = y
	o.locked = locked
	o.pos.dirx = 0
	o.pos.diry = 0
	
	if w then
		o.w = w
	end
	
	return o
end

function Sticks:new(pA,pB,h)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.pA = pA
	o.pB = pB
	if h then
		o.h = h
	end
	
	return o
end

Worm = {
	x = 0,
	y = 0,
	w = 160,
	h = 480,
	
	segCount = 24,
	
	dirx = 0,
	diry = 0,
	
	--ground stuff
	speed = 960,
	accel = 0.6,
	decel = 0.8,
	
	points = {},
	sticks = {},
	
	damping = 0.75,
	numIter = 100,
}

function Worm:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	return o
end

function Worm:load(x,y)
	self.points = {}
	self.sticks = {}
	table.insert(self.points,Points:new(x,y,true,self.w/2))
	self.x = x
	self.y = y
	for z = 1,self.segCount-1 do
		table.insert(self.points,Points:new(x,y+z*self.h/self.segCount,false,self.w/2*((self.segCount-z)/(self.segCount))^0.8))
	end
	for z = 2,#self.points do
		table.insert(self.sticks,Sticks:new(self.points[z-1],self.points[z],self.h/self.segCount))
	end
end

function Worm:update(dt)
	self:move(dt)
	self:bodyUpdate(dt)
end

function Worm:move(dt)
	if self.y > scene.h then
		if scene.endTimer > 0 then
			self.diry = self.diry - scene.grav*dt*4
		else
			self.diry = self.diry + scene.grav*dt*4
		end
	elseif self.y < scene.y then
		self.diry = self.diry + scene.grav*dt
	else
		local dirx = 0
		local diry = 0
		if love.keyboard.isDown("right","d") then
			dirx = dirx + 1
		end
		if love.keyboard.isDown("left","a") then
			dirx = dirx - 1
		end
		if love.keyboard.isDown("down","s") then
			diry = diry + 1
		end
		if love.keyboard.isDown("up","w") then
			diry = diry - 1
		end
		local movex = false
		local movey = false
		if dirx > 0 then
			if self.dirx + dt / self.accel * self.speed < self.speed * dirx then
				self.dirx = self.dirx + dt / self.accel * self.speed
				movex = true
				if self.dirx > self.speed * dirx then
					self.dirx = self.speed * dirx
				end
			end
		elseif dirx < 0 then
			if self.dirx - dt / self.accel * self.speed > dirx * self.speed then
				self.dirx = self.dirx - dt / self.accel * self.speed
				movex = true
				if self.dirx < dirx * self.speed then
					self.dirx = dirx * self.speed
				end
			end
		end
		if diry > 0 then
			if self.diry + dt / self.accel * self.speed < self.speed * diry then
				self.diry = self.diry + dt / self.accel * self.speed
				movey = true
				if self.diry > self.speed * diry then
					self.diry = self.speed * diry
				end
			end
		elseif diry < 0 then
			if self.diry - dt / self.accel * self.speed > diry * self.speed then
				self.diry = self.diry - dt / self.accel * self.speed
				movey = true
				if self.diry < diry * self.speed then
					self.diry = diry * self.speed
				end
			end
		end
		if not movex then
			if self.dirx > 0 then
				self.dirx = self.dirx - dt / self.decel * self.speed
				if self.dirx < 0 then
					self.dirx = 0
				end
			elseif self.dirx < 0 then
				self.dirx = self.dirx + dt / self.decel * self.speed
				if self.dirx > 0 then
					self.dirx = 0
				end
			end
		end
		if not movey then
			if self.diry > 0 then
				self.diry = self.diry - dt / self.decel * self.speed
				if self.diry < 0 then
					self.diry = 0
				end
			elseif self.diry < 0 then
				self.diry = self.diry + dt / self.decel * self.speed
				if self.diry > 0 then
					self.diry = 0
				end
			end
		end
	end
	
	self.x = self.x + self.dirx*dt
	self.y = self.y + self.diry*dt
end

function Worm:bodyUpdate(dt)
	if self.x < 0 then
		self.x = self.x+scene.w
		for z = 1,#self.points do
			self.points[z].pos.x = self.points[z].pos.x+scene.w
			self.points[z].posB.x = self.points[z].posB.x+scene.w
		end
	elseif self.x > scene.w then
		self.x = self.x-scene.w
		for z = 1,#self.points do
			self.points[z].pos.x = self.points[z].pos.x-scene.w
			self.points[z].posB.x = self.points[z].posB.x-scene.w
		end
	end
	self.points[1].pos.x = self.x
	self.points[1].pos.y = self.y
	self:simulate(dt)
end

function Worm:simulate(dt)
	for i,o in pairs(self.points) do
		if not o.locked then
			local posBefore = {}
			posBefore.x = o.pos.x
			posBefore.y = o.pos.y
			o.pos.x = o.pos.x + (o.pos.x - o.posB.x)*self.damping
			o.pos.y = o.pos.y + (o.pos.y - o.posB.y)*self.damping
			o.posB.x = posBefore.x
			o.posB.y = posBefore.y
		end
	end
	for z = 1,self.numIter do
		for i,o in pairs(self.sticks) do
			local centre = {}
			centre.x = (o.pA.pos.x + o.pB.pos.x)/2
			centre.y = (o.pA.pos.y + o.pB.pos.y)/2
			local dir = {}
			dir.x = (o.pA.pos.x - o.pB.pos.x)/((o.pA.pos.x-o.pB.pos.x)^2+(o.pA.pos.y-o.pB.pos.y)^2)^0.5
			dir.y = (o.pA.pos.y - o.pB.pos.y)/((o.pA.pos.x-o.pB.pos.x)^2+(o.pA.pos.y-o.pB.pos.y)^2)^0.5
			if not o.pA.locked then
				o.pA.pos.x = centre.x + dir.x * o.h /2
				o.pA.pos.y = centre.y + dir.y * o.h /2
			end
			if not o.pB.locked then
				o.pB.pos.x = centre.x - dir.x * o.h /2
				o.pB.pos.y = centre.y - dir.y * o.h /2
			end
		end
	end
end

function Worm:draw()
	love.graphics.setColor(39/255,6/255,0/255)
	for z = 1,#self.sticks-1 do
		local o = self.sticks[z]
		local p = self.sticks[z+1]
		local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
		local ang2 = -math.atan2(p.pB.pos.y-p.pA.pos.y,p.pB.pos.x-p.pA.pos.x)
		love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w,o.pA.pos.y-math.cos(ang)*o.pA.w,
									 o.pA.pos.x+math.sin(ang)*o.pA.w,o.pA.pos.y+math.cos(ang)*o.pA.w,
									 o.pB.pos.x+math.sin(ang2)*o.pB.w,o.pB.pos.y+math.cos(ang2)*o.pB.w,
									 o.pB.pos.x-math.sin(ang2)*o.pB.w,o.pB.pos.y-math.cos(ang2)*o.pB.w)
	end
	local o = self.sticks[#self.sticks]
	local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
	love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w,o.pA.pos.y-math.cos(ang)*o.pA.w,
								 o.pA.pos.x+math.sin(ang)*o.pA.w,o.pA.pos.y+math.cos(ang)*o.pA.w,
								 o.pB.pos.x,o.pB.pos.y)
	local o = self.sticks[1]
	local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
	for z = 1,8 do
		love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w+math.sin(ang)*o.pA.w*2*((z-1)/8),o.pA.pos.y-math.cos(ang)*o.pA.w+math.cos(ang)*o.pA.w*2*((z-1)/8),
									 o.pA.pos.x-math.sin(ang)*o.pA.w+math.sin(ang)*o.pA.w*2*((z)/8),o.pA.pos.y-math.cos(ang)*o.pA.w+math.cos(ang)*o.pA.w*2*((z)/8),
									 o.pA.pos.x-math.sin(ang)*o.pA.w+math.sin(ang)*o.pA.w*2*((z-0.5)/8)-12*math.cos(-ang),o.pA.pos.y-math.cos(ang)*o.pA.w+math.cos(ang)*o.pA.w*2*((z-0.5)/8)-12*math.sin(-ang))
	end
end

function Worm:eatDraw()
	love.graphics.setColor(39/255,6/255,0/255)
	for z = 1,3 do
		local o = self.sticks[z]
		local p = self.sticks[z+1]
		local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
		local ang2 = -math.atan2(p.pB.pos.y-p.pA.pos.y,p.pB.pos.x-p.pA.pos.x)
		love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w,o.pA.pos.y-math.cos(ang)*o.pA.w,
									 o.pA.pos.x+math.sin(ang)*o.pA.w,o.pA.pos.y+math.cos(ang)*o.pA.w,
									 o.pB.pos.x+math.sin(ang2)*o.pB.w,o.pB.pos.y+math.cos(ang2)*o.pB.w,
									 o.pB.pos.x-math.sin(ang2)*o.pB.w,o.pB.pos.y-math.cos(ang2)*o.pB.w)
	end
	local o = self.sticks[1]
	local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
	for z = 1,8 do
		love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w+math.sin(ang)*o.pA.w*2*((z-1)/8),o.pA.pos.y-math.cos(ang)*o.pA.w+math.cos(ang)*o.pA.w*2*((z-1)/8),
									 o.pA.pos.x-math.sin(ang)*o.pA.w+math.sin(ang)*o.pA.w*2*((z)/8),o.pA.pos.y-math.cos(ang)*o.pA.w+math.cos(ang)*o.pA.w*2*((z)/8),
									 o.pA.pos.x-math.sin(ang)*o.pA.w+math.sin(ang)*o.pA.w*2*((z-0.5)/8)-12*math.cos(-ang),o.pA.pos.y-math.cos(ang)*o.pA.w+math.cos(ang)*o.pA.w*2*((z-0.5)/8)-12*math.sin(-ang))
	end
end

Camera = {
	x = 0,
	y = 0,
}

function Camera:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = 0
	o.y = 0
	
	o.w = love.graphics.getWidth()
	o.h = love.graphics.getHeight()
	
	return o
end

function Camera:update(dt)
	self.x = scene.player.x-self.w/2
	self.y = scene.player.y-self.h/2
	if self.y < 0 then
		self.y = 0
		self.y = self.y + scene.player.y%1
	end
	if self.y + self.h > scene.h then
		self.y = scene.h-self.h
		self.y = self.y + scene.player.y%1 -1
	end
end