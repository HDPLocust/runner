
-- Animation class
do
	local floor, ceil = math.floor, math.ceil
	map = {}
	setmetatable(map, {
		__call = function(self, img, sx, sy)
			local o = {}
			o.img = img
			o.sx = sx or 1
			o.sy = sy or 1
			local imgx, imgy = o.img:getDimensions()
			o.sw, o.sh = floor(imgx / o.sx), floor(imgy / o.sy)
			o.quad = {}
			local x = floor(imgx/o.sx)
			for i = 1, o.sx do
				o.quad[i] = {}
				local y = floor(imgy/o.sy)
				for j = 1, o.sy do
					print(i*x, j*y)
					o.quad[i][j] = love.graphics.newQuad((i-1)*x, (j-1)*y, o.sw, o.sh, imgx, imgy)
				end
			end
			self.__index = self
			return setmetatable(o, {__index = self})
		end
	})

	function map:getSprite(x, y)
		x = x or 1
		y = y or 1
		return self.img, self.quad[x][y]
	end

	anim = {}
	setmetatable(anim, {
		__call = function(self, map, t, time, loop)
			local o = {}
			o.map = map
			o.seq = t
			o.count = #o.seq
			o.delay = time/#t
			o.loop = loop
			o.timer = 0.1
			self.__index = self
			return setmetatable(o, {__index = self})
		end
	})

	function anim:update(dt)
		self.timer = self.timer + dt
	end

	function anim:draw(x, y, w, h, r, sx, sh)
		local time = self.timer/self.delay%self.count
		local img, quad = self.map:getSprite(unpack(self.seq[ceil(time)]))
		love.graphics.draw(img, quad, x, y)
	end
end
function love.load()

	bckgr = love.graphics.newImage('BG.png')
	img = love.graphics.newImage('tesla.png')
	m = map(img, 6, 1)
	local t = {
		{1, 1},
		{2, 1},
		{3, 1},
		{4, 1},
		{5, 1},
		{6, 1}
	}
	tesla = anim(m, t, 0.5)
	
		for i, v in pairs(arg) do
			print(i, v)
		end
end

BModes = {
	{'add', 'alphamultiply'},
	{'subtract', 'alphamultiply'},
	{'replace', 'alphamultiply'},
	{'multiply', 'alphamultiply'},
	{'screen', 'alphamultiply'},
	{'lighten', 'premultiplied'},
	{'darken', 'premultiplied'}
}
CBMode = 1

function love.keypressed(key, unicode)
	if key == 'escape' then love.event.quit() end
	if key:find('%d') then
		local n = tonumber(key:match('%d'))
		CBMode = n > 0 and n <= #BModes and n or CBMode
	end
end

function love.filedropped(file)
	--str = 'COPY /Y '..file:getFilename()..' '..arg[1]:gsub('/', '\\')..'\\temp.i'
	--print(str)
	--os.execute(str)
	--local f = io.open(arg[1]..'/temp.i')
	m.img = love.graphics.newImage(file)
end

function love.update(dt)
	love.window.setTitle(love.timer.getFPS())
	tesla:update(dt)
end

function love.draw()
	local storedmode = love.graphics.getBlendMode()
	love.graphics.draw(bckgr, 0, 0)
	love.graphics.setBlendMode(unpack(BModes[CBMode]))
-- https://love2d.org/wiki/BlendMode_Formulas
	tesla:draw(love.mouse.getPosition(-20))
	love.graphics.setBlendMode(storedmode)
end