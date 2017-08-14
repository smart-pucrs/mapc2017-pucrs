+default::actionID(0).
+default::actionID(X) 
	: free
<-
	!action::skip;
	.

+!go_to_workshop(Storage)
	: new::workshopList(WList)
<-
	actions.closest(truck,WList,Storage,ClosestWorkshop);
	!action::goto(ClosestWorkshop);
	.

+!go_deliver
<-
	!go_to_storage;
	!deliver;
	.
	
+!go_to_storage
	: default::winner(_, assemble(Storage, _))
<-
	.print("Finished assembling all items, going to deliver.");
	!action::goto(Storage);
	.
	
+!deliver
	: default::winner(_, assemble(_, JobId))
<-
	!action::deliver_job(JobId);
	?default::lastActionResult(Result);
	if ( not default::lastActionResult(failed_job_status) ) {
		+strategies::jobDone(JobId);
	}
	-default::winner(_,_)[source(_)];
	.send(vehicle1,achieve,initiator::job_finished(JobId)); 
	!strategies::check_charge;
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	!!strategies::free;
	.
	
+!go_buy
	: strategies::buyList(_,_,Shop,_)
<-
//	.print("Going to shop ",Shop);
	!action::goto(Shop);
	for ( strategies::buyList(ItemId,Qty,Shop,Id) ) {
		!action::buy(ItemId,Qty);
//		.print("Buying #",Qty," of ",ItemId);
		-strategies::buyList(ItemId,Qty,Shop,Id);
	}
	!go_buy
	.
+!go_buy.

+!empty_load
	: default::role(Role, _, _, _, _) 
<- 
	.abolish(org::_);
	if ( default::hasItem(_,_) ) { !go_store(Role); }
	if ( default::hasItem(_,_) ) { !go_dump; }
	!strategies::check_charge;
	if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_truck_to_free); }
	else { 
		.my_name(Me);
		if (Me == vehicle1) {
			!initiator::add_myself_to_free;
		}
		else { .send(vehicle1,achieve,initiator::add_agent_to_free); }
	}
	!!strategies::free;
	.

+!check_charge
	: default::role(Role,_,_,BatteryCap,_) & (Role == truck | Role == car) & default::charge(Battery) & Battery <= BatteryCap div 2 & new::chargingList(CList)
<-
	.print("Running low on battery, going to charge before taking any new tasks.");
	actions.closest(Role,CList,ClosestChargingStation);
	!action::goto(ClosestChargingStation);
	!action::charge;
	.
-!check_charge.

+!go_dump
	: default::role(Role, _, _, _, _) & new::dumpList(DList)
<-
	actions.closest(Role,DList,ClosestDump);
	!action::goto(ClosestDump);
	for ( default::hasItem(ItemId,Qty) ) {
		!action::dump(ItemId,Qty);
	}
	.
	
+!go_store(Role)
	: new::storageList(SList) & actions.closest(Role,SList,Facility) & default::storage(Facility, _, _, TotCap, UsedCap, _) & default::load(Load) & UsedCap + Load < TotCap
<-
	!action::goto(Facility);
	?default::storage(Facility, _, _, TotCap2, UsedCap2, _);
	if ( UsedCap2 + Load < TotCap2 ) {
		for ( default::hasItem(ItemId,Qty) ) {
			?default::storage(Facility, _, _, TotCapL, UsedCapL, _);
			if ( default::load(LoadL) & UsedCapL + LoadL < TotCapL ) {
				addAvailableItem(Facility,ItemId);
				!action::store(ItemId,Qty);
			}
		}
	}
	.
+!go_store(Role).	
	
+!job_failed_assist
	: default::role(Role, _, _, _, _) & .my_name(Me)
<-
	-default::winner(_,_)[source(_)];
	.abolish(strategies::_);
	.drop_desire(org::_);
	.drop_desire(strategies::go_buy);
	.drop_desire(strategies::go_to_workshop(_));
	.abolish(org::_);
	if ( not default::routeLength(0) ) { !action::abort; }
	if ( default::hasItem(_,_) ) { !go_store(Role); }
	if ( default::hasItem(_,_) ) { !go_dump; }
	if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_truck_to_free); }
	else { 
		if (Me == vehicle1) {
			!initiator::add_myself_to_free;
		}
		else { .send(vehicle1,achieve,initiator::add_agent_to_free); }
	}
	!!strategies::free;
	.
+!job_failed_assemble
	: default::role(Role, _, _, _, _)
<-
	-default::winner(_, assemble(_, JobId))[source(_)];
	if ( org::goalState(JobId,job_delivered,_,_,waiting) ) { org::removeScheme(JobId); }
	.drop_desire(org::_);
	.abolish(org::_);
	.drop_desire(strategies::go_deliver);
	.drop_desire(strategies::go_to_workshop(_));
	.drop_desire(strategies::deliver);
	.drop_desire(strategies::go_to_storage);
	if ( not default::routeLength(0) ) { !action::abort; }
	
	if ( default::hasItem(_,_) ) { !go_store(Role); }
	if ( default::hasItem(_,_) ) { !go_dump; }
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	!!strategies::free;
	.
	
@free[atomic]
+!free : not free <- +free; !!action::skip; .
//+!free : not free <- .print("free added");+free; !!action::skip;.
+!free <- !!action::skip.
@notFree[atomic]
+!not_free <- -free.
//+!not_free <- .print("free removed");-free.

@reasoning[atomic]
+!reasoning : not ::reasoning <- +::reasoning;.
//+!reasoning : not ::reasoning <- .print("reasoning added");+::reasoning;.
+!reasoning.
@notReasoning[atomic]
+!not_reasoning <- -::reasoning.
//+!not_reasoning <- .print("reasoning removed");-::reasoning.

@noAction[atomic]
+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Step ",S," I have done ",Count+1," noActions.");
	-+metrics::noAction(Count+1);
	.
	
+default::job_done(JobId, _, Reward, _, _, _)
	: jobDone(JobId)
<-
	-jobDone(JobId);
	.print("$$$$$$$$$$$$ Job ",JobId," completed, got reward ",Reward);
	.
+default::job_done(JobId, _, _, _, _, _)
	: default::winner(_, assemble(_, JobId))
<-
	.print("!!!!!!!!!!!!!!!!! Job ",JobId," failed!");
	!job_failed_assemble;
	.
+default::job_done(JobId, _, _, _, _, _)
	: default::winner(_, assist(_, _, JobId))
<-
	.print("!!!!!!!!!!!!!!!!! Job ",JobId," failed!");
	!job_failed_assist;
	.
+default::job_done(JobId, _, Reward, _, _, Fine, _, _, _)
	: jobDone(JobId)
<-
	-jobDone(JobId);
	.print("$$$$$$$$$$$$ Mission ",JobId," completed, got reward ",Reward);
	
	.
+default::job_done(JobId, _, _, _, _, Fine, _, _, _)
	: default::winner(_, assemble(_, JobId))
<-
	.print("!!!!!!!!!!!!!!!!! Mission ",JobId," failed, paying fine ",Fine);
	!job_failed_assemble;
	.
+default::job_done(JobId, _, _, _, _, Fine, _, _, _)
	: default::winner(_, assist(_, _, JobId))
<-
	.print("!!!!!!!!!!!!!!!!! Mission ",JobId," failed, paying fine ",Fine);
	!job_failed_assist;
	.