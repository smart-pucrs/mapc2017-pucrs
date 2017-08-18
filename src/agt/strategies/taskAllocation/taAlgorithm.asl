{ include("definitions.asl") }

{begin namespace (taProcess, global)}

currentLoad(0).
bidsN(0).
bidLastProcessed(0).
bidLastPreProcessed(0).
scalar(1).
comBidDone(0).
readyMe(false).


@puTL[atomic]
+!run_distributed_TA_algorithm(communication(COMMUNICATION_TYPE,AGENT_LIST),SUBTASKLIST,AVAILABLE_LOAD):true
<- 
.time(HH,NN,SS);
.concat(HH,":",NN,":",SS,INITIME);
+initime(INITIME);
!invertUtility(SUBTASKLIST);
+communicationType(COMMUNICATION_TYPE);
!setAgentList(AGENT_LIST);
+loadCapacity(AVAILABLE_LOAD);
.findall(subtask(SUBTASK2,TASK2,LOAD2,UTILITY2,TASKTYPE2,ROLE2),taProcess::subtaskReceived(SUBTASK2,TASK2,LOAD2,UTILITY2,TASKTYPE2,ROLE2),LSTK2);
!prepareTaskList;
.

@puTLxa[atomic]
+!invertUtility(SUBTASKLIST):true  
<- 
if(taDefinitions::taUtilityGoal(UGOAL) & (UGOAL=="maximize")){
	for (.member(subtask(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE),SUBTASKLIST)) {
		+taProcess::subtaskReceived(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE);
		+taProcess::subtaskReceivedOriginal(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE);
		}
}
else{
	?taDefinitions::maxUtility(MaxUtility);
	for(.member(subtask(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE),SUBTASKLIST)) {
		
		+taProcess::subtaskReceivedOriginal(SUBTASK,TASK,LOAD,UTILITY,TASKTYPE,ROLE);
		
		if((MaxUtility-UTILITY)>0){
			+taProcess::subtaskReceived(SUBTASK,TASK,LOAD,(MaxUtility-UTILITY),TASKTYPE,ROLE);
		}
		else{
			+taProcess::subtaskReceived(SUBTASK,TASK,LOAD,0,TASKTYPE,ROLE);
		}
	}
}
.



@puTLxaw//[atomic]
+!prepareTaskList:true  
<- 
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
!preparetaProcess;
.


@pSAL//[atomic]
+!setAgentList(AGLIST): .my_name(Me) 
<-
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
+taProcessStatus(done);
!alocP1;
.


@pip0[atomic]
+!processInitialPriceValues[source(self)]:true //.findall(GRP,k(GRP,tcl),LTCL)  
<- 
	.findall(subtask(SUBTASK,TASK),taProcess::subtask(SUBTASK,TASK),LTASK);
	for (.member(subtask(SUBTASK2,TASK2),LTASK)) {
	if (not priceGlobal(SUBTASK2,TASK2,XXPG)){
		-priceGlobal(SUBTASK2,TASK2,XX1);
		+priceGlobal(SUBTASK2,TASK2,0);
	}
	-priceLocal(SUBTASK2,TASK2,XX2);
	+priceLocal(SUBTASK2,TASK2,0);
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


@pip02[atomic]
+!processInitialPriceGlobalTask(SUBTASK,TASK)[source(self)]:true //.findall(GRP,k(GRP,tcl),LTCL)  
<- 
	-priceGlobal(SUBTASK,TASK,XX1);
	+priceGlobal(SUBTASK,TASK,0);
.

@pip03[atomic]
+!processInitialPriceLocalTask(SUBTASK,TASK)[source(self)]:true //.findall(GRP,k(GRP,tcl),LTCL)  
<- 
	-priceLocal(SUBTASK,TASK,XX2);
	+priceLocal(SUBTASK,TASK,0);
.


@pa02[atomic]
+!processInitialNetValueTask(SUBTASK,TASK)[source(self)]:true  
<- 
	?taProcess::subtaskUtility(SUBTASK,TASK,Vutility);
	?taProcess::priceGlobal(SUBTASK,TASK,Vpriceglobal);
	VLNEW=Vutility-Vpriceglobal;		
	-netValue(SUBTASK,TASK,XXX);
	+netValue(SUBTASK,TASK,VLNEW);
.


@p0[atomic]
+!alocP1: true 
<-
if(taProcess::preAllocatedTasks(X1,X2,X3)){
	.count(taProcess::preAllocatedTasks(_,_,_),QtyAllocTasks);
	.findall(LOAD,taProcess::subtaskLoad(SUBTASK,TASK,LOAD) & taProcess::preAllocatedTasks(NVXXXX, SUBTASKalloc, TASKalloc) & (SUBTASK==SUBTASKalloc) & (TASK==TASKalloc),LLOAD);
	TOTLOAD = math.sum(LLOAD);
	-currentLoad(XXX);
	+currentLoad(TOTLOAD);
}
else{
	-currentLoad(NAx);
	+currentLoad(0);
}
?taProcess::currentLoad(NA);
?taProcess::loadCapacity(LA);

if ((LA-NA) > 0) { 

!processNetValue;
!processTasks;
!filterCandidates;
!processCandidatesSD;
.findall(bestCandidates(NetValueBC, SubtaskBC, TaskBC),taProcess::bestCandidates(NetValueBC, SubtaskBC, TaskBC),LBESTCAND);
.length(LBESTCAND,NBESTCAND);
if(NBESTCAND>0){
!calculateBids;
}
!cleanAuxLists;

-readyMe(XX);
+readyMe(true);

!checkReady;

if(taProcess::runAlocP1(true)){
	-taProcess::runAlocP1(true);
}

if(taProcess::rerunAlocP1(true)){
		-taProcess::rerunAlocP1(XXrerun);
		-readyMe(XXXX);
		+readyMe(false);
		!alocP1;
}

}
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

			if(candidate(VXXXX, SUBTKXXXX, TASK)){
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
+!processCandidatesSD[source(self)]:true  
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
	+communicateDone;
}
.


@paddTA[atomic]
+!addAllocatedTask(NetValue, Subtask, Task)[source(self)]:true   
<- 
+preAllocatedTasks(NetValue, Subtask, Task);
	   	?taProcess::subtaskLoad(Subtask,Task,Load);
		?taProcess::currentLoad(CurrentLoad);
		NewLoad=CurrentLoad+Load;
		-+currentLoad(NewLoad);
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


@pTOtal[atomic]
+!totalAllocated:true
<-
.print("---------------------------------");
.findall(preAllocatedTasks(NetValue, Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LAlloc);
.sort(LAlloc,LAlloc2);
.reverse(LAlloc2,LAlloc3);
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
		//.print("NewTotalX:",NewTotal);
		
		?taProcess::subtaskReceivedOriginal(Subtaska, Taska,LOADORIG,UTILITYORIG,TASKTYPEORIG,ROLEORIG);
		?taProcess::totalUtilityOriginal(TotalOrigX);
		LTotalOrig=TotalOrigX;
		NewTotalOrig=LTotalOrig+UTILITYORIG;
		-+totalUtilityOriginal(NewTotalOrig);
		//.print("NewTotalX:",NewTotalOrig);
	}
	else{
		//.print("Task SD por enquanto para nao dar erro");
		.findall(subtask(Subtaska2,Taska,UTILITYORIG),taProcess::subtaskReceivedOriginal(Subtaska2, Taska,LOADORIG,UTILITYORIG,TASKTYPEORIG,ROLEORIG), LSUBTASK);
		 for (.member(subtask(SubtaskSD,TaskSD,UTILITYORIGSD),LSUBTASK)) {
	
			?taProcess::totalUtilityOriginal(TotalOrigX);
			LTotalOrig=TotalOrigX;
			NewTotalOrig=LTotalOrig+UTILITYORIGSD;
			-+totalUtilityOriginal(NewTotalOrig);
			//.print("NewTotalSD:",NewTotalOrig);
		}
			?taProcess::subtaskUtility(Subtaska,Taska,SubtaskUtilityX)
			?taProcess::totalUtility(TotalX);
			LTotal=TotalX;
			NewTotal=LTotal+SubtaskUtilityX;
			-+totalUtility(NewTotal);
			//.print("NewTotalSD:",NewTotal);
	}
	
	}

	//?total(TotXX2);
//	.print("Total alocado:", TotXX2);
	?taProcess::totalUtility(TotXX3);
	.print("totalUtility alocado:", TotXX3);
	
	?taProcess::totalUtilityOriginal(TotalOrigX2);
	.print("totalUtility alocado ORIGINAL:", TotalOrigX2);

	.print("---------------------------------");
.

@pTOtalFinal[atomic]
+!totalAllocatedFinal:true
<-
.findall(preAllocatedTasks(NetValue, Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LAlloc);
.print("preAllocatedTasks:",LAlloc);
	for (.member(preAllocatedTasks(NetValuea, Subtaska, Taska),LAlloc)) {
	
	if(not Subtaska==Taska){
		+taResults::allocatedTasks(Subtaska, Taska);
		.print("+taResults::allocatedTasks: Subtaska:",Subtaska," - Taska:",Taska)
	}
	else{
		//.print("Task SD por enquanto para nao dar erro");
		.findall(subtask(Subtaska2,Taska,UTILITYORIG),taProcess::subtaskReceivedOriginal(Subtaska2,Taska,LOADORIG,UTILITYORIG,TASKTYPEORIG,ROLEORIG), LSUBTASK);
		.print("Taska:",Taska);
		.print("LSUBTASK:",LSUBTASK);
		 for (.member(subtask(SubtaskSD,TaskSD,UTILITYORIGSD),LSUBTASK)) {
			+taResults::allocatedTasks(SubtaskSD, TaskSD);
			.print("+taResults::allocatedTasks: SubtaskSD:",SubtaskSD," - TaskSD:",TaskSD)
		}
	}
	
	}
?initime(INITIME);
.time(HH,NN,SS);
.concat(HH,":",NN,":",SS,ENDTIME);
.print("INITIME:",INITIME);
.print("ENDTIME:",ENDTIME);
!printAuxFinal;	
.


@pzasas//[atomic]
+!printAuxFinal:true
<-
.print("*********************************************");
.print("waiting...");
//.wait(5000);
.findall(preAllocatedTasks(Subtask, Task),taProcess::preAllocatedTasks(NetValue, Subtask, Task),LPreAlloc);
.sort(LPreAlloc,LPreAlloc2);
.print("preAllocatedTasks:",LPreAlloc2);
.findall(allocatedTasks(Subtaskx, Taskx),taResults::allocatedTasks(Subtaskx, Taskx),LAlloc);
.sort(LAlloc,LAlloc2);
.print("AllocatedTasks:",LAlloc2);
.print("*********************************************");
.




@p22n[atomic]
+!updateGlobalPrice(Subtask,Task,PriceGlobalNew):true 
   <-
?taProcess::priceGlobal(Subtask,Task,PriceGlobalCurrent);
.my_name(Me);

if (PriceGlobalCurrent > PriceGlobalNew) { 
		!removeAllocatedTask(Subtask,Task);
	   -taProcess::candidate(NetValueX, Subtask,Task);
	   -taProcess::bestCandidates(NetValueX, Subtask,Task);
	   if(not taProcess::rerunAlocP1(true)){
			-taProcess::rerunAlocP1(XXX);
			+taProcess::rerunAlocP1(true);
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
		
		-taProcess::priceGlobal(Subtask,Task,X);
		-taProcess::subtaskOwner(Subtask,Task,Name);
		+taProcess::priceGlobal(Subtask,Task,VmaxPrice);
		+taProcess::subtaskOwner(Subtask,Task,Me);
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
		
		-taProcess::priceGlobal(Subtask,Task,X);
		-taProcess::subtaskOwner(Subtask,Task,Name);
		+taProcess::priceGlobal(Subtask,Task,VmaxPrice);
		+taProcess::subtaskOwner(Subtask,Task,Me);
		!updateNetValue(Subtask,Task);//X
	    +toCommunicate(Subtask,Task,PriceGlobalNew);
	}
	 if (taProcess::subtaskOwner(Subtask,Task,Owner) & (Me < Owner)) {
       !removeAllocatedTask(Subtask,Task);
	   -taProcess::candidate(X, Subtask,Task);
	   -taProcess::bestCandidates(X2,Subtask,Task);
	   if(not taProcess::rerunAlocP1(true)){
			-taProcess::rerunAlocP1(XXX);
			+taProcess::rerunAlocP1(true);
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

   	  if(not taProcess::initialBid(Me)) {
			+taProcess::initialBid(Me);
			+taProcess::missingBid(Me,0);
	  }

   	  !updateMissingBid(Me,-1);

   	  .time(HH,NN,SS);
   	  .broadcast(tell, taProcess::bid(done,BDNEW));
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
if(not (A==Me)){
		?taProcess::missingBid(A,Value);
		-taProcess::missingBid(A,XX);	
		+taProcess::missingBid(A,ReceivedValue);
}
else{
	if(ReceivedValue==1){
		-readyMe(XX);
		+readyMe(false);
	}
}
.

@pbidswes[atomic]
+!checkReady:true
<-
if (taProcess::communicateDone){
	if(not processingBids(true)){
		if (not ((taProcess::notProcessedBid(XXA,NPB) & (NPB>0)) | taProcess::bidQueue(XNBidsNEW,XLBIDS,XA))){
			-taProcess::communicateDone;
			!communicateDone;
		}
	}
}


?taDefinitions::agentsBid(NAgBid);
.count(taProcess::missingBid(A,Value),NMissBid);
if(NAgBid>NMissBid)
{

}
else {
	.findall(notProcessedBid(AA,ANPB),taProcess::notProcessedBid(AA,ANPB),LNPB);
	.findall(missingBid(A,Value),taProcess::missingBid(A,Value),LMB);
	?taProcess::readyMe(VL);
	
	if ((taProcess::notProcessedBid(XXA,NPB) & (NPB>0)) | taProcess::bidQueue(XNBidsNEW,XLBIDS,XA) ){

	}
	else {
		if(taProcess::missingBid(A,Value) & (Value>0)){

		}
		else {
				if (taProcess::readyMe(false)){

			}
			else{
				if(processingBids(true)){

				}
				else {
					.print("TA process ready...");
					!totalAllocated;
					!totalAllocatedFinal;
				}
			
			}
		}
	}
}
.


@pbidxz2//[atomic]
+!processbidDone(BDNEW,A): (taProcess::notProcessedBid(XA,NotP) & NotP>0) | (taProcess::bidQueue(XNBids,XLBIDS,XXA))
<-
.wait(200);
!processbidDone(BDNEW,A);
.


@pbidxz3[atomic]
+!processbidDone(BDNEW,A): (not taProcess::notProcessedBid(XXA,XXX)) | (taProcess::notProcessedBid(XA,NotP) & NotP<=0) 
<-
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
.

@pbidxz//[atomic]
+taProcess::bid(done,BDNEW)[source(A)]:true
<-
!processbidDone(BDNEW,A);
.


@paddBidN[atomic]
+!increaseBidsN[source(A)]:true
<-
?bidsN(NBids);
NBidsNEW=NBids+1;
-bidsN(NBids);
+bidsN(NBidsNEW);
.

@pbidx2//[atomic]
+taProcess::bids(LBIDS)[source(A)]:true
<-
!increaseBidsN;
?bidsN(NBids);
+taProcess::bidQueue(NBids,LBIDS,A);
+taProcess::bidQueuePre(NBids,LBIDS,A);
+test::xbidQueue(NBids,LBIDS,A);
!preProcessBids;
.


@pbidx2n2//[atomic]
+!preProcessBids: processingBids(true) | not taProcess::taProcessStatus(STATUS)
<-
.wait(200);
!preProcessBids;
.

@pbidx2n[atomic]
+!preProcessBids: not processingBids(true)
<-
+processingBids(true);

?taProcess::bidLastPreProcessed(BIDLASTP_OLD);
BIDLASTP=BIDLASTP_OLD+1;
-taProcess::bidLastPreProcessed(BIDLASTP_OLD);
+taProcess::bidLastPreProcessed(BIDLASTP);
?taProcess::bidQueuePre(BIDLASTP,LBIDS,A);

if(not taProcess::missingBid(A,XMB)){
	+taProcess::missingBid(A,0);
}

if(not taProcess::notProcessedBid(A,XPMB)){
	+taProcess::notProcessedBid(A,0);
}


?taProcess::notProcessedBid(A,XNPB);
XNPBNEW=XNPB+1;
-taProcess::notProcessedBid(A,XXNPB);
+taProcess::notProcessedBid(A,XNPBNEW);
?taProcess::notProcessedBid(A,XNPB2);

-processingBids(true);
-taProcess::bidQueuePre(BIDLASTP,LBIDS,A);
!processBids;
.


@pbidsListNt//[atomic]
+!processBids:not taProcess::taProcessStatus(STATUS)
<-
.wait(500);
!processBids;
.

@pbidsList//[atomic]
+!processBids:taProcess::taProcessStatus(STATUS) & (STATUS==done)
<-

?taProcess::bidLastProcessed(BIDLASTP_OLD);
BIDLASTP=BIDLASTP_OLD+1;
-taProcess::bidLastProcessed(BIDLASTP_OLD);
+taProcess::bidLastProcessed(BIDLASTP);

?taProcess::bidQueue(BIDLASTP,LBIDS,A);

-bidIgnorado(A,XX);
+bidIgnorado(A,false);

for (.member(taProcess::bid(Subtask,Task,VBid),LBIDS)) {

if(not taProcess::initialBid(A)){
	+taProcess::initialBid(A);
	+taProcess::missingBid(A,0);
}

if(taProcess::subtask(Subtask,Task)){
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
 	
	-taProcess::priceGlobal(Subtask,Task,XX);
	-taProcess::subtaskOwner(Subtask,Task,Name);
	+taProcess::priceGlobal(Subtask,Task,VBid);
	+taProcess::subtaskOwner(Subtask,Task,A);	
	!updateNetValue(Subtask,Task);
	!update_assign_info(Subtask, Task, VBid);	
}
if (VBid == PriceGlobal) {
	?taProcess::subtaskOwner(Subtask,Task,OName);
	if (A < OName) {
	-bidIgnorado(A,XX);
	+bidIgnorado(A,true);
	}
	if (A > OName) {
	if (taProcess::subtaskOwner(Subtask,Task,CurrentOwner)){
 	?taProcess::subtaskOwner(Subtask,Task,CurrentOwner);
 	!updateMissingBid(CurrentOwner,1);
 	}
	
	-taProcess::priceGlobal(Subtask,Task,XX);
	-taProcess::subtaskOwner(Subtask,Task,Name);
	+taProcess::priceGlobal(Subtask,Task,VBid);
	+taProcess::subtaskOwner(Subtask,Task,A);
	!updateNetValue(Subtask,Task);
	!update_assign_info(Subtask, Task, VBid);
	}
}

}//end IF

else{
	if (not taProcess::priceGlobal(Subtask,Task,PriceGlobalx)){
		+taProcess::priceGlobal(Subtask,Task,0);
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
	-taProcess::priceGlobal(Subtask,Task,XX);
	-taProcess::subtaskOwner(Subtask,Task,Name);
	+taProcess::priceGlobal(Subtask,Task,VBid);
	+taProcess::subtaskOwner(Subtask,Task,A);	
}
if (VBid == PriceGlobal) {
	?taProcess::subtaskOwner(Subtask,Task,OName);
	if (A < OName) {
	-bidIgnorado(A,XX);
	+bidIgnorado(A,true);
	}
	if (A > OName) {
	if (taProcess::subtaskOwner(Subtask,Task,CurrentOwner)){
 	?taProcess::subtaskOwner(Subtask,Task,CurrentOwner);
 	!updateMissingBid(CurrentOwner,1);
 	}
	-taProcess::priceGlobal(Subtask,Task,XX);
	-taProcess::subtaskOwner(Subtask,Task,Name);
	+taProcess::priceGlobal(Subtask,Task,VBid);
	+taProcess::subtaskOwner(Subtask,Task,A);
	}
}
}//end ELSE

}//end for BIDS

if (bidIgnorado(A,true)){
	!updateMissingBid(A,1);
}
else{
	if (bidIgnorado(A,false)){
	!updateMissingBid(A,-1);
	}
	else{
		
	}	
}


-taProcess::bidQueue(BIDLASTP,LBIDS,A);

!checkRunAgain;

?taProcess::notProcessedBid(A,XNPB);
XNPBNEW=XNPB-1;
-taProcess::notProcessedBid(A,XXNPB);
+taProcess::notProcessedBid(A,XNPBNEW);
?taProcess::notProcessedBid(A,XNPB2);

!checkReady;

if(taProcess::runAlocP1(true)){
		!alocP1;
}
.



@pciv[atomic]
+!checkInitialValues(Subtask,Task):true
<-
if (not priceGlobal(Subtask,Task,XXPG)){
	!processInitialPriceGlobalTask(Subtask,Task);
}

if (not priceLocal(Subtask,Task,XXPL)){
	!processInitialPriceLocalTask(Subtask,Task);
}
	
if (not netValue(Subtask,Task,XXNV)){
	!processInitialNetValueTask(Subtask,Task);
}
.



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
	if(not taProcess::runAlocP1(true)){
		+taProcess::runAlocP1(true);
		-taProcess::removedTask(true);
	}
}
.

{end}


