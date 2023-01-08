Build = {
	worm = {},
	buildings = {},
	backBuildings = {},
	backBackBuildings = {},
	
	backGround = {},
	
	screenw = love.graphics.getWidth(),
	screenh = love.graphics.getHeight(),
	
	y = 600,
	w = love.graphics.getWidth(),
	h = 950,
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
	
	return o
end

function Build:load(worm)
	self.backGround = gradientMesh("vertical",{149/255,228/255,241/255},{224/255,255/255,255/255})

	self.worm = worm
	local dif = self.worm.x
	self.worm.x = self.w/2
	dif = dif - self.worm.x
	for z = 1,#self.worm.points do
		self.worm.points[z].pos.x = self.worm.points[z].pos.x+dif
		self.worm.points[z].posB.x = self.worm.points[z].posB.x+dif
	end
end

function Build:update(dt)
	self.worm:buildUpdate(dt)
end

function Build:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.backGround,0,0,0,self.screenw,self.screenh)
	
	love.graphics.translate(math.floor(-self.worm.x+self.screenw/2),math.floor(-self.worm.y+self.screenh/2))
	love.graphics.setColor(83/255,27/255,2/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h*20)
	love.graphics.origin()
	
	love.graphics.translate(-self.worm.x+self.screenw/2,-self.worm.y+self.screenh/2)
	self.worm:draw()
	love.graphics.origin()
end