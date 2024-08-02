/*
		Team Blue Spring's Series of Libaries.
		Radial menu framework

		TODO:
		1) Queue for invidiual menus
		2) Page sharding
		3) In-game/Player interface of Radial menu due to online.
		4) 1 item page descriptive neater transition

Contributors: Skydusk
@Team Blue Spring 2024
*/

//
// ELEMENTAL DRAWING FUNCTIONS
//

-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
local function V_DrawLineLow(v, x_0, y_0, x_1, y_1, color, thickness)
	local dx = x_1-x_0
	local dy = y_1-y_0
	local yi = 1
	if dy < 0 then
		yi = -1
		dy = -dy
	end
	local D = 2*dy - dx
	local y = y_0

	for x = x_0, x_1 do
		v.drawFill(x, y - thickness/2, 1, thickness, color)
		if D > 0 then
			y = y+yi
			D = D + (2*(dy - dx))
		else
			D = D + 2*dy
		end
	end
end

-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
local function V_DrawLineHigh(v, x_0, y_0, x_1, y_1, color, thickness)
	local dx = x_1-x_0
	local dy = y_1-y_0
	local xi = 1
	if dx < 0 then
		xi = -1
		dx = -dx
	end
	local D = 2*dx - dy
	local x = x_0

	for y = y_0, y_1 do
		v.drawFill(x - thickness/2, y, thickness, 1, color)
		if D > 0 then
			x = x+xi
			D = D + (2*(dx - dy))
		else
			D = D + 2*dx
		end
	end
end

local function V_DrawLine(v, x_0, y_0, x_1, y_1, color, thickness)
	if abs(y_1 - y_0) < abs(x_1 - x_0) then
		if x_0 > x_1 then
			V_DrawLineLow(v, x_1, y_1, x_0, y_0, color, thickness)
		else
			V_DrawLineLow(v, x_0, y_0, x_1, y_1, color, thickness)
		end
	else
		if y_0 > y_1 then
			V_DrawLineHigh(v, x_1, y_1, x_0, y_0, color, thickness)
		else
			V_DrawLineHigh(v, x_0, y_0, x_1, y_1, color, thickness)
		end
	end
end

--https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
--https://stackoverflow.com/questions/27755514/circle-with-thickness-drawing-algorithm (M Oehm)
local function V_DrawLine_x(v, x_1, x_2, y, color)
	v.drawFill(x_1, y, x_2-x_1, 1, color)
end

local function V_DrawLine_y(v, x, y_1, y_2, color)
	v.drawFill(x, y_1, 1, y_2-y_1, color)
end

local function V_DrawThickCircle(v, x_center, y_center, inner, outer, color)
	local x_o = outer
	local x_i = inner
	local y = 0
	local erro = 1 - x_o
	local erri = 1 - x_i

	local bandaid = 3*(outer-inner)/4
	v.drawFill(x_center - 5*x_o/7, y_center - 5*x_o/7, bandaid, bandaid, color)

	while (x_o >= y) do
		V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center + y, color)
		V_DrawLine_y(v, x_center + y, y_center + x_i, y_center + x_o, color)
		V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center + y, color)
		V_DrawLine_y(v, x_center - y, y_center + x_i, y_center + x_o, color)
		V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center - y, color)
		V_DrawLine_y(v, x_center - y, y_center - x_o, y_center - x_i, color)
		V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center - y, color)
		V_DrawLine_y(v, x_center + y, y_center - x_o, y_center - x_i, color)

		y = $+1

		if erro < 0 then
			erro = $+2*y+1
		else
			x_o = $-1
			erro = $+2*(y-x_o+1)
		end

		if (y > inner) then
			x_i = y
		else
			if erri < 0 then
				erri = $+2*y+1
			else
				x_i = $-1
				erri = $+2*(y-x_i+1)
			end
		end
	end
end

local function V_DrawThickPartCircle(v, x_center, y_center, inner, outer, color, corner1, corner2, corner3, corner4)
	local x_o = outer
	local x_i = inner
	local y = 0
	local erro = 1 - x_o
	local erri = 1 - x_i


	if corner2 then
		local bandaid = 3*(outer-inner)/4
		v.drawFill(x_center - 5*x_o/7, y_center - 5*x_o/7, bandaid, bandaid, color)
	end

	while (x_o >= y) do
		if corner1 then
			V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center + y, color)
			V_DrawLine_y(v, x_center + y, y_center + x_i, y_center + x_o, color)
		end
		if corner2 then
			V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center + y, color)
			V_DrawLine_y(v, x_center - y, y_center + x_i, y_center + x_o, color)
		end
		if corner3 then
			V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center - y, color)
			V_DrawLine_y(v, x_center - y, y_center - x_o, y_center - x_i, color)
		end
		if corner4 then
			V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center - y, color)
			V_DrawLine_y(v, x_center + y, y_center - x_o, y_center - x_i, color)
		end

		y = $+1

		if erro < 0 then
			erro = $+2*y+1
		else
			x_o = $-1
			erro = $+2*(y-x_o+1)
		end

		if (y > inner) then
			x_i = y
		else
			if erri < 0 then
				erri = $+2*y+1
			else
				x_i = $-1
				erri = $+2*(y-x_i+1)
			end
		end
	end
end

local function V_DrawThickPartCircleRecolor(v, x_center, y_center, inner, outer, color1, color2, color3, color4)
	local x_o = outer
	local x_i = inner
	local y = 0
	local erro = 1 - x_o
	local erri = 1 - x_i

	local bandaid = 3*(outer-inner)/4
	v.drawFill(x_center - 5*x_o/7, y_center - 5*x_o/7, bandaid, bandaid, color2)

	while (x_o >= y) do
		V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center + y, color1)
		V_DrawLine_y(v, x_center + y, y_center + x_i, y_center + x_o, color1)
		V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center + y, color2)
		V_DrawLine_y(v, x_center - y, y_center + x_i, y_center + x_o, color2)
		V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center - y, color3)
		V_DrawLine_y(v, x_center - y, y_center - x_o, y_center - x_i, color3)
		V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center - y, color4)
		V_DrawLine_y(v, x_center + y, y_center - x_o, y_center - x_i, color4)

		y = $+1

		if erro < 0 then
			erro = $+2*y+1
		else
			x_o = $-1
			erro = $+2*(y-x_o+1)
		end

		if (y > inner) then
			x_i = y
		else
			if erri < 0 then
				erri = $+2*y+1
			else
				x_i = $-1
				erri = $+2*(y-x_i+1)
			end
		end
	end
end

local function V_DrawPolygonFill(v, x_center, y_center, points, color)
	-- Determine the minimum and maximum x-coordinates and y-coordinates
	local ymin, ymax = INT32_MAX, -INT32_MAX
	for i = 1, #points do
		local y = points[i].y
		ymin = min(ymin, y)
		ymax = max(ymax, y)
	end

	-- Iterate over each scanline
	for y = ymin, ymax do
		local intersections = {}

		-- Find the intersection points of the scanline with the polygon edges
		for i = 1, #points do
			local p_1, p_2 = points[i], points[(i % #points) + 1]
			local x_1, y_1 = p_1.x, p_1.y
			local x_2, y_2 = p_2.x, p_2.y

			if (y_1 <= y and y < y_2) or (y_2 <= y and y < y_1) then
				local x = x_1 + (x_2 - x_1) * (y - y_1) / (y_2 - y_1)
				table.insert(intersections, x)
			end
		end

		-- Sort the intersection points
		table.sort(intersections)

		-- Fill the regions between consecutive intersection points
		for i = 1, #intersections, 2 do
			local x_1, x_2 = intersections[i], intersections[i + 1]
			if x_1 and x_2 then
				v.drawFill(x_center+x_1, y_center+y, x_2 - x_1, 1, color)
			end
		end
	end
end

local ANG4 = ANG1 * 4

local function V_RotateOffsetPolygon(points, angle, offset)
	local point_data = {}
	for i = 1, #points do
		point_data[i] = {x = FixedInt(points[i].x*cos(angle)-points[i].y*sin(angle)) + offset,
						 y = FixedInt(points[i].y*cos(angle)+points[i].x*sin(angle)) + offset}
	end
	return point_data
end

// Before it was just normal function, but I guess I won't avoid polygon drawing anyway :V
local function V_DrawCricleArcs(v, x_center, y_center, inner, outer, alpha, beta, color)
	local points = {}
	local offset = 1000
	local outern = outer+2
	local innern = inner-2
	local angledif = beta - alpha

	for angle = 0, angledif, ANG1 do
		table.insert(points, {x = outern*cos(angle) / FRACUNIT, y = outern*sin(angle) / FRACUNIT})
	end
		table.insert(points, {x = outern*cos(angledif) / FRACUNIT, y = outern*sin(angledif) / FRACUNIT})

	for angle = angledif, 0, -ANG1 do
		table.insert(points, {x = innern*cos(angle) / FRACUNIT, y = innern*sin(angle) / FRACUNIT})
	end
		table.insert(points, {x = innern*cos(0) / FRACUNIT, y = innern*sin(0) / FRACUNIT})

	V_DrawPolygonFill(v, x_center - offset, y_center - offset, V_RotateOffsetPolygon(points, alpha, offset), color)
end

local function Math_FakeSquare(num)
    if num <= 0 then return 1 end
	if num < 2 then
		return num
	end

	local shift = 2
	while ((num >> shift) ~= 0) do
		shift = $+2
	end

	local result = 0
	while (shift >= 0) do
		result = result << 1
		local large_cand = result + 1
		if ((large_cand * large_cand) <= (num >> shift)) then
			result = large_cand
		end
		shift = $-2
	end

	return result
end

local frac_half = FRACUNIT/2

local function V_DrawCircle(v, x_center, y_center, radius, color)
	local x
	local rad_2 = radius*radius

	for y = -radius, radius, 1 do
		x = Math_FakeSquare(((rad_2 - y*y) << FRACBITS + frac_half) >> FRACBITS)
		v.drawFill(x_center - x, y_center+y, x * 2, 1, color)
	end
end

//
// BASE TBS LIBRARY COPY
//

local function T_ScrollTable(table, index)
	if index < 1 then
		index = #table + index
	end

	local new_index = ((index - 1) % #table) + 1

	return new_index, table[new_index]
end

local function Math_Clamp(x, min_x, max_x)
    return min(max(x, min_x), max_x)
end

//
// SHARED VARIABLES
//


local queue = {}
local enable_rad = false
local window_scale = 0
local window_width = 0
local window_height = 0

local real_offset_x = 0
local real_offset_y = 0
local offset_x = 0
local offset_y = 0

local contorller_change_delay = 0
local controller_type = 0 -- (0 == keyboard), (1 == mouse), (2 == controller),

local mouse_x = 0
local mouse_y = 0
local mouse_timer = 0

local axis_horizontal = 0
local axis_vertical = 0

local selected = 0

local window_relative_radius = 0

//
// ACTUAL DRAWING FUNCTION
//

local WIDENESS = 32
local radius = 0
local force_radius = 0
local force_width = 0
local max_radius = 80
local pause_grow = 48
local pause_draw = 14
local each_item = 12

local items = {}

local function V_DrawRadialMenu(v, radius, offsetx, offsety, width)

	// Base coordinates
	local base_x = 160 + offsetx
	local base_y = 100 + offsety

	// Half-width
	local halfwidth = width/2

	// Background circle
	local inner = max(radius - width, 0)
	local inner_circle_radius = max(inner-5, 0)

	if #items > 2 or (selected == 0 and #items == 2) then
		V_DrawThickCircle(v, base_x, base_y, inner, radius, 159)
	elseif #items < 2 then
		V_DrawCircle(v, base_x, base_y, radius, #items and 156 or 159)
	else
		local color1 = (selected == 1) and 156 or 159
		local color2 = (selected == 2) and 156 or 159
		V_DrawThickPartCircleRecolor(v, base_x, base_y, inner, radius, color2, color1, color1, color2)
	end

	// Projection of window coordinates for radial menu's logic
	window_scale = v.dupx()
	window_width = v.width()
	window_height = v.height()
	window_relative_radius = radius * window_scale

	// Window relative coordinates
	local offset_window_x = offsetx * window_scale
	local offset_window_y = offsety * window_scale

	// Cache
	local mouse_p = v.cachePatch('STCFN030POINTER')

	// Pre-calculations before loop
	local item_distance = (radius-halfwidth)
	local angle_split = (ANG1/#items)*360
	local half_split = angle_split >> 1

	local prev_item = T_ScrollTable(items, selected-1)

	if radius > pause_draw then
		// Each item drawer
		if #items == 1 then
			local patch = v.cachePatch(items[1].patch)
			if radius > pause_grow and (items[1].description or items[1].name) then
				v.drawString(base_x, base_y - 14, items[1].name or '', 0, 'center')
				v.drawString(base_x, base_y + 2, items[1].description or '', 0, 'thin-center')

				v.draw(base_x - (patch.width >> 1), base_y - 30 - (patch.height >> 1), patch)
			else
				v.draw(base_x - (patch.width >> 1), base_y - (patch.height >> 1), patch, 0)
			end
		else
			local selected_item = items[selected]

			if selected_item and (#items > 6 or (radius > pause_grow and #items > 1))
			and (selected_item.description or selected_item.name) then
				V_DrawCircle(v, base_x, base_y, inner_circle_radius, 159|V_30TRANS)

				if enable_rad then
					v.drawString(base_x, base_y - 14, selected_item.name or '', 0, 'center')
					v.drawString(base_x, base_y + 2, selected_item.description or '', 0, 'thin-center')

					local patch = v.cachePatch(selected_item.patch)
					v.draw(base_x - (patch.width >> 1), base_y - 30 - (patch.height >> 1), patch)
				end
			end

			if selected > 0 and #items > 2 then
				local angle = angle_split * selected
				V_DrawCricleArcs(v, base_x, base_y, inner, radius, angle-half_split, angle+half_split, 156)
			end

			for i = 1, #items do
				local angle = angle_split*i
				local item = items[i]
				local x = (item_distance*cos(angle)) / FRACUNIT
				local y = (item_distance*sin(angle)) / FRACUNIT

				local x_0 = (inner*cos(angle+half_split)) / FRACUNIT
				local x_1 = (radius*cos(angle+half_split)) / FRACUNIT
				local y_0 = (inner*sin(angle+half_split)) / FRACUNIT
				local y_1 = (radius*sin(angle+half_split)) / FRACUNIT

				if selected > 0 and i == prev_item or i == selected then
					V_DrawLine(v, base_x+x_0, base_y+y_0, base_x+x_1, base_y+y_1, 72, 2)
				else
					V_DrawLine(v, base_x+x_0, base_y+y_0, base_x+x_1, base_y+y_1, 0, 2)
				end

				local patch = v.cachePatch(item.patch)

				if item.drawer then
					item.drawer(base_x + x, base_y + y, i, selected)
				else
					v.draw(base_x + x - (patch.width >> 1), base_y + y - (patch.height >> 1), patch, 0,
					v.getColormap(TC_DEFAULT, 0, i == selected and 'SelectedItem' or nil))
				end
			end
		end
	end

	//
	//	Pointers
	//

	if enable_rad then
		if controller_type == 1 then
			v.drawScaled((FRACUNIT * (mouse_x+offset_window_x)),
				(FRACUNIT * (mouse_y+offset_window_y)),
				(FRACUNIT / window_scale) << 3,
				mouse_p, V_NOSCALESTART)
		end

		if controller_type == 2 then
			local mouse_p = v.cachePatch('mouse_pointer')
			local pointer_x = (FRACUNIT * ((window_width/2) + offset_window_x + (window_relative_radius*axis_horizontal)/JOYAXISRANGE))
			local pointer_y = (FRACUNIT * ((window_height/2) + offset_window_y - (window_relative_radius*axis_vertical)/JOYAXISRANGE))

			v.drawScaled(pointer_x,
						pointer_y,
						(FRACUNIT / window_scale) << 3,
						mouse_p, V_NOSCALESTART)
		end
	end

	Debuglib.insertFunction(V_DrawRadialMenu, 'V_DrawRadialMenu')
end

//
// GAMEPLAY LOGIC
//

local press = 0
local FM_DISABLE = 1
local FM_PLAYERONLY = 2

local function Rad_Insert(patch, func, name, description, drawer, flags, args)
	table.insert(items, {patch = patch, func = func, drawer = drawer, name = name, description = description, flags = flags or 0, args = args})
end

local function Rad_Summon_RadianMenu(inserts, selected, x_offset, y_offset, custom_radius)
	if not (inserts and not enable_rad) then return end
	enable_rad = true
	selected = tonumber(selected or 0)
	offset_x = tonumber(x_offset or 0)
	offset_y = tonumber(y_offset or 0)
	force_radius = tonumber(custom_radius or 0)

	items = {}
	for i = 1, #inserts do
		local item = inserts[i]
		Rad_Insert(item.patch, item.func, item.name, item.description, item.drawer, item.flags, item.args)
	end
end

local function Rad_Summon_RadianSubMenu(inserts, selected, x_offset, y_offset, custom_radius)
	if not (inserts and enable_rad) then return end
	selected = tonumber(selected or 0)
	offset_x = tonumber(x_offset or 0)
	offset_y = tonumber(y_offset or 0)
	force_radius = tonumber(custom_radius or 0)

	items = {}
	for i = 1, #inserts do
		local item = inserts[i]
		Rad_Insert(item.patch, item.func, item.name, item.description, item.drawer, item.flags, item.args)
	end
end

local function Rad_Toggle(toggle)
	if toggle and not items then return end
	enable_rad = toggle
end

local function Rad_Disable()
	enable_rad = false
	press = 0
end

addHook("KeyDown", function(keyevent)
	if not enable_rad then return end
	if keyevent.name == "escape" then
		Rad_Disable()
	end

	local STRAFELEFT, ALT_STRAFELEFT		= input.gameControlToKeyNum(GC_STRAFELEFT)
	local TURNLEFT, ALT_TURNLEFT 			= input.gameControlToKeyNum(GC_TURNLEFT)
	local WEAPONPREV, ALT_WEAPONPREV 		= input.gameControlToKeyNum(GC_WEAPONPREV)
	local STRAFERIGHT, ALT_STRAFERIGHT		= input.gameControlToKeyNum(GC_STRAFERIGHT)
	local TURNRIGHT, ALT_TURNRIGHT			= input.gameControlToKeyNum(GC_TURNRIGHT)
	local WEAPONNEXT, ALT_WEAPONNEXT		= input.gameControlToKeyNum(GC_WEAPONNEXT)

	local JUMP, ALT_JUMP					= input.gameControlToKeyNum(GC_JUMP)

	if controller_type == 0 or not contorller_change_delay then
		if keyevent.num == STRAFELEFT
		or keyevent.num == TURNLEFT
		or keyevent.num == WEAPONPREV
		or keyevent.num == ALT_STRAFELEFT
		or keyevent.num == ALT_TURNLEFT
		or keyevent.num == ALT_WEAPONPREV then
			press = 1
			controller_type = 0
			return true
		end

		if keyevent.num == STRAFERIGHT
		or keyevent.num == TURNRIGHT
		or keyevent.num == WEAPONNEXT
		or keyevent.num == ALT_STRAFERIGHT
		or keyevent.num == ALT_TURNRIGHT
		or keyevent.num == ALT_WEAPONNEXT then
			press = 2
			controller_type = 0
			return true
		end
	end

	// Where player only interaction is expected only.
	if items[selected] and (items[selected].flags & FM_PLAYERONLY) then
		return
	end

	if (keyevent.name == "enter"
	or keyevent.num == JUMP
	or keyevent.num == ALT_JUMP
	or keyevent.name == "joy10"
	or mouse.buttons & MB_BUTTON1)
	and not keyevent.repeated then
		press = 3
		return true
	end

	press = 0
	return true
end)

addHook("PlayerThink", function(p)
	p.rings = Debuglib.insertEditableNumber(p.rings, "player rings", nil, 1, 9999, 0)
	p.score = Debuglib.insertEditableNumber(p.score, "player score", nil, 1000, 99999999, 0)

	if not (enable_rad and items) then return end
	if items[selected]
	and items[selected].func
	and (items[selected].flags & FM_PLAYERONLY)
	and (p.cmd.buttons & BT_JUMP or p.cmd.buttons & BT_ATTACK) then
		items[selected].func(selected, items[selected], p)
	end
end)

addHook("ThinkFrame", function()
	if not enable_rad then return end
	if not items then
		Rad_Disable()
		radius = 0
		return
	end

	if contorller_change_delay then
		contorller_change_delay = $-1
	end

	//
	//	Keyboard
	//

	if press == 1 then
		selected = T_ScrollTable(items, selected-1)
		press = 0

		contorller_change_delay = TICRATE
	end

	if press == 2 then
		selected = T_ScrollTable(items, selected+1)
		press = 0

		contorller_change_delay = TICRATE
	end

	if press == 3 and not (items[selected].flags & FM_PLAYERONLY) then
		if items[selected].func then
			items[selected].func(selected, items[selected])
		end

		press = 0
		if items[selected].flags & FM_DISABLE then
			Rad_Disable()
		end
	end

	//
	//	Mouse
	//

	local center_x = window_width/2
	local center_y = window_height/2
	local mouse_a = mouse

	if controller_type == 1 or not contorller_change_delay then
		if mouse_a and (mouse_a.dx or mouse_a.dy) then
			if controller_type != 1 then
				controller_type = 1

				mouse_x = center_x
				mouse_y = center_y

			end

			mouse_x = mouse_x + mouse_a.dx*10
			mouse_y = mouse_y + mouse_a.dy*10
			local angle = R_PointToAngle2(center_x << FRACBITS, center_y << FRACBITS, mouse_x << FRACBITS, mouse_y << FRACBITS)
			local sine = abs(window_relative_radius*sin(angle)) >> FRACBITS
			local cose = abs(window_relative_radius*cos(angle)) >> FRACBITS

			mouse_x = Math_Clamp(mouse_x, center_x - cose, center_x + cose)
			mouse_y = Math_Clamp(mouse_y, center_y - sine, center_y + sine)
			mouse_timer = TICRATE

			contorller_change_delay = TICRATE
		elseif (mouse_x != center_x or mouse_y != center_y) then
			if mouse_timer then
				mouse_timer = $-1
			else
				mouse_x = ease.outsine(FRACUNIT >> 5, mouse_x, center_x)
				mouse_y = ease.outsine(FRACUNIT >> 5, mouse_y, center_y)
			end
		end
	end

	//
	//	Controller
	//

	if controller_type == 2 or not contorller_change_delay then
		axis_horizontal = input.joyAxis(JA_TURN)
		axis_vertical = input.joyAxis(JA_LOOK)

		if axis_horizontal
		or axis_vertical then
			controller_type = 2

			contorller_change_delay = TICRATE
		end
	end

	//
	//	Wheel handling of both Controller/Mouse
	//

	if controller_type > 0 then
		local dist = controller_type == 1 and
		R_PointToDist2(0, 0, mouse_x, mouse_y) or
		R_PointToDist2(0, 0, axis_horizontal, axis_vertical)

		local angle = AngleFixed(controller_type == 1 and
		R_PointToAngle2(center_x << FRACBITS, center_y << FRACBITS, mouse_x << FRACBITS, mouse_y << FRACBITS) or
		R_PointToAngle2(0, axis_vertical << FRACBITS, axis_horizontal << FRACBITS, 0))

		print(angle/FRACUNIT)

		if dist and dist > 5 then
			local angle_split = (360 << FRACBITS)/#items
			local localsel = FixedDiv(angle - angle_split / 2, angle_split) >> FRACBITS + 1
			selected = T_ScrollTable(items, localsel)
		else
			selected = 0
		end
	end

	press = 0
	--print(selected)
end)

//
// HUD Hook
//

local function V_RadicalMenuDrawer(v)
	if enable_rad then
		if radius < max_radius then
			radius = ease.outsine(FRACUNIT >> 3, radius, force_radius or max(pause_grow, each_item*#items))
		end
	else
		if radius > 0 then
			radius = ease.outsine(FRACUNIT >> 3, radius, 0)
		else
			radius = 0
		end
	end

	if real_offset_x != offset_x or real_offset_y != offset_y then
		real_offset_x = ease.outsine(FRACUNIT >> 3, real_offset_x, offset_x)
		real_offset_y = ease.outsine(FRACUNIT >> 3, real_offset_y, offset_y)
	end

	if radius then
		V_DrawRadialMenu(v, radius, real_offset_x, real_offset_y, force_width or WIDENESS)
	end

	Debuglib.insertFunction(V_RadicalMenuDrawer, 'V_RadicalMenuDrawer')
end

addHook("HUD", V_RadicalMenuDrawer, "game")
addHook("HUD", V_RadicalMenuDrawer, "title")
addHook("HUD", V_RadicalMenuDrawer, "intermission")

//
// Globals
//

rawset(_G, "FM_DISABLE", FM_DISABLE)
rawset(_G, "FM_PLAYERONLY", FM_PLAYERONLY)
rawset(_G, "Rad_Insert", Rad_Insert)
rawset(_G, "Rad_Disable", Rad_Disable)

// These functions are essentially same, only difference between them is check whenever menu is enabled or not
// While might seem silly, but it is to avoid overwriting. In future, this might have even bigger meaning once queue is implemented
rawset(_G, "Rad_Summon_RadianMenu", Rad_Summon_RadianMenu)
rawset(_G, "Rad_Summon_RadianSubMenu", Rad_Summon_RadianSubMenu)

