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
	
	colours - city
	6 - (39/255,6/255,0/255)
	5 - (83/255,27/255,2/255)
	4 - (170/255,77/255,20/255)
	3 - (212/255,109/255,20/255)
	2 - (254/255,157/255,0/255)
	1 - (254/255,223/255,96/255)
	
	colours - build
	6 - (1/255,33/255,13/255)
	5 - (12/255,69/255,43/255)
	4 - (27/255,110/255,85/255)
	3 - (43/255,164/255,150/255)
	2 - (149/255,228/255,241/255)
	1 - (224/255,255/255,255/255)
	
]]--

require "base"
require "city"
require "player"
require "build"

function love.load()
	math.randomseed(os.time())
	cityBuilding = Build:new()
	scene = City:new()
	scene:load()
end

function love.update(dt)
	scene:update(dt)
end

function love.draw()
	scene:draw()
end

function love.keypressed(key)
	if scene.currentBuilding then
		scene:keypressed(key)
	end
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