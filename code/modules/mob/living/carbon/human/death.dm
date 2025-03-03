GLOBAL_LIST_EMPTY(dead_players_during_shift)
/mob/living/carbon/human/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, dna.species.gib_anim)

/mob/living/carbon/human/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, dna.species.dust_anim)

/mob/living/carbon/human/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/human(drop_location(), src, get_static_viruses())
	else
		new /obj/effect/gibspawner/human/bodypartless(drop_location(), src, get_static_viruses())

/mob/living/carbon/human/spawn_dust(just_ash = FALSE)
	if(just_ash)
		new /obj/effect/decal/cleanable/ash(loc)
	else
		new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return
	stop_sound_channel(CHANNEL_HEARTBEAT)
	var/obj/item/organ/internal/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(H)
		H.beat = BEAT_NONE

	. = ..()

	if(client && !suiciding && !(client in GLOB.dead_players_during_shift))
		GLOB.dead_players_during_shift += client

	if(!QDELETED(dna)) //The gibbed param is bit redundant here since dna won't exist at this point if they got deleted.
		dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
		log_message("has died (BRUTE: [src.getBruteLoss()], BURN: [src.getFireLoss()], TOX: [src.getToxLoss()], OXY: [src.getOxyLoss()], CLONE: [src.getCloneLoss()])", LOG_ATTACK)
		investigate_log("[key_name(src)] has died at [loc_name(src)].<br>\
			BRUTE: [src.getBruteLoss()] BURN: [src.getFireLoss()] TOX: [src.getToxLoss()] OXY: [src.getOxyLoss()] CLONE: [src.getCloneLoss()] STAM: [src.getStaminaLoss()]<br>\
			<b>Brain damage</b>: [src.getOrganLoss(ORGAN_SLOT_BRAIN) || "0"]<br>\
			<b>Blood volume</b>: [src.blood_volume]cl ([round((src.blood_volume / BLOOD_VOLUME_NORMAL) * 100, 0.1)]%)<br>\
			<b>Reagents</b>:<br>[reagents_readout()]<br>\
			<b>Last attacker</b>: [src.lastattacker] ([src.lastattackerckey || "none"])", INVESTIGATE_DEATHS)
	to_chat(src, span_warning("You have died. Barring complete bodyloss, you can in most cases be revived by other players. If you do not wish to be brought back, use the \"Do Not Resuscitate\" verb in the ghost tab."))

/mob/living/carbon/human/proc/reagents_readout()
	var/readout = "Blood:"
	for(var/datum/reagent/reagent in reagents?.reagent_list)
		readout += "<br>[round(reagent.volume, 0.001)] units of [reagent.name]"

	readout += "<br>Stomach:"
	var/obj/item/organ/internal/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	for(var/datum/reagent/bile in belly?.reagents?.reagent_list)
		if(!belly.food_reagents[bile.type])
			readout += "<br>[round(bile.volume, 0.001)] units of [bile.name]"

	return readout

/mob/living/carbon/human/proc/makeSkeleton()
	ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)
	set_species(/datum/species/skeleton)
	return TRUE

/mob/living/carbon/proc/Drain()
	become_husk(CHANGELING_DRAIN)
	ADD_TRAIT(src, TRAIT_BADDNA, CHANGELING_DRAIN)
	blood_volume = 0
	return TRUE
