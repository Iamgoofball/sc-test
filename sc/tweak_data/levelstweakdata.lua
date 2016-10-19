local old_ltd_init = LevelsTweakData.init
function LevelsTweakData:init()
   	old_ltd_init(self, tweak_data)
	if Global.load_level == true and not PackageManager:loaded("levels/narratives/elephant/mad/world_sounds") then
		PackageManager:load("levels/narratives/elephant/mad/world_sounds")
	end
	if Global.load_level == true and not PackageManager:loaded("packages/job_nail") then
   		PackageManager:load("packages/job_nail")
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