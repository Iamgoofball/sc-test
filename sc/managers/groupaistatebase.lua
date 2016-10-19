local old_init = GroupAIStateBase._init
function GroupAIStateBase:_init()
	old_init()
	warn_about_stuff()
end

function GroupAIStateBase:warn_about_stuff(warn_type)
	log("SAYING " .. warn_type)
	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		if warn_type == "saw" then
			u_data.unit:sound():say("ch4", true)
		elseif warn_type == "sentry_gun" then
			u_data.unit:sound():say("ch2", true)
		elseif warn_type == "medibag" then
			u_data.unit:sound():say("med", true)
		elseif warn_type == "trip" then
			u_data.unit:sound():say("ch1", true)
		elseif warn_type == "ecm" then
			u_data.unit:sound():say("ch3", true)
		elseif warn_type == "hostages" then
			u_data.unit:sound():say("civ", true)
		elseif warn_type == "ammo" then
			u_data.unit:sound():say("amm", true)
		elseif warn_type == "reloading" then
			u_data.unit:sound():say("rrl", true)
		elseif warn_type == "hostage_delay" then
			local voice_lines = {"p01", "p02"}
			local voice_meme = math.random(1,2)
			u_data.unit:sound():say(voice_lines[voice_meme], true)
		elseif warn_type == "hostage_nodelay" then
			u_data.unit:sound():say("p03", true)
		end
	end
end

if SC._data.sc_ai_toggle then

function GroupAIStateBase:has_room_for_police_hostage()
	local nr_hostages_allowed = 4
	for u_key, u_data in pairs(self._player_criminals) do
		if u_data.unit:base().is_local_player then
			if managers.player:has_category_upgrade("player", "intimidate_enemies") then
				if Global.game_settings.single_player then
					nr_hostages_allowed = 4
				else
					nr_hostages_allowed = 4
				end
			end
		elseif u_data.unit:base():upgrade_value("player", "intimidate_enemies") then
			if Global.game_settings.single_player then
				nr_hostages_allowed = 4
			else
				nr_hostages_allowed = 4
			end
		end
	end
	return nr_hostages_allowed > self._police_hostage_headcount + table.size(self._converted_police)
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