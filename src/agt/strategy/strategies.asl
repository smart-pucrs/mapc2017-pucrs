{ include("new-round.asl", new) }
{ include("end-round.asl") }
{ include("common-plans.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("bidder.asl") }
{ include("common-strategies.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("strategy/strategy_ringing.asl",ringing) }

{begin namespace(priv, local)}

+!go_to_facility(Facility)
<-
	!goto(Facility);
	?step(S);
	.print("I have arrived at ", Facility, "   -   Step: ",S);
	.send(vehicle15,tell,doneExploration);
	!free;
	.
	 	
 +!generateListOfAgents(ListOfAgents)
	: true /* not initiatorShopChoice */
<-	
//	ListOfAgents = [agents(vehicle1),agents(vehicle2),agents(vehicle3),agents(vehicle4),agents(vehicle5),agents(vehicle6),agents(vehicle7),agents(vehicle8),agents(vehicle9),agents(vehicle10),agents(vehicle11),agents(vehicle12),agents(vehicle13),agents(vehicle14),agents(vehicle15),agents(vehicle16)];
	ListOfAgents = [agents(vehicle1),agents(vehicle2),agents(vehicle3),agents(vehicle4),agents(vehicle5),agents(vehicle6)];
	.	

{end}

+!execute_ringing
	: .my_name(Me) & default::shopList(List) & default::find_shops_id(List,[],ListOfShops)
//	: .my_name(Me) 
<-
	.print("Setting up ringing");
	.print("Lista: ",List);
	+numberAwarded(.length(List));
	
	!priv::generateListOfAgents(ListOfAgents);
	
	!ringing::start_ringing(Me, ListOfAgents, ListOfShops);
	.




