local function select_wep(selected, item, p)
	local arg = item.args[1]

	if arg == 1 then
		p.currentweapon = WEP_AUTO
	elseif arg == 2 then
		p.currentweapon = WEP_BOUNCE
	elseif arg == 3 then
		p.currentweapon = WEP_SCATTER
	elseif arg == 4 then
		p.currentweapon = WEP_GRENADE
	elseif arg == 5 then
		p.currentweapon = WEP_EXPLODE
	elseif arg == 6 then
		p.currentweapon = WEP_RAIL
	else
		p.currentweapon = 0
	end
end

local function insert_weps(p)
	local array = {}

	if p.powers[pw_infinityring] then
		table.insert(array, {patch = 'INFNIND', func = select_wep, name = 'INFINITY RING', description = 'Even Better Ring', flags = FM_DISABLE|FM_PLAYERONLY, args = {0}})
	else
		table.insert(array, {patch = 'RINGIND', func = select_wep, name = 'RED RING', description = 'Normal Ring', flags = FM_DISABLE|FM_PLAYERONLY, args = {0}})
	end

	if p.ringweapons & RW_AUTO then
		table.insert(array, {patch = 'AUTOIND', func = select_wep, name = 'AUTO RING', description = 'Machine-like Ring', flags = FM_DISABLE|FM_PLAYERONLY, args = {1}})
	end

	if p.ringweapons & RW_BOUNCE then
		table.insert(array, {patch = 'BNCEIND', func = select_wep, name = 'BOUNCE RING', description = 'Bouncy Ring', flags = FM_DISABLE|FM_PLAYERONLY, args = {2}})
	end

	if p.ringweapons & RW_SCATTER then
		table.insert(array, {patch = 'SCATIND', func = select_wep, name = 'SCATTER RING', description = 'It is Scattering!', flags = FM_DISABLE|FM_PLAYERONLY, args = {3}})
	end

	if p.ringweapons & RW_GRENADE then
		table.insert(array, {patch = 'GRENIND', func = select_wep, name = 'GRENADE RING', description = 'Best Ring', flags = FM_DISABLE|FM_PLAYERONLY, args = {4}})
	end

	if p.ringweapons & RW_EXPLODE then
		table.insert(array, {patch = 'BOMBIND', func = select_wep, name = 'BOMB RING', description = 'Explosive Ring', flags = FM_DISABLE|FM_PLAYERONLY, args = {5}})
	end

	if p.ringweapons & RW_RAIL then
		table.insert(array, {patch = 'RAILIND', func = select_wep, name = 'RAIL RING', description = 'Sniper Rifle', flags = FM_DISABLE|FM_PLAYERONLY, args = {6}})
	end

	return array
end

addHook("KeyDown", function(keyevent)
	if gamestate == GS_LEVEL
	and G_RingSlingerGametype()
	and keyevent.name == 'q'
	and not keyevent.repeated then
		Rad_Summon_RadianMenu(insert_weps(consoleplayer), 0, 80, 0, 80)
		return true
	end
end)

addHook("KeyUp", function(keyevent)
	if gamestate == GS_LEVEL
	and G_RingSlingerGametype()
	and keyevent.name == 'q' then
		Rad_Disable()
		return true
	end
end)

local function get_rings(selected)
	consoleplayer.rings = 999
end

local function get_score(selected)
	consoleplayer.score = 9999999
end

COM_AddCommand("weapon_wheel", function(p)
	Rad_Summon_RadianMenu(insert_weps(p), 0, 80, 0, 80)
end)

COM_AddCommand("spawn_wheel", function(p)
	Rad_Summon_RadianMenu(
	{{patch = 'NRNG1', func = get_rings, flags = FM_DISABLE},
	{patch = 'NBON1', func = get_score, flags = FM_DISABLE}})
end)


local mobjslist = setmetatable({}, {
	__newindex = function(array, index, value)
		freeslot(index)
		return mobjinfo[_G[index]]
	end,
	__index = function(array, index)
		return mobjinfo[_G[index]]
	end
})

mobjslist["MT_RINGSNEW"] = {
	spawnhealth = 8,
}

print(mobjinfo[MT_RINGSNEW].spawnhealth)

