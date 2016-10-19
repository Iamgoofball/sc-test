function CopLogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj
	if new_att_obj then
		new_reaction = new_reaction or new_att_obj.settings.reaction
		new_att_obj.reaction = new_reaction
		local new_crim_rec = new_att_obj.criminal_record
		local is_same_obj, contact_chatter_time_ok
		if old_att_obj then
			if old_att_obj.u_key == new_att_obj.u_key then
				is_same_obj = true
				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 2
				if new_att_obj.stare_expire_t and data.t > new_att_obj.stare_expire_t then
					if new_att_obj.settings.pause then
						new_att_obj.stare_expire_t = nil
						new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())
					end
				elseif new_att_obj.pause_expire_t and data.t > new_att_obj.pause_expire_t then
					if not new_att_obj.settings.attract_chance or math.random() < new_att_obj.settings.attract_chance then
						new_att_obj.pause_expire_t = nil
						new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
					else
						debug_pause_unit(data.unit, "skipping attraction")
						new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())
					end
				end
			else
				if old_att_obj.criminal_record then
					managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
				end
				if new_crim_rec then
					managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
				end
				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
			end
		else
			if new_crim_rec then
				managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
			end
			contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
		end
		if not is_same_obj then
			if new_att_obj.settings.duration then
				new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
				new_att_obj.pause_expire_t = nil
			end
			new_att_obj.acquire_t = data.t
		end
		if new_reaction >= AIAttentionObject.REACT_SHOOT and new_att_obj.verified and contact_chatter_time_ok and (data.unit:anim_data().idle or data.unit:anim_data().move) and new_att_obj.is_person and data.char_tweak.chatter.contact then
			if data.unit:base()._tweak_table == "medic" then
				data.unit:sound():say("contact", true)
			else
				local voice_lines = {"c01", "i03", "g90", "t01", "att"}
				local voice_meme = math.random(1,5)
				data.unit:sound():say(voice_lines[voice_meme], true)
			end
		end
	elseif old_att_obj and old_att_obj.criminal_record then
		managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
		data.unit:sound():say("m01", true)
	end
end

function CopLogicBase.on_suppressed_state(data)
	if data.is_suppressed and data.objective then
		local allow_trans, interrupt = CopLogicBase.is_obstructed(data, data.objective, nil, nil)
		if interrupt then
			data.objective_failed_clbk(data.unit, data.objective)
		end
		data.unit:sound():say("lk3a", true)
	end
end