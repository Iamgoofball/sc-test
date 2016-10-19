local init_original = RaycastWeaponBase.init
local setup_original = RaycastWeaponBase.setup

function RaycastWeaponBase:init(...)
	init_original(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
end

function RaycastWeaponBase:setup(...)
	setup_original(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
end

if SC._data.sc_player_weapon_toggle then

	function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
		if self:ammo_max() then
			return false, 0
		end
		local multiplier_min = 1
		local multiplier_max = 1
		local ammo_min = self._ammo_data and self._ammo_data.ammo_pickup_min_mul
		local ammo_max = self._ammo_data and self._ammo_data.ammo_pickup_max_mul
		if ammo_min then
			multiplier_min = multiplier_min * self._ammo_data.ammo_pickup_min_mul
		end
		multiplier_min = multiplier_min * managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
			
		if ammo_max then
			multiplier_max = multiplier_max * self._ammo_data.ammo_pickup_max_mul
		end
		multiplier_max = multiplier_max * managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
			
		local add_amount = add_amount_override
		local picked_up = true
		if not add_amount then
			local rng_ammo = math.lerp(self._ammo_pickup[1] * multiplier_min, self._ammo_pickup[2] * multiplier_max, math.random())
			picked_up = rng_ammo > 0
			add_amount = math.max(0, math.round(rng_ammo))
		end
		add_amount = math.floor(add_amount * (ratio or 1))
		self:set_ammo_total(math.clamp(self:get_ammo_total() + add_amount, 0, self:get_ammo_max()))
		if Application:production_build() then
			managers.player:add_weapon_ammo_gain(self._name_id, add_amount)
		end
		return picked_up, add_amount
	end

	function RaycastWeaponBase:clip_full()
		if tweak_data.weapon[self._name_id].tactical_reload == true then
			return self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip() + 1
		elseif tweak_data.weapon[self._name_id].tactical_akimbo == true then
			return self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip() + 2
		else
			return self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip()
		end
	end
	
	function RaycastWeaponBase:can_reload()
		if tweak_data.weapon[self._name_id].uses_clip == true and ( (self:get_ammo_max_per_clip() == tweak_data.weapon[self._name_id].clip_capacity and self:get_ammo_remaining_in_clip() > 0 ) or self:get_ammo_remaining_in_clip() > self:get_ammo_max_per_clip() - tweak_data.weapon[self._name_id].clip_capacity) then
			return false
		elseif self:get_ammo_total() > self:get_ammo_remaining_in_clip() then
			return true
		end
	end
	
	function RaycastWeaponBase:on_reload()
		if self:get_ammo_remaining_in_clip() > 0 and tweak_data.weapon[self._name_id].tactical_reload == true then
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip() + 1))
		elseif self:get_ammo_remaining_in_clip() > 1 and tweak_data.weapon[self._name_id].tactical_akimbo == true then
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip() + 2))
		elseif self:get_ammo_remaining_in_clip() == 1 and tweak_data.weapon[self._name_id].tactical_akimbo == true then
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip() + 1))
		elseif tweak_data.weapon[self._name_id].uses_clip == true and self:get_ammo_remaining_in_clip() <= self:get_ammo_max_per_clip()  then
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + tweak_data.weapon[self._name_id].clip_capacity))
		elseif self._setup.expend_ammo then
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip()))
		else
			self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())
			self:set_ammo_total(self:get_ammo_max_per_clip())
		end
	end

	local raycast_current_damage_orig = RaycastWeaponBase._get_current_damage
	function RaycastWeaponBase:_get_current_damage(dmg_mul)
	   if self._ammo_data and (self._ammo_data.bullet_class == "InstantExplosiveBulletBase") then
 	       dmg_mul = dmg_mul / managers.player:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1)
  	   end
  	   return raycast_current_damage_orig(self, dmg_mul)
	end

end