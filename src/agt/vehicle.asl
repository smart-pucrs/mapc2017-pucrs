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
	addName(Me,ServerMe);
	.
	
+default::role(_,_,_,_,Tools)
	: .my_name(Me) & Me == vehicle1
<- 
	!coalition::introduce_to_the_coalition_artefact;    
	addTools(Tools);
	!coalition::setup_coalition_artefact;
    .
+default::role(_,_,_,_,Tools)
	: .my_name(Me) & Me == vehicle5
<- 
	!coalition::introduce_to_the_coalition_artefact;    
	addTools(Tools);
    .
+default::role(_,_,_,_,Tools)
	: .my_name(Me) & Me == vehicle13
<- 
	!coalition::introduce_to_the_coalition_artefact;    
	addTools(Tools);
    .
+default::role(_,_,_,_,Tools)
	: .my_name(Me) & Me == vehicle21
<- 
	!coalition::introduce_to_the_coalition_artefact;    
	addTools(Tools);
    .
+default::role(_,_,_,_,_)
	: true
<- 
	!coalition::introduce_to_the_coalition_artefact;    
    .