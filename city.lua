local mask_shader = love.graphics.newShader[[
   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).r <= 50.0/255.0) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(Texel(texture, texture_coords));
   }
]]

City = {
	endTimer = 0,
	endTimerMax = 60,

	player = {},
	buildings = {},
	backBuildings = {},
	backBackBuildings = {},
	
	bombs = {},
	backBombs = {},
	backBackBombs = {},
	
	explode = {},
	backExplode = {},
	backBackExplode = {},
	
	bombTimer = 0,
	backBombTimer = 0,
	backBackBombTimer = 0,
	bombTimerMax = 0.5,
	
	y = 600,
	w = 6*love.graphics.getWidth(),
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
	
	startTimer = 3,
	startTimerMax = 3,
	
	winTimer = 2,
	winTimerMax = 2,
	
	backGround = {},
	
	maxPixelCount = 120,
}

function City:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.player = {}
	o.buildings = {}
	o.backBuildings = {}
	o.backBackBuildings = {}
	o.camera = {}
	
	o.bombs = {}
	o.backBombs = {}
	o.backBackBombs = {}
	
	o.explode = {}
	o.backExplode = {}
	o.backBackExplode = {}
	
	return o
end

function City:load()
	self.backGround = gradientMesh("vertical",{254/255,157/255,0/255},{254/255,223/255,96/255})

	self.endTimer = self.endTimerMax
	self.startTimer = self.startTimerMax
	
	self.player = Worm:new()
	self.player:load(0,self.h+50)
	self.camera = Camera:new()
	self.camera.x = self.player.x-self.camera.w/2
	self.camera.y = self.h-self.camera.h-2000*self.startTimer/self.startTimerMax
	local buildPos = math.random(self.player.w+1,self.sBuildDif)
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
	if self.startTimer <= 0 then
		self.endTimer = self.endTimer - dt
		if self.won then
			self.winTimer = self.winTimer - dt
			if self.winTimer < 0 then
				self.winTimer = 0
			end
		elseif self.player.dead == false then
			if self.endTimer <= self.endTimerMax/4 then --bombs start to drop on player's level
				self.bombTimer = self.bombTimer - dt
				if self.bombTimer <= 0 then
					table.insert(self.bombs,Bomb:new(1))
					self.bombTimer = self.bombTimerMax
				end
			end
			if self.endTimer <= self.endTimerMax/2 then --bombs on first background
				self.backBombTimer = self.backBombTimer - dt
				if self.backBombTimer <= 0 then
					table.insert(self.backBombs,Bomb:new(2))
					self.backBombTimer = self.bombTimerMax*3/4
				end
			end
			if self.endTimer <= self.endTimerMax*3/4 then --bombs on second background
				self.backBackBombTimer = self.backBackBombTimer - dt
				if self.backBackBombTimer <= 0 then
					table.insert(self.backBackBombs,Bomb:new(3))
					self.backBackBombTimer = self.bombTimerMax/2
				end
			end
		end
		self.player:update(dt)
		if self.player.sceneChange then
			return
		end
		self.camera:update(dt)
		for i,o in pairs(self.buildings) do
			o:update(dt)
		end
		for i,o in pairs(self.bombs) do
			if o.remove then
				table.remove(self.bombs,i)
			end
		end
		for i,o in pairs(self.backBombs) do
			if o.remove then
				table.remove(self.backBombs,i)
			end
		end
		for i,o in pairs(self.backBackBombs) do
			if o.remove then
				table.remove(self.backBackBombs,i)
			end
		end
		for i,o in pairs(self.bombs) do
			o:update(dt,nil)
		end
		for i,o in pairs(self.backBombs) do
			o:update(dt,self.backBuildings)
		end
		for i,o in pairs(self.backBackBombs) do
			o:update(dt,self.backBackBuildings)
		end
		for i,o in pairs(self.explode) do
			o:update(dt)
		end
		for i,o in pairs(self.backExplode) do
			o:update(dt)
		end
		for i,o in pairs(self.backBackExplode) do
			o:update(dt)
		end
	else
		if self.player.dead then
			self.startTimer = self.startTimer + dt
			if self.startTimer > self.startTimerMax then
				scene = City:new()
				scene:load()
			end
		else
			self.startTimer = self.startTimer - dt
		end
		self.camera.x = self.player.x-self.camera.w/2
		self.camera.y = self.h-self.camera.h-2000*self.startTimer/self.startTimerMax
	end
end

function City:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.backGround,0,0,0,self.camera.w,self.camera.h)
	love.graphics.translate(0,-math.floor(self.camera.y*1/2))
	love.graphics.setColor(254/255,223/255,96/255)
	love.graphics.circle("fill",self.camera.w/2,self.camera.h*2/3,self.camera.w/4)
	love.graphics.origin()
	
	self:drawBackgrounds()
	self:drawForegrounds()
	
	if self.endTimer <= 0 then
		love.graphics.setColor(254/255,223/255,96/255,-self.endTimer)
		love.graphics.translate(-math.floor(self.camera.x),-math.floor(self.camera.y))
		love.graphics.polygon("fill",self.player.x-40,self.h-160,self.player.x+40,self.h-160,self.player.x,self.h-160+80*0.866)
		love.graphics.origin()
	end
end

function City:drawBackgrounds()
	love.graphics.translate(-math.floor(self.camera.x*3/4),-math.floor(self.camera.y*3/4))
	love.graphics.scale(3/4,3/4)
	
	love.graphics.stencil(function () for i,o in pairs(self.backBackExplode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(212/255,109/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.backBackBuildings) do
		o:draw()
	end
	love.graphics.setColor(212/255,109/255,20/255)
	for i,o in pairs(self.backBackBombs) do
		o:draw()
	end
	for i,o in pairs(self.backBackExplode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor((self.camera.x-self.w)*3/4),-math.floor(self.camera.y*3/4))
	love.graphics.scale(3/4,3/4)
	
	love.graphics.stencil(function () for i,o in pairs(self.backBackExplode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(212/255,109/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.backBackBuildings) do
		o:draw()
	end
	love.graphics.setColor(212/255,109/255,20/255)
	for i,o in pairs(self.backBackBombs) do
		o:draw()
	end
	for i,o in pairs(self.backBackExplode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor((self.camera.x+self.w)*3/4),-math.floor(self.camera.y*3/4))
	love.graphics.scale(3/4,3/4)
	
	love.graphics.stencil(function () for i,o in pairs(self.backBackExplode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(212/255,109/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.backBackBuildings) do
		o:draw()
	end
	love.graphics.setColor(212/255,109/255,20/255)
	for i,o in pairs(self.backBackBombs) do
		o:draw()
	end
	for i,o in pairs(self.backBackExplode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor(self.camera.x*5/6),-math.floor(self.camera.y*5/6))
	love.graphics.scale(5/6,5/6)
	
	love.graphics.stencil(function () for i,o in pairs(self.backExplode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(170/255,77/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.backBuildings) do
		o:draw()
	end
	love.graphics.setColor(170/255,77/255,20/255)
	for i,o in pairs(self.backBombs) do
		o:draw()
	end
	for i,o in pairs(self.backExplode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor((self.camera.x-self.w)*5/6),-math.floor(self.camera.y*5/6))
	love.graphics.scale(5/6,5/6)
	
	love.graphics.stencil(function () for i,o in pairs(self.backExplode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(170/255,77/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.backBuildings) do
		o:draw()
	end
	love.graphics.setColor(170/255,77/255,20/255)
	for i,o in pairs(self.backBombs) do
		o:draw()
	end
	for i,o in pairs(self.backExplode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor((self.camera.x+self.w)*5/6),-math.floor(self.camera.y*5/6))
	love.graphics.scale(5/6,5/6)
	
	love.graphics.stencil(function () for i,o in pairs(self.backExplode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(170/255,77/255,20/255)
	love.graphics.rectangle("fill",0,self.y,self.w,self.h-self.y)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.backBuildings) do
		o:draw()
	end
	love.graphics.setColor(170/255,77/255,20/255)
	for i,o in pairs(self.backBombs) do
		o:draw()
	end
	for i,o in pairs(self.backExplode) do
		o:draw()
	end
	love.graphics.origin()
end

function City:drawForegrounds()
	love.graphics.translate(-math.floor(self.camera.x),-math.floor(self.camera.y))
	
	love.graphics.stencil(function () for i,o in pairs(self.explode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(83/255,27/255,2/255)
	if self.won then
		love.graphics.setColor(math.lerp(83,12,1-self.winTimer/self.winTimerMax)/255,math.lerp(27,69,1-self.winTimer/self.winTimerMax)/255,math.lerp(2,43,1-self.winTimer/self.winTimerMax)/255)
	end
	love.graphics.rectangle("fill",0,self.y,self.w,self.h*20)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.buildings) do
		o:draw()
	end
	love.graphics.setColor(83/255,27/255,2/255)
	for i,o in pairs(self.bombs) do
		o:draw()
	end
	for i,o in pairs(self.explode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor(self.camera.x-self.w),-math.floor(self.camera.y))
	
	love.graphics.stencil(function () for i,o in pairs(self.explode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(83/255,27/255,2/255)
	if self.won then
		love.graphics.setColor(math.lerp(83,12,1-self.winTimer/self.winTimerMax)/255,math.lerp(27,69,1-self.winTimer/self.winTimerMax)/255,math.lerp(2,43,1-self.winTimer/self.winTimerMax)/255)
	end
	love.graphics.rectangle("fill",0,self.y,self.w,self.h*20)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.buildings) do
		o:draw()
	end
	love.graphics.setColor(83/255,27/255,2/255)
	for i,o in pairs(self.bombs) do
		o:draw()
	end
	for i,o in pairs(self.explode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-math.floor(self.camera.x+self.w),-math.floor(self.camera.y))
	
	love.graphics.stencil(function () for i,o in pairs(self.explode) do o:eatDraw() end end, "replace", 1)
	love.graphics.setStencilTest("less", 1)
	love.graphics.setColor(83/255,27/255,2/255)
	if self.won then
		love.graphics.setColor(math.lerp(83,12,1-self.winTimer/self.winTimerMax)/255,math.lerp(27,69,1-self.winTimer/self.winTimerMax)/255,math.lerp(2,43,1-self.winTimer/self.winTimerMax)/255)
	end
	love.graphics.rectangle("fill",0,self.y,self.w,self.h*20)
	love.graphics.setStencilTest()
	
	for i,o in pairs(self.buildings) do
		o:draw()
	end
	love.graphics.setColor(83/255,27/255,2/255)
	for i,o in pairs(self.bombs) do
		o:draw()
	end
	for i,o in pairs(self.explode) do
		o:draw()
	end
	love.graphics.origin()
	
	love.graphics.translate(-self.camera.x,-self.camera.y)
	self.player:draw()
	love.graphics.origin()
end

function City:explodeBomb(x,y,r,layer)
	if layer == 1 then
		table.insert(self.explode,Explosion:new(x,y,r))
		if checkCircleCollision(x,y,r,self.player.x,self.player.y,1) then
			self:die()
		end
	elseif layer == 2 then
		for i,o in pairs(self.backBuildings) do
			love.graphics.setCanvas({o.canvas,stencil=true})
				love.graphics.translate(-o.x,-o.y)
				love.graphics.setColor(0,1,0)
				love.graphics.circle("fill",x,y,r)
				love.graphics.origin()
			love.graphics.setCanvas()
		end
		table.insert(self.backExplode,Explosion:new(x,y,r))
	elseif layer == 3 then
		for i,o in pairs(self.backBackBuildings) do
			love.graphics.setCanvas({o.canvas,stencil=true})
				love.graphics.translate(-o.x,-o.y)
				love.graphics.setColor(0,1,0)
				love.graphics.circle("fill",x,y,r)
				love.graphics.origin()
			love.graphics.setCanvas()
		end
		table.insert(self.backBackExplode,Explosion:new(x,y,r))
	end
end

function City:die()
	self.player.dead = true
	--player freeze frames wherever they currently are
	--segments all do the colour change flash thing that the explosions do in order
	--after all segments have dissapeared game fades to city brown
end

function City:leave()
	self.won = true
	
	self.winTimer = self.winTimerMax
	
	self.backBuildings = {}
	self.backBackBuildings = {}
	
	self.bombs = {}
	self.backBombs = {}
	self.backBackBombs = {}
	
	self.explode = {}
	self.backExplode = {}
	self.backBackExplode = {}
	--screen pans down into the ground to show the player tunneling left
	--the ground slowly changes colour to city building green
	--after the colour change is complete, the worm tunnels up until breaching the surface and the buildings
	--they collected get spat out into a sidebar and the worm tunnels back down
	--city building commences
end

function City:change()
	for i,o in pairs(self.buildings) do
		local image = o.canvas:newImageData() -- Checking the level
		local pixelCount = 0
		for x = 0, image:getWidth()-1 do -- Actual making the level
			for y = 0, image:getHeight()-1 do
				local r, g, b, a = image:getPixel(x,y) -- Looking at the pixels in the picture to make the level
				if r > 50/255 then
					if a > 0 then
						pixelCount = pixelCount + 1
					end
				end
			end
		end
		if pixelCount > self.maxPixelCount then
			o.remove = true
		else
			o.remove = false
		end
	end
	for i=#self.buildings,1,-1 do
		if self.buildings[i].remove then
			table.remove(self.buildings, i)
		end
	end
	scene = cityBuilding
	scene:load(self.player,self.buildings)
end

Building = {
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	
	sky = false,
	
	features = {},
	canvas = {},
	startCanvas = {},
}

function Building:new(x,w,h,sky,house)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.features = {}
	o.canvas = {}
	o.startCanvas = {}
	o.backCanvas = {}
	
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
	self.startCanvas = love.graphics.newCanvas(self.w,self.h)
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
	self:canvasLoad()
end

function Building:canvasLoad()
	local colour = {love.graphics.getColor()}
	love.graphics.setCanvas({self.startCanvas,stencil=true})
		love.graphics.clear()
		love.graphics.stencil(function () for i,o in pairs(self.features) do
											love.graphics.polygon("fill",o.poly)
										end end,
							  "replace", 1)

		love.graphics.setStencilTest("less", 1)

		love.graphics.rectangle("fill",0,0,self.w,self.h)

		love.graphics.setStencilTest()
	love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.startCanvas)
	love.graphics.setCanvas()
	love.graphics.setColor(colour)
end

function Building:update(dt)
	if scene.player.x > self.x-scene.player.w then
		if scene.player.x < self.x+scene.player.w+self.w then
			love.graphics.setCanvas({self.canvas,stencil=true})
				love.graphics.translate(-self.x,-self.y)
				scene.player:eatDraw()
				love.graphics.origin()
			love.graphics.setCanvas()
		end
	end
end

function Building:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setShader(mask_shader)
	love.graphics.draw(self.canvas,self.x,self.y)
	love.graphics.setShader()
end

function Building:buildDraw(a)
	if not a then
		a = 1
	end
	love.graphics.setColor(1,1,1,a)
	love.graphics.draw(self.canvas,self.x,self.y)
end

Bomb = {
	x = 0,
	y = 0,
	w = 20,
	h = 40,
	
	dirx = 0,
	diry = 1,
	
	speed = 260,
	
	bombR = 320,
}

function Bomb:new(layer)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = math.random(0,scene.w)
	o.y = -200
	
	o.speed = math.random(200,350)
	
	o.bombR = math.random(80,160)
	
	o.layer = layer
	
	return o
end

function Bomb:update(dt,buildings)
	self.x = self.x + self.dirx * dt * self.speed
	self.y = self.y + self.diry * dt * self.speed
	if buildings then
		for i,o in pairs(buildings) do
			if checkCollision(self.x-self.w/2,self.y-self.h,self.w,self.h,o.x,o.y,o.w,o.h) then
				self:explode()
			end
		end
	end
	if self.y >= scene.y then
		self:explode()
	end
end

function Bomb:explode()
	scene:explodeBomb(self.x,self.y,self.bombR,self.layer)
	self.remove = true
end

function Bomb:draw()
	love.graphics.polygon("fill",self.x-self.w/2,self.y-self.h,
								self.x+self.w/2,self.y-self.h,
								self.x,self.y)
end

Explosion = {
	x = 0,
	y = 0,
	r = 0,
	
	timer = 0,
	timerMax = 0.4,
}

function Explosion:new(x,y,r)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = x
	o.y = y
	o.r = r
	o.timer = o.timerMax
	
	return o
end

function Explosion:update(dt)
	self.timer = self.timer-dt
end

function Explosion:draw()
	if self.timer >= self.timerMax*4/5 then
		love.graphics.setColor(1,1,1)
		love.graphics.circle("fill",self.x,self.y,self.r)
	elseif self.timer >= self.timerMax/2 then
		love.graphics.setColor(254/255,223/255,96/255)
		love.graphics.circle("fill",self.x,self.y,self.r*(1-(self.timerMax*4/5-self.timer)*5/4))
	elseif self.timer >= 0 then
		love.graphics.setColor(254/255,157/255,0/255)
		love.graphics.circle("fill",self.x,self.y,self.r*(1-(self.timerMax*4/5-self.timer)*5/4))
	end
end

function Explosion:eatDraw()
	love.graphics.setColor(0,0,0)
	love.graphics.circle("fill",self.x,self.y,self.r)
end