{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-rules.asl") }
{ include("new-round.asl") }
{ include("strategy/strategies.asl", strategies) }
{ include("server/server.asl", strategies) }


//{ include("new-round.asl") }
//{ include("end-round.asl") }
//{ include("common-plans.asl") }
//{ include("common-rules.asl") }
//{ include("common-actions.asl") }
//{ include("bidder.asl") }
//{ include("common-strategies.asl") }
//{ include("$jacamoJar/templates/common-cartago.asl") }
//{ include("strategies.asl", strategies) }


/* Initial beliefs and rules */

/* Initial goals */


/* Plans */
//+!register(E)
//	: .my_name(Me)
//<- 
//	!new_round;
//    .print("Registering...");
//    register(E);
//    
//    .wait({ +step(_) });
//	if (Me == vehicle6) {
//		!strategies::execute_ringing;	
//	}
//	.
+!register(E)
	: .my_name(Me)
<- 
	!new_round;
    .print("Registering...");
    register(E);
    
    .wait({ +step(_) });
	if (Me == vehicle6) {
		!strategies::execute_ringing;	
	}
	.



//+step(X) : true <-
//	.print("Received step percept.").
	
//+actionID(X) : true <- 
//	.print("Determining my action ",X);
//	action(goto(workshop0));
//	action(skip);
//	.

+step(X) 
	: true 
<-
	!strategies::choose_my_action(X);
	.
	

+lastAction(Action)
	: step(S) & S \== 0 & Action == noAction & noActionCount(Count)
<-
	-+noActionCount(Count+1);
	.print(">>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
+lastActionParams(List)
<- .print(List).	