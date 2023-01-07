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
	
	colours
	6 - (39/255,6/255,0/255)
	5 - (83/255,27/255,2/255)
	4 - (170/255,77/255,20/255)
	3 - (212/255,109/255,20/255)
	2 - (254/255,157/255,0/255)
	1 - (254/255,223/255,96/255)
	
]]--

local backGround = {}

function love.load()
	backGround = gradientMesh("vertical",{254/255,157/255,0/255},{254/255,223/255,96/255})
	scene = City:new()
	scene:load()
end

function love.update(dt)
	scene:update(dt)
end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(backGround,0,0,0,love.graphics.getWidth(),love.graphics.getHeight())
	scene:draw()
end

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
		self.diry = self.diry - scene.grav*dt*4
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

City = {
	player = {},
	buildings = {},
	backBuildings = {},
	backBackBuildings = {},
	allBack = {},
	y = 600,
	w = 8*love.graphics.getWidth(),
	h = 950,
	
	cBuildDif = 80,
	cBuildDifMin = 10,
	cBuildH = 550,
	cBuildHmin = 100,
	cBuildW = 80,
	cBuildWmax = 120,
	
	sBuildDif = 160,
	sBuildDifMin = 60,
	sBuildH = 180,
	sBuildHmin = 60,
	sBuildW = 60,
	sBuildWmax = 120,
	
	camera = {},
	
	grav = 800,
}

function City:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.player = {}
	o.buildings = {}
	o.backBuildings = {}
	o.backBackBuildings = {}
	o.allBack = {}
	o.camera = {}
	
	return o
end

function City:load()
	self.player = Worm:new()
	self.player:load(100,100)
	self.camera = Camera:new()
	local buildPos = math.random(0,self.sBuildDif)
	while buildPos < self.w - self.sBuildWmax do
		if buildPos < self.w/3 or buildPos > self.w*2/3 then
			local hh = math.random(self.sBuildHmin,self.sBuildH)
			local ww = math.random(self.sBuildW,math.min(hh,self.sBuildWmax))
			local isHouse = math.random(1,5)
			if isHouse >= 3 then
				isHouse = false
			else
				hh = math.ceil(hh*2/3)
				ww = math.random(hh,hh*3/2)
			end			
			table.insert(self.buildings,Building:new(buildPos,ww,hh,false,isHouse))
			buildPos = buildPos + ww + math.random(self.sBuildDifMin,self.sBuildDif)
		else
			local hh = math.random(self.cBuildHmin,self.cBuildH)
			local ww = math.random(self.cBuildW,math.min(hh,self.cBuildWmax))
			table.insert(self.buildings,Building:new(buildPos,ww,hh,true))
			buildPos = buildPos + ww + math.random(self.cBuildDifMin,self.cBuildDif)
		end
	end
	love.graphics.setColor(83/255,27/255,2/255)
	for i,o in pairs(self.buildings) do
		o:load()
	end
	
	local buildPos = math.random(0,self.sBuildDif)
	while buildPos < self.w - self.sBuildWmax do
		if buildPos < self.w/3 or buildPos > self.w*2/3 then
			local hh = math.random(self.sBuildHmin,self.sBuildH)
			local ww = math.random(self.sBuildW,math.min(hh,self.sBuildWmax))
			local isHouse = math.random(1,5)
			if isHouse >= 3 then
				isHouse = false
			else
				hh = math.ceil(hh*2/3)
				ww = math.random(hh,hh*3/2)
			end			
			table.insert(self.backBuildings,Building:new(buildPos,ww,hh,false,isHouse))
			buildPos = buildPos + ww + math.random(self.sBuildDifMin,self.sBuildDif)
		else
			local hh = math.random(self.cBuildHmin,self.cBuildH)
			local ww = math.random(self.cBuildW,math.min(hh,self.cBuildWmax))
			table.insert(self.backBuildings,Building:new(buildPos,ww,hh,true))
			buildPos = buildPos + ww + math.random(self.cBuildDifMin,self.cBuildDif)
		end
	end
	love.graphics.setColor(170/255,77/255,20/255)
	for i,o in pairs(self.backBuildings) do
		o:load()
	end
	
	local buildPos = math.random(0,self.sBuildDif)
	while buildPos < self.w - self.sBuildWmax do
		if buildPos < self.w/3 or buildPos > self.w*2/3 then
			local hh = math.random(self.sBuildHmin,self.sBuildH)
			local ww = math.random(self.sBuildW,math.min(hh,self.sBuildWmax))
			local isHouse = math.random(1,5)
			if isHouse >= 3 then
				isHouse = false
			else
				hh = math.ceil(hh*2/3)
				ww = math.random(hh,hh*3/2)
			end			
			table.insert(self.backBackBuildings,Building:new(buildPos,ww,hh,false,isHouse))
			buildPos = buildPos + ww + math.random(self.sBuildDifMin,self.sBuildDif)
		else
			local hh = math.random(self.cBuildHmin,self.cBuildH)
			local ww = math.random(self.cBuildW,math.min(hh,self.cBuildWmax))
			table.insert(self.backBackBuildings,Building:new(buildPos,ww,hh,true))
			buildPos = buildPos + ww + math.random(self.cBuildDifMin,self.cBuildDif)
		end
	end
	love.graphics.setColor(212/255,109/255,20/255)
	for i,o in pairs(self.backBackBuildings) do
		o:load()
	end
end

function City:update(dt)
	self.player:update(dt)
	self.camera:update(dt)
end

function City:draw()
	love.graphics.translate(0,-math.floor(self.camera.y*1/2))
	love.graphics.setColor(254/255,223/255,96/255)
	love.graphics.circle("fill",self.camera.w/2,self.camera.h*2/3,self.camera.w/4)
	
	self:drawBackgrounds()
	self:drawForegrounds()
end

function City:drawBackgrounds()
	love.graphics.origin()
	love.graphics.translate(-math.floor(self.camera.x*3/4),-math.floor(self.camera.y*3/4))
	love.graphics.scale(3/4,3/4)
	love.graphics.setColor(212/255,109/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.backBackBuildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor((self.camera.x-self.w)*3/4),-math.floor(self.camera.y*3/4))
	love.graphics.scale(3/4,3/4)
	love.graphics.setColor(212/255,109/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.backBackBuildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor((self.camera.x+self.w)*3/4),-math.floor(self.camera.y*3/4))
	love.graphics.scale(3/4,3/4)
	love.graphics.setColor(212/255,109/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.backBackBuildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor(self.camera.x*5/6),-math.floor(self.camera.y*5/6))
	love.graphics.scale(5/6,5/6)
	love.graphics.setColor(170/255,77/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.backBuildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor((self.camera.x-self.w)*5/6),-math.floor(self.camera.y*5/6))
	love.graphics.scale(5/6,5/6)
	love.graphics.setColor(170/255,77/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.backBuildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor((self.camera.x+self.w)*5/6),-math.floor(self.camera.y*5/6))
	love.graphics.scale(5/6,5/6)
	love.graphics.setColor(170/255,77/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.backBuildings) do
		o:draw()
	end
end

function City:drawForegrounds()
	love.graphics.origin()
	love.graphics.translate(-math.floor(self.camera.x),-math.floor(self.camera.y))
	love.graphics.setColor(83/255,27/255,2/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.buildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor(self.camera.x-self.w),-math.floor(self.camera.y))
	love.graphics.setColor(83/255,27/255,2/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.buildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-math.floor(self.camera.x+self.w),-math.floor(self.camera.y))
	love.graphics.setColor(83/255,27/255,2/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	for i,o in pairs(self.buildings) do
		o:draw()
	end
	
	love.graphics.origin()
	love.graphics.translate(-self.camera.x,-self.camera.y)
	self.player:draw()
end

Building = {
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	
	sky = false,
	
	features = {},
	canvas = {},
}

function Building:new(x,w,h,sky,house)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.features = {}
	o.canvas = {}
	
	o.w = w
	o.h = h
	o.x = x
	o.y = scene.y-h
	
	if sky then
		o.sky = true
	end
	
	if house then
		o.house = true
	end
	
	return o
end

function Building:load()
	self.canvas = love.graphics.newCanvas(self.w,self.h)
	if self.house then
		local inlay = math.random(self.w/8,self.w/4)
		local height = self.h*3/4
		table.insert(self.features,{poly={0,self.h,0,self.h-height,inlay,self.h-height,inlay,self.h}})
		table.insert(self.features,{poly={self.w,self.h,self.w,self.h-height,self.w-inlay,self.h-height,self.w-inlay,self.h}})
		table.insert(self.features,{poly={0,0,self.w/2,0,0,self.h-height}})
		table.insert(self.features,{poly={self.w,0,self.w/2,0,self.w,self.h-height}})
	else
		local featureType = math.random(1,10)
		if featureType == 1 then
			local length = math.random(self.w/4,self.w/2)
			table.insert(self.features,{poly={0,0,0,length,length,0}})
		elseif featureType == 2 then
			local length = math.random(self.w/4,self.w/2)
			table.insert(self.features,{poly={self.w,0,self.w,length,self.w-length,0}})
		elseif featureType == 3 then
			local ww = math.random(self.w*1/3,self.w*2/3)
			table.insert(self.features,{poly={self.w/2-ww/2,self.h/2+ww*0.866/2,self.w/2+ww/2,self.h/2+ww*0.866/2,self.w/2,self.h/2-ww*0.866/2}})
		else
			local hh = math.random(self.h/12,self.h/6)
			if self.sky then
				hh = math.random(self.w/8,self.w/4)
			end
			local ww = math.random(hh/2,hh*3/4)
			local xx = math.random(self.w/10,self.w-ww-self.w/10)
			local yy = math.random(self.h/12,self.h-hh-self.w/12)
			table.insert(self.features,{poly={xx,yy,xx+ww,yy,xx+ww,yy+hh,xx,yy+hh}})
			local extraWindows = featureType-4
			if self.sky then
				extraWindows = extraWindows + math.random(0,12)
			end
			while extraWindows > 0 do
				local offx = math.random(-6,6)
				local offy = math.random(-6,6)
				if xx + ww*offx*2 > self.w/10 then
					if yy + hh*offy*2 > self.h/12 then
						if xx + ww*offx*2 < self.w-ww-self.w/10 then
							if yy + hh*offy*2 < self.h-hh-self.w/12 then
								table.insert(self.features,{poly={xx + ww*offx*2,yy+ hh*offy*2,xx+ww + ww*offx*2,yy+ hh*offy*2,xx+ww + ww*offx*2,yy+hh + hh*offy*2,xx + ww*offx*2,yy+hh + hh*offy*2}})
								extraWindows = extraWindows - 1
							end
						end
					end
				end
			end
		end
	end
	love.graphics.setCanvas({self.canvas,stencil=true})
		love.graphics.stencil(function () for i,o in pairs(self.features) do
											love.graphics.polygon("fill",o.poly)
										end end,
							  "replace", 1)

		love.graphics.setStencilTest("less", 1)

		love.graphics.rectangle("fill",0,0,self.w,self.h)

		love.graphics.setStencilTest()
	love.graphics.setCanvas()
end

function Building:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.canvas,self.x,self.y)
end

function gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or 1}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or 1}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end