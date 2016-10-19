function CopLogicAttack._upd_combat_movement(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover
	local enemy_visible = focus_enemy.verified
	local enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < 2
	local enemy_visible_softer = focus_enemy.verified_t and t - focus_enemy.verified_t < 15
	local alert_soft = data.is_suppressed
	local action_taken = data.logic.action_taken(data, my_data)
	local want_to_take_cover = my_data.want_to_take_cover
	action_taken = action_taken or CopLogicAttack._upd_pose(data, my_data)
	local move_to_cover, want_flank_cover
	if my_data.cover_test_step ~= 1 and not enemy_visible_softer and (action_taken or want_to_take_cover or not in_cover) then
		my_data.cover_test_step = 1
	end
	if my_data.stay_out_time and (enemy_visible_soft or not my_data.at_cover_shoot_pos or action_taken or want_to_take_cover) then
		my_data.stay_out_time = nil
	elseif my_data.attitude == "engage" and not my_data.stay_out_time and not enemy_visible_soft and my_data.at_cover_shoot_pos and not action_taken and not want_to_take_cover then
		my_data.stay_out_time = t + 7
	end
	if action_taken then
	elseif want_to_take_cover then
		move_to_cover = true
	elseif not enemy_visible_soft then
		if data.tactics and data.tactics.charge and data.objective and data.objective.grp_objective and data.objective.grp_objective.charge and (not my_data.charge_path_failed_t or data.t - my_data.charge_path_failed_t > 6) then
			if my_data.charge_path then
				local path = my_data.charge_path
				my_data.charge_path = nil
				action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path)
			elseif not my_data.charge_path_search_id and data.attention_obj.nav_tracker then
				my_data.charge_pos = CopLogicTravel._get_pos_on_wall(data.attention_obj.nav_tracker:field_position(), my_data.weapon_range.optimal, 45, nil)
				if my_data.charge_pos then
					my_data.charge_path_search_id = "charge" .. tostring(data.key)
					log("COPVOICE: PUSHING")
					unit:sound():say("pus", true) -- CHAAAAARGE line
					unit:brain():search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
				else
					debug_pause_unit(data.unit, "failed to find charge_pos", data.unit)
					my_data.charge_path_failed_t = TimerManager:game():time()
				end
			end
		elseif in_cover then
			if 2 >= my_data.cover_test_step then
				local height
				if in_cover[4] then
					height = 150
				else
					height = 80
				end
				local my_tracker = unit:movement():nav_tracker()
				local shoot_from_pos = CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, focus_enemy.m_head_pos, height)
				if shoot_from_pos then
					local path = {
						my_tracker:position(),
						shoot_from_pos
					}
					action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, math.random() < 0.5 and "run" or "walk")
				else
					my_data.cover_test_step = my_data.cover_test_step + 1
				end
			elseif not enemy_visible_softer and math.random() < 0.05 then
				move_to_cover = true
				want_flank_cover = true
			end
		elseif my_data.walking_to_cover_shoot_pos then
		elseif my_data.at_cover_shoot_pos then
			if t > my_data.stay_out_time then
				move_to_cover = true
			end
		else
			move_to_cover = true
		end
	end
	if not my_data.processing_cover_path and not my_data.cover_path and not my_data.charge_path_search_id and not action_taken and best_cover and (not in_cover or best_cover[1] ~= in_cover[1]) and (not my_data.cover_path_failed_t or data.t - my_data.cover_path_failed_t > 5) then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		local search_id = tostring(unit:key()) .. "cover"
		if data.unit:brain():search_for_path_to_cover(search_id, best_cover[1], best_cover[5]) then
			my_data.cover_path_search_id = search_id
			my_data.processing_cover_path = best_cover
		end
	end
	if not action_taken and move_to_cover and my_data.cover_path then
		log("COPVOICE: MOVE COVER")
		unit:sound():say("mov", true) -- move cover line
		action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	end
	if want_flank_cover then
		if not my_data.flank_cover then
			local sign = math.random() < 0.5 and -1 or 1
			local step = 30
			my_data.flank_cover = {
				step = step,
				angle = step * sign,
				sign = sign
			}
		end
		log("COPVOICE: FLANKING")
		unit:sound():say("t01", true) -- flanking line
	else
		my_data.flank_cover = nil
	end
	if data.important and not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and CopLogicAttack._can_move(data) and data.attention_obj.verified and (not in_cover or not in_cover[4]) then
		if data.is_suppressed and data.t - data.unit:character_damage():last_suppression_t() < 0.7 then
			action_taken = CopLogicBase.chk_start_action_dodge(data, "scared")
		end
		if not action_taken and focus_enemy.is_person and focus_enemy.dis < 2000 and (data.group and 1 < data.group.size or math.random() < 0.5) then
			local dodge
			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()
				if not e_movement_state:_is_reloading() and not e_movement_state:_interacting() and not e_movement_state:is_equipping() then
					dodge = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()
				if (e_anim_data.move or e_anim_data.idle) and not e_anim_data.reload then
					dodge = true
				end
			end
			if dodge and focus_enemy.aimed_at then
				action_taken = CopLogicBase.chk_start_action_dodge(data, "preemptive")
			end
		end
	end
	if not action_taken and want_to_take_cover and not best_cover then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, false)
	end
	action_taken = action_taken or CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
end

function CopLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	if action_type == "walk" then
		my_data.advancing = nil
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		if my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = data.t
			end
			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		if data.important and action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			data.logic._upd_aim(data, my_data)
		end
		local helpcall_chance = math.random(1,10)
		if helpcall_chance == 1 then
			data.unit:sound():say("hlp", true)
		else
			data.unit:sound():say("x01a_any_3p", true)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()
		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	end
end