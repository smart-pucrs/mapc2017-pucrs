{include("taAlgorithm.asl",algorithm)}

{begin namespace(localTask, local) }

//findTools([],Temp, Result) :- Result = Temp.
//findTools([Tool | ListOfTools],Temp,Result) :- .member(item(Tool,_),Temp) & findTools(ListOfTools, Temp,Result).
//findTools([Tool | ListOfTools],Temp,Result) :- not .member(item(Tool,_),Temp) & findTools(ListOfTools, [item(Tool,1) | Temp],Result).
//findParts(Qtd,[],Temp, Result) :- Result = Temp.
//findParts(Qtd,[[PartName,PartQtd] | ListOfPart],Temp,Result) :- (NewQtd = Qtd*PartQtd) & default::item(PartName,_,tools(Tools),parts(Parts)) & decomposeItem(PartName,NewQtd,Tools,Parts,Temp,ListItensJob) & findParts(Qtd,ListOfPart,ListItensJob,Result).
//decomposeItem(Item,Qtd,[],[],Temp,ListItensJob) :- ListItensJob = [item(Item,Qtd) | Temp].
//decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) :- findTools(Tools,Temp,NewTempTools) & findParts(Qtd,Parts,NewTempTools,NewTempParts) & ListItensJob = NewTempParts.
//
//findPartsNoTools([],Temp, Result) :- Result = Temp.
//findPartsNoTools([[PartName,_] | ListOfPart],Temp,Result) :- default::item(PartName,_,_,parts(Parts)) & decomposeItemNoTools(PartName,Parts,Temp,ListItensJob) & findPartsNoTools(ListOfPart,ListItensJob,Result).
//decomposeItemNoTools(Item,[],Temp,ListItensJob) :- ListItensJob = [Item | Temp].
//decomposeItemNoTools(Item,Parts,Temp,ListItensJob) :- findPartsNoTools(Parts,[],NewTempParts) & ListItensJob = NewTempParts.
//
//decomposeRequirements([],Temp,Result):- Result = Temp.
//// ESSA TA COM BUG, QUANDO PRECISA DE MAIS DE UMA TOOL igual, S� RETORNA UMA
////decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- default::item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) & decomposeRequirements(Requirements,ListItensJob,Result).
//decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- default::item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,[],ListItensJob) & decomposeRequirements(Requirements,[compoundedItem(Item,ListItensJob)|Temp],Result).
//decomposeRequirementsNoTools([],Temp,Result):- Result = Temp.
//decomposeRequirementsNoTools([required(Item,_) | Requirements],Temp,Result):- default::item(Item,_,_,parts(Parts)) & decomposeItemNoTools(Item,Parts,[],ListItensJob) & .union(ListItensJob,Temp,New) & decomposeRequirementsNoTools(Requirements,New,Result).

findTools([],Temp, Result) :- Result = Temp.
findTools([Tool | ListOfTools],Temp,Result) :- .member(item(Tool,_),Temp) & findTools(ListOfTools, Temp,Result).
findTools([Tool | ListOfTools],Temp,Result) :- not .member(item(Tool,_),Temp) & findTools(ListOfTools, [item(Tool,1) | Temp],Result).
findParts(Qtd,[],Temp, Result) :- Result = Temp.
findParts(Qtd,[[PartName,PartQtd] | ListOfPart],Temp,Result) :- (NewQtd = Qtd*PartQtd) 
															& 	default::item(PartName,_,tools([]),parts([])) 
															& 	decomposeItem(PartName,NewQtd,Tools,Parts,Temp,ListItensJob) 
															& 	findParts(Qtd,ListOfPart,ListItensJob,Result).
findParts(Qtd,[[PartName,PartQtd] | ListOfPart],Temp,Result) :- (NewQtd = Qtd*PartQtd) 
															& 	default::item(PartName,_,tools(Tools),parts(Parts)) 
															& 	decomposeRequirements([required(PartName,PartQtd)],Temp,ListItensJob)
															& 	findParts(Qtd,ListOfPart,ListItensJob,Result).
decomposeItem(Item,Qtd,[],[],Temp,ListItensJob) 		:- ListItensJob = [item(Item,Qtd) | Temp].
decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) 	:- findTools(Tools,Temp,NewTempTools) & findParts(Qtd,Parts,NewTempTools,NewTempParts) & ListItensJob = NewTempParts.
decomposeRequirements([],Temp,Result):- Result = Temp.
decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- default::item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,[],ListItensJob) & decomposeRequirements(Requirements,[compoundedItem(Item,ListItensJob)|Temp],Result).

removeDuplicateTool([],ListTools). 	
removeDuplicateTool([subtask(required(BaseItem,_),_,_,_,_,_)|B],ListTools) 					
:- 
	.substring("tool",BaseItem) & 
	.member(subtask(required(BaseItem,_),_,_,_,_,_),B) & 
	removeDuplicateTool(B,ListTools).
removeDuplicateTool([Task|B],[Task|ListTools]) :- removeDuplicateTool(B,ListTools).


//evaluateUtilityItem(ItemId,Vol,Utility) :-default::load(MyLoad) 
//										& default::role(Role,Speed,LoadCap,_,_) 
//										& new::shopList(SList)
////										& (LoadCap - MyLoad >= Vol + 15) 
//										& (LoadCap - MyLoad >= Vol) 
//										& default::find_shops(ItemId,SList,Shops)
//										& actions.closest(Role,Shops,ClosestShop)
//										& actions.route(Role,Speed,ClosestShop,RouteShop)
//										& Utility = RouteShop.
//evaluateUtilityItem(ItemId,Vol,Utility) :- Utility = -1.
//evaluateUtilityTool(ItemId,Utility) :- default::role(_,_,_,_,Tools) & .sublist([ItemId],Tools) & Utility = -1.
//evaluateUtilityTool(ItemId,Utility) :- Utility = -1.
//evaluateUtility(ItemId,Vol,Utility) :- .substring("item",ItemId) & evaluateUtilityItem(ItemId,Vol,Utility).
//evaluateUtility(ItemId,Vol,Utility) :- evaluateUtilityTool(ItemId,Utility).
//generateSubTaskList(Item,[],Temp,Result) :- Result = Temp.
//generateSubTaskList(Item,[item(BaseItem,Qtd)|List],Temp,Result) :-default::item(BaseItem,Vol,_,_) 
//																& NewVol = Qtd*Vol 
//																& evaluateUtility(BaseItem,NewVol,Utility) 
//																& generateSubTaskList(Item,List,[subtask(BaseItem,Item,NewVol,Utility,"tcl","")|Temp],Result).
//generateTaskList([],Temp,Result) :- Result = Temp.
//generateTaskList([compoundedItem(Item,ListItensJob)|List],Temp,Result) :- generateSubTaskList(Item,ListItensJob,[],Translated) & .concat(Translated,Temp,NewTemp) & generateTaskList(List,NewTemp,Result).

evaluateUtilityItem(ItemId,TotalVol,Utility) :-	  default::load(MyLoad) 
												& default::role(Role,Speed,LoadCap,_,_) 										
												& (LoadCap - MyLoad >= TotalVol) 
												& default::item(ItemId,Vol,_,_)
												& Qty = (TotalVol / Vol)
												& new::shopList(SList)
												& default::find_shop_qty(item(ItemId, Qty),SList,Buy,99999,Route,99999,"",Facility,99999)
												& Utility = Route.
evaluateUtilityItem(ItemId,Vol,Utility) :- Utility = -1.

evaluateUtilityTool(ItemId,Utility) :- default::role(_,_,_,_,Tools) & .member(ItemId,Tools) & Utility = 1.
evaluateUtilityTool(ItemId,Utility) :- Utility = -1.

evaluateUtilityAssemble(StorageId,Items,Utility) :- default::load(MyLoad) 
												& 	default::total_load(Items,0,Vol) 
												&	default::role(Role, Speed, LoadCap, _, _) 
												&	(LoadCap - MyLoad >= Vol)
												&	new::workshopList(WList)
												&	actions.closest(Role,WList,StorageId,ClosestWorkshop)
												&	actions.route(Role,Speed,ClosestWorkshop,RouteWorkshop)
												&	Utility = RouteWorkshop.
evaluateUtilityAssemble(StorageId,Items,Utility) :- Utility = -1.

evaluateUtility(ItemId,Vol,Utility) :- .substring("item",ItemId) & evaluateUtilityItem(ItemId,Vol,Utility).
evaluateUtility(ItemId,Vol,Utility) :- evaluateUtilityTool(ItemId,Utility).


generateSubTaskList(ParentId,[],Temp,Result) :- Result = Temp.
//generateSubTaskList(ParentId,[item(BaseItem,Qtd)|List],Temp,Result) :-	default::item(BaseItem,Vol,_,_) 
//																	& 	NewVol = Qtd*Vol 
//																	& 	evaluateUtility(BaseItem,NewVol,Utility) 
//																	&	(	
//																			(Utility \== -1
//																		& 	.term2string(TermId,ParentId)
//																		& 	generateSubTaskList(ParentId,List,[subtask(required(BaseItem,Qtd),TermId,NewVol,Utility,tcl,"")|Temp],Result))
//																	|		
//																			(generateSubTaskList(ParentId,List,Temp,Result))
//																		).
generateSubTaskList(ParentId,[item(BaseItem,Qtd)|List],Temp,Result) :-	default::item(BaseItem,Vol,_,_) 
																	& 	NewVol = Qtd*Vol 
																	& 	evaluateUtility(BaseItem,NewVol,Utility)
																	& 	.term2string(TermId,ParentId)
																	& 	generateSubTaskList(ParentId,List,[subtask(required(BaseItem,Qtd),TermId,NewVol,Utility,tcl,"")|Temp],Result).
generateSubTaskList(ParentId,[compoundedItem(Item,ListItensJob)|List],Temp,Result) :- 
																					generateTaskList(ParentId,[compoundedItem(Item,ListItensJob)],[],Translated) 
																				&	.concat(Translated,Temp,NewTemp) 
																				& 	generateSubTaskList(ParentId,List,NewTemp,Result).
generateTaskList(ParentId,[],Temp,Result) :- Result = Temp.
generateTaskList(ParentId,[compoundedItem(Item,ListItensJob)|List],Temp,Result) :- 	
																					.concat(ParentId,Item,NewId)
																				&	generateSubTaskList(NewId,ListItensJob,[],Translated) 
																				& 	.concat(Translated,Temp,NewTemp)
																				& 	generateTaskList(NewId,List,NewTemp,Result).
generateAssembleTask(JobId,StorageId,Items,Temp,Result) :- evaluateUtilityAssemble(StorageId,Items,Utility) 
//												&	(Utility \== -1)
												&	default::total_load(Items,0,Vol)
												&	.concat([subtask(assemble,JobId,Vol,Utility,tcl,"")],Temp,Result).
generateAssembleTask(JobId,StorageId,Items,Temp,Result) :- Result = Temp.

converCoalitionMembers([],Temp,Result) :- Result = Temp.
converCoalitionMembers([agent(Member,_)|Coalition],Temp,Result) :- converCoalitionMembers(Coalition,[Member|Temp],Result).

convertTaskId([],Temp,Result) :- Result = Temp.
convertTaskId([subtask(required(BaseItem,Qtd),ParentId,NewVol,Utility,Type,Unkown)|List],Temp,Result) :- convertTaskId(List,[subtask(BaseItem,ParentId,NewVol,Utility,Type,Unkown)|Temp],Result).

{end}

{begin namespace(gTaskAllocation, global) }

testVetor([]).
testVetor([T|Lista]) :- .print("Na lista: ",T) & testVetor(Lista).
	
+!allocate_job(JobId,StorageId,Requirements,FreeAgents)
	: not default::winner(_,_) & default::role(_,_,RoleLoad,_,_) & default::load(MyLoad)
<-
	.print("Initialising Task Allocation ",JobId);
	?localTask::decomposeRequirements(Requirements,[],Bases);
	.print("Itens Base: ",Bases);	
	?localTask::generateTaskList(JobId,Bases,[],DuplicatedToolsTasks);
//	.print("Tasks: ",DuplicatedToolsTasks);
	?localTask::removeDuplicateTool(DuplicatedToolsTasks,Tasks);
	.print("Tasks: ",Tasks);
	
	Namespace = taProcess;

	+Namespace::task(JobId,StorageId);
	for ( .member(subtask(required(TaskId,Qtd),ParentId,_,_,_,_),Tasks) ) {
        +Namespace::taskBiding(JobId,ParentId,required(TaskId,Qtd),TaskId);
    }
    
    ?localTask::convertTaskId(Tasks,[],ConvertedTasks);
	
	
	?localTask::generateAssembleTask(JobId,StorageId,Requirements,ConvertedTasks,FullTasks);
	.print("Tasks: ",FullTasks);
	
//	!taProcess::run_distributed_TA_algorithm(communication(coalition,FreeAgents),Tasks,RoleLoad-MyLoad);
	!Namespace::run_distributed_TA_algorithm(communication(broadcast,[]),FullTasks,RoleLoad-MyLoad);
	.
	
{end}

+taResults::allocationProcess(ready)
	//: ::taskBiding(JobId,_)
<-
	.findall(TaskId,(taResults::allocatedTasks(TuTask,TuParent) & gTaskAllocation::taskBiding(_,TuParent,TaskId,TuTask)),LTASKS);
//	.findall(Task,taResults::allocatedTasks(Task,ParentId),LTASKS);
	
	?taResults::jobAllocationStatus(STATUS);
	.print("jobAllocationStatus:",STATUS);
	
	if (taResults::assemblerAgent(Ag)){
		.print("assemblerAgent:",Ag);
	}
	
	.length(LTASKS, NTASKS);
	if(NTASKS>0){
		.print("I won ",NTASKS, " tasks!");
		.print("Tasks I won:",LTASKS);
		//.abolish(::taskBiding(JobId,_));
	}
	else {
		.print("I won 0 tasks");
	}
	+winner(LTASKS, assist(Storage, Assembler, JobId))
	.




//+taResults:: allocatedTasks(Task,Parent)
//	: ::taskBiding(JobId,Parent)
//<-
//	.print("I won task ",Task," for ",JobId);
//	.abolish(::taskBiding(JobId,_));
//	.
	
//+default::winner(TaskList, assist(Storage, Assembler, JobId))
//	: default::joined(org,OrgId) & metrics::jobHaveWorked(Jobs)
//<-
//	!strategies::not_free;
//	-+metrics::jobHaveWorked(Jobs+1);
//	lookupArtifact(JobId,SchArtId)[wid(OrgId)];
//	org::focus(SchArtId)[wid(OrgId)];
//	.print("I won the tasks(",JobId,") ",TaskList);
//	org::commitMission(massist)[artifact_id(SchArtId)];
//	.
//+default::winner(TaskList, assemble(Storage, JobId))
//	: default::joined(org,OrgId) & metrics::jobHaveWorked(Jobs)
//<-
//	!strategies::not_free;
//	-+metrics::jobHaveWorked(Jobs+1);
//	lookupArtifact(JobId,SchArtId)[wid(OrgId)];
//	org::focus(SchArtId)[wid(OrgId)];
//	.print("I won the tasks to assemble ",TaskList," and deliver to ",Storage," for ",JobId);
//	org::commitMission(massemble)[artifact_id(SchArtId)];
//	.


+!task_allocation_coalition(JobId, Requirements)
	: true
<-
	.print("Initialising Task Allocation");
	?localTask::decomposeRequirements(Requirements,[],Bases);
	.print("Itens Base: ",Bases);
	?localTask::generateTaskList(Bases,[],Tasks);
	.print("Tasks: ",Tasks);
//	!algorithm::run_distributed_algorithm(communication(coalition,[agent1,agent2]),Tasks);
	.
	

