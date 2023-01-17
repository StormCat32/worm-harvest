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
	
	pan5Timer = 3,
	pan5TimerMax = 3,
	
	buildSpeed = 400,
	buildingTimer = 0,
	buildingWaitTime = 0.2,
	
	currentBuilding = {},
	currentLayer = 2,
	currentTimer = 0,
	currentTimerMax = 0.5,
	
	deathCount = 0,
	
	placeSound = love.audio.newSource("sound/place.wav","static"),
	blockedSound = love.audio.newSource("sound/block.wav","static"),
	moveSound = love.audio.newSource("sound/move.wav","static"),
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
	self.pan5Timer = self.pan5TimerMax
	self.buildingTimer = 0
end

function Build:keypressed(key)
	if self.pan2Timer <= 0 then
		if not self.finished and not self.gameOver then
			if key == "w" or key == "up" then
				self:changeLayer(self.currentLayer-1)
				self.moveSound:play()
			end
			if key == "s" or key == "down" then
				self:changeLayer(self.currentLayer+1)
				self.moveSound:play()
			end
			if key == "space" or key == "return" then
				if self.currentLayer == 1 then
					for i,o in pairs(self.backBackBuildings) do
						if checkCollision(o.x,o.y,o.w,o.h,self.currentBuilding.x,self.currentBuilding.y,self.currentBuilding.w,self.currentBuilding.h) then
							self.blockedSound:play()
							return
						end
					end
					self.placeSound:play()
					table.insert(self.backBackBuildings,self.currentBuilding)
					if #self.buildingList > 0 then
						self:newBuilding()
					else
						self.finished = true
						self.currentLayer = 3
					end
				elseif self.currentLayer == 2 then
					for i,o in pairs(self.backBuildings) do
						if checkCollision(o.x,o.y,o.w,o.h,self.currentBuilding.x,self.currentBuilding.y,self.currentBuilding.w,self.currentBuilding.h) then
							self.blockedSound:play()
							return
						end
					end
					self.placeSound:play()
					table.insert(self.backBuildings,self.currentBuilding)
					if #self.buildingList > 0 then
						self:newBuilding()
					else
						self.finished = true
						self.currentLayer = 3
					end
				elseif self.currentLayer == 3 then
					for i,o in pairs(self.buildings) do
						if checkCollision(o.x,o.y,o.w,o.h,self.currentBuilding.x,self.currentBuilding.y,self.currentBuilding.w,self.currentBuilding.h) then
							self.blockedSound:play()
							return
						end
					end
					self.placeSound:play()
					table.insert(self.buildings,self.currentBuilding)
					if #self.buildingList > 0 then
						self:newBuilding()
					else
						self.finished = true
						self.currentLayer = 3
					end
				end
			end
		end
	end
end

function Build:update(dt)
	if self.gameOver then
		self.pan5Timer = self.pan5Timer - dt
		if self.pan5Timer < 0 then
			self.pan5Timer = 0
		end
	elseif not self.animationStart then
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
				o.dirx = 0
				o.diry = -1
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
				self:newBuilding()
			else
				self.finished = true
				self.currentLayer = 3
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

function Build:newBuilding()
	self.currentBuilding = self.buildingList[1]
	table.remove(self.buildingList,1)
	local canPlace = false
	
	local curX = 0
	while curX + self.currentBuilding.w < self.w do
		canPlace = true
		for i,o in pairs(self.buildings) do
			if checkCollision(curX,self.currentBuilding.y,self.currentBuilding.w,self.currentBuilding.h,o.x,o.y,o.w,o.h) then
				canPlace = false
				break
			end
		end
		if canPlace then
			break
		else
			curX = curX + self.currentBuilding.w 
		end
	end
	
	if not canPlace then
		curX = 0
		while curX + self.currentBuilding.w < self.w do
			canPlace = true
			for i,o in pairs(self.backBuildings) do
				if checkCollision(curX,self.currentBuilding.y,self.currentBuilding.w,self.currentBuilding.h,o.x,o.y,o.w,o.h) then
					canPlace = false
					break
				end
			end
			if canPlace then
				break
			else
				curX = curX + self.currentBuilding.w 
			end
		end
	end
	
	if not canPlace then
		curX = 0
		while curX + self.currentBuilding.w < self.w do
			canPlace = true
			for i,o in pairs(self.backBackBuildings) do
				if checkCollision(curX,self.currentBuilding.y,self.currentBuilding.w,self.currentBuilding.h,o.x,o.y,o.w,o.h) then
					canPlace = false
					break
				end
			end
			if canPlace then
				break
			else
				curX = curX + self.currentBuilding.w 
			end
		end
	end
	
	self.currentTimer = self.currentTimerMax
	self:changeLayer(math.random(1,3))
	
	if not canPlace then
		self.gameOver = true
		self:changeLayer(3)
		local count1 = 0 --houses (5 points)
		local count2 = 0 --sheared buildings (10 points)
		local count3 = 0 --traingles (15 points)
		local count4 = 0 --windows (1 point)
		local score = 0
		for i,o in pairs(self.backBuildings) do
			if o.type == 1 then
				count1 = count1 + 1
			elseif o.type == 2 then
				count2 = count2 + 1
			elseif o.type == 3 then
				count3 = count3 + 1
			else
				count4 = count4 + o.type-3
			end
		end
		score = 5*count1+10*count2+15*count3+count4-10*self.deathCount
		self.gameOverMessage = "Salvage City Score\nWindows: "..count4.." x 1\nHouses: "..count1.." x 5\nSheared Skyscrapers: "..count2.." x 10\nTriangle Viewports: "..count3.." x 15\nDeaths: "..self.deathCount.." x -10\n\nFinal Score: "..score
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
	if self.gameOver then
		camOff = math.lerp(0,self.screenh*1.4,1-self.pan5Timer/self.pan5TimerMax)
	elseif self.finished then
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
	if not self.gameOver then
		if self.pan2Timer <= 0 and not self.finished then
			if self.currentLayer == 1 then
				self.currentBuilding:buildDraw(1-self.currentTimer/self.currentTimerMax)
			end
		end
	end
	love.graphics.origin()
	
	love.graphics.translate(self.w/12,math.floor(camOff*5/6))
	love.graphics.scale(5/6,5/6)
	love.graphics.setColor(27/255,110/255,85/255)
	love.graphics.rectangle("fill",-self.w/2,self.y,self.w*2,self.h*20)
	for i,o in pairs(self.backBuildings) do
		if self.currentLayer == 1 then
			o:buildDraw(0.5)
		else
			o:buildDraw()
		end
	end
	if not self.gameOver then
		if self.pan2Timer <= 0 and not self.finished then
			if self.currentLayer == 2 then
				self.currentBuilding:buildDraw(1-self.currentTimer/self.currentTimerMax)
			end
		end
	end
	love.graphics.origin()
	
	love.graphics.translate(0,math.floor(camOff))
	love.graphics.setColor(12/255,69/255,43/255)
	love.graphics.rectangle("fill",-self.w/2,self.y,self.w*2,self.h*20)
	for i,o in pairs(self.buildings) do
		if self.currentLayer < 3 then
			o:buildDraw(0.5)
		else
			o:buildDraw()
		end
	end
	if not self.gameOver then
		if self.pan2Timer <= 0 and not self.finished then
			if self.currentLayer == 3 then
				self.currentBuilding:buildDraw(1-self.currentTimer/self.currentTimerMax)
			end
		end
	end
	
	if self.animationBegin and not self.animationDone then
		for i,o in pairs(self.buildingList) do
			o:buildDraw()
		end
	end
	
	if self.gameOver then
		love.graphics.setColor(1/255,33/255,13/255)
		love.graphics.print(self.gameOverMessage,64,-self.screenh*1.4+64)
	end
	
	self.worm:buildDraw()
	love.graphics.origin()
end