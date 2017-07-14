{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-rules.asl") }
{ include("strategies/new-round.asl", new) }
{ include("strategies/common-plans.asl", strategies) }
{ include("strategies/coalition.asl", coalition) }
{ include("strategies/initiator.asl", initiator) }
{ include("strategies/bidder.asl", bidder) }

+!create_taskboard <- makeArtifact("task_board","cnp.TaskBoard",[]).

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
	
+default::role(_,_,LoadCap,_,Tools)
	: .my_name(Me) & new::tool_types(Agents)
<- 
	!coalition::introduce_to_the_coalition_artefact;
	if ( .sublist([Me],Agents) ) { addTools(Tools); }
	addLoad(Me,LoadCap);
	if ( Me == vehicle1 ) { !coalition::setup_coalition_artefact; }
    .