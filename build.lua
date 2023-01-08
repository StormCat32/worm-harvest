Build = {
	worm = {},
	buildings = {},
	backBuildings = {},
	backBackBuildings = {},
	
	backGround = {},
	
	buildingList = {},
	
	screenw = love.graphics.getWidth(),
	screenh = love.graphics.getHeight(),
	
	y = 600,
	w = love.graphics.getWidth(),
	h = 950,
	
	panTimer = 1,
	panTimerMax = 1,
	panH = 240,
	pan2Timer = 1,
	pan2TimerMax = 1,
	pan3Timer = 3,
	pan3TimerMax = 3,
	pan4Timer = 2,
	pan4TimerMax = 2,
	
	buildSpeed = 400,
	buildingTimer = 0,
	buildingWaitTime = 0.2,
	
	currentBuilding = {},
	currentLayer = 2,
	currentTimer = 0,
	currentTimerMax = 0.5,
}

function Build:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.worm = {}
	o.buildings = {}
	o.backBuildings = {}
	o.backBackBuildings = {}
	o.backGround = {}
	
	o.buildingList = {}
	o.currentBuilding = {}
	
	return o
end

function Build:load(worm,buildings)
	self.backGround = gradientMesh("vertical",{149/255,228/255,241/255},{224/255,255/255,255/255})
	self.backGround2 = gradientMesh("vertical",{254/255,157/255,0/255},{254/255,223/255,96/255})
	
	self.worm = {}
	self.worm = worm
	local dif = self.worm.x
	self.worm.x = self.w/2
	dif = self.worm.x - dif
	for z = 1,#self.worm.points do
		self.worm.points[z].pos.x = self.worm.points[z].pos.x+dif
		self.worm.points[z].posB.x = self.worm.points[z].posB.x+dif
	end
	
	self.buildingList = {}
	self.currentBuilding = {}
	self.currentLayer = 2
	self.buildingList = buildings
	for i,o in pairs(self.buildingList) do
		local rand = math.random(1,3)
		if rand == 1 then
			love.graphics.setColor(43/255,164/255,150/255)
		elseif rand == 2 then
			love.graphics.setColor(27/255,110/255,85/255)
		else
			love.graphics.setColor(12/255,69/255,43/255)
		end
		o:canvasLoad()
	end
	
	self.animationStart = false
	self.animationBegin = false
	self.animationDone = false
	self.finished = false
	self.panTimer = self.panTimerMax
	self.pan2Timer = self.pan2TimerMax
	self.pan3Timer = self.pan3TimerMax
	self.pan4Timer = self.pan4TimerMax
end

function Build:keypressed(key)
	if self.pan2Timer <= 0 then
		if not self.finished then
			if key == "w" or key == "up" then
				self:changeLayer(self.currentLayer-1)
			end
			if key == "s" or key == "down" then
				self:changeLayer(self.currentLayer+1)
			end
			if key == "space" or key == "return" then
				if self.currentLayer == 1 then
					table.insert(self.backBackBuildings,self.currentBuilding)
					if #self.buildingList > 0 then
						self.currentBuilding = self.buildingList[1]
						table.remove(self.buildingList,1)
						self.currentTimer = self.currentTimerMax
						self:changeLayer(math.random(1,3))
					else
						self.finished = true
					end
				elseif self.currentLayer == 2 then
					table.insert(self.backBuildings,self.currentBuilding)
					if #self.buildingList > 0 then
						self.currentBuilding = self.buildingList[1]
						table.remove(self.buildingList,1)
						self.currentTimer = self.currentTimerMax
						self:changeLayer(math.random(1,3))
					else
						self.finished = true
					end
				elseif self.currentLayer == 3 then
					table.insert(self.buildings,self.currentBuilding)
					if #self.buildingList > 0 then
						self.currentBuilding = self.buildingList[1]
						self.currentTimer = self.currentTimerMax
						table.remove(self.buildingList,1)
						self:changeLayer(math.random(1,3))
					else
						self.finished = true
					end
				end
			end
		end
	end
end

function Build:update(dt)
	if not self.animationStart then
		if self.worm.diry ~= 0 then
			self.worm:buildUpdate(dt)
		else
			self.animationStart = true
			self.panTimer = self.panTimerMax
		end
	elseif not self.animationBegin then
		self.panTimer = self.panTimer - dt
		if self.panTimer < 0 then
			self.panTimer = 0
			self.animationBegin = true
			for i,o in pairs(self.buildingList) do
				o.x = self.w/2-o.w/2
				o.y = self.worm.y
				o.dirx = math.random(-0.4,0.4)
				o.diry = -math.random(0.8,1.2)
				local ang = math.atan2(o.diry,o.dirx)
				o.dirx = math.cos(ang)
				o.diry = math.sin(ang)
			end
		end
	elseif not self.animationDone then
		self.buildingTimer = self.buildingTimer+dt
		local above = true
		for i,o in pairs(self.buildingList) do
			if o.y+o.h > self.panH then
				above = false
			end
			if self.buildingTimer > self.buildingWaitTime*i then
				o.x = o.x + o.dirx*self.buildSpeed*dt
				o.y = o.y + o.diry*self.buildSpeed*dt
			else
				break
			end
		end
		if above then
			self.animationDone = true
		end
	elseif self.pan2Timer > 0 then
		self.pan2Timer = self.pan2Timer - dt
		if self.pan2Timer <= 0 then
			self.pan2Timer = 0
			if #self.buildingList > 0 then
				for i,o in pairs(self.buildingList) do
					o.x = math.random(10,self.w-o.w-10)
					o.y = self.y-o.h
				end
				self.currentBuilding = self.buildingList[1]
				table.remove(self.buildingList,1)
				self.currentTimer = self.currentTimerMax
				self:changeLayer(2)
			else
				self.finished = true
			end
		end
	elseif self.finished then
		self.pan3Timer = self.pan3Timer-dt
		if self.pan3Timer <= 0 then
			self.pan3Timer = 0
			self.pan4Timer = self.pan4Timer-dt
			if self.pan4Timer <= 0 then
				scene = City:new()
				scene:load()
			end
		end
		--transition screens somehow
	else
		self.currentTimer = self.currentTimer - dt
		if love.keyboard.isDown("left","a") then
			self.currentBuilding.x = self.currentBuilding.x-self.buildSpeed*dt
		end
		if love.keyboard.isDown("right","d") then
			self.currentBuilding.x = self.currentBuilding.x+self.buildSpeed*dt
		end
		if self.currentBuilding.x < 0 then
			self.currentBuilding.x = 0
		elseif self.currentBuilding.x+self.currentBuilding.w > self.w then
			self.currentBuilding.x = self.w-self.currentBuilding.w
		end
	end
end

function Build:changeLayer(layer)
	self.currentLayer = layer
	if self.currentLayer > 3 then
		self.currentLayer = 3
	elseif self.currentLayer < 1 then
		self.currentLayer = 1
	end
	if self.currentLayer == 1 then
		love.graphics.setColor(43/255,164/255,150/255)
	elseif self.currentLayer == 2 then
		love.graphics.setColor(27/255,110/255,85/255)
	else
		love.graphics.setColor(12/255,69/255,43/255)
	end
	self.currentBuilding:canvasLoad()
end

function Build:draw()
	love.graphics.setColor(1,1,1,self.pan4Timer/self.pan4TimerMax)
	love.graphics.draw(self.backGround,0,0,0,self.screenw,self.screenh)
	love.graphics.setColor(1,1,1,1-self.pan4Timer/self.pan4TimerMax)
	love.graphics.draw(self.backGround2,0,0,0,self.screenw,self.screenh)
	
	local camOff = -self.worm.y+self.screenh/2
	camOff = math.lerp(camOff,-self.panH,1-self.panTimer/self.panTimerMax)
	if self.finished then
		camOff = math.lerp(0,self.screenh*2,1-self.pan3Timer/self.pan3TimerMax)
	elseif self.animationDone then
		camOff = math.lerp(-self.panH,0,1-self.pan2Timer/self.pan2TimerMax)
	end
	
	love.graphics.translate(0,math.floor(camOff/2))
	love.graphics.setColor(224/255,255/255,255/255)
	love.graphics.circle("fill",self.w*2/3,self.screenh/3,self.w/16)
	love.graphics.origin()
	
	love.graphics.translate(self.w/8,math.floor(camOff*3/4))
	love.graphics.scale(3/4,3/4)
	love.graphics.setColor(43/255,164/255,150/255)
	love.graphics.rectangle("fill",-self.w/2,self.y,self.w*2,self.h*20)
	for i,o in pairs(self.backBackBuildings) do
		o:buildDraw()
	end
	if self.pan2Timer <= 0 and not self.finished then
		if self.currentLayer == 1 then
			self.currentBuilding:buildDraw(1-self.currentTimer/self.currentTimerMax)
		end
	end
	love.graphics.origin()
	
	love.graphics.translate(self.w/12,math.floor(camOff*5/6))
	love.graphics.scale(5/6,5/6)
	love.graphics.setColor(27/255,110/255,85/255)
	love.graphics.rectangle("fill",-self.w/2,self.y,self.w*2,self.h*20)
	for i,o in pairs(self.backBuildings) do
		o:buildDraw()
	end
	if self.pan2Timer <= 0 and not self.finished then
		if self.currentLayer == 2 then
			self.currentBuilding:buildDraw(1-self.currentTimer/self.currentTimerMax)
		end
	end
	love.graphics.origin()
	
	love.graphics.translate(0,math.floor(camOff))
	love.graphics.setColor(12/255,69/255,43/255)
	love.graphics.rectangle("fill",-self.w/2,self.y,self.w*2,self.h*20)
	for i,o in pairs(self.buildings) do
		o:buildDraw()
	end
	if self.pan2Timer <= 0 and not self.finished then
		if self.currentLayer == 3 then
			self.currentBuilding:buildDraw(1-self.currentTimer/self.currentTimerMax)
		end
	end
	
	if self.animationBegin and not self.animationDone then
		for i,o in pairs(self.buildingList) do
			o:buildDraw()
		end
	end
	
	self.worm:buildDraw()
	love.graphics.origin()
end