if SC._data.sc_ai_toggle then

function SpoocLogicAttack._is_last_standing_criminal(focus_enemy)
    local all_criminals = managers.groupai:state():all_char_criminals()
    for u_key, u_data in pairs(all_criminals) do
        if not u_data.status and focus_enemy.u_key ~= u_key then
            return
        end
    end
    return false
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