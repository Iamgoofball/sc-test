if SC._data.sc_player_weapon_toggle then

local sc_cstd = CustomSafehouseTweakData.init
function CustomSafehouseTweakData:init(tweak_data)
	sc_cstd(self, tweak_data)

	self.prices.weapon_mod = 1

end

end