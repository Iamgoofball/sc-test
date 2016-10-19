if SC._data.sc_player_weapon_toggle then

	function BlackMarketManager:fire_rate_multiplier(name, category, sub_category, silencer, detection_risk, current_state, blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local tweak_data = tweak_data.weapon
		local weapon = tweak_data[name]
		local factory = tweak_data.factory[factory_id]
		local default_blueprint = factory.default_blueprint
			
		local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(factory_id, blueprint or default_blueprint)
		local multiplier = 1
		local rof_multiplier = 1
		
		for part_id, stats in pairs(custom_stats) do
			if stats.rof_mult then
				rof_multiplier = rof_multiplier * stats.rof_mult
			end
		end
		local multiplier = managers.player:upgrade_value(category, "fire_rate_multiplier", 1)
		if sub_category then
			multiplier = multiplier * managers.player:upgrade_value(sub_category, "fire_rate_multiplier", 1)
		end
		multiplier = multiplier * rof_multiplier * managers.player:upgrade_value(name, "fire_rate_multiplier", 1)
		return multiplier
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