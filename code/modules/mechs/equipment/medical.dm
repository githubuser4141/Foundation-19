/obj/item/mech_equipment/sleeper
	name = "\improper exosuit sleeper"
	desc = "An exosuit-mounted sleeper designed to mantain patients stabilized on their way to medical facilities, this model has an  advanced chemical synthesizer."
	icon_state = "mech_sleeper"
	restricted_hardpoints = list(HARDPOINT_BACK)
	restricted_software = list(MECH_SOFTWARE_MEDICAL)
	equipment_delay = 30 //don't spam it on people pls
	active_power_use = 0 //Usage doesn't really require power. We don't want people stuck inside
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	passive_power_use = 0 //Raised to 1.5 KW when patient is present.
	var/obj/machinery/sleeper/mounted/sleeper = null

/obj/item/mech_equipment/sleeper/Initialize()
	. = ..()
	sleeper = new /obj/machinery/sleeper/mounted(src)
	sleeper.forceMove(src)

/obj/item/mech_equipment/sleeper/Destroy()
	sleeper.go_out() //If for any reason you weren't outside already.
	QDEL_NULL(sleeper)
	. = ..()

/obj/item/mech_equipment/sleeper/uninstalled()
	. = ..()
	sleeper.go_out()

/obj/item/mech_equipment/sleeper/attack_self(var/mob/user)
	. = ..()
	if(.)
		sleeper.ui_interact(user)

/obj/item/mech_equipment/sleeper/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/reagent_containers/glass))
		sleeper.attackby(I, user)
	else return ..()

/obj/item/mech_equipment/sleeper/afterattack(var/atom/target, var/mob/living/user, var/inrange, var/params)
	. = ..()
	if(.)
		if(ishuman(target) && !sleeper.occupant)
			owner.visible_message(SPAN_NOTICE("\The [src] is lowered down to load [target]"))
			sleeper.go_in(target, user)
		else to_chat(user, SPAN_WARNING("You cannot load that in!"))

/obj/item/mech_equipment/sleeper/get_hardpoint_maptext()
	if(sleeper && sleeper.occupant)
		return "[sleeper.occupant]"

/obj/machinery/sleeper/mounted
	name = "\improper mounted sleeper"
	density = FALSE
	anchored = FALSE
	idle_power_usage = 0
	active_power_usage = 0 //It'd be hard to handle, so for now all power is consumed by mech sleeper object
	synth_modifier = 0
	stasis_power = 0
	interact_offline = TRUE
	stat_immune = NOPOWER
	base_chemicals = list(
	"Inaprovaline" = /datum/reagent/medicine/inaprovaline,
	"Paracetamol" = /datum/reagent/medicine/painkiller/paracetamol,
	"Dylovene" = /datum/reagent/medicine/dylovene,
	"Dexalin" = /datum/reagent/medicine/dexalin,
	"Kelotane" = /datum/reagent/medicine/kelotane,
	"Bicaridine" = /datum/reagent/medicine/bicaridine,
	"Hyronalin" = /datum/reagent/medicine/hyronalin
	)

/obj/machinery/sleeper/mounted/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.mech_state)
	. = ..()

/obj/machinery/sleeper/mounted/nano_host()
	var/obj/item/mech_equipment/sleeper/S = loc
	if(istype(S))
		return S.owner
	return null

/obj/machinery/sleeper/mounted/go_in()
	..()
	var/obj/item/mech_equipment/sleeper/S = loc
	if(istype(S) && occupant)
		S.passive_power_use = 1.5 KILOWATTS

/obj/machinery/sleeper/mounted/go_out()
	..()
	var/obj/item/mech_equipment/sleeper/S = loc
	if(istype(S))
		S.passive_power_use = 0 //No passive power drain when the sleeper is empty. Set to 1.5 KW when patient is inside.

//You cannot modify these, it'd probably end with something in nullspace. In any case basic meds are plenty for an ambulance
/obj/machinery/sleeper/mounted/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/reagent_containers/glass))
		if(!user.unEquip(I, src))
			return

		if(beaker)
			beaker.forceMove(get_turf(src))
			user.visible_message("<span class='notice'>\The [user] removes \the [beaker] from \the [src].</span>", "<span class='notice'>You remove \the [beaker] from \the [src].</span>")
		beaker = I
		user.visible_message("<span class='notice'>\The [user] adds \a [I] to \the [src].</span>", "<span class='notice'>You add \a [I] to \the [src].</span>")

#define MEDIGEL_SALVE 1
#define MEDIGEL_SCAN  2

/obj/item/mech_equipment/mender
	name = "exosuit medigel spray-scanner matrix"
	desc = "An exosuit-mounted matrix of medical gel nozzles and radiation emitters designed to treat wounds before transporting patient, with an integrated health scanning suite for field analysis of injuries."
	icon_state = "mech_mender"
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_MEDICAL)
	active_power_use = 0 //Usage doesn't really require power. It's per wound
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	var/list/apply_sounds = list('sounds/effects/spray.ogg', 'sounds/effects/spray2.ogg', 'sounds/effects/spray3.ogg')
	var/mode = MEDIGEL_SALVE
	var/obj/item/device/scanner/health/scanner = null

/obj/item/mech_equipment/mender/attack_self(mob/user)
	.=..()
	if (!.)
		return
	if (mode == MEDIGEL_SALVE)
		return
	mode = mode == MEDIGEL_SALVE ? MEDIGEL_SCAN : MEDIGEL_SALVE
	to_chat(user, SPAN_NOTICE("You set \the [src] to [mode == MEDIGEL_SALVE ? "dispense medigel" : "scan for injuries"]."))
	update_icon()

/obj/item/mech_equipment/mender/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if(.)
		if (istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

			if(affecting.is_bandaged() && affecting.is_disinfected() && affecting.is_salved())
				to_chat(user, SPAN_WARNING("The wounds on \the [H]'s [affecting.name] have already been treated."))
			else
				if(!LAZYLEN(affecting.wounds))
					return
				owner.visible_message(SPAN_NOTICE("\The [owner] extends \the [src] towards \the [H]'s [affecting.name]."))
				var/large_wound = FALSE
				for (var/datum/wound/W as anything in affecting.wounds)
					if (W.bandaged && W.disinfected && W.salved)
						continue
					var/delay = (W.damage / 4) * user.skill_delay_mult(SKILL_MEDICAL, 0.8)
					owner.setClickCooldown(delay)
					if(!do_after(user, delay, target))
						break

					var/obj/item/cell/C = owner.get_cell()
					if(istype(C))
						C.use(0.01 KILOWATTS) //Does cost power, so not a freebie, specially with large amount of wounds
					else
						return //Early out, cell is gone

					if (W.current_stage <= W.max_bleeding_stage)
						owner.visible_message(SPAN_NOTICE("\The [owner] covers \a [W.desc] on \the [H]'s [affecting.name] with large globs of medigel."))
						large_wound = TRUE
					else if (W.damage_type == BRUISE)
						owner.visible_message(SPAN_NOTICE("\The [owner] sprays \a [W.desc] on \the [H]'s [affecting.name] with a fine layer of medigel."))
					else
						owner.visible_message(SPAN_NOTICE("\The [owner] drizzles some medigel over \a [W.desc] on \the [H]'s [affecting.name]."))
					playsound(owner, pick(apply_sounds), 20)
					W.bandage()
					W.disinfect()
					W.salve()
					if (H.stat == UNCONSCIOUS && prob(25))
						to_chat(H, SPAN_NOTICE(SPAN_BOLD("... [pick("feels better", "hurts less")] ...")))
				if(large_wound)
					owner.visible_message(SPAN_NOTICE("\The [src]'s UV matrix glows faintly as it cures the medigel."))
					playsound(owner, 'sounds/items/Welder2.ogg', 10)
				affecting.update_damages()
				H.update_bandages(TRUE)
	else if(mode == MEDIGEL_SCAN)
		if (istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			medical_scan_action(H, user, scanner)

/obj/item/device/scanner/health/mech
	name = "exosuit health analyzer"

#undef MEDIGEL_SALVE
#undef MEDIGEL_SCAN

/obj/item/mech_equipment/crisis_drone
	name = "crisis dronebay"
	desc = "A small shoulder-mounted dronebay containing a rapid response drone capable of moderately stabilizing a patient near the exosuit."
	icon_state = "med_droid"
	origin_tech = list(TECH_PHORON = 2, TECH_MAGNET = 3, TECH_BIO = 3, TECH_DATA = 3)
	active_power_use = 0
	passive_power_use = 3000
	restricted_hardpoints = list(HARDPOINT_LEFT_SHOULDER)
	restricted_software = list(MECH_SOFTWARE_MEDICAL)
	equipment_delay = 3

	var/beam_state = "medbeam"

	var/enabled = FALSE

	var/max_distance = 3

	var/damcap = 30
	var/heal_dead = FALSE	// Does this device heal the dead?

	var/brute_heal = 2	// Amount of bruteloss healed.
	var/burn_heal = 2	// Amount of fireloss healed.
	var/tox_heal = 2		// Amount of toxloss healed.
	var/oxy_heal = 4		// Amount of oxyloss healed.
	var/rad_heal = 0		// Amount of radiation healed.
	var/clone_heal = 0	// Amount of cloneloss healed.
	var/hal_heal = 0.8	// Amount of halloss healed.
	var/bone_heal = 0	// Percent chance it will heal a broken bone. this does not mean 'make it not instantly re-break'.

	var/mob/living/carbon/Target = null
	var/datum/beam/MyBeam = null

/obj/item/mech_equipment/crisis_drone/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/mech_equipment/crisis_drone/uninstalled()
	. = ..()
	shut_down()
	STOP_PROCESSING(SSprocessing, src)

/obj/item/mech_equipment/crisis_drone/Process()	// Will continually try to find the nearest person above the threshold that is a valid target, and try to heal them.
	if(!(owner.get_cell()?.check_charge(active_power_use * CELLRATE)))
		shut_down()

	var/mob/living/carbon/Targ = Target
	var/TargDamage = 0

	if(!valid_target(Target))
		Target = null
		passive_power_use = 3000

	if(Target)
		TargDamage = (Targ.getOxyLoss() + Targ.getFireLoss() + Targ.getBruteLoss() + Targ.getToxLoss())

	for(var/mob/living/carbon/Potential in view(max_distance, owner))
		if(!valid_target(Potential))
			continue

		var/tallydamage = 0
		if(oxy_heal)
			tallydamage += Potential.getOxyLoss()
		if(burn_heal)
			tallydamage += Potential.getFireLoss()
		if(brute_heal)
			tallydamage += Potential.getBruteLoss()
		if(tox_heal)
			tallydamage += Potential.getToxLoss()
		if(hal_heal)
			tallydamage += Potential.getHalLoss()
		if(clone_heal)
			tallydamage += Potential.getCloneLoss()

		if(tallydamage > TargDamage)
			Target = Potential

	if(MyBeam && !valid_target(MyBeam.target))
		QDEL_NULL(MyBeam)

	if(Target)
		if(MyBeam && MyBeam.target != Target)
			QDEL_NULL(MyBeam)

		if(valid_target(Target))
			if(!MyBeam)
				MyBeam = owner.Beam(Target,icon='icons/effects/beam.dmi',icon_state=beam_state,time=3 SECONDS,maxdistance=max_distance,beam_type = /obj/effect/ebeam,beam_sleep_time=2)
			heal_target(Target)


/obj/item/mech_equipment/crisis_drone/proc/valid_target(var/mob/living/carbon/L)
	. = TRUE

	if(!L || !istype(L))
		return FALSE

	if(get_dist(L, owner) > max_distance)
		return FALSE

	if(!(L in view(max_distance, owner)))
		return FALSE

	if(!unique_patient_checks(L))
		return FALSE

	if(L.stat == DEAD && !heal_dead)
		return FALSE

	var/tallydamage = 0
	if(oxy_heal)
		tallydamage += L.getOxyLoss()
	if(burn_heal)
		tallydamage += L.getFireLoss()
	if(brute_heal)
		tallydamage += L.getBruteLoss()
	if(tox_heal)
		tallydamage += L.getToxLoss()
	if(hal_heal)
		tallydamage += L.getHalLoss()
	if(clone_heal)
		tallydamage += L.getCloneLoss()

	if(tallydamage < damcap)
		return FALSE

/obj/item/mech_equipment/crisis_drone/proc/shut_down()
	if(enabled)
		owner.visible_message("<span class='notice'>\The [owner]'s [src] buzzes as its drone returns to port.</span>")
		toggle_drone()
	if(!isnull(Target))
		Target = null
	if(MyBeam)
		QDEL_NULL(MyBeam)

/obj/item/mech_equipment/crisis_drone/proc/unique_patient_checks(var/mob/living/carbon/L)	// Anything special for subtypes. Does it only work on Robots? Fleshies? A species?
	. = TRUE

/obj/item/mech_equipment/crisis_drone/proc/heal_target(var/mob/living/carbon/L)	// We've done all our special checks, just get to fixing damage.
	passive_power_use = 50000
	if(istype(L))
		L.adjustBruteLoss(brute_heal * -1)
		L.adjustFireLoss(burn_heal * -1)
		L.adjustToxLoss(tox_heal * -1)
		L.adjustOxyLoss(oxy_heal * -1)
		L.adjustCloneLoss(clone_heal * -1)
		L.adjustHalLoss(hal_heal * -1)
		L.add_chemical_effect(CE_PAINKILLER, 50) //Pain is bad :(

		if(ishuman(L) && bone_heal)
			var/mob/living/carbon/human/H = L

			if(H.bad_external_organs.len)
				for(var/obj/item/organ/external/E in H.bad_external_organs)
					if(prob(bone_heal))
						E.status &= ~ORGAN_BROKEN

/obj/item/mech_equipment/crisis_drone/proc/toggle_drone(var/mob/user)
	enabled = !enabled
	if(enabled)
		to_chat(user, SPAN_NOTICE("Medical drone activated."))
		icon_state = "med_droid_a"
		START_PROCESSING(SSprocessing, src)
	else
		to_chat(user, SPAN_NOTICE("Medical drone deactivated."))
		icon_state = "med_droid"
		STOP_PROCESSING(SSprocessing, src)
	update_icon()
	owner.update_icon()

/obj/item/mech_equipment/crisis_drone/attack_self(var/mob/user)
	. = ..()
	if(.)
		toggle_drone(user)
