function CopLogicIdle._surrender(data, amount, aggressor_unit)
	local params = {effect = amount, aggressor_unit = aggressor_unit}
	data.brain:set_objective({type = "surrender", params = params})
	data.unit:sound():say("s01x", true)
end