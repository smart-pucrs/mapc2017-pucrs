+goalState(JobId,job_delivered,_,_,satisfied)
	: default::winner(_, assemble(_, JobId, _))
<-
//   .print("*** all done! ***");
   removeScheme(JobId);
   .abolish(org::_);
   .

+!prepare_assemble
	: default::winner(_, assemble(Storage, _, TaskList))
<-
	if ( not .empty(TaskList) ) { !buy_items; }
	else {
		!strategies::go_to_workshop(Storage);
		!!strategies::free;
	}
	.

+!do_assemble
	: default::winner(TaskList, assemble(_, _, _)) & default::get_assemble(TaskList, [], AssembleListNotSorted, 0)
<-
	!strategies::not_free;
	.sort(AssembleListNotSorted,AssembleList);
//	.print("Assemble List ",AssembleList);
	for ( .member(item(_,ItemId,Qty),AssembleList) ) {
		for ( .range(I,1,Qty) ) {
//			.print("trying to assemble ",ItemId);
			!action::assemble(ItemId);
		} 
	}
	!!strategies::go_deliver;
	.

+!buy_items
	: default::role(Role, _, _, _, _) & new::shopList(SList) & (default::winner(TaskList, assist(Storage, _, _)) | default::winner(_, assemble(Storage, _, TaskList))) & .my_name(Me)
<-
	for ( .member(tool(ItemId),TaskList) ) {
		.findall(StorageAdd,default::available_items(StorageS,AvailableT) & .term2string(ItemId,ToolS) & .substring(ToolS,AvailableT) & .term2string(StorageAdd,StorageS), StorageList);
		if ( StorageList \== [] ) {
			actions.closest(Role,StorageList,Facility);
			removeAvailableItem(Facility,ItemId,1);
			+strategies::retrieveList(ItemId,1,Facility);
		}
		else {
			?default::find_shops(ItemId,SList,Shops);
			actions.closest(Role,Shops,ClosestShop);
			+strategies::buyList(ItemId,1,ClosestShop);
		}
	}
	for ( .member(item(ItemId,Qty),TaskList) ) {
		?default::find_shop_qty(item(ItemId, Qty),SList,Buy,99999,RouteShop,99999,"",Shop,99999);
		if (strategies::buyList(ItemId,Qty2,ShopOld)) {
			-strategies::buyList(ItemId,Qty2,ShopOld);
			?default::find_shop_qty(item(ItemId, Qty+Qty2),SList,BuyL,99999,RouteShopL,99999,"",ShopNew,99999);
			+strategies::buyList(ItemId,Qty+Qty2,ShopNew);
		}
		else { +strategies::buyList(ItemId,Qty,Shop); }
	}
//	for ( strategies::buyList(ItemId1,Qty1,Shop1) ) { .print("Buy list for #",Qty1," of ",ItemId1," in ",Shop1); }
	!strategies::go_buy;
	if (strategies::retrieveList(_,_,_)) {
		for ( strategies::retrieveList(_,_,Fac) ) {
			!action::goto(Fac);
			for ( strategies::retrieveList(ItemId,Qty,Fac) ) {
				-strategies::retrieveList(ItemId,Qty,Fac);
				!action::retrieve(ItemId,Qty);
			}
		}
	}
	!strategies::go_to_workshop(Storage);
	if (Me == vehicle1) { +strategies::waiting; }
	!!check_state;
	.
	
+!check_state : not goalState(JobId,phase1,_,_,satisfied) <- !!strategies::free.
+!check_state.
	
+!assist_assemble
	: default::winner(_, assist(_, Assembler, _)) & .my_name(Me)
<-
	if (Me == vehicle1) { -strategies::waiting; }
	!strategies::not_free;
	+strategies::assembling;
	!!action::assist_assemble(Assembler);
	.
	
+!stop_assist_assemble
	: default::winner(_,_)
<-
	-strategies::assembling;
	-default::winner(_,_)[source(_)];
//	for ( default::hasItem(ItemId,Qty) ) { .print(">>>>>>>>> Assist assemble ended, I have #",Qty," of ",ItemId); }
	!!strategies::empty_load;
	.
+!stop_assist_assemble <- .print("!!!!!!!!!!!!! Received stop assist from scheme but did not have the winner belief anymore.").