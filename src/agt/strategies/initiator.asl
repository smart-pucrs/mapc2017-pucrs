free_agents([vehicle1,vehicle2,vehicle3,vehicle4,vehicle5,vehicle6,vehicle7,vehicle8,vehicle9,vehicle10,vehicle11,vehicle12,vehicle13,vehicle14,vehicle15,vehicle16,vehicle17,vehicle18,vehicle19,vehicle20,vehicle21,vehicle22,vehicle23,vehicle24,vehicle25,vehicle26,vehicle27,vehicle28]).
free_trucks([vehicle21,vehicle22,vehicle23,vehicle24,vehicle25,vehicle26,vehicle27,vehicle28]).

@job[atomic]
+default::job(Id, Storage, Reward, Start, End, Items)
	: initiator::free_agents(FreeAgents) & initiator::free_trucks(FreeTrucks) & not .length(FreeTrucks,0) & .length(FreeAgents,FreeAgentsN) & FreeAgentsN >= 2
<- 
	.print("New job ",Id," deliver to ",Storage," for ",Reward," starting at ",Start," to ",End);
	.print("Items required: ",Items);
	+job(Id, Storage, End, Items);
	!!separate_tasks(Id, Storage, Items);
	.
+default::job(Id, Storage, Reward, Start, End, Items) <- .print("Ignoring job ",Id).
	
@mission[atomic]
+default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items)
	: not job(_,_,_,_)
<- 
	.print("New mission ",Id," deliver to ",Storage," for ",Reward," starting at ",Start," to ",End," or pay ",Fine);
	.print("Items required: ",Items);
	+job(Id, Storage, End, Items);
	!!separate_tasks(Id, Storage, Items);
	.
	
+!announce(Task,Deadline,NumberOfAgents,JobId)
<- 
	announce(Task,Deadline,NumberOfAgents,CNPBoardName);
//	.print("Created cnp ",CNPBoardName," for task #",Qty," of ",ItemId);
	getBidsTask(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0) {		
//		.print("Got bids (",.length(Bids),") for task #",Qty," ",ItemId," Bids: ",Bids);
		+bids(Task,Bids,JobId);
	}
	else {
		.print("No bids.");
	}
	remove[artifact_name(CNPBoardName)];
	clear(CNPBoardName);
	.
	
+!separate_tasks(Id, Storage, Items)
	: new::max_bid_time(Deadline) & initiator::free_trucks(FreeTrucks) & .length(FreeTrucks,NumberOfTrucks) & initiator::free_agents(FreeAgents) & .length(FreeAgents,NumberOfAgents)
<-
	?default::decomposeRequirements(Items,[],Bases);
	+bases([]);
	for ( .member(Item,Bases) ) {
		?bases(L);
		.concat(L,Item,New);
		-+bases(New);
	}
	?bases(B);
	-bases(B);
	if (.substring("tool",B)) {
		?default::separateItemTool(B,ListTools,ListItems);
		?default::removeDuplicateTool(ListTools,ListToolsNew);
	}
	else { ListToolsNew = []; ListItems = B; }
	+number_of_tasks(.length(ListItems)+.length(ListToolsNew)+1,Id);
	!!announce(assemble(Storage),Deadline,NumberOfTrucks,Id);
	for ( .member(item(ItemId,Qty),ListToolsNew) ) {
		!!announce(tool(ItemId),Deadline,NumberOfAgents,Id);
	}
	for ( .member(item(ItemId,Qty),ListItems) ) {
		!!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Id);
	}
	.
	
@selectBids[atomic]
+bids(_,_,JobId)
	: .count(initiator::bids(_,_,JobId),NumberOfBids) & number_of_tasks(NumberOfTasks,JobId) & NumberOfBids == NumberOfTasks
<-
	-number_of_tasks(NumberOfTasks,JobId);
	for ( bids(assemble(StorageId),Bids,JobId) ) {
		if ( not initiator::impossible_task ) {
			-bids(assemble(StorageId),Bids,JobId);
			?default::select_bid_assemble(Bids,bid(99999,99999),bid(Agent,Distance));
			if (Distance \== 99999) {
				?initiator::job(JobId, _, _, Items);
				+awarded_assemble(Agent,Items,StorageId,JobId);
	//			.print("Awarding assemble to ",Agent);
			}
			else { +initiator::impossible_task; .print("Unable to allocate assemble to deliver at ",StorageId); }
		}
	}
	for ( bids(tool(ItemId),Bids,JobId) ) {
		if ( not initiator::impossible_task ) {
			-bids(tool(ItemId),Bids,JobId);
			?default::select_bid_tool(Bids,bid(99999,99999,99999),bid(Agent,Distance,Shop));
			if (Distance \== 99999) {
				getLoad(Agent,Load);
				?default::item(ItemId,Volume,_,_);
		    	addLoad(Agent,Load-Volume);
	//	    	.print("Awarding ",ItemId," to ",Agent," at",Shop);
				if (not awarded(Agent,_,_)) {
					+awarded(Agent,Shop,[tool(ItemId)]);
				}
				else {
					?awarded(Agent,_,List);
		    		-awarded(Agent,_,List);
		    		.concat(List,[tool(ItemId)],NewList);
		    		+awarded(Agent,Shop,NewList);
				}
			}
			else { +initiator::impossible_task; .print("Unable to allocate tool ",ItemId); }
		}
	}
	for ( bids(item(ItemId,Qty),Bids,JobId) ) {
		if ( not initiator::impossible_task ) {
			-bids(item(ItemId,Qty),Bids,JobId);
			?default::select_bid(Bids,bid(99999,99999,99999),bid(Agent,Distance,Shop));
			if (Distance \== 99999) {
				getLoad(Agent,Load);
				?default::item(ItemId,Volume,_,_);
		    	addLoad(Agent,Load-Volume*Qty);
	//	    	.print("Awarding #",Qty," of ",ItemId," to ",Agent," at",Shop);
				if (not initiator::awarded(Agent,_,_)) {
					+awarded(Agent,Shop,[item(ItemId,Qty)]);
				}
				else {
					?awarded(Agent,_,List);
		    		-awarded(Agent,_,List);
		    		.concat(List,[item(ItemId,Qty)],NewList);
		    		+awarded(Agent,Shop,NewList);
				}
			}
			else { +initiator::impossible_task; .print("Unable to allocate #",Qty," of ",ItemId); }
		}
	}
	if (not initiator::impossible_task) {
		?awarded_assemble(AgentA,Items,Storage,Id);
		-awarded_assemble(AgentA,Items,Storage,Id);
		?initiator::free_agents(FreeAgentsA);
		?initiator::free_trucks(FreeTrucksA);
		.delete(AgentA,FreeTrucksA,FreeTrucksNewA);
		-+initiator::free_trucks(FreeTrucksNewA);
		.delete(AgentA,FreeAgentsA,FreeAgentsNewA);
		-+initiator::free_agents(FreeAgentsNewA);
//		.print("Removing ",AgentA," from free lists.");
		+job_members(Id,[]);
		for (awarded(Agent,Shop,List)) {
//			.print("Removing ",Agent," from free lists.");
			?initiator::free_agents(FreeAgents);
			.delete(Agent,FreeAgents,FreeAgentsNew);
			-+initiator::free_agents(FreeAgentsNew);
			?initiator::free_trucks(FreeTrucks);
			if (.member(Agent,FreeTrucks)) {
				.delete(Agent,FreeTrucks,FreeTrucksNew);
				-+initiator::free_trucks(FreeTrucksNew);
			}
			?job_members(Id,Aux);
			-+job_members(Id,[Agent|Aux]);
	    	.send(Agent,tell,winner(List,assist(Storage,AgentA)));
			-awarded(Agent,Shop,List);	
		}
		?job_members(Id,JobMembers);
		-job_members(Id,JobMembers);
//		.print("Job members ",JobMembers);
		.send(AgentA,tell,winner(Items,assemble(Storage,Id,JobMembers)));
		?initiator::free_agents(FreeAgents);
		for( .member(FreeAgent,FreeAgents) ) {
			.send(FreeAgent,achieve,strategies::not_selected);
		}
	}
	else { 
		-impossible_task; 
		?initiator::free_agents(FreeAgents);
		for( .member(FreeAgent,FreeAgents) ) {
			.send(FreeAgent,achieve,strategies::not_selected);
		}
		-job(_, _, _, _)[source(_)];
		-awarded_assemble(_,_,_,_);
		.abolish(initiator::bids(_,_,JobId));
		.abolish(initiator::awarded(_,_,_));
		.print("Impossible job, aborting it.");
	}
	.

@add_me_to_free[atomic]
+!add_me_to_free[source(Agent)]
	: initiator::free_agents(FreeAgents)
<-
	-+initiator::free_agents([Agent|FreeAgents]);
	.
@add_me_to_free2[atomic]
+!add_me_to_free2[source(Agent)]
	: initiator::free_agents(FreeAgents) & initiator::free_trucks(FreeTrucks)
<-
	-+initiator::free_agents([Agent|FreeAgents]);
	-+initiator::free_trucks([Agent|FreeTrucks]);
	.
@add_me_to_free3[atomic]
+!add_myself_to_free
	: initiator::free_agents(FreeAgents) & .my_name(Me)
<-
	-+initiator::free_agents([Me|FreeAgents]);
	.
	
+default::step(End)
	: job(Id, _, End, _)
<-
	.print("Job ",Id," failed: deadline.");
	-job(Id, _, End, _);
	.