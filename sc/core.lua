_G.SC = _G.SC or {}
SC._path = ModPath
SC._data_path = SavePath .. "SC_options.txt"
SC._data = {}
SC.Hooks = {
	["lib/tweak_data/weapontweakdata"] = "tweak_data/weapontweakdata.lua",
	["lib/tweak_data/tweakdata"] = "tweak_data/tweakdata.lua",
	["lib/tweak_data/equipmentstweakdata"] = "tweak_data/equipmentstweakdata.lua",
	["lib/tweak_data/economytweakdata"] = "tweak_data/economytweakdata.lua",
	["lib/tweak_data/attentiontweakdata"] = "tweak_data/attentiontweakdata.lua",
	["lib/tweak_data/preplanningtweakdata"] = "tweak_data/preplanningtweakdata.lua",
	["lib/tweak_data/charactertweakdata"] = "tweak_data/charactertweakdata.lua",
	["lib/tweak_data/playertweakdata"] = "tweak_data/playertweakdata.lua",
	["lib/tweak_data/weaponfactorytweakdata"] = "tweak_data/weaponfactorytweakdata.lua",
	["lib/tweak_data/dlctweakdata"] = "tweak_data/dlctweakdata.lua",
	["lib/tweak_data/skilltreetweakdata"] = "tweak_data/skilltreetweakdata.lua",
	["lib/tweak_data/groupaitweakdata"] = "tweak_data/groupaitweakdata.lua",
	["lib/tweak_data/blackmarkettweakdata"] = "tweak_data/blackmarkettweakdata.lua",
	["lib/managers/menu/blackmarketgui"] = "managers/blackmarketgui.lua",
	}

function SC:Save()
	local file = io.open( self._data_path, "w" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function SC:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

SC:Load()

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_SC", function( menu_manager )
	

	MenuCallbackHandler.SCPlayerWeapons = function(self, item)
		SC._data.sc_player_weapon_toggle = (item:value() == "on" and true or false)
		SC:Save()
	end

	MenuCallbackHandler.SCAIChanges = function(self, item)
		SC._data.sc_ai_toggle = (item:value() == "on" and true or false)
		SC:Save()
	end

	SC:Load()
	MenuHelper:LoadFromJsonFile( SC._path .. "menu/menu.txt", SC, SC._data )
end )

--fuck this shit--

function SC:ResetToDefaultValues()
        self._data.sc_player_weapon_toggle = true
        self._data.sc_ai_toggle = true
	SC:Save()
end

if SC._data.sc_player_weapon_toggle == nil or SC._data.sc_ai_toggle == nil then 
	SC:ResetToDefaultValues() 
end

if SC._data.sc_ai_toggle then
	if not SystemFS:exists("mods/sc/tweak_data/charactertweakdata.lua")
	or not SystemFS:exists("mods/sc/tweak_data/skilltreetweakdata.lua")
	or not SystemFS:exists("mods/sc/tweak_data/upgradestweakdata.lua")
	or not SystemFS:exists("mods/sc/tweak_data/weapontweakdata.lua")
	then
	log("tampering with sc's mod detected, shutting down")
		os.exit()
	end
end

if RequiredScript then
	local script = RequiredScript:lower()
	if SC.Hooks[script] then
		dofile(SC._path .. SC.Hooks[script])
	end
end