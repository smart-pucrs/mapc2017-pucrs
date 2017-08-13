{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl", org) }
{ include("action/actions.asl",action) }
{ include("common-rules.asl") }
{ include("strategies/round/new-round.asl") }
{ include("strategies/common-plans.asl", strategies) }
{ include("strategies/scheme-plans.asl", org) }
{ include("strategies/bidder.asl", bidder) }
{ include("strategies/round/end-round.asl") }
//{ include("strategies/job/auction/execute-auction.asl", execution_auction) }

+!add_initiator
<- 
	.include("strategies/initiator.asl", initiator);
	.
	
+!register(E)
	: .my_name(Me)
<- 
	!new::new_round;
    .print("Registering...");
    register(E);
	.
	
+default::name(ServerMe)
	: .my_name(Me)
<-
	addServerName(Me,ServerMe);
	.
	
//+default::hasItem(Item,Qty)
//<- .print("Just got #",Qty," of ",Item).
	
+default::role(Role,_,LoadCap,_,Tools)
	: .my_name(Me) & new::tool_types(Agents)
<- 
	addLoad(Me,LoadCap);
	addRole(Me,Role);
	.wait(1000);
	if ( .member(Me,Agents) ) { .broadcast(tell,tools(Role,Tools)); }
	!!action::skip;
	.wait( {+default::step(S)} );
	!!action::skip;
	.wait( {+default::step(S+1)} );
	if ( default::hasItem(_,_) ) { !strategies::go_store }
	if ( default::hasItem(_,_) ) { !strategies::go_dump }
	if ( Me == vehicle1 ) { !initiator::add_myself_to_free; +initiator::accept_jobs; }
	else {
		if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_truck_to_free); }
		else { .send(vehicle1,achieve,initiator::add_agent_to_free); }
	}
	!strategies::free;
    .
    
+tools(Role,Tools) : default::role(Role,_,_,_,_) <- -tools(Role,Tools)[source(_)].