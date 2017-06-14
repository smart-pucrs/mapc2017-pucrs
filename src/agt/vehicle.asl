{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("strategies/new-round.asl", new) }
{ include("strategies/common-plans.asl", strategies) }

+!register(E)
	: .my_name(Me)
<- 
	!new::new_round;
    .print("Registering...");
    register(E);
    if (Me == vehicle28) {
    	.include("strategies/coalition.asl", coalition);
    }
	.