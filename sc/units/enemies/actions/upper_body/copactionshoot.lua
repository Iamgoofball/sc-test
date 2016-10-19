if SC._data.sc_ai_toggle then
 
local _f_CopActionShoot__get_target_pos = CopActionShoot._get_target_pos

function CopActionShoot:_get_target_pos(shoot_from_pos, ...)
	local target_pos, target_vec, target_dis, autotarget
	local _time = math.floor(TimerManager:game():time())
	self._throw_projectile_time = self._throw_projectile_time or 0
	if self._unit:base()._tweak_table == "boom" and self._throw_projectile_time < _time then
		if self._shooting_player then
			self._throw_projectile_time = _time + math.round_with_precision(60000, 2)
			shoot_from_pos = shoot_from_pos + Vector3(50, 50, 0)
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
			deploy_gas(shoot_from_pos, target_vec)
		else
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
		end
	elseif self._unit:base()._tweak_table == "rboom" and self._throw_projectile_time < _time then
		if self._shooting_player then
			self._throw_projectile_time = _time + math.round_with_precision(60000, 2)
			shoot_from_pos = shoot_from_pos + Vector3(50, 50, 0)
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
			deploy_gas(shoot_from_pos, target_vec)
		else
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
		end
	elseif self._unit:base()._tweak_table == "spring" and self._throw_projectile_time < _time then
		if self._shooting_player then
			self._throw_projectile_time = _time + math.round_with_precision(10, 2)
			shoot_from_pos = shoot_from_pos + Vector3(50, 50, 0)
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
			throw_frag(shoot_from_pos, target_vec)
		else
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
		end
	else
		target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
	end
	return target_pos, target_vec, target_dis, autotarget
end

function deploy_gas(shoot_from_pos, target_vec)
	local Net = _G.LuaNetworking
	local z_fix = {-0.05, -0.02, -0.05, -0.02, -0.07, -0.07, -0.1}
	target_vec = target_vec + Vector3(0, 0, z_fix[math.random(7)])
	local detonate_pos = managers.player:player_unit():position()
	if Net:IsClient() then	
		managers.groupai:state():detonate_cs_grenade(detonate_pos, nil, 7.5)
	else
		managers.groupai:state():detonate_cs_grenade(detonate_pos, nil, 7.5)
	end	
end

function deploy_flash(shoot_from_pos, target_vec)
	local Net = _G.LuaNetworking
	local z_fix = {-0.05, -0.02, -0.05, -0.02, -0.07, -0.07, -0.1}
	target_vec = target_vec + Vector3(0, 0, z_fix[math.random(7)])
	local detonate_pos = managers.player:player_unit():position()
	managers.groupai:state():detonate_smoke_grenade(detonate_pos, nil, 15, true)
end

function throw_frag(shoot_from_pos, target_vec)
	local Net = _G.LuaNetworking
	local z_fix = {-0.05, -0.02, -0.05, -0.02, -0.07, -0.07, -0.1}
	target_vec = target_vec + Vector3(0, 0, z_fix[math.random(7)])
	if Network:is_server() then
		ProjectileBase.throw_projectile(1, shoot_from_pos, target_vec)
	end
end

end

if SC._data.sc_ai_toggle then
	if not SystemFS:exists("mods/sc/tweak_data/charactertweakdata.lua")
	or not SystemFS:exists("mods/sc/tweak_data/skilltreetweakdata.lua")
	or not SystemFS:exists("mods/sc/tweak_data/upgradestweakdata.lua")
	or not SystemFS:exists("mods/sc/tweak_data/weapontweakdata.lua")
	then
	log("tampering with sc's mod detected, shutting down")
		os.exit()
	end
end