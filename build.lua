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
	
	return o
end

function Build:load(worm,buildings)
	self.backGround = gradientMesh("vertical",{149/255,228/255,241/255},{224/255,255/255,255/255})

	self.worm = worm
	local dif = self.worm.x
	self.worm.x = self.w/2
	dif = self.worm.x - dif
	for z = 1,#self.worm.points do
		self.worm.points[z].pos.x = self.worm.points[z].pos.x+dif
		self.worm.points[z].posB.x = self.worm.points[z].posB.x+dif
	end
	self.buildingList = buildings
	love.graphics.setColor(12/255,69/255,43/255)
	for i,o in pairs(self.buildingList) do
		o:canvasLoad()
		o.x = self.w/2-o.w/2
		o.y = 400
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
		end
	end
end

function Build:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.backGround,0,0,0,self.screenw,self.screenh)
	
	local camOff = -self.worm.y+self.screenh/2
	camOff = math.lerp(camOff,-self.panH,1-self.panTimer/self.panTimerMax)
	
	love.graphics.translate(0,math.floor(camOff*3/4))
	love.graphics.scale(3/4,3/4)
	love.graphics.setColor(43/255,164/255,150/255)
	love.graphics.rectangle("fill",0,self.y,self.w*2,self.h*20)
	love.graphics.origin()
	
	love.graphics.translate(0,math.floor(camOff*5/6))
	love.graphics.scale(5/6,5/6)
	love.graphics.setColor(27/255,110/255,85/255)
	love.graphics.rectangle("fill",0,self.y,self.w*2,self.h*20)
	love.graphics.origin()
	
	love.graphics.translate(0,math.floor(camOff))
	love.graphics.setColor(12/255,69/255,43/255)
	love.graphics.rectangle("fill",0,self.y,self.w*2,self.h*20)
	
	if self.animationBegin then
		for i,o in pairs(self.buildingList) do
			o:draw()
		end
	end
	
	self.worm:buildDraw()
	love.graphics.origin()
end