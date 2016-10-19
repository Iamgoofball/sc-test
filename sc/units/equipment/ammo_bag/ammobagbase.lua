function AmmoBagBase:take_ammo(unit)
	if self._empty then
		return false, false
	end
	local taken = self:_take_ammo(unit)
	if taken > 0 then
		unit:sound():play("pickup_ammo")
		managers.groupai:state():warn_about_stuff("ammo")
		if 0 >= self._ammo_amount then
			taken = 1
		end
		managers.network:session():send_to_peers_synched("sync_ammo_bag_ammo_taken", self._unit, taken)
	end
	if 0 >= self._ammo_amount then
		self:_set_empty()
	else
		self:_set_visual_stage()
	end
	local bullet_storm = false
	if self._bullet_storm_level and 0 < self._bullet_storm_level then
		bullet_storm = self._BULLET_STORM[self._bullet_storm_level] * taken
	end
	return taken > 0, bullet_storm
end