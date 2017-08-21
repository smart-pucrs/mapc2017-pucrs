//+default::actionID(0).
//+default::actionID(X) 
//	: free & not strategies::hold_action(Action)
//<-
//	!action::recharge_is_new_skip;
//	.

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
//	?default::lastActionResult(Result);
//	if ( not default::lastActionResult(failed_job_status) ) {
//		+strategies::jobDone(JobId);
//	}
	-default::winner(_,_)[source(_)];
//	!strategies::check_charge;
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	!!strategies::free;
	.
	
+!go_buy
	: strategies::buyList(_,_,Shop)
<-
//	.print("Going to shop ",Shop);
	!action::goto(Shop);
	for ( strategies::buyList(ItemId,Qty,Shop) ) {
		!action::buy(ItemId,Qty);
//		.print("Buying #",Qty," of ",ItemId);
		-strategies::buyList(ItemId,Qty,Shop);
	}
	!go_buy
	.
+!go_buy.

+!empty_load
	: default::role(Role, _, _, _, _) 
<- 
	.abolish(org::_);
	if ( default::hasItem(ItemId,_) ) { !go_store(Role); }
	if ( default::hasItem(_,_) ) { !go_dump; }
//	!strategies::check_charge;
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
//			.print("Trying to store #",Qty," of ",ItemId);
			?default::storage(Facility, _, _, TotCapL, UsedCapL, _);
			if ( default::load(LoadL) & UsedCapL + LoadL < TotCapL ) {
				addAvailableItem(Facility,ItemId,Qty);
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
	?default::step(S);
	if (action::action(S)) {
		.abolish(action::_);
		.wait( default::step(S2) & S2 \== S );
	}
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
//	.print("Failed job, why I am not doing recharge.");
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
	?default::step(S);
	if (action::action(S)) {
		.abolish(action::_);
		.wait( default::step(S2) & S2 \== S );
	}
	if ( not default::routeLength(0) ) { !action::abort; }
	
	if ( default::hasItem(_,_) ) { !go_store(Role); }
	if ( default::hasItem(_,_) ) { !go_dump; }
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	!!strategies::free;
	.
	
@free[atomic]
+!free : not free <- +free; !!action::recharge_is_new_skip; .
//+!free : not free <- .print("free added");+free; !!action::recharge_is_new_skip;.
+!free : free <- !!action::recharge_is_new_skip.
@notFree[atomic]
+!not_free <- -free.
//+!not_free <- .print("free removed");-free.

//@reasoning[atomic]
//+!reasoning : not ::reasoning <- +::reasoning;.
////+!reasoning : not ::reasoning <- .print("reasoning added");+::reasoning;.
//+!reasoning.
//@notReasoning[atomic]
//+!not_reasoning <- -::reasoning.
////+!not_reasoning <- .print("reasoning removed");-::reasoning.

+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Step ",S-1," I have done ",Count+1," noActions.");
	-+metrics::noAction(Count+1);
	.
	
+default::job_done(JobId, _, Reward, _, _, _)
	: jobDone(JobId)
<-
	-jobDone(JobId);
	.send(vehicle1,achieve,initiator::job_finished(JobId)); 
	.print("$$$$$$$$$$$$ Job ",JobId," completed, got reward ",Reward);
	.
+default::job_done(JobId, _, _, _, _, _)
	: default::winner(_, assemble(_, JobId)) & metrics::jobHaveFailed(JobsFail)
<-
	.print("!!!!!!!!!!!!!!!!! Job ",JobId," failed!");
	-+metrics::jobHaveFailed(JobsFail+1);
	.send(vehicle1,achieve,initiator::update_job_failed);
	!job_failed_assemble;
	.
+default::job_done(JobId, _, _, _, _, _)
	: default::winner(_, assist(_, _, JobId)) & metrics::jobHaveFailed(JobsFail)
<-
	.print("!!!!!!!!!!!!!!!!! Job ",JobId," failed!");
	-+metrics::jobHaveFailed(JobsFail+1);
	!job_failed_assist;
	.
+default::job_done(JobId, _, Reward, _, _, Fine, _, _, _)
	: jobDone(JobId)
<-
	-jobDone(JobId);
	.send(vehicle1,achieve,initiator::mission_finished(JobId)); 
	.print("$$$$$$$$$$$$ Mission ",JobId," completed, got reward ",Reward);
	
	.
+default::job_done(JobId, _, _, _, _, Fine, _, _, _)
	: default::winner(_, assemble(_, JobId)) & metrics::missionHaveFailed(MissionsFail)
<-
	.print("!!!!!!!!!!!!!!!!! Mission ",JobId," failed, paying fine ",Fine);
	-+metrics::missionHaveFailed(MissionsFail+1);
	.send(vehicle1,achieve,initiator::update_mission_failed(Fine));
	!job_failed_assemble;
	.
+default::job_done(JobId, _, _, _, _, Fine, _, _, _)
	: default::winner(_, assist(_, _, JobId)) & metrics::missionHaveFailed(MissionsFail)
<-
	.print("!!!!!!!!!!!!!!!!! Mission ",JobId," failed, paying fine ",Fine);
	-+metrics::missionHaveFailed(MissionsFail+1);
	!job_failed_assist;
	.
	
-default::auction(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)
<-
	.wait(default::actionID(_));
	!::check_aucion_finished(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items);
	.
+!check_aucion_finished(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)
	: default::step(S) & (S <= (Start+Time+2))
	.
+!check_aucion_finished(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)
	: jobDone(Id)
<-
	-jobDone(Id);
	.send(vehicle1,achieve,initiator::auction_finished(Id)); 
	.print("$$$$$$$$$$$$ Auction ",Id," completed, got reward ",Reward);	
	.
+!check_aucion_finished(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)
	: default::winner(_, assemble(_, Id)) & metrics::auctionHaveFailed(AuctionFail)
<-
	.print("!!!!!!!!!!!!!!!!! Auction ",Id," failed, paying fine ",Fine);
	-+metrics::auctionHaveFailed(AuctionFail+1);
	.send(vehicle1,achieve,initiator::update_auction_failed(Fine));
	!job_failed_assemble;
	.
+!check_aucion_finished(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)
	: default::winner(_, assist(_, _, Id)) & metrics::auctionHaveFailed(AuctionFail)
<-
	.print("!!!!!!!!!!!!!!!!! Auction ",Id," failed, paying fine ",Fine);
	-+metrics::auctionHaveFailed(AuctionFail+1);
	!job_failed_assist;
	.
+!check_aucion_finished(_,_,_,_,_,_,_,_,_).
