{ include("$jacamoJar/templates/common-cartago.asl") }

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */
+!register(E)
	: .my_name(Me)
<-
    .print("Registering...");
    .concat("eis_art_", Me, ArtName);
    .term2string(Me, MeS);
    makeArtifact(ArtName, "env.EISArtifact", [], AId);
    focus(AId);
    register(E);
	.

+!start : true <- 
	.print("hello massim world.").

+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action");
	skip.
