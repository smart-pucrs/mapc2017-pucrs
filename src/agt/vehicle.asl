{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-rules.asl") }
{ include("strategies/new-round.asl", new) }
{ include("strategies/common-plans.asl", strategies) }
{ include("strategies/bidder.asl", bidder) }

+!create_taskboard 
<- 
	makeArtifact("task_board","cnp.TaskBoard",[]);
	.include("strategies/initiator.asl", initiator); 
	.

+!register(E)
	: .my_name(Me)
<- 
	focusWhenAvailable("task_board");
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
	if ( .sublist([Me],Agents) ) { .broadcast(tell,tools(Role,Tools)); }
	addLoad(Me,LoadCap);
	+strategies::free;
	!strategies::firstskip;
    .
    
+tools(Role,Tools) : default::role(Role,_,_,_,_) <- -tools(Role,Tools)[source(_)].