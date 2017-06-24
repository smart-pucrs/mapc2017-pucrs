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