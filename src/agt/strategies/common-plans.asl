{ include("action/actions.asl",action) }
free.

+default::actionID(X) 
	: free
<-
	!action::skip;
	.
	
+!go_assemble(AssembleList,Storage,JobId,Members)
	: default::role(Role, _, _, _, _) & new::workshopList(WList)
<-
	-free;
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
	.print("Finished assembly all items, ready to deliver.");
	!action::goto(Storage);
	!action::deliver_job(JobId);
	.print("$$$ I have just delivered job ",JobId);
	.send(vehicle1,achieve,initiator::add_me_to_free2);
	.send(vehicle1,achieve,strategies::job_finished(JobId));
	-default::winner(_,_);
	+free;
	!action::skip;
	.
	
+!go_work(TaskList, Storage, Assembler)
	: default::role(Role, _, _, _, _) & new::workshopList(WList) & new::shopList(SList)
<-
	-free;
	for ( .member(tool(ItemId),TaskList) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		+buyList(ItemId,1,ClosestShop);
	}
	for ( .member(item(ItemId,Qty),TaskList) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		if (buyList(ItemId,Qty2,ClosestShop)) {
			-buyList(ItemId,Qty2,ClosestShop);
			getShopItem(item(ClosestShop,ItemId),QtyCap);
			if (Qty+Qty2 > QtyCap) {
				for ( .range(I,1,math.floor((Qty+Qty2)/QtyCap)) ) {
					+buyList(ItemId,QtyCap,ClosestShop);
				}
				Mod = (Qty+Qty2) mod QtyCap;
				if ( Mod \== 0 ) {
					+buyList(ItemId,Mod,ClosestShop);
				}
			}
			else { +buyList(ItemId,Qty+Qty2,ClosestShop); }
		}
		else { 
			if (Qty > QtyCap) {
				for ( .range(I,1,math.floor(Qty/QtyCap)) ) {
					+buyList(ItemId,QtyCap,ClosestShop);
				}
				Mod = Qty mod QtyCap;
				if ( Mod \== 0 ) {
					+buyList(ItemId,Mod,ClosestShop);
				}
			}
			else { +buyList(ItemId,Qty,ClosestShop); }
		}
	}
	!go_buy;
	actions.closest(Role,WList,Storage,ClosestWorkshop);
	!action::goto(ClosestWorkshop);
	+assembling;
	!action::assist_assemble(Assembler);
	+free;
	!action::skip;
	.
	
+!go_buy
	: buyList(_,_,Shop)
<-
//	.print("Going to shop ",Shop);
	!action::goto(Shop);
	for ( buyList(ItemId,Qty,Shop) ) {
		!action::buy(ItemId,Qty);
//		.print("Buying #",Qty," of ",ItemId);
		-buyList(ItemId,Qty,Shop);
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
	: default::role(Role, _, _, _, _) & .my_name(Me)
<- 
	-assembling;
	if ( default::hasItem(_,_) ) { !go_dump; }
	if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_me_to_free2); }
	else { 
		if (Me == vehicle1) {  
			?initiator::free_agents(FreeAgents);
			-+initiator::free_agents([Me|FreeAgents]);
		}
		else { .send(vehicle1,achieve,initiator::add_me_to_free); }
	}
	-default::winner(_,_);
	.

+!job_finished(JobId) <- -initiator::job(JobId, _, _, _)[source(_)].

+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
//+default::hasItem(Item,Qty)
//<- .print("I now have #",Qty," of item ",Item).