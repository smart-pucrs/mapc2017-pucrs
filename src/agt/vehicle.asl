{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-rules.asl") }
//{ include("strategies/round/new-round.asl", new) }
{ include("strategies/round/new-round.asl") }
{ include("strategies/common-plans.asl", strategies) }
{ include("strategies/bidder.asl", bidder) }
{ include("strategies/round/end-round.asl") }

+!add_initiator
<- 
	+default::imTheInitiator[source(initiator)];
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
	.wait(1000);
	if ( .member(Me,Agents) ) { .broadcast(tell,tools(Role,Tools)); }
	addLoad(Me,LoadCap);
	+strategies::free;
	!strategies::firstskip;
    .
    
+tools(Role,Tools) : default::role(Role,_,_,_,_) <- -tools(Role,Tools)[source(_)].