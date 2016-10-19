if SC._data.sc_ai_toggle then

function GroupAIStateBesiege:on_objective_complete(unit, objective)
	local new_objective, so_element
	if objective.followup_objective then
		if not objective.followup_objective.trigger_on then
			new_objective = objective.followup_objective
		else
			new_objective = {
				type = "free",
				followup_objective = objective.followup_objective,
				interrupt_dis = objective.interrupt_dis,
				interrupt_health = objective.interrupt_health
			}
		end
	elseif objective.followup_SO then
		local current_SO_element = objective.followup_SO
		so_element = current_SO_element:choose_followup_SO(unit)
		new_objective = so_element and so_element:get_objective(unit)
	end
	if new_objective then
		if new_objective.nav_seg then
			local u_key = unit:key()
			local u_data = self._police[u_key]
			if u_data and u_data.assigned_area then
				self:set_enemy_assigned(self._area_data[new_objective.nav_seg], u_key)
			end
		end
	else
		local seg = unit:movement():nav_tracker():nav_segment()
		local area_data = self:get_area_from_nav_seg_id(seg)
		if self:rescue_state() and tweak_data.character[unit:base()._tweak_table].rescue_hostages then
			for u_key, u_data in pairs(managers.enemy:all_civilians()) do
				if seg == u_data.tracker:nav_segment() then
					local so_id = u_data.unit:brain():wants_rescue()
					if so_id then
						local so = self._special_objectives[so_id]
						local so_data = so.data
						local so_objective = so_data.objective
						new_objective = self.clone_objective(so_objective)
						if so_data.admin_clbk then
							so_data.admin_clbk(unit)
						end
						unit:say("bak", true)
						self:remove_special_objective(so_id)
					end
				else
				end
			end
		end
		if not new_objective and objective.type == "free" then
			new_objective = {
				type = "free",
				is_default = true,
				attitude = objective.attitude
			}
		end
		if not area_data.is_safe then
			area_data.is_safe = true
			self:_on_nav_seg_safety_status(seg, {reason = "guard", unit = unit})
		end
	end
	objective.fail_clbk = nil
	unit:brain():set_objective(new_objective)
	if objective.complete_clbk then
		objective.complete_clbk(unit)
	end
	if so_element then
		so_element:clbk_objective_administered(unit)
	end
end

function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault
	if not task_data.active then
		return
	end
	local t = self._t
	self:_assign_recon_groups_to_retire()
	local force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)
	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif t > task_data.phase_end_t or self._drama_data.zone == "high" then
			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault()
			self:_set_rescue_state(false)
			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			task_data.is_hesitating = nil
			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)
			if task_data.is_hesitating and self._t > task_data.voice_delay then
				if 0 < self._hostage_headcount then
					managers.groupai:state():warn_about_stuff("hostage_delay")
					local best_group
					for _, group in pairs(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end
					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					managers.groupai:state():warn_about_stuff("hostage_nodelay")
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif t > task_data.phase_end_t or self._drama_data.zone == "high" then
			task_data.phase = "sustain"
			task_data.phase_end_t = t + math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)
		end
	elseif task_data.phase == "sustain" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif t > task_data.phase_end_t and not self._hunt_mode then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")
		if not self._hunt_mode then
			local min_enemies_left = 7
			if enemies_left < min_enemies_left or t > task_data.phase_end_t + 350 then
				if t > task_data.phase_end_t - 8 and not task_data.said_retreat then
					if self._drama_data.amount < tweak_data.drama.assault_fade_end then
						task_data.said_retreat = true
						self:_police_announce_retreat()
					end
				elseif t > task_data.phase_end_t and self._drama_data.amount < tweak_data.drama.assault_fade_end and self:_count_criminals_engaged_force(4) <= 3 then
					end_assault = true
				end
			else
			end
			if task_data.force_end or end_assault then
				print("assault task clear")
				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end
				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task()
				return
			end
		else
		end
	end
	if self._drama_data.amount <= tweak_data.drama.low then
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			self:criminal_spotted(criminal_data.unit)
			for group_id, group in pairs(self._groups) do
				if group.objective.charge then
					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
			end
		end
	end
	local primary_target_area = task_data.target_areas[1]
	if self:is_area_safe_assault(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)
				if not nearest_dis or nearest_dis > dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end
		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end
	local nr_wanted = task_data.force - self:_count_police_force("assault")
	if task_data.phase == "anticipation" then
		nr_wanted = nr_wanted - 5
	end
	if nr_wanted > 0 and task_data.phase ~= "fade" then
		local used_event
		if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
			task_data.use_spawn_event = false
			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end
		if used_event or next(self._spawning_groups) then
		else
			local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, nil, nil, nil)
			if spawn_group then
				local grp_objective = {
					type = "assault_area",
					area = spawn_group.area,
					coarse_path = {
						{
							spawn_group.area.pos_nav_seg,
							spawn_group.area.pos
						}
					},
					attitude = "avoid",
					pose = "crouch",
					stance = "hos"
				}
				self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
			end
		end
	end
	if task_data.phase ~= "anticipation" then
		if t > task_data.use_smoke_timer then
			task_data.use_smoke = true
		end
		if self._smoke_grenade_queued and task_data.use_smoke and not self:is_smoke_grenade_active() then
			managers.groupai:state():warn_about_stuff("smoke")
			self:detonate_smoke_grenade(self._smoke_grenade_queued[1], self._smoke_grenade_queued[1], self._smoke_grenade_queued[2], self._smoke_grenade_queued[4])
			if self._smoke_grenade_queued[3] then
				self._smoke_grenade_ignore_control = true
			end
		end
	end
	self:_assign_enemy_groups_to_assault(task_data.phase)
end

function GroupAIStateBesiege:_check_spawn_phalanx()
	if self._task_data and self._task_data.assault.active and self._phalanx_center_pos and not self._phalanx_spawn_group then
		if self._task_data.assault.phase == "build" or self._task_data.assault.phase == "sustain" then
		local now = TimerManager:game():time()
		local respawn_delay = tweak_data.group_ai.phalanx.spawn_chance.respawn_delay
		if not self._phalanx_despawn_time or now >= self._phalanx_despawn_time + respawn_delay then
			local spawn_chance_start = tweak_data.group_ai.phalanx.spawn_chance.start
			self._phalanx_current_spawn_chance = self._phalanx_current_spawn_chance or spawn_chance_start
			self._phalanx_last_spawn_check = self._phalanx_last_spawn_check or now
			self._phalanx_last_chance_increase = self._phalanx_last_chance_increase or now
			local spawn_chance_increase = tweak_data.group_ai.phalanx.spawn_chance.increase
			local spawn_chance_max = tweak_data.group_ai.phalanx.spawn_chance.max
			if spawn_chance_max > self._phalanx_current_spawn_chance and spawn_chance_increase > 0 then
				local chance_increase_intervall = tweak_data.group_ai.phalanx.chance_increase_intervall
				if now >= self._phalanx_last_chance_increase + chance_increase_intervall then
					self._phalanx_last_chance_increase = now
					self._phalanx_current_spawn_chance = math.min(spawn_chance_max, self._phalanx_current_spawn_chance + spawn_chance_increase)
					print("Phalanx spawn chance increased to ", self._phalanx_current_spawn_chance)
				end
			else
			end
			if self._phalanx_current_spawn_chance > 0 then
				local check_spawn_intervall = tweak_data.group_ai.phalanx.check_spawn_intervall
				if now >= self._phalanx_last_spawn_check + check_spawn_intervall then
					self._phalanx_last_spawn_check = now
					print("Spawn chance roll...")
					if math.random() <= self._phalanx_current_spawn_chance then
						self:_spawn_phalanx()
					else
						print("Spawn chance roll failed!")
					end
				end
			end
		end
	end
	else
	end
end

end