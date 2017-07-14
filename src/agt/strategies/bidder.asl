+default::task(item(ItemId, Qty), CNPBoard, TaskId)
	: .my_name(Me)
<- 
	lookupArtifact(CNPBoard, BoardId);
	focus(BoardId);
    !create_bid_task(item(ItemId, Qty), Bid, Shop);
    bid(Me, Bid, Shop, item(ItemId, Qty), TaskId)[artifact_id(BoardId)];
  	.
+default::task(tool(ItemId), CNPBoard, TaskId)
	: .my_name(Me)
<- 
	lookupArtifact(CNPBoard, BoardId);
	focus(BoardId);
  	!create_bid_task(tool(ItemId), Bid, Shop);
	bid(Me, Bid, Shop, tool(ItemId), TaskId)[artifact_id(BoardId)];
	.
+default::task(assemble(StorageId), CNPBoard, TaskId)
	: .my_name(Me) & default::role(truck,_,_,_,_)
<- 
	lookupArtifact(CNPBoard, BoardId);
	focus(BoardId);
	!create_bid_task(assemble(StorageId), Bid, Shop);
	bid(Me, Bid, Shop, assemble(StorageId), TaskId)[artifact_id(BoardId)];
	.

@create_bid_task_item[atomic]
+!create_bid_task(item(ItemId, Qty), Bid, Shop)
	: default::load(MyLoad) & default::role(Role, Speed, LoadCap, _, Tools) & default::item(ItemId,Vol,_,_) & new::shopList(SList)
<-
	if (not default::winner(_, _) & LoadCap - MyLoad >= Vol * Qty) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		actions.route(Role,Speed,ClosestShop,RouteShop);
		Bid = RouteShop;
		Shop = ClosestShop;
	}
	else { Bid = -1; Shop = null; }
	.
@create_bid_task_tool[atomic]
+!create_bid_task(tool(ItemId), Bid, Shop)
	: default::role(Role, _, _, _, Tools) & new::shopList(SList)
<-
	if ( not default::winner(_, _) & .sublist([ItemId],Tools) ) {
		for ( default::tools(_,T) ) {
			if (Role == drone & .sublist([ItemId],T) & not multiple_roles) { +multiple_roles }
		}
		if (multiple_roles) { -multiple_roles; Bid = 2; }
		else { Bid = 1; }
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		Shop = ClosestShop;
	}
	else { Bid = -1; Shop = null; }
	.
@create_bid_task_assemble[atomic]
+!create_bid_task(assemble(StorageId), Bid, Shop)
	: default::role(Role, Speed, _, _, _) & new::workshopList(WList)
<-
	if ( not default::winner(_, _) ) {
		actions.closest(Role,WList,StorageId,ClosestWorkshop);
		actions.route(Role,Speed,ClosestWorkshop,RouteWorkshop);
		Bid = RouteWorkshop;
		Shop = StorageId;
	}
	else { Bid = -1; Shop = null; }
	.
	
+default::winner(TaskList, assist(Storage, Assembler))
<-
	.print("I won the tasks ",TaskList);
	!strategies::go_work(TaskList, Storage, Assembler);
	.
+default::winner(TaskList, assemble(Storage, JobId, Members))
<-
	?default::get_assemble(TaskList, [], AssembleList);
	.sort(AssembleList,AssembleListSorted);
	.print("I won the tasks to assemble ",AssembleListSorted," and deliver to ",Storage," for ",JobId);
	!strategies::go_assemble(AssembleListSorted, Storage, JobId, Members);
	.