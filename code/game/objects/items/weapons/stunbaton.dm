/obj/item/weapon/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	var/charges = 10
	var/status = 0
	var/mob/foundmob = "" //Used in throwing proc.

	origin_tech = "combat=2"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</b>"
		return (FIRELOSS)

/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"

/obj/item/weapon/melee/baton/attack_self(mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "\red You grab the [src] on the wrong side."
		user.Weaken(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		user << "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>"
		playsound(src.loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>\The [src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/M as mob, mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'>You accidentally hit yourself with the [src]!</span>"
		user.Weaken(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return

	var/mob/living/carbon/human/H = M
	if(isrobot(M))
		..()
		return

	if(user.a_intent == "hurt")
		if(!..()) return
		//H.apply_effect(5, WEAKEN, 0)
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Beat [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Beaten by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[user.name] ([user.ckey]) beat [H.name] ([H.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		playsound(src.loc, "swing_hit", 50, 1, -1)
	else if(!status)
		H.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return

	if(status)
		H.apply_effect(10, STUN, 0)
		H.apply_effect(10, WEAKEN, 0)
		H.apply_effect(10, STUTTER, 0)
		user.lastattacked = M
		H.lastattacker = user
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(50)
		else
			charges--
		H.visible_message("<span class='danger'>[M] has been stunned with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[key_name(user)] stunned [key_name(H)] with [src.name] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>")

		playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		if(charges < 1)
			status = 0
			update_icon()

	add_fingerprint(user)

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom)
	. = ..()
	if (prob(50))
		if(istype(hit_atom, /mob/living))
			var/mob/living/carbon/human/H = hit_atom
			if(status)
				H.apply_effect(10, STUN, 0)
				H.apply_effect(10, WEAKEN, 0)
				H.apply_effect(10, STUTTER, 0)
				charges--

				for(var/mob/M in player_list) if(M.key == src.fingerprintslast)
					foundmob = M
					break

				H.visible_message("<span class='danger'>[src], thrown by [foundmob.name], strikes [H] and stuns them!</span>")

				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
				msg_admin_attack("Flying [src.name], last touched by ([src.fingerprintslast]) stunned [key_name(H)] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>" )

/obj/item/weapon/melee/baton/emp_act(severity)
	switch(severity)
		if(1)
			charges = 0
		if(2)
			charges = max(0, charges - 5)
	if(charges < 1)
		status = 0
		update_icon()


/*
 *
 *
 *Stun Rod, WALL OF TEXT!
 *
 *
 */

/obj/item/weapon/melee/baton/stunrod
	name = "stun rod"
	desc = "A more-than-lethal weapon used to deal with high threat situations."
	icon_state = "stunrod"
	item_state = "stunrod"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 12
	throwforce = 8
	w_class = 3

	origin_tech = "combat=4,illegal=2"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</b>"
		return (FIRELOSS)

/obj/item/weapon/melee/baton/stunrod/update_icon()
	if(status)
		icon_state = "stunrod_active"
		item_state = "stunrod_active"
	else
		icon_state = "stunrod"
		item_state = "stunrod"

/obj/item/weapon/melee/baton/stunrod/attack_self(mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "\red You grab the [src] on the wrong side and burn yourself."
		user.Weaken(40)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		user << "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>"
		playsound(src.loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>\The [src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/baton/stunrod/attack(mob/M as mob, mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'>You accidentally hit yourself with the [src]!</span>"
		user.Weaken(20)
//		user.apply_damage(10,BURN)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return

	var/mob/living/carbon/human/H = M
	if(isrobot(M))
		..()
		return

	if(user.a_intent == "hurt")
		if(!..()) return
		H.apply_effect(5, WEAKEN, 0)
		H.apply_damage(15, BURN)
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Beat [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Beaten by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[user.name] ([user.ckey]) beat [H.name] ([H.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		playsound(src.loc, "swing_hit", 50, 1, -1)
	else if(!status)
		H.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return

	if(status)
		H.apply_effect(5, STUN, 0)
		H.apply_effect(5, WEAKEN, 0)
		H.apply_effect(5, STUTTER, 0)
		H.apply_damage(15, BURN)
		user.lastattacked = M
		H.lastattacker = user
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(75)
		else
			charges--
		H.visible_message("<span class='danger'>[M] has been stunned with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[key_name(user)] stunned [key_name(H)] with [src.name] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>")

		playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		if(charges < 1)
			status = 0
			update_icon()

	add_fingerprint(user)

/obj/item/weapon/melee/baton/stunrod/throw_impact(atom/hit_atom)
	. = ..()
	if (prob(50))
		if(istype(hit_atom, /mob/living))
			var/mob/living/carbon/human/H = hit_atom
			if(status)
				H.apply_effect(5, STUN, 0)
				H.apply_effect(5, WEAKEN, 0)
				H.apply_effect(5, STUTTER, 0)
				H.apply_damage(15, BURN)
				charges--

				for(var/mob/M in player_list) if(M.key == src.fingerprintslast)
					foundmob = M
					break

				H.visible_message("<span class='danger'>[src], thrown by [foundmob.name], strikes [H] and stuns them!</span>")

				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
				msg_admin_attack("Flying [src.name], last touched by ([src.fingerprintslast]) stunned [key_name(H)] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>" )

/obj/item/weapon/melee/baton/stunrod/emp_act(severity)
	switch(severity)
		if(1)
			charges = 0
		if(2)
			charges = max(0, charges - 5)
	if(charges < 1)
		status = 0
		update_icon()