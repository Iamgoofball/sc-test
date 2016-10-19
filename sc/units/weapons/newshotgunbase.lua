if SC._data.sc_player_weapon_toggle then

local old_update_stats_values = NewShotgunBase._update_stats_values

	function NewShotgunBase:_update_stats_values()
		NewShotgunBase.super._update_stats_values(self)
		self:setup_default()
		if self._ammo_data then
			if self._ammo_data.rays ~= nil then
				self._rays = self._ammo_data.rays
			end
			if self._ammo_data.damage_near ~= nil then
				self._damage_near = self._ammo_data.damage_near
			end
			if self._ammo_data.damage_near_mul ~= nil then
				self._damage_near = self._damage_near + self._ammo_data.damage_near_mul
			end
			if self._ammo_data.damage_far ~= nil then
				self._damage_far = self._ammo_data.damage_far
			end
			if self._ammo_data.damage_far_mul ~= nil then
				self._damage_far = self._damage_far + self._ammo_data.damage_far_mul
			end
			self._range = self._damage_far
		end
		local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
		for part_id, stats in pairs(custom_stats) do
			if stats.damage_near_mul then
				self._damage_near = self._damage_near + stats.damage_near_mul
			end
			if stats.damage_far_mul then
				self._damage_far = self._damage_far + stats.damage_far_mul
			end
		end
		
	end

	function NewShotgunBase:reload_expire_t()
		local ammo_remaining_in_clip = self:get_ammo_remaining_in_clip()
		if self:get_ammo_remaining_in_clip() > 0 and tweak_data.weapon[self._name_id].tactical_reload == true then
			return math.min(self:get_ammo_total() - ammo_remaining_in_clip, self:get_ammo_max_per_clip() + 1 - ammo_remaining_in_clip) * self:reload_shell_expire_t()
		else
			return math.min(self:get_ammo_total() - ammo_remaining_in_clip, self:get_ammo_max_per_clip() - ammo_remaining_in_clip) * self:reload_shell_expire_t()
		end
	end
	
	function NewShotgunBase:reload_enter_expire_t()
		return self:weapon_tweak_data().timers.shotgun_reload_enter or 0.3
	end
	
	function NewShotgunBase:reload_exit_expire_t()
		return self:weapon_tweak_data().timers.shotgun_reload_exit_empty or 0.7
	end
	
	function NewShotgunBase:reload_not_empty_exit_expire_t()
		return self:weapon_tweak_data().timers.shotgun_reload_exit_not_empty or 0.3
	end
	
	function NewShotgunBase:reload_shell_expire_t()
		return self:weapon_tweak_data().timers.shotgun_reload_shell or 0.56666666
	end
	
	function NewShotgunBase:_first_shell_reload_expire_t()
		return self:reload_shell_expire_t() - (self:weapon_tweak_data().timers.shotgun_reload_first_shell_offset or 0.33)
	end
	
	function NewShotgunBase:start_reload(...)
		NewShotgunBase.super.start_reload(self, ...)
		self._started_reload_empty = self:clip_empty()
		local speed_multiplier = self:reload_speed_multiplier()
		self._next_shell_reloded_t = managers.player:player_timer():time() + self:_first_shell_reload_expire_t() / speed_multiplier
	end
	
	function NewShotgunBase:started_reload_empty()
		return self._started_reload_empty
	end
	
	function NewShotgunBase:update_reloading(t, dt, time_left)
		if t > self._next_shell_reloded_t then
			local speed_multiplier = self:reload_speed_multiplier()
			self._next_shell_reloded_t = self._next_shell_reloded_t + self:reload_shell_expire_t() / speed_multiplier
			if self:get_ammo_remaining_in_clip() > 0 and tweak_data.weapon[self._name_id].tactical_reload == true then
				self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip() + 1, self:get_ammo_remaining_in_clip() + 1))
				return true
			else
				self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + 1))
				return true
			end
		end
	end
	
	SaigaShotgun = SaigaShotgun or class(NewShotgunBase)
	function SaigaShotgun:reload_expire_t()
		return nil
	end
	
	function SaigaShotgun:reload_enter_expire_t()
		return nil
	end
	
	function SaigaShotgun:reload_exit_expire_t()
		return nil
	end
	
	function SaigaShotgun:reload_not_empty_exit_expire_t()
		return nil
	end
	
	function SaigaShotgun:update_reloading(t, dt, time_left)
	end

end