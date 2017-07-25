{ include("action/actions.asl",action) }

+default::actionID(0).
+default::actionID(X) 
	: free
<-
	!action::skip;
	.
//+default::actionID(X) 
//	: not free & not default::winner(_,_) & not initiator::cnp(_)
//<-
//	!free;
//	.
	
+!go_assemble(AssembleList,Storage,JobId,Members)
	: default::role(Role, _, _, _, _) & new::workshopList(WList)
<-
	actions.closest(Role,WList,Storage,ClosestWorkshop);
	!action::goto(ClosestWorkshop);
//	.print("Assemble List ",AssembleList);
	for ( .member(item(_,ItemId,Qty),AssembleList) ) {
		for ( .range(I,1,Qty) ) {
//			.print("trying to assemble ",ItemId);
			!action::assemble(ItemId);
		} 
	}
	for ( .member(Agent,Members) ) {
		.send(Agent,achieve,strategies::stop_assisting);
	}
	.print("Finished assembling all items, going to deliver.");
	!action::goto(Storage);
	!action::deliver_job(JobId);
	?default::lastActionResult(Result);
	if ( not default::lastActionResult(failed_job_status) ) {
		+jobDone(JobId);
	}
	.send(vehicle1,achieve,initiator::job_finished(JobId)); 
	!check_charge;
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	!free;
	.
	
+!go_work(TaskList, Storage, Assembler)
	: default::role(Role, _, _, _, _) & new::workshopList(WList) & new::shopList(SList)
<-
	for ( .member(tool(ItemId),TaskList) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		+buyList(ItemId,1,ClosestShop);
	}
	for ( .member(item(ItemId,Qty),TaskList) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		if (buyList(ItemId,Qty2,ClosestShop)) {
			-buyList(ItemId,Qty2,ClosestShop)
			+buyList(ItemId,Qty+Qty2,ClosestShop);
		}
		else { +buyList(ItemId,Qty,ClosestShop); }
	}
	+buy_list_id(0);
	for ( buyList(ItemId,Qty,Shop) ) {
		getShopItem(item(Shop,ItemId),QtyCap);
		-buyList(ItemId,Qty,Shop);
		if (Qty > QtyCap) {
//			.print("Need to buy #",Qty," of ",ItemId," from ",Shop," cap ",QtyCap);
			for ( .range(I,1,math.floor(Qty/QtyCap)) ) {
				?buy_list_id(Id);
				-+buy_list_id(Id+1);
				+buyList(ItemId,QtyCap,Shop,Id+1);
//				.print("Adding buylist #",QtyCap," ",ItemId);
			}
			Mod = Qty mod QtyCap;
			if ( Mod \== 0 ) {
				?buy_list_id(Id);
				-+buy_list_id(Id+1);
				+buyList(ItemId,Mod,Shop,Id+1);
//				.print("Adding buylist #",Mod," ",ItemId);
			}
		}
		else { ?buy_list_id(Id); -+buy_list_id(Id+1); +buyList(ItemId,Qty,Shop,Id+1);  }
	}
	-buy_list_id(_);
	!go_buy;
	actions.closest(truck,WList,Storage,ClosestWorkshop);
	!action::goto(ClosestWorkshop);
	+assembling;
	!action::assist_assemble(Assembler);
	.
	
+!go_buy
	: buyList(_,_,Shop,_)
<-
//	.print("Going to shop ",Shop);
	!action::goto(Shop);
	for ( buyList(ItemId,Qty,Shop,Id) ) {
		!action::buy(ItemId,Qty);
//		.print("Buying #",Qty," of ",ItemId);
		-buyList(ItemId,Qty,Shop,Id);
	}
	!go_buy
	.
+!go_buy.

+!go_dump
	: default::role(Role, _, _, _, _) & new::dumpList(DList)
<-
	actions.closest(Role,DList,ClosestDump);
	!action::goto(ClosestDump);
	for ( default::hasItem(ItemId,Qty) ) {
		!action::dump(ItemId,Qty);
	}
	.
	
+!stop_assisting
	: default::winner(_,_) & default::role(Role, _, _, _, _) & .my_name(Me)
<- 
	-assembling;
	.wait(500);
	if ( default::hasItem(_,_) ) { !go_dump; }
	!check_charge;
	if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_truck_to_free); }
	else { 
		if (Me == vehicle1) {
			!initiator::add_myself_to_free;
		}
		else { .send(vehicle1,achieve,initiator::add_agent_to_free); }
	}
	!!free;
	.

+!job_failed_assist
	: default::role(Role, _, _, _, _) & .my_name(Me)
<-
	.drop_desire(strategies::go_work(_,_,_));
	-assembling;
	!action::abort;
	.abolish(strategies::buyList(_,_,_));
	 -buy_list_id(_);
	if ( default::hasItem(_,_) ) { !go_dump; }
	if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_truck_to_free); }
	else { 
		if (Me == vehicle1) {
			!initiator::add_myself_to_free;
		}
		else { .send(vehicle1,achieve,initiator::add_agent_to_free); }
	}
	!!free;
	.
+!job_failed_assemble
	: true
<-
	.drop_desire(strategies::go_assemble(_,_,_,_));
	!action::abort;
	if ( default::hasItem(_,_) ) { !go_dump; }
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	!!free;
	.
	
+!check_charge
	: default::role(Role,_,_,BatteryCap,_) & (Role == truck | Role == car) & default::charge(Battery) & Battery <= BatteryCap div 2 & new::chargingList(CList)
<-
	.print("Running low on battery, going to charge before taking any new tasks.");
	actions.closest(Role,CList,ClosestChargingStation);
	!action::goto(ClosestChargingStation);
	!action::charge;
	.
-!check_charge.
	
@free[atomic]
+!free : not free <- +free; -default::winner(_,_)[source(_)]; !action::skip; .
+!free <- !action::skip.

@notFree[atomic]
+!not_free <- -free.

+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
+default::job_done(JobId, _, Reward, _, _, _)
	: jobDone(JobId)
<-
	-jobDone(JobId);
	.print("$$$$$$$$$$$$ Job ",JobId," completed, got reward ",Reward);
	.
+default::job_done(JobId, _, _, _, _, _)
	: default::winner(_, assemble(_, JobId, Members))
<-
	.print("!!!!!!!!!!!!!!!!! Job ",JobId," failed!");
	for ( .member(Agent,Members) ) {
		.send(Agent,achieve,strategies::job_failed_assist);
	}
	!job_failed_assemble;
	.
+default::job_done(JobId, _, Reward, _, _, Fine, _, _, _)
	: jobDone(JobId)
<-
	-jobDone(JobId);
	.print("$$$$$$$$$$$$ Mission ",JobId," completed, got reward ",Reward);
	
	.
+default::job_done(JobId, _, _, _, _, Fine, _, _, _)
	: default::winner(_, assemble(_, JobId, Members))
<-
	.print("!!!!!!!!!!!!!!!!! Mission ",JobId," failed, paying fine ",Fine);
	for ( .member(Agent,Members) ) {
		.send(Agent,achieve,strategies::job_failed_assist);
	}
	!job_failed_assemble;
	.