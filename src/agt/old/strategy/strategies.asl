{ include("new-round.asl", new) }
{ include("common-plans.asl") }
{ include("common-rules.asl") }
{ include("common-actions.asl") }
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("strategy/strategy_ringing.asl",ringing) }
{ include("strategy/strategy_taskallocation.asl",task) }
{ include("action/actions.asl",action) }

{begin namespace(localStrategies, local)}
	 	
 +!generate_list_of_agents(ListOfAgents)
	: true /* not initiatorShopChoice */
<-	
//	ListOfAgents = [agents(vehicle1),agents(vehicle2),agents(vehicle3),agents(vehicle4),agents(vehicle5),agents(vehicle6),agents(vehicle7),agents(vehicle8),agents(vehicle9),agents(vehicle10),agents(vehicle11),agents(vehicle12),agents(vehicle13),agents(vehicle14),agents(vehicle15),agents(vehicle16)];
	ListOfAgents = [agents(vehicle1),agents(vehicle2),agents(vehicle3),agents(vehicle4),agents(vehicle5),agents(vehicle6)];
	.	

{end}

{begin namespace(globalStrategies, global)}

+!go_to_facility(Facility)
<-
	.print("Going to facility ", Facility);
	!action::goto(Facility);
	?default::step(S);
	.print("I have arrived at ", Facility, "   -   Step: ",S);
//	.send(vehicle15,tell,doneExploration);
//	!free;
	.
	
{end}

+!execute_ringing
	: .my_name(Me) & default::shopList(List) & default::find_shops_id(List,[],ListOfShops)
<-
	.print("Setting up ringing");
	+numberAwarded(.length(List));
	
	!localStrategies::generate_list_of_agents(ListOfAgents);
	
	!ringing::start_ringing(Me, ListOfAgents, ListOfShops);
	.

+!choose_my_action(Step)
	: default::routeLength(R) & R \== 0
<-
//	.print("I'm going to continue my movement at step ",Step);
	!action::continue;
	.
+!choose_my_action(Step)
	: true
<-
//	.print("I'm doing nothing at step ",Step);
	!action::skip;
	.
	
+!decomposeItem
	: true
<-
	.print("Decomposing Item");
	!task::test;
	.