{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("common-actions.asl") }

/* Initial beliefs and rules */

/* Initial goals */


/* Plans */
+!register(E)
<-
    .print("Registering...");
    register(E);
	.


+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action");
	!skip.
