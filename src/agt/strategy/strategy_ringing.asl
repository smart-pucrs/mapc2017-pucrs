{ include("$jacamoJar/templates/common-cartago.asl") }

{begin namespace(privRinging, local)}

find_remaining_shops_agents([],ShopList,AgentList,Result1, Result2) :- Result1 = ShopList & Result2 = AgentList.
find_remaining_shops_agents([proposalAgent(Shop,Agent,_)|List],ShopList,AgentList,Result1,Result2) :- .delete(Shop,ShopList,NewShopList) & .delete(agents(Agent),AgentList,NewAgentList) & find_remaining_shops_agents(List,NewShopList,NewAgentList,Result1,Result2).

next_agent([],Result) :- Result = [].
next_agent([agents(Agent)|List],Result) :- Result = Agent.

agents_into_the_ring([],Result) :- Result = [].
agents_into_the_ring([agents(Agent)|List],Result) :- Result = List.

find_shop_my_tool(Tool,[],Temp,Result):- Result = Temp.
find_shop_my_tool(Tool,[shop(ShopId,ListItens)|List],Temp,Result):- .member(item(Tool,_,_,_,_,_),ListItems) /*& not .member(ShopId,Temp)*/ & find_shop_my_tool(Tool,List,[ShopId|Temp],Result).
find_shop_my_tools([],ShopList,Temp,Result) :- Result = Temp.
find_shop_my_tools([Tool | Tools],ShopList,Temp,Result):- find_shop_my_tool(Tool,ShopList,Temp,ResultTool) & find_shop_my_tools(Tools,ShopList,[ResultTool|Temp],Result).

//+!ringingFinished
//	: not .desire(goto(_))
//<-
//	-myProposal(_);
//	!free;
//	.
+!ringingFinished
<-
	-myProposal(_);
	.
	
+!create_list_of_proposals(ListOfShops, ListOfProposals)
<-
	+tempProposalsShopRing([]);	
	for (.member(Shop, ListOfShops)){
		?tempProposalsShopRing(InitialList);
		.concat(InitialList,[currentProposal(Shop,"ini1",100,"ini2",100)],NewList);	
		-+tempProposalsShopRing(NewList);
	}
	
	?tempProposalsShopRing(FinalList);	
	ListOfProposals = FinalList;
	-tempProposalsShopRing(FinalList);
	.


+!calculate_steps_required_all_shops
	: .my_name(Me) & default::role(Role, Speed, _, _, Tools) & default::shopList(List) & default::find_shops_id(List,[],ShopsList)
<- 	
	actions.pathsToFacilities(Me, Role, Speed, ShopsList, Proposal);
	-+myProposal(Proposal);	
	.print("My Proposal: ", Proposal);
	
//	.print("#### Calculate My Tools");
//	.findall(shop(ShopId,ListaItens),default::shop(ShopId,_,_,_,ListaItens),Shops)
//
////	?find_shop_my_tools(Tools,Shops,[],ShopsToLook);
//	?find_shop_my_tool(tool1,Shops,[],ShopsToLook);
//	.print("#### ShopsTools: ",ShopsToLook);
//	.print("#### Fim");
	.
+!calculate_steps_required_all_shops
<- 	
	!calculate_steps_required_all_shops;
	.

+!sendAgentsToTheirShops
	: tempAgentsSendProposals(ListShopAgent)
<-
	for (.member(proposalAgent(Shop,Agent,_),ListShopAgent) ){
		.send(Agent,achieve,globalStrategies::go_to_facility(Shop));
	}
	.
+!calculateBestShopToEachAgent
	: tempComparingProposals(Proposals)
<-
	-+tempAgentsSendProposals([]); 
	
	for (.member(currentProposal(Shop,FirstAgent,FirstSteps,SecondAgent,SecondSteps),Proposals) ){		
		
		?tempAgentsSendProposals(InitialList);
		
		if (.member(proposalAgent(ShopProposal,FirstAgent,WorstBetterSteps), InitialList) ){	
			if (FirstSteps > WorstBetterSteps){
				.difference(InitialList,[proposalAgent(ShopProposal,FirstAgent,WorstBetterSteps)],TempProposal);
				.concat(TempProposal,[proposalAgent(Shop,FirstAgent,FirstSteps)],NewProposals);	
				-+tempAgentsSendProposals(NewProposals);
			} 
		} else{
			.concat(InitialList,[proposalAgent(Shop,FirstAgent,FirstSteps)],NewProposals);	
			-+tempAgentsSendProposals(NewProposals);
		}
	}	
 	.
 	
 +!make_proposal(AvailableShops, Proposals, [], AvailableAgents)
	: .my_name(Me)
<-
	!calculate_steps_required_all_shops;
		
	!compare_proposals(AvailableShops, Proposals);
	
	!calculateBestShopToEachAgent;
	
	!sendAgentsToTheirShops;
	
	?tempAgentsSendProposals(ListShopAgent);
	?find_remaining_shops_agents(ListShopAgent,AvailableShops,AvailableAgents,NewAvailableShops,NewAvailableAgents);
	
	!create_list_of_proposals(NewAvailableShops, ListOfProposals);	
	
	?next_agent(NewAvailableAgents, NextAgent);	
	?agents_into_the_ring(NewAvailableAgents, ListAgentsRing);	
	
	if (not .empty(NewAvailableShops)){
		.send(NextAgent,achieve,globalRinging::speak_proposal(NewAvailableShops,ListOfProposals,ListAgentsRing,NewAvailableAgents));
	} else{
		.print("Ringing is Done");
		.broadcast(achieve,ringingFinished);
		
		if(not .length(NewAvailableAgents, 0)) {
			.nth(0, NewAvailableAgents, agents(FreeAgent));
			.send(FreeAgent, tell, allowedToPostJobs);
		}
//		!!default::free;			
	}	
	
	// Clean up
	-tempComparingProposals(_);	
	-tempAgentsSendProposals(_);
	.
+!make_proposal(AvailableShops, Proposals, [agents(NextAgent)|RemainingAgents], AvailableAgents)
	: .my_name(Me)
<-
	!calculate_steps_required_all_shops;

	!compare_proposals(AvailableShops, Proposals);
	
	!send_proposal_next_agent(AvailableShops, NextAgent, RemainingAgents, AvailableAgents);
	
	-tempComparingProposals(_);	
	.
	
+!compare_proposals(AvailableShops, Proposals)
	: .my_name(Me) & myProposal(MyProposal)
<-
	-+tempComparingProposals([]);	
	
	for (.member(proposal(_,Shop,MeSteps), MyProposal)){	
		ShopBusca = Shop;
		if (.member(currentProposal(Shop,FirstAgent,FirstSteps,SecondAgent,SecondSteps),Proposals) ){		
			if (MeSteps < FirstSteps){
				RetSecondAgent 	= FirstAgent;
				RetSecondSteps 	= FirstSteps;
				RetFirstAgent 	= Me;
				RetFirstSteps 	= MeSteps;
			} else{
				if (MeSteps < SecondSteps){
					RetSecondAgent 	= Me;
					RetSecondSteps 	= MeSteps;
					RetFirstAgent 	= FirstAgent;
					RetFirstSteps 	= FirstSteps;
				} else{
					RetSecondAgent 	= SecondAgent;
					RetSecondSteps 	= SecondSteps;
					RetFirstAgent 	= FirstAgent;
					RetFirstSteps 	= FirstSteps;
				}
			}
			
			?tempComparingProposals(InitialList);
			.concat(InitialList,[currentProposal(Shop,RetFirstAgent,RetFirstSteps,RetSecondAgent,RetSecondSteps)],NewProposals);
			-+tempComparingProposals(NewProposals);
		} 
	}
	
	?tempComparingProposals(LastProposals);
	.
	
+!send_proposal_next_agent(AvailableShops, NextAgent, RemainingAgents, AvailableAgents)
	: tempComparingProposals(Proposals)
<-
	.print("Next agent into the list: ",NextAgent);
	.send(NextAgent,achieve,globalRinging::speak_proposal(AvailableShops, Proposals, RemainingAgents, AvailableAgents));
	.

{end}

{begin namespace(globalRinging, global)}
+!speak_proposal(ListOfShops,ListOfProposals,ListOfAgentsWithoutMe,ListOfAgents)
	: true
<- 
	.print("Received a request for making my proposal");
	!privRinging::make_proposal(ListOfShops,ListOfProposals,ListOfAgentsWithoutMe,ListOfAgents);
	.
{end}

+!start_ringing(Me, ListOfAgents, ListOfShops)
	: true
<-
	.print(Me, " is starting ringing");
	
	.delete(agents(Me),ListOfAgents,ListOfAgentsWithoutMe);
	
	!privRinging::create_list_of_proposals(ListOfShops,ListOfProposals);
	
//	.print("List of Proposals: ",ListOfProposals);
	
	!privRinging::make_proposal(ListOfShops,ListOfProposals,ListOfAgentsWithoutMe,ListOfAgents);
	. 
