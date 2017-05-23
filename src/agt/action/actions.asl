{ include("common-rules.asl", rules) }

{begin namespace(localActions, local)}

+!commitAction(Action)
	: true
<-
	action(Action);
	.

{end}

// Goto (option 1)
// FacilityId must be a string
//+!goto(FacilityId) 
//	: default::inFacility(FacilityId)
//<-
//	-default::going(FacilityId);
//	.
//+!goto(_) 
//	: default::lastActionResult(Result) & Result == default::failed_random & default::lastActionReal(Action) & .substring("goto",Action) & default::going(FacilityId)
//<-
//	!localActions::commitAction(goto(facility(FacilityId)));
//	!localActions::commitAction(goto(facility(FacilityId)));
//	!goto(FacilityId);
//	.	
//+!goto(FacilityId)
//	: default::charge(Battery) & Battery == 0
//<-
//	!call_breakdown_service;
//	-default::going(FacilityId);
//	!goto(FacilityId);
//	.
//+!goto(FacilityId)
//	: going(FacilityId)
//<-
//	!continue;
//	!goto(FacilityId);
//	.	
//// Tests if there is enough battery to go to my goal AND to the nearest charging station around that goal
//+!goto(FacilityId)
//: not .desire(go_charge(_)) & default::chargingList(List) & rules::closest_facility(List, FacilityId, FacilityId2) & rules::enough_battery(FacilityId, FacilityId2, Result)
//<-
//    if (not Result) {
//    	!go_charge(FacilityId);
//    }
//    else {+default::going(FacilityId); !localActions::commitAction(goto(facility(FacilityId))); !localActions::commitAction(goto(facility(FacilityId)));}
////	!commitAction(goto(facility(FacilityId)));
//	!goto(FacilityId);
//	. 	
+!goto(FacilityId)
	: not default::going(FacilityId)
<-	
	+default::going(FacilityId);
	!localActions::commitAction(goto(FacilityId));
	!goto(FacilityId);
	.
+!goto(FacilityId)
	: default::going(FacilityId) & not facility(FacilityId)
<-	
//	.print("Already going to facility ",FacilityId);
	!continue;
	.

// Goto (option 2)
// Lat and Lon must be floats
+!goto(Lat, Lon)
	: true
<-
	!localActions::commitAction(
		goto(
			lat(Lat),
			lon(Lon)
		)
	);
	+default::going(Lat,Lon);
	.
	
// Charge
// No parameters
+!charge
	: default::charging & default::charge(Battery) & default::role(_, _, _, BatteryCap, _) & Battery = BatteryCap
<-
	-default::charging.
+!charge
	: default::lastActionResult(Result) & Result == default::failed_random & default::lastActionReal(Action) & .substring("charge",Action)
<-
	!localActions::commitAction(charge);
	!localActions::commitAction(charge);
	!charge;
	.	
+!charge
	: not default::charging
<-
	+default::charging;
	!localActions::commitAction(charge);
	!localActions::commitAction(charge);
	!charge;
	.
+!charge
	: default::charge(Battery) & default::role(_, _, _, BatteryCap, _) & Battery < BatteryCap
<-
	!continue;
	!charge;
	.	

// Buy
// ItemId must be a string
// Amount must be an integer
+!buy(ItemId, Amount)
	: true
<-	
	!localActions::commitAction(buy(item(ItemId),amount(Amount)));
	.

// Give
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!give(AgentId, ItemId, Amount)
	: true
<-
	!localActions::commitAction(
		give(
			agent(AgentId),
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Receive
// AgentId must be a string
// ItemId must be a string
// Amount must be an integer
+!receive
	: true
<-
	!localActions::commitAction(
		receive
	);
	.

// Store
// ItemId must be a string
// Amount must be an integer
+!store(ItemId, Amount)
	: true
<-
	!localActions::commitAction(
		store(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Retrieve
// ItemId must be a string
// Amount must be an integer
+!retrieve(ItemId, Amount)
	: true
<-
	!localActions::commitAction(
		retrieve(
			item(ItemId),
			amount(Amount)
		)
	);
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
	!localActions::commitAction(
		dump(
			item(ItemId),
			amount(Amount)
		)
	);
	.

// Assemble
// ItemId must be a string
+!assemble(ItemId)
	: true
<-
	!localActions::commitAction(
		assemble(
			item(ItemId)
		)
	);
	.

// Assist assemble
// AgentId must be a string
+!assist_assemble(AgentId)
	: true
<-
	!localActions::commitAction(
		assist_assemble(
			assembler(AgentId)
		)
	);
	.

// Deliver job
// JobId must be a string
+!deliver_job(JobId)
	: true
<-
	!localActions::commitAction(
		deliver_job(
			job(JobId)
		)
	);
	.

// Bid for job
// JobId must be a string
// Price must be an integer
+!bid_for_job(JobId, Price)
	: true
<-
	!localActions::commitAction(
		bid_for_job(
			job(JobId),
			price(Price)
		)
	);
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

// Abort
// No parameters
+!abort
	: true
<-
	!localActions::commitAction(abort);
	.

+!call_breakdown_service
<-
	!localActions::commitAction(call_breakdown_service);
	.	