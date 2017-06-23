{begin namespace(localActions, local)}
+!commitAction(Action)
	: default::step(S) & not action(S)
<-
	+action(S);
	action(Action);
//	.print("Doing action ",Action, " at step ",S);
	.wait({ +default::lastActionResult(Result) });
	-action(S);
	if (Result == failed) {
		.print("Failed to execute action ",Action," due to the 1% random error. Executing it again.");
		!commitAction(Action);
	}
	.
-!commitAction(Action) : Action == skip.
-!commitAction(Action) <- !commitAction(Action).
{end}

// Goto (option 1)
// FacilityId must be a string
+!goto(FacilityId) : default::facility(FacilityId).
+!goto(FacilityId)
	: default::routeLength(R) & R \== 0
<-	
	!continue;
	!goto(FacilityId);
	.
+!goto(FacilityId)
	: true
<-	
	!localActions::commitAction(goto(FacilityId));
	!goto(FacilityId);
	.

// Goto (option 2)
// Lat and Lon must be floats
+!goto(Lat, Lon) : going(Lat,Lon) & default::routeLength(R) & R == 0 <- -going(Lat,Lon).
+!goto(Lat, Lon)
	: going(Lat,Lon) & default::routeLength(R) & R \== 0
<-	
	!continue;
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
	!localActions::commitAction(buy(ItemId,Amount));
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

+!call_breakdown_service
<-
	!localActions::commitAction(call_breakdown_service);
	.	