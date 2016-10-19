if not tweak_data then return end
	if SC._data.sc_ai_toggle then	
	--HE'S GOT AN RPG--
	tweak_data.projectiles.launcher_rocket.damage = 34
	tweak_data.projectiles.launcher_rocket.player_damage = 34
	tweak_data.projectiles.launcher_rocket.range = 350

	--Grenade launcher stuff--
	tweak_data.projectiles.launcher_frag.damage = 34
	tweak_data.projectiles.launcher_frag.player_damage = 34
	tweak_data.projectiles.launcher_incendiary.damage = 2
	tweak_data.projectiles.launcher_incendiary.launch_speed = 1250
	tweak_data.projectiles.launcher_incendiary.curve_pow = 0.1
	tweak_data.projectiles.launcher_incendiary.player_damage = 2
	tweak_data.projectiles.launcher_incendiary.burn_duration = 10
	tweak_data.projectiles.launcher_incendiary.fire_dot_data = {
		dot_damage = 1,
		dot_trigger_max_distance = 3000,
		dot_trigger_chance = 35,
		dot_length = 3.1,
		dot_tick_period = 0.5
	}

	--Plainsrider--
	tweak_data.projectiles.west_arrow.damage = 18.1
	tweak_data.projectiles.west_arrow.launch_speed = 10000
	tweak_data.projectiles.west_arrow_exp.damage = 30
	tweak_data.projectiles.west_arrow_exp.launch_speed = 10000
	tweak_data.projectiles.bow_poison_arrow.damage = 18.1
	tweak_data.projectiles.bow_poison_arrow.launch_speed = 10000

	--Hunter crossbow--
	tweak_data.projectiles.crossbow_arrow.damage = 18.1
	tweak_data.projectiles.crossbow_poison_arrow.damage = 18.1
	tweak_data.projectiles.crossbow_arrow_exp.damage = 30
	tweak_data.projectiles.crossbow_arrow_exp.launch_speed = 10000
	tweak_data.projectiles.crossbow_arrow.launch_speed = 10000
	tweak_data.projectiles.crossbow_poison_arrow.launch_speed = 10000

	--Arblast Heavy Crossbow--
	tweak_data.projectiles.arblast_arrow.damage = 26
	tweak_data.projectiles.arblast_arrow_exp.damage = 34
	tweak_data.projectiles.arblast_poison_arrow.damage = 26
	tweak_data.projectiles.arblast_arrow_exp.launch_speed = 10000
	tweak_data.projectiles.arblast_arrow.launch_speed = 10000
	tweak_data.projectiles.arblast_poison_arrow.launch_speed = 10000

	--Franken fish--
	tweak_data.projectiles.frankish_arrow.damage = 18.1
	tweak_data.projectiles.frankish_arrow_exp.damage = 30
	tweak_data.projectiles.frankish_poison_arrow.damage = 18.1
	tweak_data.projectiles.frankish_poison_arrow.launch_speed = 10000
	tweak_data.projectiles.frankish_arrow_exp.launch_speed = 10000
	tweak_data.projectiles.frankish_arrow.launch_speed = 10000

	--BOWMEN, FORM UP--
	tweak_data.projectiles.long_arrow.damage = 26
	tweak_data.projectiles.long_arrow_exp.damage = 34
	tweak_data.projectiles.long_poison_arrow.damage = 26
	tweak_data.projectiles.long_arrow_exp.launch_speed = 10000
	tweak_data.projectiles.long_arrow.launch_speed = 10000
	tweak_data.projectiles.long_poison_arrow.launch_speed = 10000

	--GRENADE OUT--
	tweak_data.projectiles.frag.damage = 34
	tweak_data.projectiles.frag.player_damage = 34
	tweak_data.projectiles.frag.curve_pow = 0.1
	tweak_data.projectiles.frag.range = 350

	--Dynamite--
	tweak_data.projectiles.dynamite.damage = 34
	tweak_data.projectiles.dynamite.player_damage = 34
	tweak_data.projectiles.dynamite.curve_pow = 0.1
	tweak_data.projectiles.dynamite.range = 350

	--Community Frag--
	tweak_data.projectiles.frag_com.damage = 34
	tweak_data.projectiles.frag_com.player_damage = 34
	tweak_data.projectiles.frag_com.curve_pow = 0.1
	tweak_data.projectiles.frag_com.range = 350

        --Molliest of tovs--
	tweak_data.projectiles.molotov.damage = 2
	tweak_data.projectiles.molotov.player_damage = 2
	tweak_data.projectiles.molotov.burn_duration = 10

	--Throwing Card--
	tweak_data.projectiles.wpn_prj_ace.damage = 26.5

	--Shuriken
	tweak_data.projectiles.wpn_prj_four.damage = 23.5

	--Javelin--
	tweak_data.projectiles.wpn_prj_jav.damage = 55
	tweak_data.projectiles.wpn_prj_jav.launch_speed = 1500
	tweak_data.projectiles.wpn_prj_jav.adjust_z = 30

	--Throwing axe--
	tweak_data.projectiles.wpn_prj_hur.damage = 55
	tweak_data.projectiles.wpn_prj_hur.launch_speed = 1000
	tweak_data.projectiles.wpn_prj_hur.adjust_z = 120

	tweak_data.dot_types.poison = {
		damage_class = "PoisonBulletBase",
		dot_length = 5,
		dot_damage = 1,
		hurt_animation_chance = 0.5
	}

	--Stun nades--
	tweak_data.projectiles.concussion.damage = 0
	tweak_data.projectiles.concussion.curve_pow = 0.1
	tweak_data.projectiles.concussion.range = 1500
	tweak_data.projectiles.concussion.duration = {min = 10, additional = 10}

	tweak_data.player.stances.msr.steelsight.shakers.breathing.amplitude = 0
	tweak_data.player.stances.r93.steelsight.shakers.breathing.amplitude = 0
	tweak_data.player.stances.m95.steelsight.shakers.breathing.amplitude = 0
	tweak_data.player.stances.mosin.steelsight.shakers.breathing.amplitude = 0
	tweak_data.player.stances.winchester1874.steelsight.shakers.breathing.amplitude = 0
	tweak_data.player.stances.wa2000.steelsight.shakers.breathing.amplitude = 0
	tweak_data.player.stances.model70.steelsight.shakers.breathing.amplitude = 0

	--Had to include this in here due to some BS with it being in upgradestweakdata
	tweak_data.upgrades.values.player.health_multiplier = {1.25, 1.5}
	tweak_data.upgrades.values.trip_mine.quantity = {3, 7}

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