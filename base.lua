--a file containing all of the functions i plan to use in about any project
--to be elaborated on when needed

function checkCollision(x1,y1,w1,h1,x2,y2,w2,h2)
	if x1 + w1 > x2 then
		if x2+w2 > x1 then
			if y1 + h1 > y2 then
				if y2+h2 > y1 then
					return true
				end
			end
		end
	end
	return false
end

function checkCircleCollision(x1,y1,r1,x2,y2,r2)
	return r1+r2 > ((x1-x2)^2+(y1-y2)^2)^0.5
end

function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function checkLineCollision(x1,y1,x2,y2,x3,y3,w,h)
	if x1 > x2 then
		if y1 < y2 then -- Bottom Left Corner
			if lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3) then -- top wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3) then -- right wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h) then -- bottom wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h)
			end
			if lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h) then -- left wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h)
			end
		else -- Top Left Corner
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3) then -- right wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h) then -- bottom wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h)
			end
			if lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3) then -- top wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h) then -- left wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h)
			end
		end
	else
		if y1 > y2 then -- Bottom Right Corner
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h) then -- bottom wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h)
			end
			if lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h) then -- left wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h)
			end
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3) then -- right wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3) then -- top wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3)
			end
		else -- Top Right Corner
			if lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3) then -- top wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h) then -- left wall
				return lineLine(x1,y1,x2,y2,x3,y3,x3,y3+h)
			end
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3) then -- right wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3+w,y3)
			end
			if lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h) then -- bottom wall
				return lineLine(x1,y1,x2,y2,x3+w,y3+h,x3,y3+h)
			end
		end
	end
end

function lineLine(x1,y1,x2,y2,x3,y3,x4,y4)

	uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
	uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))

	if (uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1) then
		intersectionX = x1 + (uA * (x2-x1))
		intersectionY = y1 + (uA * (y2-y1))
		return intersectionX,intersectionY
	end
	return
end

-- Save copied tables in `copies`, indexed by original table.
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function math.sign(number)
    return (number > 0 and 1) or (number == 0 and 0) or -1
end

function math.lerp(a,b,f) --starting value, end value, phase between (0-1)
	return a + f * (b - a)
end