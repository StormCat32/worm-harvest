function love.load()
	player = Worm:new()
	player:load(100,100)
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
end

--[[
	worm game
	
	2 scenes
	-Eating/Attacking Scene
	-Building Scene

	In attacking, you go around controlling a worm creature (flash game style) attempting to eat buildings and maybe kill some people
	Small enemies try and shoot you, either walking around on the ground or standing on buildings
	They should be pretty easy to kill
	Perhaps have versions that do not attack and instead run away
	
	Once you are done (dead? time ran out?) a small cutscene plays where you spit out the buildings you ate and it transitions
	
	To building scene
	Where you have your own little people and you place the buildings you ate for them
	once your town is complete you finish the game?
	perhaps buildings can give you some form of upgrades as well

]]--

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
	w = 120,
	h = 400,
	
	segCount = 20,
	
	dirx = 0,
	diry = 0,
	
	--ground stuff
	speed = 720,
	accel = 0.6,
	decel = 0.8,
	
	points = {},
	sticks = {},
	
	damping = 0.92,
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
		table.insert(self.points,Points:new(x,y+z*self.h/self.segCount,false,self.w/2*(self.segCount-z)/(self.segCount)))
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
	
	self.x = self.x + self.dirx*dt
	self.y = self.y + self.diry*dt
end

function Worm:bodyUpdate(dt)
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
	love.graphics.setColor(1,1,1)
	for z = 2,#self.sticks-2 do
		local o = self.sticks[z]
		local p = self.sticks[z+1]
		local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
		local ang2 = -math.atan2(p.pB.pos.y-p.pA.pos.y,p.pB.pos.x-p.pA.pos.x)
		love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w,o.pA.pos.y-math.cos(ang)*o.pA.w,
									 o.pA.pos.x+math.sin(ang)*o.pA.w,o.pA.pos.y+math.cos(ang)*o.pA.w,
									 o.pB.pos.x+math.sin(ang2)*o.pB.w,o.pB.pos.y+math.cos(ang2)*o.pB.w,
									 o.pB.pos.x-math.sin(ang2)*o.pB.w,o.pB.pos.y-math.cos(ang2)*o.pB.w)
	end
	local o = self.sticks[#self.sticks-1]
	local p = self.sticks[#self.sticks]
	local ang = -math.atan2(o.pB.pos.y-o.pA.pos.y,o.pB.pos.x-o.pA.pos.x)
	local ang2 = -math.atan2(p.pB.pos.y-p.pA.pos.y,p.pB.pos.x-p.pA.pos.x)
	love.graphics.polygon("fill",o.pA.pos.x-math.sin(ang)*o.pA.w,o.pA.pos.y-math.cos(ang)*o.pA.w,
									 o.pA.pos.x+math.sin(ang)*o.pA.w,o.pA.pos.y+math.cos(ang)*o.pA.w,
									 o.pB.pos.x,o.pB.pos.y)
end