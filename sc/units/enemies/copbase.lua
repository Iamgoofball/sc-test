Month = os.date("%m")
function CopBase:_chk_spawn_gear()
	if self._tweak_table == "rboom" then
		local align_obj_name = Idstring("Head")
		local align_obj = self._unit:get_object(align_obj_name)
		self._headwear_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_boom_helmet/ene_acc_boom_helmet"), Vector3(), Rotation())
		self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
	end
	if Global.level_data.level_id == "pines" or Global.level_data.level_id == "roberts" or Global.level_data.level_id == "cane" or Month == "12" then
   		PackageManager:load("packages/narr_pines")
		if self._tweak_table == "spooc" or self._tweak_table == "taser" or self._tweak_table == "tank" or self._tweak_table == "shield" or self._tweak_table == "sniper" or self._tweak_table == "phalanx_minion" or self._tweak_table == "boom" or self._tweak_table == "rboom" or self._tweak_table == "medic" then
			local align_obj_name = Idstring("Head")
			local align_obj = self._unit:get_object(align_obj_name)
			self._headwear_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_spook_santa_hat/ene_acc_spook_santa_hat"), Vector3(), Rotation())
			self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
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