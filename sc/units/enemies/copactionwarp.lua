local level = Global.level_data.level_id
if level == "chill" then 

--NOTHING

else

function getNode(id)
    for name, script in pairs(managers.mission:scripts()) do
        if script:element(id) then
            return script:element(id)
        end
    end
end

function executeNode(id)
    local node = getNode(id)
    if node then
        node._values.trigger_times = 2
    else
        io.write("NODE DOES NOT EXIST")
    end
end

local old_CopActionWarp = CopActionWarp.init
function CopActionWarp:init(action_desc, common_data)
	old_CopActionWarp(self, action_desc, common_data)
	if Global.game_settings.level_id == "pbr2" then
		executeNode(101020)
		executeNode(101021)
	end
end

end