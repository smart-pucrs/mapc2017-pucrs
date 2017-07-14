+default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items)
	: true
<- 
	.print("New mission ",Id," deliver to ",Storage," for ",Reward," starting at ",Start," to ",End," or pay ",Fine);
	.print("Items required: ",Items);
	+job(Id, Storage, End, Items);
	!!separate_tasks(mission(Id, Storage, Reward, Start, End, Fine, Items));
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
	clear(CNPBoardName);
	.
	
+!separate_tasks(mission(Id, Storage, Reward, Start, End, Fine, Items))
	: new::max_bid_time(Deadline) & new::number_of_trucks(NumberOfTrucks) & new::number_of_agents(NumberOfAgents)
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
	?default::separateItemTool(B,ListTools,ListItems);
	?default::removeDuplicateTool(ListTools,ListToolsNew);
	+number_of_tasks(.length(ListItems)+.length(ListToolsNew)+1);
	!!announce(assemble(Storage),Deadline,NumberOfTrucks,Id);
	for ( .member(item(ItemId,Qty),ListToolsNew) ) {
		!!announce(tool(ItemId),Deadline,NumberOfAgents,Id);
	}
	for ( .member(item(ItemId,Qty),ListItems) ) {
		!!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Id);
	}
	.
	
@selectBids[atomic]
+bids(item(_,_),_,_)
	: .count(initiator::bids(_,_,_),NumberOfBids) & number_of_tasks(NumberOfTasks) & NumberOfBids == NumberOfTasks
<-
	-number_of_tasks(NumberOfTasks);
	for ( bids(assemble(StorageId),Bids,JobId) ) {
		-bids(assemble(StorageId),Bids,JobId);
		?default::select_bid_assemble(Bids,bid(99999,99999),bid(Agent,Distance));
		if (Distance \== 99999) {
			?initiator::job(JobId, _, _, Items);
			+awarded_assemble(Agent,Items,StorageId,JobId);
//			.print("Awarding assemble to ",Agent);
		}
		else { +impossible_task; .print("Unable to allocate assemble to deliver at ",StorageId); }
	}
	for ( bids(tool(ItemId),Bids,JobId) ) {
		-bids(tool(ItemId),Bids,JobId);
		?default::select_bid_tool(Bids,bid(99999,99999,99999),bid(Agent,Bid,Shop));
		if (Bid \== 99999) {
			getLoad(Agent,Load);
			?default::item(ItemId,Volume,_,_);
	    	addLoad(Agent,Load-Volume);
//	    	.print("Awarding ",ItemId," to ",Agent);
			if (not awarded(Agent,_,_)) {
				+awarded(Agent,Shop,[tool(ItemId)]);
			}
			else {
				?awarded(Agent,Shop,List);
	    		-awarded(Agent,Shop,List);
	    		.concat(List,[tool(ItemId)],NewList);
	    		+awarded(Agent,Shop,NewList);
			}
		}
		else { +impossible_task; .print("Unable to allocate tool ",ItemId); }
	}
	for ( bids(item(ItemId,Qty),Bids,JobId) ) {
		-bids(item(ItemId,Qty),Bids,JobId);
		?default::select_bid(Bids,bid(99999,99999,99999),bid(Agent,Distance,Shop));
		if (Distance \== 99999) {
			getLoad(Agent,Load);
			?default::item(ItemId,Volume,_,_);
	    	addLoad(Agent,Load-Volume*Qty);
//	    	.print("Awarding #",Qty," of ",ItemId," to ",Agent);
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
		else { +impossible_task; .print("Unable to allocate #",Qty," of ",ItemId); }
	}
	if (not impossible_task) {
		?awarded_assemble(AgentA,Items,Storage,Id);
		-awarded_assemble(AgentA,Items,Storage,Id);
		+job_members(Id,[]);
		for (awarded(Agent,Shop,List)) {
			?job_members(Id,Aux);
			-+job_members(Id,[Agent|Aux]);
	    	.send(Agent,tell,winner(List,assist(Storage,AgentA)));
			-awarded(Agent,Shop,List);	
		}
		?job_members(Id,JobMembers);
		-job_members(Id,JobMembers);
//		.print("Job members ",JobMembers);
		.send(AgentA,tell,winner(Items,assemble(Storage,Id,JobMembers)));
	}
	else { -impossible_task; -job(_, _, _, _)[source(_)]; .print("Impossible job, aborting it."); }
	.	
	
+default::step(End)
	: job(Id, _, End, _)
<-
	.print("Job ",Id," failed: deadline.");
	-job(Id, _, End, _);
	.