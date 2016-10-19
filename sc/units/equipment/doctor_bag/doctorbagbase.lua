function DoctorBagBase:take(unit)
	if self._empty then
		return
	end
	if self._damage_reduction_upgrade then
		managers.player:activate_temporary_upgrade("temporary", "first_aid_damage_reduction")
	end
	local taken = self:_take(unit)
	if taken > 0 then
		managers.groupai:state():warn_about_stuff("medibag")
		unit:sound():play("pickup_ammo")
		managers.network:session():send_to_peers_synched("sync_doctor_bag_taken", self._unit, taken)
		managers.mission:call_global_event("player_refill_doctorbag")
	end
	if 0 >= self._amount then
		self:_set_empty()
	else
		self:_set_visual_stage()
	end
	return taken > 0
end