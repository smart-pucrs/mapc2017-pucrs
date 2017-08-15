{begin namespace(localActions, local)}

//-strategies::reasoning
//<- 
//	!commitWaitingAction;
//	.
//	
//+!commitWaitingAction
//	: ::actionWantToDo(Action) & (Action \== none)
//<-
////	.print("****** I want to perform action ",Action);
//	!commitAction(Action);
//	-+::actionWantToDo(none);
//	.	
//+!commitWaitingAction.
//
//+!commitAction(Action)
//	: strategies::reasoning
//<-
////	.print("****** Storing action ",Action);
//	-+::actionWantToDo(Action);
//	.
+!commitAction(Action)
	: default::step(S) & not default::action(S) & not strategies::hold_action
<-
	+default::action(S);
	action(Action);
	.print("Doing action ",Action, " at step ",S);
	.wait({ +default::lastActionResult(Result) });
	-default::action(S);
	if (Action \== skip & Result == failed) {
//		.print("Failed to execute action ",Action," due to the 1% random error. Executing it again.");
		!commitAction(Action);
	}
	else {
		if (strategies::hold_action(Action2)) {
			-strategies::hold_action(Action2);
			.print("Removing held action ",Action2);
		}
	}
	.
+!commitAction(Action) 
	: strategies::hold_action 
<- 
//	.print("Holding action ",Action);
	.wait(500);
//	.print("Trying action ",Action," again now.");
	!commitAction(Action);
	.
+!commitAction(Action) : Action == skip.
+!commitAction(Action) : Action \== skip <- .print("Holding action ",Action); +strategies::hold_action(Action); .wait( {-strategies::hold_action(Action) }); !commitAction(Action);.
{end}

// Goto (option 1)
// FacilityId must be a string
+!goto(FacilityId) : default::facility(FacilityId).
+!goto(FacilityId)
	: default::charge(0)
<-
	!recharge;
	!goto(FacilityId);
	.
+!goto(FacilityId)
	: default::routeLength(R) & R \== 0
<-	
	!continue;
	!goto(FacilityId);
	.
// Tests if there is enough battery to go to my goal AND to the nearest charging station around that goal	
+!goto(FacilityId)
: not .desire(action::go_charge(_)) & new::chargingList(List) & default::closest_facility(List, FacilityId, FacilityId2) & default::enough_battery(FacilityId, FacilityId2, Result)
<-	
    if (Result == "false") { !go_charge(FacilityId); }
    else { !localActions::commitAction(goto(FacilityId)); }
	!goto(FacilityId);
	.
+!goto(FacilityId)
	: true
<-	
	.print("GOTO2");
	!localActions::commitAction(goto(FacilityId));
	!goto(FacilityId);
	.

// Goto (option 2)
// Lat and Lon must be floats
+!goto(Lat, Lon) : going(Lat,Lon) & default::routeLength(R) & R == 0 <- -going(Lat,Lon).
+!goto(Lat, Lon)
	: default::charge(0)
<-
	!recharge;
	!goto(Lat, Lon);
	.
+!goto(Lat, Lon)
	: going(Lat,Lon) & default::routeLength(R) & R \== 0
<-	
	!continue;
	!goto(Lat, Lon);
	.
// Tests if there is enough battery to go to my goal AND to the nearest charging station around that goal	
+!goto(Lat, Lon)
: not .desire(go_charge(_,_)) & new::chargingList(List) & default::closest_facility(List, Lat, Lon, FacilityId2) & default::enough_battery(Lat, Lon, FacilityId2, Result)
<-	
    if (Result == "false") { !go_charge(Lat, Lon); }
    else { +going(Lat,Lon); !localActions::commitAction(goto(Lat,Lon)); }
	!goto(Lat, Lon);
	.
+!goto(Lat, Lon)
	: true
<-
	+going(Lat,Lon);
	!localActions::commitAction(goto(Lat,Lon));
	!goto(Lat, Lon);
	.
	
// Charge
// No parameters
+!charge
	: default::charge(C) & not default::role(_,_,_,C,_)
<-
	!localActions::commitAction(charge);
	!charge;
	.
-!charge.

// Buy
// ItemId must be a string
// Amount must be an integer
+!buy(ItemId, Amount)
	: default::hasItem(ItemId,OldAmount)
<-	
	!localActions::commitAction(buy(ItemId,Amount));
	!buy_loop(ItemId, Amount, OldAmount);
	.
+!buy(ItemId, Amount)
	: true
<-	
	!localActions::commitAction(buy(ItemId,Amount));
	!buy_loop(ItemId, Amount, 0);
	.
+!buy_loop(ItemId, Amount, OldAmount)
	: not default::hasItem(ItemId, Amount+OldAmount)
<-
	!localActions::commitAction(buy(ItemId,Amount));
	!buy_loop(ItemId, Amount, OldAmount);
	.
-!buy_loop(ItemId, Amount, OldAmount).

// Give
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!give(AgentName, ItemId, Amount)
	: true
<-
	getServerName(AgentName,ServerName);
	?default::hasItem(ItemId, OldAmount);
	!localActions::commitAction(give(ServerName,ItemId,Amount));
	!giveLoop(ServerName, ItemId, Amount, OldAmount);
	.
+!giveLoop(AgentId, ItemId, Amount, OldAmount)
	: default::hasItem(ItemId,OldAmount)
<-
	!localActions::commitAction(give(AgentId,ItemId,Amount));
	!giveLoop(AgentId, ItemId, Amount, OldAmount);
	.
-!giveLoop(AgentId, ItemId, Amount, OldAmount).

// Receive
// No parameters
+!receive(ItemId,Amount)
	: default::hasItem(ItemId,OldAmount)
<-
	-strategies::free[source(_)];
	!localActions::commitAction(receive);
	!receiveLoop(ItemId,Amount,OldAmount);
	.
+!receive(ItemId,Amount)
	: true
<-
	-strategies::free[source(_)];
	!localActions::commitAction(receive);
	!receiveLoop(ItemId,Amount,0);
	.
+!receiveLoop(ItemId, Amount, OldAmount)
	: not default::hasItem(ItemId,Amount+OldAmount)
<-
	!localActions::commitAction(receive);
	!receiveLoop(ItemId, Amount, OldAmount);
	.
-!receiveLoop(ItemId,Amount,OldAmount).

// Store
// ItemId must be a string
// Amount must be an integer
+!store(ItemId, Amount)
	: true
<-
	!localActions::commitAction(store(ItemId,Amount));
	.

// Retrieve
// ItemId must be a string
// Amount must be an integer
+!retrieve(ItemId, Amount)
	: true
<-
	!localActions::commitAction(retrieve(ItemId,Amount));
	.

// Retrieve delivered
// ItemId must be a string
// Amount must be an integer
+!retrieve_delivered(ItemId, Amount)
	: true
<-
	!localActions::commitAction(
		retrieve_delivered(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Dump
// ItemId must be a string
// Amount must be an integer
+!dump(ItemId, Amount)
	: true
<-
	!localActions::commitAction(dump(ItemId,Amount));
	.

// Assemble
// ItemId must be a string
+!assemble(ItemId)
	: default::hasItem(ItemId,OldAmount)
<-
	!localActions::commitAction(assemble(ItemId));
	!assembleLoop(ItemId,1,OldAmount);
	.
+!assemble(ItemId)
	: true
<-
	!localActions::commitAction(assemble(ItemId));
	!assembleLoop(ItemId,1,0);
	.
+!assembleLoop(ItemId, Amount, OldAmount)
	: not default::hasItem(ItemId,Amount+OldAmount)
<-
	!localActions::commitAction(assemble(ItemId));
	!assembleLoop(ItemId, Amount, OldAmount);
	.
-!assembleLoop(ItemId,Amount,OldAmount).

// Assist assemble
// AgentId must be a string
+!assist_assemble(AgentName)
	: true
<-
	getServerName(AgentName,ServerName);
	!assist_assemble_loop(ServerName);
	.
+!assist_assemble_loop(ServerName)
	: strategies::assembling
<-
	!localActions::commitAction(assist_assemble(ServerName));
	!assist_assemble_loop(ServerName);
	.
+!assist_assemble_loop(ServerName).
	
// Deliver job
// JobId must be a string
+!deliver_job(JobId)
	: true
<-
	!localActions::commitAction(deliver_job(JobId));
	.

// Bid for job
// JobId must be a string
// Price must be an integer
+!bid_for_job(JobId, Price)
	: true
<-
	!localActions::commitAction(bid_for_job(JobId,Price));
	.

// Post job (option 1)
// MaxPrice must be an integer
// Fine must be an integer
// ActiveSteps must be an integer
// AuctionSteps must be an integer
// StorageId must be a string
// Items must be a string "item1=item_id1 amount1=10 item2=item_id2 amount2=5 ..."
// Example: !post_job_auction(1000, 50, 1, 10, storage1, [item(base1,1), item(material1,2), item(tool1,3)]);
+!post_job_auction(MaxPrice, Fine, ActiveSteps, AuctionSteps, StorageId, Items)
	: true
<-
	!localActions::commitAction(
		post_job(
			type(auction),
			max_price(MaxPrice),
			fine(Fine),
			active_steps(ActiveSteps),
			auction_steps(AuctionSteps), 
			storage(StorageId),
			Items
		)
	);
	.

// Post job (option 2)
// Price must be an integer
// ActiveSteps must be an integer
// StorageId must be a string
// Items must be a string "item1=item_id1 amount1=10 item2=item_id2 amount2=5 ..."
// Example: !post_job_priced(1000, 50, storage1, [item(base1,1), item(material1,2), item(tool1,3)]);
+!post_job_priced(Price, ActiveSteps, StorageId, Items)
	: true
<-
	!localActions::commitAction(
		post_job(
			type(priced),
			price(Price),
			active_steps(ActiveSteps), 
			storage(StorageId),
			Items
		)
	);
	.

// Continue
// No parameters
+!continue
	: true
<-
	!localActions::commitAction(continue);
	.

// Skip
// No parameters
+!skip
	: true
<-
	!localActions::commitAction(skip);
	.
	
// Recharge
// No parameters
+!recharge
	: default::charge(C) & not default::role(_,_,_,C,_)
<-
	!localActions::commitAction(recharge);
	!recharge;
	.
-!recharge <- .print("Fully recharged.").
	
// Gather
// No parameters
+!gather(Vol)
	: default::role(_,_,LoadCap,_,_) & default::load(Load) & Load + Vol <= LoadCap
<-
	!localActions::commitAction(gather);
	!gather(Vol);
	.
-!gather(Vol).

// Abort
// No parameters
+!abort
	: true
<-
	!localActions::commitAction(abort);
	.

// Strategies for verifying battery and going to charging stations
+!go_charge(Flat,Flon)
	: new::chargingList(List) & default::lat(Lat) & default::lon(Lon) & default::role(_, Speed, _, BatteryCap, _)
<-
	+onMyWay([]);
	for(.member(ChargingId,List)){
		?default::chargingStation(ChargingId,Clat,Clon,_);
		if(math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Lat-Clat)**2+(Lon-Clon)**2)) & math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Clat-Flat)**2+(Clon-Flon)**2))){
			?onMyWay(AuxList);
			-onMyWay(AuxList);
			+onMyWay([ChargingId|AuxList]);
		}
	}
	?onMyWay(Aux2List);
	if(.empty(Aux2List)){
		?default::closest_facility(List,Facility);
		?default::closest_facility(List,Flat,Flon,FacilityId2);
		?default::enough_battery2(Facility, Flat, Flon, FacilityId2, Result, BatteryCap);
		if (Result == "false") {
			+impossible;
			.print("@@@@ Impossible route, going to try anyway.");
			+going(Flat,Flon);
			!localActions::commitAction(goto(Flat,Flon));
			!goto(Flat,Flon);
		}
		else {
			FacilityAux2 = Facility;
			.print("There is no charging station between me and my goal, going to the nearest one.");
		}
	}
	else{
		?default::closest_facility(Aux2List,Facility);
		?default::enough_battery_charging(Facility, Result);
		if (Result == "false") {
			?default::closest_facility(List,FacilityAux);
			?default::enough_battery_charging2(FacilityAux, Facility, Result2, BatteryCap);
			if (Result2 == "false") {
				+impossible;
				.print("@@@@ Impossible route, going to try anyway and hopefully call service breakdown.");
				+going(Flat,Flon);
				!localActions::commitAction(goto(Flat,Flon));
				!goto(Flat,Flon);
			}
			else {
				FacilityAux2 = FacilityAux;
				.print("There is no charging station between me and my goal, going to the nearest one.");
			}
		}
		else {
			?default::closest_facility(Aux2List,Flat,Flon,FacilityAux);
			?default::enough_battery_charging(FacilityAux, ResultAux);
			if (ResultAux == "true") {
				FacilityAux2 = FacilityAux;
			}
			else {
				.delete(FacilityAux,Aux2List,Aux2List2);
				!check_list_charging(Aux2List2,Flat,Flon);
				?charge_in(FacAux);
				-charge_in(FacAux);
				FacilityAux2 = FacAux;
			}
		}
	}
	-onMyWay(Aux2List);
	if (not impossible) {
		.print("**** Going to charge my battery at ", FacilityAux2);
		!localActions::commitAction(goto(FacilityAux2));
		!goto(FacilityAux2);
		!charge;		
	}
	else {
		-impossible;
	}
	.
+!check_list_charging(List,Lat,Lon)
<-
	?default::closest_facility(List,Lat,Lon,Facility);
	?default::enough_battery_charging(Facility, ResultC);
	if (ResultC == "true") {
		+charge_in(Facility);
	}
	else {
		.delete(Facility,List,ListAux);
		!check_list_charging(ListAux,Lat,Lon);
	}
	.
+!go_charge(FacilityId)
	: new::chargingList(List) & default::lat(Lat) & default::lon(Lon) & default::getFacility(FacilityId,Flat,Flon,Aux1,Aux2) & default::role(_, Speed, _, BatteryCap, _)
<-
	+onMyWay([]);
	?default::facility(Fac);
	if (.member(Fac,List)) {
		.delete(Fac,List,List2);
	}
	else {
		List2 = List;
	}
	for(.member(ChargingId,List2)){
		?default::chargingStation(ChargingId,Clat,Clon,_);
		if(math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Lat-Clat)**2+(Lon-Clon)**2)) & math.sqrt((Lat-Flat)**2+(Lon-Flon)**2)>(math.sqrt((Clat-Flat)**2+(Clon-Flon)**2))){
			?onMyWay(AuxList);
			-onMyWay(AuxList);
			+onMyWay([ChargingId|AuxList]);
		}
	}
	?onMyWay(Aux2List);
	if(.empty(Aux2List)){
		?default::closest_facility(List2,Facility);
		?default::closest_facility(List,FacilityId,FacilityId2);
//		?enough_battery_charging2(Facility, FacilityId, Result, BatteryCap);
		?default::enough_battery2(Facility, FacilityId, FacilityId2, Result, BatteryCap);
		if (Result == "false") {
			+impossible;
			.print("@@@@ Impossible route, going to try anyway.");
			!localActions::commitAction(goto(FacilityId));
			!goto(FacilityId);
		}
		else {
			FacilityAux2 = Facility;
			.print("There is no charging station between me and my goal, going to the nearest one.");
		}
	}
	else{
		?default::closest_facility(Aux2List,Facility);
		?default::enough_battery_charging(Facility, Result);
		if (Result == "false") {
			?default::closest_facility(List2,FacilityAux);
			?default::enough_battery_charging2(FacilityAux, Facility, Result2, BatteryCap);
			if (Result2 == "false") {
				+impossible;
				.print("@@@@ Impossible route, going to try anyway and hopefully call service breakdown.");
				!localActions::commitAction(goto(FacilityId));
				!goto(FacilityId);
			}
			else {
				FacilityAux2 = FacilityAux;
				.print("There is no charging station between me and my goal, going to the nearest one.");
			}
		}
		else {
			?default::closest_facility(Aux2List,FacilityId,FacilityAux);
			?default::enough_battery_charging(FacilityAux, ResultAux);
			if (ResultAux == "true") {
				FacilityAux2 = FacilityAux;
			}
			else {
				.delete(FacilityAux,Aux2List,Aux2List2);
				!check_list_charging(Aux2List2,FacilityId);
				?charge_in(FacAux);
				-charge_in(FacAux);
				FacilityAux2 = FacAux;
			}
		}
	}
	-onMyWay(Aux2List);
	if (not impossible) {
		.print("**** Going to charge my battery at ", FacilityAux2);
		!localActions::commitAction(goto(FacilityAux2));
		!goto(FacilityAux2);
		!charge;		
	}
	else {
		-impossible;
	}
	.
+!check_list_charging(List,FacilityId)
<-
	?default::closest_facility(List,FacilityId,Facility);
	?default::enough_battery_charging(Facility, ResultC);
	if (ResultC == "true") {
		+charge_in(Facility);
	}
	else {
		.delete(Facility,List,ListAux);
		!check_list_charging(ListAux,FacilityId);
	}
	.
