task_id(0).

@minLon[atomic]
+default::minLon(Lon) : X = Lon + 0.001 & countCenter(I) <- -minLon(Lon); +minLonReal(X); -+countCenter(I+1).
@maxLon[atomic]
+default::maxLon(Lon) : X = Lon - 0.00001 & countCenter(I) <- -maxLon(Lon); +maxLonReal(X); -+countCenter(I+1).
@minLat[atomic]
+default::minLat(Lat) : X = Lat + 0.001 & countCenter(I)  <- -minLat(Lat); +minLatReal(X); -+countCenter(I+1).
@maxLat[atomic]
+default::maxLat(Lat) : X = Lat - 0.00001 & countCenter(I)  <- -maxLat(Lat); +maxLatReal(X); -+countCenter(I+1).

+countCenter(4)
	: minLonReal(MinLon) & maxLonReal(MaxLon) & minLatReal(MinLat) & maxLatReal(MaxLat)
<- 
	-countCenter(4);
	+mapCenter(math.ceil(((MinLat+MaxLat)/2) * 100000) / 100000,math.ceil(((MinLon+MaxLon)/2) * 100000) / 100000);
	.

+default::job(_, _, _, _, _, _) : not accept_jobs.
@job[atomic]
+default::job(Id, Storage, Reward, Start, End, Items)
	: initiator::free_agents(FreeAgents) & initiator::free_trucks(FreeTrucks) & not .length(FreeTrucks,0) & .length(FreeAgents,FreeAgentsN) & FreeAgentsN >= 2
<- 
	!strategies::not_free;
	.print("New job ",Id," deliver to ",Storage," for ",Reward," starting at ",Start," to ",End);
	.print("Items required: ",Items);
	!!evaluate_job(Items, End - Start, Storage, Id, Reward);
	.
+default::job(Id, Storage, Reward, Start, End, Items) <- .print("Ignoring job ",Id).

+default::mission(_, _, _, _, _, _, _, _, _) : not accept_jobs.
@mission[atomic]
+default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items)
	: initiator::free_agents(FreeAgents) & initiator::free_trucks(FreeTrucks) & not .length(FreeTrucks,0) & .length(FreeAgents,FreeAgentsN) & FreeAgentsN >= 2
<- 
	!strategies::not_free;
	+mission(Id, Storage, Items, End, End - Start, Reward);
	.print("New mission ",Id," deliver to ",Storage," for ",Reward," starting at ",Start," to ",End," or pay ",Fine);
	.print("Items required: ",Items);
	?default::steps(TotalSteps);
	?default::step(Step);
	if ( Step + 50 < TotalSteps & Step + 50 < End ) { 
		
		!decompose(Items,ListItems,ListToolsNew);
		!!separate_tasks(Id, Storage, ListItems, ListToolsNew, Items, End);
	}
	else { 
		.print("Mission ",Id," failed evaluation, ignoring it.");
		-mission(Id, Storage, Items, End, End - Start, Reward);
		if  ( not default::winner(_, _) | strategies::waiting ) {
			!!strategies::free; 
		}
	}
	.
+default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items) <- +mission(Id, Storage, Items, End, End - Start, Reward); .print("Ignoring mission ",Id," for now.").
	
+!decompose(Items,ListItems,ListToolsNew)
<-
	?default::decomposeRequirements(Items,[],Bases);
	+bases([],Id);
	for ( .member(Item,Bases) ) {
		?bases(L,Id);
		.concat(L,Item,New);
		-+bases(New,Id);
	}
	?bases(B,Id);
	-bases(B,Id);
	if (.substring("tool",B)) {
		?default::separateItemTool(B,ListTools,ListItems); 
		?default::removeDuplicateTool(ListTools,ListToolsNew);
	}
	else { ListToolsNew = []; ListItems = B; }
	.

+!evaluate_job(Items, Duration, Storage, Id, Reward)
	: new::vehicle_job(Role,Speed) & new::shopList(SList) & new::workshopList(WList) & default::steps(TotalSteps) & default::step(Step) & mapCenter(CLat,CLon) & initiator::free_agents(FreeAgents) & default::get_roles(FreeAgents,[],Roles) & default::get_tools(Roles,[],AvailableTools)
<-
	!decompose(Items,ListItems,ListToolsNew);
	.length(ListToolsNew,NumberOfBuyTool);
	.length(ListItems,NumberOfBuyItem);
	.length(Items,NumberOfAssemble);
	if ( default::check_tools(ListToolsNew,AvailableTools,ResultT) & ResultT == "true" & default::check_buy_list(ListItems,ResultB) & ResultB == "true" & default::check_multiple_buy(ListItems,AddSteps) & default::check_price(ListToolsNew,ListItems,0,ResultP) & .print("Estimated cost ",ResultP * 1.1," reward ",Reward) & ResultP * 1.1 < Reward & actions.farthest(Role,SList,FarthestShop) & actions.route(Role,Speed,CLat,CLon,FarthestShop,_,RouteShop) & actions.closest(Role,WList,Storage,ClosestWorkshop) & actions.route(Role,Speed,FarthestShop,ClosestWorkshop,RouteWorkshop) & actions.route(Role,Speed,ClosestWorkshop,Storage,RouteStorage) & Estimate = RouteShop+RouteWorkshop+RouteStorage+NumberOfBuyTool+NumberOfBuyItem+NumberOfAssemble+AddSteps & .print("Estimate ",Estimate," < ",Duration) & Estimate < Duration & Step + Estimate < TotalSteps ) {
		+estimate(JobId,Step,Estimate);
		!separate_tasks(Id, Storage, ListItems, ListToolsNew, Items, End);
	}
	else { 
		.print("Job ",Id," failed evaluation, ignoring it.");
		if  ( not default::winner(_, _) | strategies::waiting ) {
			!!strategies::free; 
		}
	}
	.

@addCNP[atomic]
+!add_cnp(Id) <- +cnp(Id).
+!separate_tasks(Id, Storage, ListItems, ListToolsNew, Items, End)
	: not cnp(_) & new::max_bid_time(Deadline) & initiator::free_trucks(FreeTrucks) & .length(FreeTrucks,NumberOfTrucks) & initiator::free_agents(FreeAgents) & .length(FreeAgents,NumberOfAgents) 
<-
	!add_cnp(Id);
	+job(Id, Storage, End, Items);
	+number_of_tasks(.length(ListItems)+.length(ListToolsNew)+1,Id);
	!update_taskid(TaskIdA);
//	.print("Creating cnp for assemble task ",Storage," free trucks[",NumberOfTrucks,"]: ",FreeTrucks);
	!!announce(assemble(Storage, Items),Deadline,NumberOfTrucks,Id,TaskIdA,FreeAgents,FreeTrucks);
	for ( .member(item(ItemId,Qty),ListToolsNew) ) {
		!update_taskid(TaskId);
//		.print("Creating cnp for tool task ",ItemId," free agents[",NumberOfAgents,"]: ",FreeAgents);
		!!announce(tool(ItemId),Deadline,NumberOfAgents,Id,TaskId,FreeAgents,FreeTrucks);
	}
	for ( .member(item(ItemId,Qty),ListItems) ) {
		!update_taskid(TaskId);
//		.print("Creating cnp for buy task ",ItemId," free agents[",NumberOfAgents,"]: ",FreeAgents);
		!!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Id,TaskId,FreeAgents,FreeTrucks);
	}
	.
+!separate_tasks(Id, Storage, ListItems, ListToolsNew, Items, End)
<-
	.wait(500);
	!separate_tasks(Id, Storage, ListItems, ListToolsNew, Items, End);
	.

@upTaskId[atomic]
+!update_taskid(TaskId)
	: task_id(TaskIdAux)
<-
	-+task_id(TaskIdAux+1);
	TaskId = TaskIdAux;
	.

+!announce(Task,Deadline,NumberOfAgents,JobId,TaskId,FreeAgents,FreeTrucks)
	: true
<- 
	.concat("cnp_board_",TaskId,CNPBoardName);
//	.print("Creating task ",CNPBoardName);
	makeArtifact(CNPBoardName, "cnp.ContractNetBoard", [Task, Deadline, NumberOfAgents]);
	if (.substring("assemble",Task)) { !send_to_free_trucks(FreeTrucks,Task,CNPBoardName,TaskId); }
	else { !send_to_free_agents(FreeAgents,Task,CNPBoardName,TaskId); }
//	.print("Created cnp ",CNPBoardName," for task ",Task);
	getBidsTask(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0) {		
//		.print("Got bids (",.length(Bids),") for task #",Qty," ",ItemId," Bids: ",Bids);
		+bids(Task,Bids,JobId);
	}
	else {
		.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> No bids ",JobId);
		+bids(Task,[bid(99999,99999,99999,Task,TaskId)],JobId);
	}
	remove[artifact_name(CNPBoardName)];
	.
	
@sendfreetrucks[atomic]
+!send_to_free_trucks(FreeTrucks,Task,CNPBoardName,TaskId)
<-
	for ( .member(Agent,FreeTrucks) ) {
		.send(Agent,tell,task(Task,CNPBoardName,TaskId));
	}
	.
@sendfreeagents[atomic]
+!send_to_free_agents(FreeAgents,Task,CNPBoardName,TaskId)
<-
	for ( .member(Agent,FreeAgents) ) {
		.send(Agent,tell,task(Task,CNPBoardName,TaskId));
	}
	.
	
@selectBids[atomic]
+bids(_,_,JobId)
	: .count(initiator::bids(_,_,JobId),NumberOfBids) & number_of_tasks(NumberOfTasks,JobId) & NumberOfBids == NumberOfTasks & .my_name(Me)
<-
	-number_of_tasks(NumberOfTasks,JobId);
	for ( bids(assemble(StorageId,_),Bids,JobId) ) {
		if ( not initiator::impossible_task(JobId) ) {
			-bids(assemble(StorageId,_),Bids,JobId);
			?default::select_bid_assemble(Bids,bid(99999,99999),bid(Agent,Distance));
			if (Distance \== 99999) {
				?initiator::job(JobId, _, _, Items);
				+awarded_assemble(Agent,Items,StorageId,JobId);
	//			.print("Awarding assemble to ",Agent);
			}
			else { +initiator::impossible_task(JobId); .print("Unable to allocate assemble to deliver at ",StorageId); }
		}
	}
	if ( not initiator::impossible_task(JobId) ) {
		for ( bids(tool(ItemId),Bids,JobId) ) {
			if ( not initiator::impossible_task(JobId) ) {
				-bids(tool(ItemId),Bids,JobId);
				?default::select_bid_tool(Bids,bid(99999,99999,99999),bid(Agent,Distance,Shop));
				if (Distance \== 99999) {
					getLoad(Agent,Load);
					?default::item(ItemId,Volume,_,_);
			    	addLoad(Agent,Load-Volume);
		//	    	.print("Awarding ",ItemId," to ",Agent," at",Shop);
					if (not awarded(Agent,_,_,_)) {
						+awarded(Agent,Shop,[tool(ItemId)],JobId);
					}
					else {
						?awarded(Agent,_,List,JobId);
			    		-awarded(Agent,_,List,JobId);
			    		.concat(List,[tool(ItemId)],NewList);
			    		+awarded(Agent,Shop,NewList,JobId);
					}
				}
				else { +initiator::impossible_task(JobId); .print("Unable to allocate tool ",ItemId); }
			}
		}
		for ( bids(item(ItemId,Qty),Bids,JobId) ) {
			if ( not initiator::impossible_task(JobId) ) {
				-bids(item(ItemId,Qty),Bids,JobId);
				?default::select_bid(Bids,bid(99999,99999,99999),bid(Agent,Distance,Shop));
				if (Distance \== 99999) {
					getLoad(Agent,Load);
					?default::item(ItemId,Volume,_,_);
			    	addLoad(Agent,Load-Volume*Qty);
		//	    	.print("Awarding #",Qty," of ",ItemId," to ",Agent," at",Shop);
					if (not initiator::awarded(Agent,_,_,_)) {
						+awarded(Agent,Shop,[item(ItemId,Qty)],JobId);
					}
					else {
						?awarded(Agent,_,List,JobId);
			    		-awarded(Agent,_,List,JobId);
			    		.concat(List,[item(ItemId,Qty)],NewList);
			    		+awarded(Agent,Shop,NewList,JobId);
					}
				}
				else { +initiator::impossible_task(JobId); .print("Unable to allocate #",Qty," of ",ItemId); }
			}
		}
	}
	if (not initiator::impossible_task(JobId)) {
		?default::joined(org,OrgId);
		!create_scheme(JobId, st, SchArtId,OrgId);
//		debug(inspector_gui(on))[artifact_id(SchArtId)];
		?awarded_assemble(AgentA,Items,Storage,JobId);
		-awarded_assemble(AgentA,Items,Storage,JobId);
		?initiator::free_agents(FreeAgentsA);
		?initiator::free_trucks(FreeTrucksA);
		.delete(AgentA,FreeTrucksA,FreeTrucksNewA);
		-+initiator::free_trucks(FreeTrucksNewA);
		.delete(AgentA,FreeAgentsA,FreeAgentsNewA);
		-+initiator::free_agents(FreeAgentsNewA);
//		.print("Removing ",AgentA," from free lists.");
		for (awarded(Agent,Shop,List,JobId)) {
//			.print("Removing ",Agent," from free lists.");
			?initiator::free_agents(FreeAgents);
			.delete(Agent,FreeAgents,FreeAgentsNew);
			-+initiator::free_agents(FreeAgentsNew);
			?initiator::free_trucks(FreeTrucks);
			if (.member(Agent,FreeTrucks)) {
				.delete(Agent,FreeTrucks,FreeTrucksNew);
				-+initiator::free_trucks(FreeTrucksNew);
			}
	    	.send(Agent,tell,winner(List,assist(Storage,AgentA,JobId)));
			-awarded(Agent,Shop,List,JobId);	
		}
		.send(AgentA,tell,winner(Items,assemble(Storage,JobId)));
		if (initiator::mission(JobId, _, _, _, _, _)) { -initiator::mission(JobId, _, _, _, _, _) }
		-cnp(JobId);
	}
	else { 
		-impossible_task(JobId);
		-cnp(JobId);
		-job(JobId, _, _, _);
		-awarded_assemble(_,_,_,JobId);
		.abolish(initiator::bids(_,_,JobId));
		.abolish(initiator::awarded(_,_,_,JobId));
		.print("Impossible job ",JobId,", aborting it.");
	}
	if ( not default::winner(_, _) | strategies::waiting ) {
		!strategies::free;
	}
	else { !!action::skip; }
	.
+!create_scheme(JobId, st, SchArtId,OrgId) <- org::createScheme(JobId, st, SchArtId)[wid(OrgId)].
-!create_scheme(JobId, st, SchArtId,OrgId) 
<-
	-impossible_task(JobId);
	-cnp(JobId);
	-job(JobId, _, _, _);
	-awarded_assemble(_,_,_,JobId);
	.abolish(initiator::bids(_,_,JobId));
	.abolish(initiator::awarded(_,_,_,JobId));
	.print("Bug with create scheme for ",JobId,", detected, aborting it.");
	.

@addAgentFree[atomic]
+!add_agent_to_free[source(Agent)]
	: initiator::free_agents(FreeAgents)
<-
	-+initiator::free_agents([Agent|FreeAgents]);
	.
@addTruckFree[atomic]
+!add_truck_to_free[source(Agent)]
	: initiator::free_agents(FreeAgents) & initiator::free_trucks(FreeTrucks)
<-
	-+initiator::free_agents([Agent|FreeAgents]);
	-+initiator::free_trucks([Agent|FreeTrucks]);
	for (initiator::mission(Id, Storage, Items, End, Duration, Reward)) { 
		?default::steps(TotalSteps);
		?default::step(Step);
		if ( Step + 50 < TotalSteps & Step + 50 < End ) { 
			!decompose(Items,ListItems,ListToolsNew);
			!!separate_tasks(Id, Storage, ListItems, ListToolsNew, Items, End);
		}
		else { 
			.print("Mission ",Id," failed evaluation, ignoring it.");
			-mission(Id, Storage, Items, End, Duration, Reward);
			if  ( not default::winner(_, _) | strategies::waiting ) {
				!!strategies::free; 
			}
		}
	}
	.
@addMeFree[atomic]
+!add_myself_to_free
	: initiator::free_agents(FreeAgents) & .my_name(Me)
<-
	-+initiator::free_agents([Me|FreeAgents]);
	.
	
@jobFinished[atomic]	
+!job_finished(JobId) 
<- 
	-initiator::job(JobId, _, _, _);
		
	?completed_jobs(Jobs);	// debugging
	-+completed_jobs(Jobs+1);
//	?estimate(JobId,Start,Estimate);
//	?default::step(Step);
//	.print("Finished job ",JobId," at step ",Step," estimated to end in ",Start+Estimate);
//	-estimate(JobId,Start,Estimate);
	.
	
+default::step(End)
	: mission(Id, _, _, End, _, _)
<-
	.print("!!!!!!!!!!!!!!!!! Mission ",Id," failed: deadline."); 
	-initiator::mission(Id, _, _, End, _, _); 
	.
// debugging
+default::step(998)
	: default::money(Money) & completed_jobs(Jobs)
<-	.print("$$$$$$$$$$$$$$$$$$$$ Money $",Money);
	.print("$$$$$$$$$$$$$$$$$$$$ Completed ",Jobs," jobs!").