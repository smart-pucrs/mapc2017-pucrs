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

evaluateUtilityItem(ItemId,Vol,Utility) :-default::load(MyLoad) 
										& default::role(Role,Speed,LoadCap,_,_) 
										& new::shopList(SList)
//										& (LoadCap - MyLoad >= Vol + 15) 
										& (LoadCap - MyLoad >= Vol) 
										& default::find_shops(ItemId,SList,Shops)
										& actions.closest(Role,Shops,ClosestShop)
										& actions.route(Role,Speed,ClosestShop,RouteShop)
										& Utility = RouteShop.
evaluateUtilityItem(ItemId,Vol,Utility) :- Utility = -1.
evaluateUtilityTool(ItemId,Utility) :- default::role(_,_,_,_,Tools) & .sublist([ItemId],Tools) & Utility = -1.
evaluateUtilityTool(ItemId,Utility) :- Utility = -1.
evaluateUtility(ItemId,Vol,Utility) :- .substring("item",ItemId) & evaluateUtilityItem(ItemId,Vol,Utility).
evaluateUtility(ItemId,Vol,Utility) :- evaluateUtilityTool(ItemId,Utility).


generateSubTaskList(ParentId,[],Temp,Result) :- Result = Temp.
generateSubTaskList(ParentId,[item(BaseItem,Qtd)|List],Temp,Result) :-	default::item(BaseItem,Vol,_,_) 
																	& 	NewVol = Qtd*Vol 
																	& 	evaluateUtility(BaseItem,NewVol,Utility) 
																	& 	.term2string(TermId,ParentId)
																	& 	generateSubTaskList(ParentId,List,[subtask(BaseItem,TermId,NewVol,Utility,tcl,"")|Temp],Result).
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


evaluateUtilityExploration(car,Task,Utility) 		:- (((Task == first)|(Task == second)) & Utility = 1) | (Utility = -1).
evaluateUtilityExploration(drone,Task,Utility) 		:- ((Task == explore) & Utility = 1) | (Utility = -1).
evaluateUtilityExploration(motorcycle,Task,Utility) :- ((Task == shop) & Utility = 1) | (Utility = -1).
evaluateUtilityExploration(truck,Task,Utility) 		:- (((Task == workshop)|(Task == resource)) & Utility = 1) | (Utility = -1).
generateSubTaskListExloration([],Temp,Result) 			:- Result = Temp.
generateSubTaskListExloration([Task|Tasks],Temp,Result) :-default::role(Role,_,_,_,_)
														& evaluateUtilityExploration(Role,Task,Utility) 
														& generateSubTaskListExloration(Tasks,[subtask(Task,exploration,1,Utility,"tcn","")|Temp],Result).

converCoalitionMembers([],Temp,Result) :- Result = Temp.
converCoalitionMembers([agent(Member,_)|Coalition],Temp,Result) :- converCoalitionMembers(Coalition,[Member|Temp],Result).

{end}

{begin namespace(gTaskAllocation, global) }

+coalitionTask(JobId, Requirements)
	: true
<-
	!task_allocation_job(JobId, Requirements);
	.
	
+!task_allocation_exploration(Coalition)
	: default::convertListString2Term(Coalition,[],TermCoalition) & localTask::converCoalitionMembers(TermCoalition,[],NewCoalition)
<-
	.print("Task Allocation Exploration");
	Task = [first,second,explore,shop,shop,workshop,resource];
	?localTask::generateSubTaskListExloration(Task,[],Tasks);
	.print("Tasks: ",Tasks);
	!taProcess::run_distributed_TA_algorithm(communication(coalition,NewCoalition),Tasks,1);
	.
	
+!allocate_job(JobId,Requirements,FreeAgents)
	: default::role(_,_,RoleLoad,_,_) & default::load(MyLoad)
<-
	.print("Initialising Task Allocation ",JobId);
	?localTask::decomposeRequirements(Requirements,[],Bases);
	.print("Itens Base: ",Bases);
	?localTask::generateTaskList(JobId,Bases,[],Tasks);
	.print("Tasks: ",Tasks);
	!taProcess::run_distributed_TA_algorithm(communication(coalition,FreeAgents),Tasks,RoleLoad-MyLoad);
	.

	
{end}



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
	

