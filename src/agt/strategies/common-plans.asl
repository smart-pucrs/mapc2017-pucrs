{ include("action/actions.asl",action) }

+default::actionID(0).
+default::actionID(X) 
	: free & not default::winner(_,_)
<-
	!action::skip;
	.
+!firstskip <- !action::skip.
	
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
	.print("$$$ I have just delivered job ",JobId);
	.send(vehicle1,achieve,initiator::add_truck_to_free);
	.send(vehicle1,achieve,initiator::job_finished(JobId));
	-default::winner(_,_)[source(_)];
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
	: default::role(Role, _, _, _, _) & .my_name(Me)
<- 
	-assembling;
	if ( default::hasItem(_,_) ) { !go_dump; }
	if ( Role == truck ) { .send(vehicle1,achieve,initiator::add_truck_to_free); }
	else { 
		if (Me == vehicle1) {
			!initiator::add_myself_to_free;
		}
		else { .send(vehicle1,achieve,initiator::add_agent_to_free); }
	}
	-default::winner(_,_)[source(_)];
	!free;
	.
	
+!remove_truck_from_free(Agent)
<-
	remove_truck(Agent);
	remove_agent(Agent);
	.
	
@free[atomic]
+!free <- +free; !action::skip; .

+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
//+default::hasItem(Item,Qty)
//<- .print("I now have #",Qty," of item ",Item).