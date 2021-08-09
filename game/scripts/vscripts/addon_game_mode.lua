-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_ultimate_linger_baby.vpcf", context)

  PrecacheResource("particle", "particles/econ/taunts/snapfire/snapfire_taunt_bubble.vpcf", context)
  PrecacheResource("particle", "particles/snapfire_taunt_bubble_invulnerable.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_shotgun_button_mash.vpcf", context)
  PrecacheResource("particle","particles/snapfire_taunt_bubble_invulnerable_cookie_shotgun.vpcf", context)

  --lil shredder
  PrecacheResource("particle", "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_machine_gun.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_tracking_fragment.vpcf", context)
  PrecacheResource("particle", "particles/antimage_manavoid_explode_b_b_ti_5_gold_fragment.vpcf", context)
  PrecacheResource("particle", "particles/ogre_magi_arcana_ignite_burn_immolation.vpcf", context)

  --mortimer's kisses
  PrecacheResource("particle", "particles/nevermore_shadowraze_custom.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf", context)
  PrecacheResource("particle", "particles/status_fx/status_effect_earthshaker_arcana.vpcf", context)
  PrecacheResource("particle", "particles/items_fx/black_king_bar_avatar_b.vpcf", context)
  PrecacheResource("particle", "particles/snapfire_lizard_blobs_arced_green.vpcf", context)
  PrecacheResource("particle", "particles/snapfire_lizard_blobs_arced_ice.vpcf", context)
  PrecacheResource("particle", "particles/snapfire_lizard_blobs_arced_red.vpcf", context)
  PrecacheResource("particle", "particles/snapfire_lizard_blobs_arced_purple.vpcf", context)
  PrecacheResource("particle", "particles/snapfire_lizard_blobs_arced_black.vpcf", context)
  PrecacheResource("particle", "particles/bloodseeker_bloodritual_ring_custom.vpcf", context)

  --twenty one
  PrecacheResource("particle", "particles/alchemist_smooth_criminal_unstable_concoction_explosion_custom.vpcf", context)

  --cookie party
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_molotov_2.vpcf", context)
  PrecacheResource("particle", "particles/mirana_spell_arrow_custom_2.vpcf", context)
  PrecacheResource("particle", "particles/luna_glaive_crescent_moon_custom.vpcf", context)

  --cookie bullets
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_cm.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_bb.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_bb_perpendicular.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_bb_perp_down.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_cm_perpendicular.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_cm_perp_down.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_ogre_perpendicular.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_ogre_perp_down.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_jugg_perpendicular.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_jugg_perp_down.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_axe_perp_down.vpcf", context)
  PrecacheResource("particle", "particles/hero_snapfire_cookie_projectile_linear_lina_perp_down.vpcf", context)
  
  
  

  -- skins
  PrecacheResource("particle", "particles/status_fx/status_effect_teleport_image.vpcf", context)
  

  --testing
  PrecacheResource("particle","particles/snapfire_lizard_blobs_arced_green.vpcf", context) -- spawns np tree surround
  PrecacheResource("particle","particles/snapfire_lizard_blobs_arced_ice.vpcf", context)
  PrecacheResource("particle","particles/snapfire_lizard_blobs_arced_custom.vpcf", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheResource("model", "models/heroes/undying/undying_tower.vmdl", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)
  --PrecacheModel("models/props_gameplay/treasure_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest002.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)
  PrecacheResource("soundfile", "sounds/weapons/hero/snapfire/shotgun_fire.vsnd", context)
  PrecacheResource("soundfile", "sounds/weapons/hero/snapfire/shotgun_load.vsnd", context)
  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)


end



-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
  
end