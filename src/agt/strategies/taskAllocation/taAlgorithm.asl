{include("definitions.asl") }

{begin namespace (taProcess, global)}

taResults::allocationProcess(none).
currentLoad(0).
bidsN(0).
bidLastProcessed(0).
bidLastPreProcessed(0).
scalar(1).
comBidDone(0).
readyMe(false).
zero(0).

@puTLtz//[atomic]
+!run_distributed_TA_algorithm(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD):true
<- 
+jobRun(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD);
+jobIdRun(JobId,yes);
.

@puTLt2z//[atomic]
+!run_distributed_TA_algorithm(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),NO):true
<- 
+jobRun(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),NO);
+jobIdRun(JobId,no);
.

@pbidxjr//[atomic]
+taProcess::jobIdRun(JobId,XX): not taProcess::allocating(true)
<-
!executeNextJob;
.

@pbidxjrs//[atomic]
+!executeNextJob: not taProcess::allocating(true)
<-
.findall(JobId,taProcess::jobIdRun(JobId,XX),LJOBRUN);
.length(LJOBRUN,NJOBS);
if(NJOBS>0){
	.min(LJOBRUN,JOBTORUN);
	//.print("JOBTORUN:",JOBTORUN);
	.print("JOBTORUN:",JOBTORUN);
	if(taProcess::jobIdRun(JOBTORUN,Aloc) & Aloc==yes){
	?taProcess::jobRun(JOBTORUN,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD);
	!run_distributed_TA_algorithm2(JOBTORUN,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD);
    }
    else{
    	if(taProcess::jobIdRun(JOBTORUN,Aloc) & Aloc==no){
    		?taProcess::jobRun(JOBTORUN,communication(COMMUNICATION_TYPE,AGENT_LIST),NO);
			!run_distributed_TA_algorithm2(JOBTORUN,communication(COMMUNICATION_TYPE,AGENT_LIST),NO);
    	}
    }

}
else{
	//.print("No jobs to allocate for now.");
	.print("No jobs on queue to allocate for now.");
}
.




@puTLt//[atomic]
+!run_distributed_TA_algorithm2(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD):taProcess::allocating(true)
<- 
//.print("!run_distributed_TA_algorithm wait:",JobId);
//.print("!run_distributed_TA_algorithm wait:",JobId);
//.wait(10000);
.wait(200);
!run_distributed_TA_algorithm2(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD);
.


@puTL[atomic]
+!run_distributed_TA_algorithm2(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD):not taProcess::allocating(true)
<- 
+taProcess::job(JobId);
-taProcess::allocating(false);
+taProcess::allocating(true);

//.print("!run_distributed_TA_algorithm:",JobId);
.print("!run_distributed_TA_algorithm:",JobId);
//.print("ALg: ",SUBTASKLIST);

!setInitialBeleives;
.time(HH,NN,SS);
.concat(HH,":",NN,":",SS,INITIME);
+initime(INITIME,JobId);
!invertUtility(SUBTASKLIST);
+communicationType(COMMUNICATION_TYPE);
!setAgentList(AGENT_LIST);
+loadCapacity(AVAILABLE_LOAD);
//.findall(subtask(SUBTASK2,TASK2,LOAD2,UTILITY2,TASKTYPE2,ROLE2),taProcess::subtaskReceived(SUBTASK2,TASK2,LOAD2,UTILITY2,TASKTYPE2,ROLE2),LSTK2);
!!prepareTaskList;
.

@puTL2t//[atomic]
+!run_distributed_TA_algorithm2(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),NO):taProcess::allocating(true)
<- 
//.print("!run_distributed_TA_algorithm NO wait:",JobId);
//.print("!run_distributed_TA_algorithm NO wait:",JobId);
//.wait(10000);
.wait(200);
!run_distributed_TA_algorithm2(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),NO);
.


@puTL2[atomic]
+!run_distributed_TA_algorithm2(JobId,communication(COMMUNICATION_TYPE,AGENT_LIST),NO):not taProcess::allocating(true)
<- 
-taProcess::allocating(false);
+taProcess::allocating(true);

////.print("====================================================================================================================================================",JobId);
//.print("!run_distributed_TA_algorithm NO:",JobId);
.print("!run_distributed_TA_algorithm NO:",JobId);
//.wait(5000);
//.wait(20000);
+taProcess::job(JobId);

!setInitialBeleives;
.time(HH,NN,SS);
.concat(HH,":",NN,":",SS,INITIME);
+initime(INITIME,JobId);
//-taProcess::job(XX);
+taProcess::taProcessStatus(done);
+communicationType(COMMUNICATION_TYPE);
!setReadyMe(true);
//-taProcess::readyMe(XX);
//+taProcess::readyMe(true);

//+taProcess::communicateDone;
//!checkReady;
.wait(200);
!communicateDone;
!communicateReadyTeam;
.

@psRMe[atomic]
+!setReadyMe(Value):true
<-
-taProcess::readyMe(XX);
+taProcess::readyMe(Value);
.

@psCL[atomic]
+!setCurrentLoad(Value):true
<-
-taProcess::currentLoad(XXX);
+taProcess::currentLoad(Value);
.


@pSIB[atomic]
+!setInitialBeleives:true
<-
?taProcess::job(JobId);
////.print("!setInitialBeleives");
.abolish(taResults::jobAllocationStatus(_,JobId));
//.abolish(taResults::allocatedTasks(_,_));
-taResults::allocationProcess(XX);
+taResults::allocationProcess(running);
-taResults::assemblerAgent(Ag);
.


@puTLxa[atomic]
+!invertUtility(SUBTASKLIST):true  
<- 
////.print("!invertUtility");
if(taDefinitions::taUtilityGoal(UGOAL) & (UGOAL=="maximize")){
	for (.member(subtask(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE),SUBTASKLIST)) {
		if(UTILITY>-1){
			+taProcess::subtaskReceived(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE);
		}
		+taProcess::subtaskReceivedOriginal(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE);
		}
}
else{
	?taDefinitions::maxUtility(MaxUtility);
	for(.member(subtask(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE),SUBTASKLIST)) {
		
		+taProcess::subtaskReceivedOriginal(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE);
		
		if((MaxUtility-UTILITY)>0){
			if(UTILITY>-1){
				+taProcess::subtaskReceived(SUBTASK,TASK,LOAD,(MaxUtility-UTILITY),TASKTYPE,ROLE);
			}
		}
		else{
			if(UTILITY>-1){
				+taProcess::subtaskReceived(SUBTASK,TASK,LOAD,1,TASKTYPE,ROLE);
			}
		}
	}
}
.



@puTLxaw[atomic]
+!prepareTaskList:true  
<- 
////.print("!prepareTaskList");
.findall(subtask(SUBTASK2,TASK2,LOAD2,UTILITY2,TASKTYPE2,ROLE2),taProcess::subtaskReceived(SUBTASK2,TASK2,LOAD2,UTILITY2,TASKTYPE2,ROLE2),SUBTASKLIST);

//for all subtasks in the task list do
for (.member(subtask(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE),SUBTASKLIST)) {
	
	if(not task(TASK, TASKTYPE)){
		+task(TASK,TASKTYPE);
	}

	if (taDefinitions::typeMin(TYPE,MIN) & TASKTYPE==TYPE & (not (MIN=="N"))){
			+subtask(SUBTASK,TASK);
			+subtaskLoad(SUBTASK,TASK,LOAD);
			+subtaskUtility(SUBTASK,TASK,UTILITY);
	}
	else {
			if (not (subtask(TASK,TASK)) & taDefinitions::typeMin(TYPE,MIN) & TASKTYPE==TYPE & (MIN=="N")){
				+subtask(TASK,TASK);
				+subtaskLoad(TASK,TASK,LOAD);
				+subtaskUtility(TASK,TASK,UTILITY);				
			}
			else {
					if ((subtask(TASK,TASK)) & taDefinitions::typeMin(TYPE,MIN) & TASKTYPE==TYPE & (MIN=="N")){
					?subtaskLoad(TASK,TASK,LOADOLD);
					LOADNEW=LOADOLD+LOAD;
					-subtaskLoad(TASK,TASK,LOADOLD);
					+subtaskLoad(TASK,TASK,LOADNEW);
					
					?subtaskUtility(TASK,TASK,UTILITYOLD);
					UTILITYNEW=UTILITYOLD+UTILITY;
					-subtaskUtility(TASK,TASK,UTILITYOLD);
					+subtaskUtility(TASK,TASK,UTILITYNEW);
					
					}
				}
	}
}
!getMinMaxTaskType;
!!preparetaProcess;
.


@pSAL[atomic]
+!setAgentList(AGLIST): .my_name(Me) 
<-
////.print("!setAgentList");
for (.member(AGENT,AGLIST)) {
	if(not(AGENT==Me)){
		+taProcess::agentCommunicate(AGENT);
	} 
}
.findall(AGENT,taProcess::agentCommunicate(AGENT),AGENTLIST);
+taProcess::agentList(AGENTLIST);
.


@pMinMax//[atomic]
+!getMinMaxTaskType: true 
<-
////.print("!getMinMaxTaskType");
.findall(task(TASK,TYPE),taProcess::task(TASK,TYPE),LTASK);
for (.member(task(TASK,TYPE),LTASK)) {
	//count the subtasks
	 .count(taProcess::subtask(SUBTASK,TASK),NSubTasks);
	?taDefinitions::typeMin(TYPE,MINTYPE);
	?taDefinitions::typeMax(TYPE,MAXTYPE);
	
	if(MINTYPE=="N"){
		+taProcess::taskMin(TASK,NSubTasks);
	}
	else 
	{
		+taProcess::taskMin(TASK,MINTYPE);
	}	
	
	if(MAXTYPE=="N"){
			+taProcess::taskMax(TASK,NSubTasks);
		}
		else{
			+taProcess::taskMax(TASK,MAXTYPE);
		}
}

!getMinMaxLoadTask;
.


@pMinMaxLoad//[atomic]
+!getMinMaxLoadTask: true 
<-
////.print("!getMinMaxLoadTask");
.findall(taskMin(TASK,MinSubTasks),taProcess::taskMin(TASK,MinSubTasks),LTASK);

for (.member(taskMin(TASK,MinSubTasks),LTASK)) {
	+taskMinLoad(TASK,0);
	.findall(LOAD,taProcess::subtaskLoad(SUBTASK,TASK,LOAD),LSTLOAD);
	.sort(LSTLOAD,LSTLOAD2);
	
	for(.range(I,0,MinSubTasks-1)){
		.nth(I,LSTLOAD2,LOADSUBTASK);
		?taskMinLoad(TASK,CURLOAD);
		NEWLOAD=CURLOAD+LOADSUBTASK;
		-taskMinLoad(TASK,CURLOAD);
		+taskMinLoad(TASK,NEWLOAD);
	}
	
}
.

@ps1[atomic]
+!preparetaProcess: true 
<-
!processInitialPriceValues;
!processNetValue;

//ja seta que está alocando para não cair no processamento de bids após estar pronto.
//assim vai fazer todo o primeiro aloc antes de processar os primeiros bids 
//mesma crença é adicionada no inicio do allocateTasks.
//.print("setting taProcess::allocProcess(true)");
+taProcess::allocProcess(true); 

+taProcessStatus(done);
////.print("!preparetaProcess - calling allocateTasks");

!!allocateTasks;
.


@pip0[atomic]
+!processInitialPriceValues[source(self)]:true //.findall(GRP,k(GRP,tcl),LTCL)  
<- 
	.findall(subtask(SUBTASK,TASK),taProcess::subtask(SUBTASK,TASK),LTASK);
	for (.member(subtask(SUBTASK2,TASK2),LTASK)) {
	if (not taProcess::priceGlobal(SUBTASK2,TASK2,XXPG)){
		?zero(ZERO);
		-taProcess::priceGlobal(SUBTASK2,TASK2,XX1);
		+taProcess::priceGlobal(SUBTASK2,TASK2,ZERO);
	}
	-taProcess::priceLocal(SUBTASK2,TASK2,XX2);
	+taProcess::priceLocal(SUBTASK2,TASK2,ZERO);
	}
.

@pa0[atomic]
+!processNetValue[source(self)]:true  
<- 
	.findall(subtask(SUBTASK,TASK),taProcess::subtask(SUBTASK,TASK),LTASK);

	for (.member(subtask(SUBTASK2,TASK2),LTASK)) {
	?taProcess::subtaskUtility(SUBTASK2,TASK2,Vutility);
	?taProcess::priceGlobal(SUBTASK2,TASK2,Vpriceglobal);
	
	VLNEW=Vutility-Vpriceglobal;		
	
		-netValue(SUBTASK2,TASK2,XXX);
		+netValue(SUBTASK2,TASK2,VLNEW);
	
	}
.


//@pip02[atomic]
//+!processInitialPriceGlobalTask(SUBTASK,TASK)[source(self)]:true //.findall(GRP,k(GRP,tcl),LTCL)  
//<- 
//	-taProcess::priceGlobal(SUBTASK,TASK,XX1);
//	+taProcess::priceGlobal(SUBTASK,TASK,0);
//.
//
//@pip03[atomic]
//+!processInitialPriceLocalTask(SUBTASK,TASK)[source(self)]:true //.findall(GRP,k(GRP,tcl),LTCL)  
//<- 
//	-priceLocal(SUBTASK,TASK,XX2);
//	+priceLocal(SUBTASK,TASK,0);
//.
//
//
//@pa02[atomic]
//+!processInitialNetValueTask(SUBTASK,TASK)[source(self)]:true  
//<- 
//	?taProcess::subtaskUtility(SUBTASK,TASK,Vutility);
//	?taProcess::priceGlobal(SUBTASK,TASK,Vpriceglobal);
//	VLNEW=Vutility-Vpriceglobal;		
//	-netValue(SUBTASK,TASK,XXX);
//	+netValue(SUBTASK,TASK,VLNEW);
//.


@p0//[atomic]
+!allocateTasks: true 
<-
//.print("init !allocateTasks");
//.print("!allocateTasks");
if(taProcess::preAllocatedTasks(X1,X2,X3)){
	.count(taProcess::preAllocatedTasks(_,_,_),QtyAllocTasks);
	.findall(LOAD,taProcess::subtaskLoad(SUBTASK,TASK,LOAD) & taProcess::preAllocatedTasks(NVXXXX, SUBTASKalloc, TASKalloc) & (SUBTASK==SUBTASKalloc) & (TASK==TASKalloc),LLOAD);
	TOTLOAD = math.sum(LLOAD);
	!setCurrentLoad(TOTLOAD);
//	-currentLoad(XXX);
//	+currentLoad(TOTLOAD);
}
else{
	!setCurrentLoad(0);
//	-currentLoad(NAx);
//	+currentLoad(0);
}
?taProcess::currentLoad(NA);
?taProcess::loadCapacity(LA);

if ((LA-NA) > 0) { 

!processNetValue;
!processTasks;
!filterCandidates;
!processCandidates;
.findall(bestCandidates(NetValueBC, SubtaskBC, TaskBC),taProcess::bestCandidates(NetValueBC, SubtaskBC, TaskBC),LBESTCAND);
.length(LBESTCAND,NBESTCAND);
if(NBESTCAND>0){
!calculateBids;
}
!cleanAuxLists;

//alterado nesses testes - p1
//-readyMe(XX);
//+readyMe(true);
//
//!checkReady;
//
//if(taProcess::runAllocateTasks(true)){
//	-taProcess::runAllocateTasks(true);
//}
//
//if(taProcess::rerunAllocateTasks(true)){
//		-taProcess::rerunAllocateTasks(XXrerun);
//		-readyMe(XXXX);
//		+readyMe(false);
//		!allocateTasks;
//}

}
else {
	+taProcess::communicateDone;
}
//alterado nesses testes - p1
!setReadyMe(true);
//-taProcess::readyMe(XX);
//+taProcess::readyMe(true);

if(taProcess::runAllocateTasks(true)){
	-taProcess::runAllocateTasks(true);
}

!checkReady;


if(taProcess::rerunAllocateTasks(true)){
		
		-taProcess::rerunAllocateTasks(XXrerun);
		!setReadyMe(false);
//		-taProcess::readyMe(XXXX);
//		+taProcess::readyMe(false);
		!allocateTasks;
}
// end alterado nesses testes - p1

//?taProcess::initime(INITIME,JobId);
//.time(HH,NN,SS);
//.concat(HH,":",NN,":",SS,ENDTIME);
//.print("INITIME:",INITIME);
//.print("ENDTIME prepare:",ENDTIME);
//.wait(500000);


//.print("AllocateTasks - done");
-taProcess::allocProcess(true);

.

@ptk[atomic]
+!processTasks[source(self)]:.findall(TASK,taProcess::task(TASK,TYPE) & (not TYPE==vt),LTASKS)
<- 

for (.member(TASK,LTASKS)) {
	?taProcess::taskMin(TASK,MINTASK);
	?taProcess::taskMax(TASK,MAXTASK);
	?taProcess::taskMinLoad(TASK,TASKMINLOAD);
	.count(taProcess::preAllocatedTasks(VA, SUBTASKalloc, TASKalloc) & (TASK==TASKalloc),QtyAllocTasks);
	 NOTALLOCT=MAXTASK-QtyAllocTasks;
	?taProcess::loadCapacity(LA);
	?taProcess::currentLoad(NA);
	CurrentLoadCapacity=LA-NA; //l'

	if(CurrentLoadCapacity>=TASKMINLOAD){ 
		if(MAXTASK>QtyAllocTasks){ 
			.min([CurrentLoadCapacity,MAXTASK,NOTALLOCT],QtyToAlloc);
			.findall(netValue(NETVALUE,SUBTASK,TASK),taProcess::netValue(SUBTASK,TASK, NETVALUE) & (not taProcess::preAllocatedTasks(VA, SUBTASK,TASK)),LNETVALUE);  //,vij(SUBTK,Vvij) & tk(SUBTK,TASK),LNETVALUE);
			.sort(LNETVALUE,LNETVALUE2);
			.reverse(LNETVALUE2,LNETVALUE3);
			.length(LNETVALUE3,Nsubtasks);

			for(.range(I,0,QtyToAlloc-1)){
				.nth(I,LNETVALUE3,netValue(NETVALUEm, SUBTASKm,TASKm));
			    ?taProcess::subtaskLoad(SUBTASKm,TASKm,LOAD);
			    if (LOAD<=CurrentLoadCapacity){
					+candidate(NETVALUEm, SUBTASKm,TASKm);
				}
			}

			if(taProcess::candidate(VXXXX, SUBTKXXXX, TASK)){
				if (Nsubtasks>QtyToAlloc) {
					.nth(QtyToAlloc,LNETVALUE3,netValue(NETVALUEm2,SUBTASKm2,TASKm2));
					?taProcess::subtaskLoad(SUBTASKm2,TASKm2,LOAD3);
					if (LOAD3<=CurrentLoadCapacity){
					+nextCandidate(NETVALUEm2, SUBTASKm2,TASKm2);					
					}
					else {
			     	+nextCandidate(0, tnext, TASK);	     	
			     	}
					
			     } 
			     else {
			     	+nextCandidate(0, tnext, TASK);	     	
			     }
		     }
		}
	}

}//end for
. 

@paXSD2[atomic]
+!filterCandidates[source(self)]:true  
<- 
!identifyLoadFilters;

+nextBest(0, tnext, gnext);

?taProcess::loadCapacity(LoadCapacity);
?taProcess::currentLoad(CurrentLoad);
FreeLoad=LoadCapacity-CurrentLoad;//to be allocated

.findall(LoadFilter,taProcess::loadFilter(LoadFilter),LFILTERLOAD);
.sort(LFILTERLOAD,LFILTERLOAD2);
.length(LFILTERLOAD2,SIZEFILTERLOAD);

for(.range(I,0,SIZEFILTERLOAD-1)){
	.nth(I,LFILTERLOAD2,FLOAD);
	
	.findall(candidate(NetValueC, SubtaskC, TaskC, FLOAD),taProcess::candidate(NetValueC, SubtaskC, TaskC) & taProcess::subtaskLoad(SubtaskL,TaskL,FLOAD) 
		& (SubtaskC=SubtaskL) & (TaskC=TaskL),LCANDBYFILTER);
	.sort(LCANDBYFILTER,LCANDBYFILTER2);
	.reverse(LCANDBYFILTER2,LCANDBYFILTER3);

	.length(LCANDBYFILTER3,SIZECANDFILTER);
	if(SIZECANDFILTER>0){ 
		QtySubtask = math.round(FreeLoad/FLOAD);
		.min([SIZECANDFILTER,QtySubtask],Nsubtasks);
		-+contWhile(0);
		-+endWhile(Nsubtasks-1);
		?endWhile(TESTEND);
		while(contWhile(CONT) & endWhile(END) & CONT<=END & CONT<SIZECANDFILTER){
			    .nth(CONT,LCANDBYFILTER3,candidate(NetValueX, SubtaskX, TaskX, LoadX));
				if(taProcess::subtaskOwner(SubtaskX, TaskX,TaskOwner)){
					?taProcess::subtaskOwner(SubtaskX, TaskX,TaskOwner);
				}
				else{
					TaskOwner="";
				}
				?taProcess::priceGlobal(SubtaskX, TaskX, PriceGlobalX);
			    !calculateBidTask(SubtaskX,TaskX);			    
			    ?taProcess::preBid(SubtaskX,TaskX,BidCalculated);
				.my_name(Me);
				
				if(BidCalculated>PriceGlobalX){
					+candidateNEW(NetValueX, SubtaskX, TaskX, LoadX);
				}
				else{
					if(BidCalculated<PriceGlobalX){
						?endWhile(TESTEND2);
						NEWTESTEND2=TESTEND2+1;
						-+endWhile(NEWTESTEND2);
						}
					else{ 
						if(BidCalculated==PriceGlobalX){
							if (Me > Owner){
							+candidateNEW(NetValueX, SubtaskX, TaskX, LoadX);
							}
							else{
							?endWhile(TESTEND2);
							NEWTESTEND2=TESTEND2+1;
							-+endWhile(NEWTESTEND2);	
							}
						}
					}
				}
				
			 ?contWhile(CONT2);
			 NEWCONT=CONT2+1;
			 -+contWhile(NEWCONT);
		}
	}
}

.abolish(taProcess::candidate(_,_,_));
.findall(candidateNEW(NetValueX2, SubtaskX2, TaskX2, LoadX2),taProcess::candidateNEW(NetValueX2, SubtaskX2, TaskX2, LoadX2),LCANDNEW);
for (.member(candidateNEW(NetValueX3, SubtaskX3, TaskX3, LoadX3),LCANDNEW)) {
	+candidate(NetValueX3, SubtaskX3, TaskX3);
}
.abolish(taProcess::candidateNEW(_,_,_,_));
.


@ploadfilter[atomic]
+!identifyLoadFilters[source(self)]:true  
<- 
	.findall(LOADVALUE,taProcess::subtaskLoad(SUBTASKL, TASKL, LOADVALUE) & taProcess::candidate(NETVALUE, SUBTASKC, TASKC) & (SUBTASKL==SUBTASKC)  & (TASKL==TASKC),LCANDLOAD);
	.length(LCANDLOAD,SIZECAND);
	if(SIZECAND>0){ 
		for(.range(I,0,SIZECAND-1)){
			.nth(I,LCANDLOAD,LOAD);
			if(not (loadFilter(LOAD))){
				+loadFilter(LOAD);
			}			
		}
	}
.


@paXSD[atomic]
+!processCandidates[source(self)]:true  
<- 
.findall(candidate(NetValueC, SubtaskC, TaskC,LoadL),taProcess::candidate(NetValueC, SubtaskC, TaskC) & taProcess::subtaskLoad(SubtaskL, TaskL,LoadL)
	& (SubtaskC==SubtaskL) & (TaskC==TaskL),LCAND);
.sort(LCAND,LCAND2);
.reverse(LCAND2,LCAND3);

	?taProcess::loadCapacity(LoadCapacity);
	?taProcess::currentLoad(CurrentLoad);
	TBA=LoadCapacity-CurrentLoad;//to be allocated

.my_name(Me);

action.mochila(LCAND3,TBA,Me,BestSelected);
.length(BestSelected,QtySelectedMochila);


if(QtySelectedMochila>0){
	
for (.member(selected(SubtaskSNew,TaskSNew),BestSelected)) {
		?taProcess::candidate(NetValueCNew, SubtaskSNew, TaskSNew);
		+bestCandidates(NetValueCNew, SubtaskSNew, TaskSNew);
		!addAllocatedTask(NetValueCNew, SubtaskSNew, TaskSNew);
	}

	.length(LCAND3,QtySubtasks);
	.min([TBA,QtySubtasks],NTA);

if (QtySubtasks>(NTA)) {
    	.nth(NTA,LCAND3,candidate(NetValueN, SubtaskN, TaskN,LoadN));
		+nextBest(NetValueN, SubtaskN, TaskN);
     } 
     else { 
     	+nextBest(0, tnext, gnext);
	}	

?nextBest(NetValueN, SubtaskN, TaskN);

}//end if
else {
	+taProcess::communicateDone;
}
.


@paddTA[atomic]
+!addAllocatedTask(NetValue, Subtask, Task)[source(self)]:true   
<- 
	+preAllocatedTasks(NetValue, Subtask, Task);
   	?taProcess::subtaskLoad(Subtask,Task,Load);
	?taProcess::currentLoad(CurrentLoad);
	NewLoad=CurrentLoad+Load;
	-+taProcess::currentLoad(NewLoad);
.



@p20axn[atomic]
+!calculateBids: taProcess::bestCandidates(NetValuex, Subtaskx, Taskx) //& not (TKMx==GRPx)
<- 
.findall(bestCandidates(NetValueBC, SubtaskBC, TaskBC),taProcess::bestCandidates(NetValueBC, SubtaskBC, TaskBC),LBCAND);
.length(LBCAND,QtySubtasks);

for(.range(I,0,QtySubtasks-1)){
	.nth(I,LBCAND,bestCandidates(NetValueBC2, SubtaskBC2, TaskBC2));
	?taProcess::priceLocal(SubtaskBC2,TaskBC2,PriceLocal);
	?taProcess::preBid(SubtaskBC2,TaskBC2,NewPrice);
	-taProcess::priceLocal(SubtaskBC2,TaskBC2,XX);
	+taProcess::priceLocal(SubtaskBC2,TaskBC2,NewPrice);
	!updateGlobalPrice(SubtaskBC2, TaskBC2, NewPrice);
}
!communicateBids;
.


@p20axt[atomic]
+!calculateBidTask(SubtaskBC,TaskBC):true
<- 
?taProcess::priceLocal(SubtaskBC,TaskBC,PriceLocal);
?taProcess::netValue(SubtaskBC,TaskBC,NetValue);
?taProcess::nextBest(NetValueNB, SubtaskNB, TaskNB); 
?nextCandidate(NetValueSB, SubtaskSB, TaskBC);
	if(SubtaskSB=tnext){
		NetValueSB=0;
	}
	else {
		if(SubtaskSB=tnextgvt){
			NetValueSB=0;
		}
		else {
			?taProcess::netValue(SubtaskSB, TaskBC, NetValueSB);
		}
	}
.max([NetValueNB,NetValueSB],Vmax);
?scalar(SCL);
NewPrice = PriceLocal + NetValue - Vmax + SCL;
-taProcess::preBid(SubtaskBC,TaskBC,XX);
+taProcess::preBid(SubtaskBC,TaskBC,NewPrice);
.


@pclean[atomic]
+!cleanAuxLists:true
<-  
.abolish(taProcess::candidate(_,_,_));
.abolish(taProcess::bestCandidates(_,_,_));
.abolish(taProcess::nextCandidate(_,_,_));
.abolish(taProcess::nextBest(_,_,_));
.

@pTOtaln[atomic]
+!totalAllocated:true
<-
//.findall(preAllocatedTasks(NetValue, Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LAlloc3);
//.print("Tarefas alocadas:",LAlloc3);
!communicateReadyTeam;
!checkReadyTeam;
.


@pTOtal[atomic]
+!totalAllocated_Tulio:true
<-
//.print("---------------------------------");
.findall(preAllocatedTasks(NetValue, Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LAlloc3);
//.sort(LAlloc,LAlloc2);
//.reverse(LAlloc2,LAlloc3);
//.print("Tarefas alocadas:",LAlloc3);
.print("Tarefas alocadas:",LAlloc3);

-+totalUtility(0);
-+totalUtilityOriginal(0);

	for (.member(preAllocatedTasks(NetValuea, Subtaska, Taska),LAlloc3)) {
	
	if(not Subtaska==Taska){
		?taProcess::subtaskUtility(Subtaska, Taska, UtilityA);
		?taProcess::totalUtility(TotalX);
		LTotal=TotalX;
		NewTotal=LTotal+UtilityA;
		-+totalUtility(NewTotal);
		////.print("NewTotalX:",NewTotal);
		
		?taProcess::subtaskReceivedOriginal(Subtaska, Taska,LOADORIG,UTILITYORIG,TASKTYPEORIG,ROLEORIG);
		?taProcess::totalUtilityOriginal(TotalOrigX);
		LTotalOrig=TotalOrigX;
		NewTotalOrig=LTotalOrig+UTILITYORIG;
		-+totalUtilityOriginal(NewTotalOrig);
		////.print("NewTotalX:",NewTotalOrig);
	}
	else{
		////.print("Task SD por enquanto para nao dar erro");
		.findall(subtask(Subtaska2,Taska,UTILITYORIG),taProcess::subtaskReceivedOriginal(Subtaska2, Taska,LOADORIG,UTILITYORIG,TASKTYPEORIG,ROLEORIG), LSUBTASK);
		 for (.member(subtask(SubtaskSD,TaskSD,UTILITYORIGSD),LSUBTASK)) {
	
			?taProcess::totalUtilityOriginal(TotalOrigX);
			LTotalOrig=TotalOrigX;
			NewTotalOrig=LTotalOrig+UTILITYORIGSD;
			-+totalUtilityOriginal(NewTotalOrig);
			////.print("NewTotalSD:",NewTotalOrig);
		}
			?taProcess::subtaskUtility(Subtaska,Taska,SubtaskUtilityX)
			?taProcess::totalUtility(TotalX);
			LTotal=TotalX;
			NewTotal=LTotal+SubtaskUtilityX;
			-+totalUtility(NewTotal);
			////.print("NewTotalSD:",NewTotal);
	}
	
	}

	//?total(TotXX2);
//	//.print("Total alocado:", TotXX2);
	?taProcess::totalUtility(TotXX3);
	//.print("totalUtility alocado:", TotXX3);
	
	?taProcess::totalUtilityOriginal(TotalOrigX2);
	//.print("totalUtility alocado ORIGINAL:", TotalOrigX2);

	//.print("---------------------------------");
	!communicateReadyTeam;
	!checkReadyTeam;
.


@pbidswest[atomic]
+!checkReadyTeam:true
<-
if(taProcess::job(JobId)){
//?taProcess::job(JobId);
if(not teamReady(JobId)){
	?taDefinitions::agentsBid(NAgBid);
	.count(taProcess::readyAgent(A,JobId),NReadyAg);
	
	if(NAgBid>NReadyAg) {
		////.print("Not all agents ready");
	}
	else {
		//.print("TA process team ready...");
		.print("TA process team ready...");
		+teamReady(JobId);
		!totalAllocatedFinal;
	}
}

}
.

@p26aqxtb[atomic]
+!communicateReadyTeam: .my_name(Me) & taProcess::communicationType(broadcast) 
<-
   ?taProcess::job(JobId);
   	-taProcess::readyAgent(Me,JobId);
   	+taProcess::readyAgent(Me,JobId);
	//.print("!communicateReadyTeam");
	//.print("!communicateReadyTeam");
	.broadcast(tell, taProcess::readyAgent(JobId));
.

@p26aqxast2[atomic]
+!communicateReadyTeam: .my_name(Me) & taProcess::communicationType(coalition) 
   <-
   ?taProcess::job(JobId);
   	-taProcess::readyAgent(Me,JobId);
   	+taProcess::readyAgent(Me,JobId);
	//.print("!communicateReadyTeam");
 	.send(AgentList, tell, taProcess::readyAgent(JobId));
.


@pbidxzt//[atomic]
+taProcess::readyAgent(JobId)[source(A)]:true
<-
   	-taProcess::readyAgent(A,JobId);
   	+taProcess::readyAgent(A,JobId);
   	//!checkReady;
   	!checkReadyTeam;
.

@pTOtalFinal2[atomic]
+!totalAllocatedFinal:job(JobId) & jobIdRun(JobId,no)
<-
//.print("JobId:",JobId);
-taResults::allocationProcess(XX);
+taResults::allocationProcess(closing);
+taResults::jobAllocationStatus(notRun,JobId);
//.print("notRun:",JobId);

-taResults::allocationProcess(XX2);
+taResults::allocationProcess(ready);
+taResults::allocationProcess(ready,JobId);

?taProcess::initime(INITIME,JobId);
.time(HH,NN,SS);
.concat(HH,":",NN,":",SS,ENDTIME);
.print("INITIME:",INITIME);
.print("ENDTIME:",ENDTIME);

//.print("INITIME:",INITIME);
//.print("ENDTIME:",ENDTIME);
!cleanFinalBelieves;
//!printAuxFinal;	
-taProcess::jobRun(JobId,_,_,_);
-taProcess::jobIdRun(JobId,_);
-taProcess::allocating(true);
+taProcess::allocating(false);
//.print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO:");
//.print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO:");
//.wait(10000);
!!executeNextJob;
.

@pTOtalFinal[atomic]
+!totalAllocatedFinal:job(JobId) & jobIdRun(JobId,yes)
<-
//?taProcess::job(JobId);
//.print("JobId:",JobId);

-taResults::allocationProcess(XX);
+taResults::allocationProcess(closing);


.count(taProcess::subtaskOwner(SubTaskf1,Taskf1,Agentf1),NLOWNER);
//.findall(taProcess::subtaskOwner(SubTaskf1,Taskf1,Agentf1),taProcess::subtaskOwner(SubTaskf1,Taskf1,Agentf1),LOWNER);
//.length(LOWNER,NLOWNER);

//.print("  LOWNER:",LOWNER);
//.print(" NLOWNER - ",NLOWNER);

.count(taProcess::subtaskReceivedOriginal(SubTaskf2,Taskf2,Xf2,X2f2,X3f2,X4f2),NLORIG);
//.findall(taProcess::subtaskReceivedOriginal(SubTaskf2,Taskf2,Xf2,X2f2,X3f2,X4f2),taProcess::subtaskReceivedOriginal(SubTaskf2,Taskf2,Xf2,X2f2,X3f2,X4f2),LORIG);
//.length(LORIG,NLORIG);
//.print(" NLORIG - ",NLORIG);

.print("Job tasks: ",NLORIG);
.print("Allocated tasks: ",NLOWNER);

//alterado para teste - p2
//only for the MAS contest
if(NLORIG>NLOWNER) {
	+taResults::jobAllocationStatus(ignored,JobId);
	//.print("ignored:",JobId);
	.print("Ignored:",JobId);
}
else{
	+taResults::jobAllocationStatus(allocated,JobId);
	//.print("allocated:",JobId);
	.print("Allocated:",JobId);
	
}

//alterado para teste - p2
////only for the MAS contest
//if((taProcess::subtaskReceivedOriginal(SubTask,Task,X,X2,X3,X4)) & (not taProcess::subtaskOwner(SubTask,Task,Agent))) {
//	+taResults::jobAllocationStatus(ignored,JobId);
//	//.print("ignored:",JobId);
//}
//else{
//	+taResults::jobAllocationStatus(allocated,JobId);
//	//.print("allocated:",JobId);
//	
//}
//.print("waitingggggg");
//.wait(500000);

if (taResults::jobAllocationStatus(allocated,JobId)){ //this IF is valid only for the MAS contest

//only for the MAS contest
	if(taProcess::subtaskOwner(assemble,JobId,Ag)){
		+taResults::assemblerAgent(Ag,JobId);
//		.my_name(MeAg);
//		if((MeAg==Ag) & (not MeAg==vehicle1)){ //se task assemble é minha e eu não sou o agente 1
//		.print("ASSEMBLER PART - sending createSchema(JobId)");
//		.send(vehicle1, tell, taResults::createSchema(JobId));
//		}
//		else{ //se sou agente 1 
//			if((MeAg==Ag) & (MeAg==vehicle1)){
//				.print("ASSEMBLER PART - ADDING createSchema(JobId)");
//				+taResults::createSchema(JobId);	
//			}
//		}

	}


.findall(preAllocatedTasks(NetValue, Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LAlloc);

////.print("preAllocatedTasks:",LAlloc);
	for (.member(preAllocatedTasks(NetValuea, Subtaska, Taska),LAlloc)) {
	
	if(not Subtaska==Taska){
		+taResults::allocatedTasks(Subtaska, Taska,JobId);
		////.print("+taResults::allocatedTasks: Subtaska:",Subtaska," - Taska:",Taska)
	}
	else{
		////.print("Task SD por enquanto para nao dar erro");
		.findall(subtask(Subtaska2,Taska,UTILITYORIG),taProcess::subtaskReceivedOriginal(Subtaska2,Taska,LOADORIG,UTILITYORIG,TASKTYPEORIG,ROLEORIG), LSUBTASK);
		////.print("Taska:",Taska);
		////.print("LSUBTASK:",LSUBTASK);
		 for (.member(subtask(SubtaskSD,TaskSD,UTILITYORIGSD),LSUBTASK)) {
			+taResults::allocatedTasks(SubtaskSD, TaskSD,JobId);
			////.print("+taResults::allocatedTasks: SubtaskSD:",SubtaskSD," - TaskSD:",TaskSD)
		}
	}
	
	}

	
.findall(taResults::allocatedTasks(Subtask, Task,JobId),taResults::allocatedTasks(Subtask, Task,JobId),LAllocF);
.print("Tarefas alocadas:",LAllocF);


}

-taResults::allocationProcess(XX2);
+taResults::allocationProcess(ready);

+taResults::allocationProcess(ready,JobId);

?taProcess::initime(INITIME,JobId);
.time(HH,NN,SS);
.concat(HH,":",NN,":",SS,ENDTIME);
.print("INITIME:",INITIME);
.print("ENDTIME:",ENDTIME);
//.print("INITIME:",INITIME);
//.print("ENDTIME:",ENDTIME);
!cleanFinalBelieves;
//!printAuxFinal;	
-taProcess::jobRun(JobId,_,_,_);
-taProcess::jobIdRun(JobId,_);
-taProcess::allocating(true);
+taProcess::allocating(false);
//.print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO:");
//.print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO:");
//.wait(10000);
!!executeNextJob;
//.wait(500000);
.


@pzasas//[atomic]
+!printAuxFinal:true
<-
//.print("*********************************************");
//.print("waiting...");
//.wait(5000);
.findall(preAllocatedTasks(Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LPreAlloc);
.sort(LPreAlloc,LPreAlloc2);
//.print("preAllocatedTasks:",LPreAlloc2);
.findall(allocatedTasks(Subtaskx, Taskx),taResults::allocatedTasks(Subtaskx, Taskx),LAlloc);
.sort(LAlloc,LAlloc2);
//.print("AllocatedTasks:",LAlloc2);
//.print("*********************************************");
.




@p22n[atomic]
+!updateGlobalPrice(Subtask,Task,PriceGlobalNew):true 
   <-
////.print("!updateGlobalPrice");
?taProcess::priceGlobal(Subtask,Task,PriceGlobalCurrent);
.my_name(Me);

if (PriceGlobalCurrent > PriceGlobalNew) { 
		!removeAllocatedTask(Subtask,Task);
	   -taProcess::candidate(NetValueX, Subtask,Task);
	   -taProcess::bestCandidates(NetValueX, Subtask,Task);
	   if(not taProcess::rerunAllocateTasks(true)){
			-taProcess::rerunAllocateTasks(XXX);
			+taProcess::rerunAllocateTasks(true);
		}
}

if (PriceGlobalCurrent < PriceGlobalNew) {
  		?taProcess::preAllocatedTasks(NetValue2, Subtask,Task);
		-taProcess::preAllocatedTasks(XX, Subtask,Task);
		+taProcess::preAllocatedTasks(PriceGlobalNew, Subtask,Task); 
		.max([PriceGlobalCurrent,PriceGlobalNew],VmaxPrice);

		if(taProcess::subtaskOwner(Subtask,Task,OldTaskOwner)){
			?taProcess::subtaskOwner(Subtask,Task,OldTaskOwner);
			!updateMissingBid(OldTaskOwner,1);	
		}
		
		!updatePriceGlobal_Owner(vmaxPrice1, Subtask,Task,VmaxPrice,Me);				
		//-taProcess::priceGlobal(Subtask,Task,X);
		//-taProcess::subtaskOwner(Subtask,Task,Name);
		//+taProcess::priceGlobal(Subtask,Task,VmaxPrice);
		//+taProcess::subtaskOwner(Subtask,Task,Me);
		!updateNetValue(Subtask,Task);//X
		+toCommunicate(Subtask,Task,PriceGlobalNew);
}

if (PriceGlobalCurrent == PriceGlobalNew) {
	if (taProcess::subtaskOwner(Subtask,Task,Owner) & (Me > Owner)) {
 		.max([PriceGlobalCurrent,PriceGlobalNew],VmaxPrice);
		if(taProcess::subtaskOwner(Subtask,Task,OldTaskOwner)){
			?taProcess::subtaskOwner(Subtask,Task,OldTaskOwner);
			!updateMissingBid(OldTaskOwner,1);	
		}
		
		
		!updatePriceGlobal_Owner(vmaxPrice2, Subtask,Task,VmaxPrice,Me);				
		//-taProcess::priceGlobal(Subtask,Task,X);
		//-taProcess::subtaskOwner(Subtask,Task,Name);
		//+taProcess::priceGlobal(Subtask,Task,VmaxPrice);
		//+taProcess::subtaskOwner(Subtask,Task,Me);
		!updateNetValue(Subtask,Task);//X
	    +toCommunicate(Subtask,Task,PriceGlobalNew);
	}
	 if (taProcess::subtaskOwner(Subtask,Task,Owner) & (Me < Owner)) {
       !removeAllocatedTask(Subtask,Task);
	   -taProcess::candidate(X, Subtask,Task);
	   -taProcess::bestCandidates(X2,Subtask,Task);
	   if(not taProcess::rerunAllocateTasks(true)){
			-taProcess::rerunAllocateTasks(XXX);
			+taProcess::rerunAllocateTasks(true);
		}

	 } 
	 if (subtaskOwner(Task,Owner) & (Me == Owner)) {
		
	 }
}
.

@premoveTA[atomic]
+!removeAllocatedTask(Subtask, Task)[source(self)]:true   
<- 
if (taProcess::preAllocatedTasks(NetValue, Subtask, Task)){	
		-taProcess::preAllocatedTasks(NetValue, Subtask, Task);
	   	?taProcess::subtaskLoad(Subtask,Task,Load);
		?taProcess::currentLoad(CurrentLoad);
		NewLoad=CurrentLoad-Load;
		-+taProcess::currentLoad(NewLoad);
}
.


@p26ax2[atomic]
+!communicateBids: .my_name(Me) & taProcess::communicationType(broadcast) 
   <-

   	  .findall(taProcess::bid(Subtask,Task,PriceGlobalNew),taProcess::toCommunicate(Subtask,Task,PriceGlobalNew),LBIDS);
   	  .broadcast(tell, taProcess::bids(LBIDS));
   	  .abolish(taProcess::toCommunicate(_,_,_));
//.print("!communicateBids:", LBIDS);
   	  if(not taProcess::initialBid(Me)) {
			+taProcess::initialBid(Me);
			+taProcess::missingBid(Me,0);
	  }
.


@p26cccxa2[atomic]
+!communicateBids: .my_name(Me) & taProcess::communicationType(coalition) 
   <-
   	  .findall(taProcess::bid(Subtask,Task,PriceGlobalNew),taProcess::toCommunicate(Subtask,Task,PriceGlobalNew),LBIDS);
   	  ?taProcess::agentList(AgentList);
	  .send(AgentList, tell, taProcess::bids(LBIDS));
  	  .abolish(taProcess::toCommunicate(_,_,_));
   	  
   	  if(not taProcess::initialBid(Me)) {
			+taProcess::initialBid(Me);
			+taProcess::missingBid(Me,0);
	  }
.


@p26aqx[atomic]
+!communicateDone: .my_name(Me) & taProcess::communicationType(broadcast) 
   <-

   	  ?taProcess::comBidDone(BD);
   	  BDNEW=BD+1;
   	  -taProcess::comBidDone(BD);
   	  +taProcess::comBidDone(BDNEW);
	  //.print("!communicateDone:",BDNEW);
   	  if(not taProcess::initialBid(Me)) {
			+taProcess::initialBid(Me);
			+taProcess::missingBid(Me,0);
	  }

   	  !updateMissingBid(Me,-1);
   	  ?taProcess::job(JobId);

   	  .time(HH,NN,SS);
//   	  .broadcast(tell, taProcess::bid(done,BDNEW));
		  //.broadcast(tell, taProcess::bids(done));
		  //.findall(taProcess::bid(Subtask,Task,PriceGlobalNew),taProcess::toCommunicate(Subtask,Task,PriceGlobalNew),LBIDS);
   	  .broadcast(tell, taProcess::bids([taProcess::bid(done,JobId,BDNEW)]));
.

@p26aqxas[atomic]
+!communicateDone: .my_name(Me) & taProcess::communicationType(coalition) 
   <-
   	   ?taProcess::comBidDone(BD);
   	  BDNEW=BD+1;
   	  -taProcess::comBidDone(BD);
   	  +taProcess::comBidDone(BDNEW);
   	  
   	   if(not taProcess::initialBid(Me)) {
			+taProcess::initialBid(Me);
			+taProcess::missingBid(Me,0);
	  }
	  
   	  !updateMissingBid(Me,-1);
   	  
   	  ?taProcess::agentList(AgentList);
   	  .time(HH,NN,SS);
   	  .send(AgentList, tell, taProcess::bid(done,BDNEW));
.


@p99x[atomic]
+!updateNetValue(Subtask,Task)[source(self)]:true   
<- 
	?taProcess::subtaskUtility(Subtask,Task,Utility);
	?taProcess::priceGlobal(Subtask,Task,PriceGlobal);
	NetValueNEW=Utility-PriceGlobal;
	-netValue(Subtask,Task,XX);
	+netValue(Subtask,Task,NetValueNEW);
. 


@pbidsss[atomic]
+!updateMissingBid(A, ReceivedValue):.my_name(Me)
<-
//.print("!updateMissingBid:",A," - ", ReceivedValue);
if(not (A==Me)){
		?taProcess::missingBid(A,Value);
		-taProcess::missingBid(A,XX);	
		+taProcess::missingBid(A,ReceivedValue);
}
else{
	if(ReceivedValue==1){
		!setReadyMe(false);
//		-taProcess::readyMe(XX);
//		+taProcess::readyMe(false);
	}
}
.

@pbidswes[atomic]
+!checkReady:true
<-
////.print("!checkReady");
if (taProcess::communicateDone){
//	//.print("existe taProcess::communicateDone");
	if(not preprocessingBids(true)){
	//	//.print("e not preprocessingBids(true)");
		if (not ((taProcess::notProcessedBid(XXA,NPB) & (NPB>0)) | taProcess::bidQueue(XNBidsNEW,XLBIDS,XA))){
			////.print("vou comunicar bid done");
			-taProcess::communicateDone;
			!communicateDone;
		} //else {//.print("nao posso comunicar bid done 1");}
	} //else {//.print("nao posso comunicar bid done 2");}
} 


?taDefinitions::agentsBid(NAgBid);
.count(taProcess::missingBid(A,Value),NMissBid);
////.print("NMissBid:",NMissBid);

if(NAgBid>NMissBid)
{
//.print("!checkReady NAgBid>NMissBid");
}
else {
	//.findall(notProcessedBid(AA,ANPB),taProcess::notProcessedBid(AA,ANPB),LNPB);
	//.findall(missingBid(A,Value),taProcess::missingBid(A,Value),LMB);
	//?taProcess::readyMe(VL);
	
	if ((taProcess::notProcessedBid(XXA,NPB) & (NPB>0)) | 
		taProcess::bidQueue(XNBidsNEW,XLBIDS,XA) | 
		taProcess::bidQueuePre(XNBidsNEW2,XLBIDS2,XA2) |
		taProcess::bidQueuePro(XNBidsNEW3,XLBIDS3,XA3)  
	){
		//.print("!checkReady notProcessedBid > 0 | bidQueue | bidQueuePre | bidQueuePro");
	}
	else {
		if(taProcess::missingBid(A,Value) & (Value>0)){
			////.print("taProcess::missingBid(A,Value) & (Value>0)");
			
			.count(taProcess::missingBid(A,Value) & (Value>0),NLMBX);
//			.findall(missingBid(A,Value),taProcess::missingBid(A,Value) & (Value>0),LMBX);
//			.length(LMBX,NLMBX);
			if(NLMBX>0){
			//.print("!checkReady missingBid value > 0:",LMBX);
			}
		}
		else {
				if (taProcess::readyMe(false)){
					//.print("!checkReady taProcess::readyMe(false)");
			}
			else{
				if(preprocessingBids(true)){
					//.print("!checkReady preprocessingBids(true)");
				}
				else {
					//.print("TA process ready...");
					.print("TA process ready...");
					!totalAllocated;
					//!totalAllocatedFinal;
				}
			
			}
		}
	}
}

.


@pbidxz2//[atomic]
+!processbidDone(BDNEW,A): (taProcess::notProcessedBid(XA,NotP) & NotP>0) | (taProcess::bidQueue(XNBids,XLBIDS,XXA)) 
| (taProcess::bidQueue(X2NBids,X2LBIDS,X2XA)) | (not taResults::allocationProcess(running))
<-
////.print("!processbidDone wait:",A," BD:",BDNEW);
.wait(200);
!processbidDone(BDNEW,A);
.


@pbidxz3[atomic]
+!processbidDone(BDNEW,A): (not taProcess::notProcessedBid(XXA,XXX)) | (taProcess::notProcessedBid(XA,NotP) & NotP<=0) 
<-
////.print("!processbidDone");
//.print("!processbidDone from:",A," BD:",BDNEW);

if (taResults::allocationProcess(running)){
	if(taProcess::missingBid(A,Value) & (Value>0)){
		+taProcess::doneBid(A);
		!updateMissingBid(A,-1);
		!checkReady;
	}
	else{
		if(taProcess::missingBid(A,Value) & (Value<1)){
			
		}
		else{ 
				if(not taProcess::missingBid(A,Value)){
					+taProcess::doneBid(A);
					+taProcess::missingBid(A,-1);
					!checkReady;
				}
			}
	}
	
}
else{ 
	.findall(bid(done,XAX),taProcess::bid(done,XAX),LBD);
	//.print("abolishing bid(done,_):",LBD);
	.abolish(taProcess::bid(done,_)[source(A)]); 
}
.


//@pbidx2as//[atomic]
//+taProcess::bid(done,BDNEW)[source(A)]:taProcess::allocating(false)
//<-
//////.print("Ignoring bid done");
//-taProcess::bid(done,BDNEW)[source(A)];
//.


@pbidxz//[atomic]
+taProcess::bid(done,BDNEW)[source(A)]:true
<-
////.print("+taProcess::bid(done,BDNEW) from:",A," BD:",BDNEW);
!processbidDone(BDNEW,A);
.

//@pbidxz//[atomic]
//+taProcess::bid(done,BDNEW)[source(A)]:true
//<-
////.print("+taProcess::bid(done,BDNEW) 2");
//!processbidDone(BDNEW,A);
//.


@paddBidN[atomic]
+!increaseBidsN[source(A)]:true
<-
?taProcess::bidsN(NBids);
NBidsNEW=NBids+1;
-bidsN(NBids);
+bidsN(NBidsNEW);
.

//@pbidx2ASF//[atomic]
//+taProcess::bids(LBIDS)[source(A)]:taProcess::allocating(false)
//<-
//////.print("Ignoring bids");
//-taProcess::bids(LBIDS)[source(A)];
//.

//@pbidx2s//[atomic]
//+taProcess::bids(LBIDS)[source(A)]:job(JobId) & jobIdRun(JobId,no)
//<-
//.print("Not participating - Ignoring bids for jobId:",JobId);
//.

@pbidx2//[atomic]
+taProcess::bids(LBIDS)[source(A)]:true //job(JobId) & jobIdRun(JobId,yes)
<-
////.print("+taProcess::bids(LBIDS)");
!increaseBidsN;
?taProcess::bidsN(NBids);
+taProcess::bidQueuePre(NBids,LBIDS,A);
////.print("BIDS RECEBIDOS - taProcess::NBids:",NBids," taProcess::bids:",LBIDS," SOURCE:",A);
!!preProcessBids;
.

@paddnp[atomic]
+!addNotProcessedBid(A):true
<-
if(not taProcess::notProcessedBid(A,XPMB)){
	////.print("!adding new notProcessedBid:",A);
	+taProcess::notProcessedBid(A,0);
}
.


@pbidx2n2//[atomic]
+!preProcessBids: preprocessingBids(true) | not taProcess::taProcessStatus(STATUS)
<-
.wait(200);
!!preProcessBids;
.

@pbidx2cn//[atomic]
+!preProcessBids: (not preprocessingBids(true)) & job(JobId) & jobIdRun(JobId,no)
<-
+preprocessingBids(true);
//.print("Not participating - Ignoring bids for jobId:",JobId);
.abolish(taProcess::bidQueuePre(_,_,_));
-preprocessingBids(true);
.

@pbidx2Scn//[atomic]
+!preProcessBids: (not preprocessingBids(true)) & job(JobId) & jobIdRun(JobId,yes) & taResults::allocationProcess(ready,JobId)
<-
//.print("Not preProcessed bid - received after close TA process for jobId::",JobId);
//.print("Not preProcessed bid - received after close TA process for jobId:",JobId);
.abolish(taProcess::bidQueuePre(_,_,_));
.



@pbidx2n//[atomic]
+!preProcessBids: (not preprocessingBids(true)) & job(JobId) & jobIdRun(JobId,yes)
<-
+preprocessingBids(true);
!increaseBidLastPreProcessed;
?taProcess::bidLastPreProcessed(BIDLASTP);
?taProcess::bidQueuePre(BIDLASTP,LBIDS,A);
////.print("BIDS RECEBIDOS - !preProcessBids - BIDLASTP:",BIDLASTP," - ",LBIDS," SOURCE:",A);

if(not taProcess::missingBid(A,XMB)){
	////.print("!adding new missingBid:",A);
	+taProcess::missingBid(A,0);
}

!addNotProcessedBid(A);
//if(not taProcess::notProcessedBid(A,XPMB)){
//	////.print("!adding new notProcessedBid:",A);
//	+taProcess::notProcessedBid(A,0);
//}

!increaseNotProcessedBid(A);

!updateQueuePrePro(BIDLASTP,LBIDS,A);
//+taProcess::bidQueuePro(BIDLASTP,LBIDS,A);
//-taProcess::bidQueuePre(BIDLASTP,LBIDS,A);


if(not processingBids(true)){
////.print("chamando !!processBids");
//.print("preproc chamando !!processBids");
!!processBids;	
}

-preprocessingBids(true);
.

@puPrePro[atomic]
+!updateQueuePrePro(BIDLASTP,LBIDS,A):true
<-
+taProcess::bidQueuePro(BIDLASTP,LBIDS,A);
-taProcess::bidQueuePre(BIDLASTP,LBIDS,A);
.


@paddBidNs2[atomic]
+!increaseBidLastPreProcessed:true
<-
?taProcess::bidLastPreProcessed(BIDLASTP_OLD);
BIDLASTP=BIDLASTP_OLD+1;
-taProcess::bidLastPreProcessed(BIDLASTP_OLD);
+taProcess::bidLastPreProcessed(BIDLASTP);
.

@paddBidNs3[atomic]
+!increaseNotProcessedBid(A):true
<-
//if(taProcess::notProcessedBid(A,XPMB)){
	////.print("!increaseNotProcessedBid:",A);
	?taProcess::notProcessedBid(A,XNPB);
	XNPBNEW=XNPB+1;
	-taProcess::notProcessedBid(A,_);
	+taProcess::notProcessedBid(A,XNPBNEW);
	//+taProcess::notProcessedBid(A,0);
//}
//else{
//	//.print("!adding new notProcessedBid:",A);
//	+taProcess::notProcessedBid(A,0);
//}
.

@paddBidNs3v2[atomic]
+!decreaseNotProcessedBid(A):true
<-
////.print("!decreaseNotProcessedBid:",A);
?taProcess::notProcessedBid(A,XNPB);
XNPBNEW=XNPB-1;
-taProcess::notProcessedBid(A,_);
+taProcess::notProcessedBid(A,XNPBNEW);
.

@paddBidNs4[atomic]
+!increaseBidLastProcessed:true
<-
?taProcess::bidLastProcessed(BIDLASTP_OLD);
BIDLASTP=BIDLASTP_OLD+1;
-taProcess::bidLastProcessed(BIDLASTP_OLD);
+taProcess::bidLastProcessed(BIDLASTP);
.


@pbidsListNt//[atomic]
+!processBids:(not taProcess::taProcessStatus(STATUS)) | taProcess::allocProcess(true)
<-
////.print("waiting !processBids");
.wait(500);
!!processBids;
.

@pbidsListNtsd//[atomic]
+!processBids: (taProcess::taProcessStatus(STATUS) & (STATUS==done)) & processingBids(true) & (not taProcess::keepProcessingBids(true)) 
<-
//.print("I'm processing bids - do not calling !processBids again...");
XQW=0;
.


@pbidsToProcess[atomic]
+!setBidsToProcess:taProcess::bidLastProcessed(BIDLASTP)
<-
//.findall(taProcess::bidQueuePro(BIDQUEUE,LBIDS,A), taProcess::bidQueuePro(BIDQUEUE,LBIDS,A),LBIDSTOPROCx3);
////.print(LBIDSTOPROCx3);
//.findall(taProcess::bidQueuePro(BIDQUEUE,LBIDS,A), taProcess::bidQueuePro(BIDQUEUE,LBIDS,A) & (BIDQUEUE>BIDLASTP),LBIDSTOPROC);
.findall(taProcess::bidQueuePro(BIDQUEUE,LBIDS,A), taProcess::bidQueuePro(BIDQUEUE,LBIDS,A),LBIDSTOPROC);
////.print("LBIDSTOPROC:",LBIDSTOPROC);
//precisa reverter se tiver q pegar os x primeiros
for (.member(taProcess::bidQueuePro(BIDQUEUE,LBIDS,A),LBIDSTOPROC)) {
	+taProcess::bidQueue(BIDQUEUE,LBIDS,A);
	-taProcess::bidQueuePro(BIDQUEUE,LBIDS,A);
}

////.wait(10000);
//.findall(taProcess::bidQueuePro(BIDQUEUE2,LBIDS2,A2), taProcess::bidQueuePro(BIDQUEUE2,LBIDS2,A2) & (BIDQUEUE2>BIDLASTP),LBIDSTOPROCX2);
////.print(LBIDSTOPROCX2);
.findall(taProcess::bidQueue(BIDQUEUE3,LBIDS3,A3), taProcess::bidQueue(BIDQUEUE3,LBIDS3,A3),LBIDSTOPROCX);
////.print("LBIDSTOPROCX:",LBIDSTOPROCX);
////.wait(15000);
.

@pbidsListvaqwc[atomic]
+!processBids:(taProcess::taProcessStatus(STATUS) & (STATUS==done)) & (not processingBids(true) | keepProcessingBids(true)) & (not taProcess::allocProcess(true)) & taProcess::bidLastProcessed(BIDLASTP) &
(not taProcess::bidQueuePro(BIDQUEUEc,LBIDSc,Ac)) //& (BIDQUEUE==(BIDLASTP+1))
<-
X2=0;
//.print("NAO TEM COMO PROCESSAR NADA");
//.wait(500000);
.

@pbidsListvc//[atomic]
+!processBids:(taProcess::taProcessStatus(STATUS) & (STATUS==done)) & (not processingBids(true) | keepProcessingBids(true)) & (not taProcess::allocProcess(true)) & taProcess::bidLastProcessed(BIDLASTP) &
taProcess::bidQueuePro(BIDQUEUEc,LBIDSc,Ac) //& (BIDQUEUE==(BIDLASTP+1))
<-
+processingBids(true);
-keepProcessingBids(true);
//.print("starting !processBids");
//.print("starting !processBids");

!setBidsToProcess;

.findall(taProcess::bidQueue(BIDQUEUEf,LBIDSf,Af), taProcess::bidQueue(BIDQUEUEf,LBIDSf,Af),LBIDSRUN);
////.print("LBIDSRUN:",LBIDSRUN);
.sort(LBIDSRUN,LBIDSRUN2);
//.print("LBIDSRUN2:",LBIDSRUN2);
.length(LBIDSRUN2,NLBIDSRUN2);
//.print("length LBIDSRUN2:",NLBIDSRUN2);

for (.member(taProcess::bidQueue(BIDQUEUE,LBIDS,A),LBIDSRUN2)) {
!increaseBidLastProcessed;
//?taProcess::bidLastProcessed(BIDLASTP);
//?taProcess::bidQueue(BIDLASTP,LBIDS,A);
////.print("BIDQUEUE:",BIDQUEUE);
//.print("BIDS RECEBIDOS - !processBids: BIDQUEUE:",BIDQUEUE," - ",LBIDS," SOURCE:",A);

-bidIgnorado(A,XX);
+bidIgnorado(A,false);

for (.member(taProcess::bid(Subtask,Task,VBid),LBIDS)) {

if(not taProcess::initialBid(A)){
	+taProcess::initialBid(A);
	+taProcess::missingBid(A,0);
}

if(taProcess::subtask(Subtask,Task)){ //IF TASK CONHECIDA
////.print("TASK CONHECIDA:",Subtask," - ",Task);

?taProcess::priceGlobal(Subtask,Task,PriceGlobal);

if (VBid < PriceGlobal) {
////.print("VBid < PriceGlobal");
-bidIgnorado(A,XX);
+bidIgnorado(A,true);
}

if (VBid > PriceGlobal) {
 //	//.print("VBid > PriceGlobal");
 	if (taProcess::subtaskOwner(Subtask,Task,CurrentOwner)){
 	?taProcess::subtaskOwner(Subtask,Task,CurrentOwner);
 	!updateMissingBid(CurrentOwner,1);
 	}
	
	!updatePriceGlobal_Owner(vbid1,Subtask,Task,VBid,A) 	
	!updateNetValue(Subtask,Task);
	!update_assign_info(Subtask, Task, VBid);	
}
if (VBid == PriceGlobal) {
//	//.print("VBid == PriceGlobal");
	?taProcess::subtaskOwner(Subtask,Task,OName);
	if (A < OName) {
	////.print("A < OName");
	-bidIgnorado(A,XX);
	+bidIgnorado(A,true);
	}
	if (A > OName) { 
	////.print("A > OName");
	if (taProcess::subtaskOwner(Subtask,Task,CurrentOwnerX1)){
 	?taProcess::subtaskOwner(Subtask,Task,CurrentOwner);
 	!updateMissingBid(CurrentOwner,1);
 	}
	!updatePriceGlobal_Owner(vbid2,Subtask,Task,VBid,A)
	!updateNetValue(Subtask,Task);
	!update_assign_info(Subtask, Task, VBid);
	}
}

}//end IF TASK CONHECIDA
else {
	if(Subtask==done){ //IF DONE RECEIVED
	//.print("!processbidDone from:",A," BD:",BDNEW, " for job: ",Task);
	if (taResults::allocationProcess(running)){
		if(taProcess::missingBid(A,Value) & (Value>0)){
			+taProcess::doneBid(A);
			!updateMissingBid(A,-1);
			//!checkReady;
		}
		else{
			if(taProcess::missingBid(A,Value) & (Value<1)){
				
			}
			else{ 
					if(not taProcess::missingBid(A,Value)){
						+taProcess::doneBid(A);
						+taProcess::missingBid(A,-1);
						//!checkReady;
					}
				}
		}
		
	}
	else{ 
		//.findall(bid(done,XAX),taProcess::bid(done,XAX),LBD);
		//.print("abolishing bid(done,_):",LBD);
		.abolish(taProcess::bid(done,_)[source(A)]); 
	}
	}//end IF DONE RECEIVED

else{ 
	//else TASK NAO CONHECIDA
	////.print("TASK NAO CONHECIDA:",Subtask," - ",Task);

	if (not taProcess::priceGlobal(Subtask,Task,PriceGlobalx)){
		?zero(ZERO);
		+taProcess::priceGlobal(Subtask,Task,ZERO);
	}
	
	?taProcess::priceGlobal(Subtask,Task,PriceGlobal);

if (VBid < PriceGlobal) {
-bidIgnorado(A,XX);
+bidIgnorado(A,true);
}

if (VBid > PriceGlobal) {
 	if (taProcess::subtaskOwner(Subtask,Task,CurrentOwner)){
 	?taProcess::subtaskOwner(Subtask,Task,CurrentOwner);
 	!updateMissingBid(CurrentOwner,1);
 	}
	!updatePriceGlobal_Owner(vbid3,Subtask,Task,VBid,A)	
}
if (VBid == PriceGlobal) {
	?taProcess::subtaskOwner(Subtask,Task,OName);
	if (A < OName) {
	-bidIgnorado(A,XX);
	+bidIgnorado(A,true);
	}
	if (A > OName) {
	if (taProcess::subtaskOwner(Subtask,Task,CurrentOwnerX)){
 	?taProcess::subtaskOwner(Subtask,Task,CurrentOwner);
 	!updateMissingBid(CurrentOwner,1);
 	}
	!updatePriceGlobal_Owner(vbid4,Subtask,Task,VBid,A)
	}
}
}//end else TASK NAO CONHECIDA
}//end ELSE - //IF DONE RECEIVED
////.print("END1 BIDS RECEBIDOS - !processBids:",LBIDS," SOURCE:",A);
}//end for BIDS

if (taProcess::bidIgnorado(A,true)){
	!updateMissingBid(A,1);
}
else{
	if (taProcess::bidIgnorado(A,false)){
	!updateMissingBid(A,-1);
	}
	else{
		
	}	
}
////.print("removendo -taProcess::bidQueue(BIDQUEUE,LBIDS,A):",BIDQUEUE," - ",A);
-taProcess::bidQueue(BIDQUEUE,LBIDS,A);

!decreaseNotProcessedBid(A);

//.print("END2 BIDS RECEBIDOS - !processBids:",LBIDS," SOURCE:",A);

}//end for lista bids para processar

////.print("END LISTA DE TODOS BIDS SELECIONADOS...");

!checkRunAgain;

.findall(taProcess::bidQueuePro(BIDQUEUE,LBIDS,A), taProcess::bidQueuePro(BIDQUEUE,LBIDS,A),LBIDSTOPROCXX);
//.print("LBIDSTOPROCXX:",LBIDSTOPROCXX);
//.print("FINAL processo bids disponívis - 1 vez");
//.print("FINAL processo bids disponívis - 1 vez");
//.wait(15000);

if(taProcess::runAllocateTasks(true)){
	////.print("chamando !allocateTasks");
	+taProcess::allocProcess(true);
	!!allocateTasks;
}
else
{ 
  ////.print("chamando !checkready");
  !checkReady; 
}


if (taProcess::bidQueuePro(BIDQUEUEX,LBIDSX,AX)){
	////.print("Entrou aqui...");
	+taProcess::keepProcessingBids(true);
	//.print("keepProcessingBids chamando !!processBids");
	!!processBids;
}
else{
	//.print("retirar -processingBids(true) aqui");
	-taProcess::processingBids(true);
}

.

//-!processBids:(taProcess::taProcessStatus(STATUS) & (STATUS==done)) & not processingBids(true)
//<-
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//.findall(taProcess::priceGlobal(SB,T,PG),taProcess::priceGlobal(SB,T,PG),LPG);
//print("-processBids:",LPG);
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	//.print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
//	.wait(500000);
//.

@pupgo[atomic]
+!updatePriceGlobal_Owner(Chamada,Subtask,Task,ValueBid,Agent):true
<-
//.print("I !updatePriceGlobal_Owner:",Subtask," - ",Task);
	-taProcess::priceGlobal(Subtask,Task,OlvValue);
	+taProcess::priceGlobal(Subtask,Task,ValueBid);
	-taProcess::subtaskOwner(Subtask,Task,NameOld);
	+taProcess::subtaskOwner(Subtask,Task,Agent);	
//.print("E !updatePriceGlobal_Owner");

	////.print("Chamada:",Chamada," - Subtask:",Subtask," - Task:",Task," - VALUE:",ValueBid," - OWNER:",Agent);
//	.my_name(Me);
//	if(A==Me){
//		//.print("VALUE:",VBid," - OWNER:",A);
//	}

.	


//@pciv[atomic]
//+!checkInitialValues(Subtask,Task):true
//<-
//if (not priceGlobal(Subtask,Task,XXPG)){
//	!processInitialPriceGlobalTask(Subtask,Task);
//}
//
//if (not priceLocal(Subtask,Task,XXPL)){
//	!processInitialPriceLocalTask(Subtask,Task);
//}
//	
//if (not netValue(Subtask,Task,XXNV)){
//	!processInitialNetValueTask(Subtask,Task);
//}
//.



@p3x[atomic]
+!update_assign_info(Subtask,Task,VBid)[source(self)]:true   
<- 
if (taProcess::preAllocatedTasks(NetValueX, Subtask,Task)){	
	!removeAllocatedTask(Subtask,Task);
	if (not taProcess::removedTask(true)){	
		+taProcess::removedTask(true);
	}	
}
. 

@p3x2[atomic]
+!checkRunAgain[source(self)]:true   
<- 
if (taProcess::removedTask(true)){
	if(not taProcess::runAllocateTasks(true)){
		+taProcess::runAllocateTasks(true);
		-taProcess::removedTask(true);
	}
}
.

@pcFinalBel[atomic]
+!cleanFinalBelieves:true
<-  
//.print("!cleanFinalBelieves");
//.print("!cleanFinalBelieves");
//.wait(5000);
//.abolish(taProcess::_);
?taProcess::job(JobId);

.abolish(taProcess::agentList(_));
.abolish(taProcess::bidLastPreProcessed(_));
.abolish(taProcess::bidLastProcessed(_));
.abolish(taProcess::bids(_));
//.abolish(taProcess::bidsN(_));
.abolish(taProcess::comBidDone(_));
.abolish(taProcess::communicationType(_));
.abolish(taProcess::contWhile(_));
.abolish(taProcess::currentLoad(_));
.abolish(taProcess::doneBid(_));
.abolish(taProcess::endWhile(_));
.abolish(taProcess::initialBid(_));
.abolish(taProcess::initime(_,JobId));
.abolish(taProcess::loadCapacity(_));
.abolish(taProcess::loadFilter(_));
.abolish(taProcess::readyMe(_));
//.abolish(taProcess::scalar(_));
.abolish(taProcess::taProcessStatus(_));
.abolish(taProcess::totalUtility(_));
.abolish(taProcess::totalUtilityOriginal(_));
.abolish(taProcess::bid(_,_));
.abolish(taProcess::bidIgnorado(_,_));
.abolish(taProcess::missingBid(_,_));
.abolish(taProcess::notProcessedBid(_,_));
.abolish(taProcess::subtask(_,_));
.abolish(taProcess::task(_,_));
.abolish(taProcess::taskMax(_,_));
.abolish(taProcess::taskMin(_,_));
.abolish(taProcess::taskMinLoad(_,_));
.abolish(taProcess::netValue(_,_,_));
.abolish(taProcess::preAllocatedTasks(_,_,_));
.abolish(taProcess::preBid(_,_,_));
.abolish(taProcess::priceGlobal(_,_,_));
.abolish(taProcess::priceLocal(_,_,_));
.abolish(taProcess::subtaskLoad(_,_,_));
.abolish(taProcess::subtaskOwner(_,_,_));
.abolish(taProcess::subtaskUtility(_,_,_));
.abolish(taProcess::subtaskReceived(_,_,_,_,_,_));
.abolish(taProcess::subtaskReceivedOriginal(_,_,_,_,_,_));
.abolish(taProcess::readyAgent(_,JobId));
-taProcess::teamReady(JobId);
-taProcess::job(JobId);
-+currentLoad(0);
-+bidsN(0);
-+bidLastProcessed(0);
-+bidLastPreProcessed(0);
//-+scalar(1);
-+comBidDone(0);//x
-+taProcess::readyMe(false);
.


{end}


