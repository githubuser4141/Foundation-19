//Procs.

/obj/item/ammo_magazine/mecha/attack_self(mob/user)
	to_chat(user, SPAN_WARNING("It's pretty hard to extract ammo from a magazine that fits on a mech. You'll have to do it one round at a time."))
	return

/obj/item/gun/projectile/automatic/get_hardpoint_status_value()
	if(!isnull(ammo_magazine))
		return ammo_magazine.stored_ammo.len
	else
		return null

/obj/item/gun/projectile/automatic/get_hardpoint_maptext()
	if(!isnull(ammo_magazine))
		return "[ammo_magazine.stored_ammo.len]/[ammo_magazine.max_ammo]"
	else
		return 0

/obj/item/mech_equipment/mounted_system/projectile/attackby(var/obj/item/O as obj, mob/user as mob)
	var/obj/item/gun/projectile/automatic/A = holding
	if(istype(O, /obj/item/crowbar))
		A.unload_ammo(user)
		to_chat(user, SPAN_NOTICE("You remove the ammo magazine from the [src]."))
	if(istype(O, A.magazine_type))
		A.load_ammo(O, user)
		to_chat(user, SPAN_NOTICE("You load the ammo magazine into the [src]."))

/obj/item/mech_equipment/mounted_system/projectile/attack_self(var/mob/user)
	. = ..()
	if(. && holding)
		var/obj/item/gun/M = holding
		return M.switch_firemodes(user)

//Weapons below this.

/obj/item/mech_equipment/mounted_system/projectile
	name = "mech projectile weapon"
	icon_state = "mech_ballistic"
	holding_type = /obj/item/gun/projectile
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)

/obj/item/mech_equipment/mounted_system/projectile/shotgun
	name = "mounted Remmington 29x"
	icon_state = "mech_ballistic"
	holding_type = /obj/item/gun/projectile/automatic/shotgun/mech
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)

/obj/item/gun/projectile/automatic/shotgun/mech
	name = "mounted Remmington 29x"
	magazine_type = /obj/item/ammo_magazine/mech/drum
	allowed_magazines = /obj/item/ammo_magazine/mech/drum
	one_hand_penalty=0
	has_safety = FALSE
	ammo_type = /obj/item/ammo_casing/shotgun
	firemodes = list(
		list(mode_name="semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=0, burst_accuracy=null, dispersion=null),
		list(mode_name="2-round bursts", burst=2, fire_delay=null, move_delay=3,    one_hand_penalty=0, burst_accuracy=list(0,0,-0.5),       dispersion=list(0.0, 0.4)),
		)

/obj/item/mech_equipment/mounted_system/projectile/assault_rifle
	name = "mounted SR17"
	icon_state = "mech_ballistic2"
	holding_type = /obj/item/gun/projectile/automatic/assault_rifle/mech
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_WEAPONS)

/obj/item/gun/projectile/automatic/assault_rifle/mech
	name = "mounted SR17"
	magazine_type = /obj/item/ammo_magazine/mech/mil_rifle
	allowed_magazines = /obj/item/ammo_magazine/mech/mil_rifle
	one_hand_penalty=0
	has_safety = FALSE
	firemodes = list(
		list(mode_name="semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=0, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=5,    one_hand_penalty=0, burst_accuracy=list(0,-0.7,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="5-round bursts",   burst=5, fire_delay=null, move_delay=6,    one_hand_penalty=0, burst_accuracy=list(0,-0.7,-1.5,-2,-2.5), dispersion=list(0.6, 0.6, 0.6, 1.2, 1.5)),
		)

//magazines below this.

/obj/item/ammo_magazine/mech/drum // Shotgun
	name = "large 12g drum magazine"
	desc = "A large ammo drum for a mech's gun. Looks way too big for a normal gun."
	icon_state = "smg_top"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/shotgun
	matter = list(MATERIAL_STEEL = 12500)
	caliber = CALIBER_PISTOL_SMALL
	max_ammo = 56


/obj/item/ammo_magazine/mech/mil_rifle // SR17
	name = "massive 5.56x45 magazine"
	icon_state = "bullup"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = CALIBER_RIFLE_MILITARY
	matter = list(MATERIAL_STEEL = 10000)
	ammo_type = /obj/item/ammo_casing/rifle/military
	max_ammo = 100
	multiple_sprites = 1

