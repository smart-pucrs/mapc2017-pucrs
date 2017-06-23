{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-rules.asl") }
{ include("strategies/new-round.asl", new) }
{ include("strategies/common-plans.asl", strategies) }
{ include("strategies/coalition.asl", coalition) }



+!register(E)
	: .my_name(Me)
<- 
	!new::new_round;
    .print("Registering...");
    register(E);
	.
	
+default::role(_,_,_,_,_)
	: .my_name(Me)
<- 
	!coalition::introduce_to_the_coalition_artefact;    
    if (Me == vehicle1){
    	!coalition::setup_coalition_artefact;
    }
    .