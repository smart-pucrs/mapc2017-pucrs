{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-actions.asl") }
{ include("common-plans.asl") }
{ include("common-rules.asl") }
{ include("new-round.asl") }
{ include("strategy/coalition.asl", coalition) }
{ include("strategy/strategies.asl", strategies) }

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
    
//    .wait({ +step(_) });
//	if (Me == vehicle6) {
//		!strategies::decomposeItem;
//		
//		!strategies::execute_ringing;	
//	}
	.


//+step(X) : true <-
//	.print("Received step percept.").
	
//+actionID(X) : true <- 
//	.print("Determining my action ",X);
//	action(goto(workshop0));
//	action(skip);
//	.
//+step(X) 
//	: .my_name(Me) & Me == vehicle1 & shop(shop0,Lat,Lon,_,_) & not lat(Lat) & not lon(Lon)
//<-
//	!commitAction(goto(Lat,Lon));
////	actions.route(Role,shop0,Route);
////	.print("Route lenght to shop0: ",Route);
//	.
//	
//+step(X) 
//	: .my_name(Me) & Me == vehicle1 & facility(shop0) & shop(shop0,_,_,_,[item(ItemId,_,_,_,_,_)|Items]) & not done
//<-
//	.print("Items ",ItemId);
//	!commitAction(buy(ItemId,2));
//	+done;
////	!commitAction(goto(shop0));
////	actions.route(Role,shop0,Route);
////	.print("Route lenght to shop0: ",Route);
//	actions.route(Role,shop0,Route);
//	.print("Route lenght to shop0: ",Route);
//	.
//
//+hasItem(Item,Qty)
//<- .print("I have ",Qty," of the item ",Item).
//
//+lastActionResult(Result)
//	: .my_name(Me) & Me == vehicle1 
//<-	.print(Result).

+actionID(X) 
	: X \== 0
<-
//	!commitAction(goto(48.821,2.261)); bottom left
//	!commitAction(goto(48.821,2.40999)); bottom right
//	!commitAction(goto(48.89999,2.261)); top left
//	!commitAction(goto(48.89999,2.40999)); top right
//	!commitAction(goto(48.8802425,2.2982475));
	!strategies::choose_my_action(X);
//	action(goto(48.821,2.2609999999999997));
	.

+lastAction(Action)
	: step(S) & S \== 0 & Action == noAction & noActionCount(Count)
<-
	-+noActionCount(Count+1);
	.print(">>>>>>>>>>> I have done ",Count+1," noActions.");
	.