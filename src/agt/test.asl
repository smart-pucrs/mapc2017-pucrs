{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-actions.asl") }
{ include("new-round.asl") }
{ include("strategy/strategies.asl", ringing) }

/* Initial beliefs and rules */

/* Initial goals */


/* Plans */
+!register(E)
	: .my_name(Me)
<- 
	!new_round;
    .print("Registering...");
    register(E);
    
    .wait({ +step(_) });
	if (Me == vehicle6) {
		!ringing::execute_ringing;	
	}
	.


//+step(X) : true <-
//	.print("Received step percept.").
	
+actionID(X) : true <- 
//	.print("Determining my action ",X);
	action(goto(workshop0));
//	action(skip);
	.

+lastAction(Action)
	: step(S) & S \== 0 & Action == noAction & noActionCount(Count)
<-
	-+noActionCount(Count+1);
	.print(">>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
+lastActionParams(List)
<- .print(List).	