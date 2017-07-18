@itemTask[atomic]
+default::task(item(ItemId, Qty), CNPBoard, TaskId)[source(X)]
	: .my_name(Me)
<- 
	-default::task(item(ItemId, Qty), CNPBoard, TaskId)[source(X)];
    !create_bid_task(item(ItemId, Qty), Bid, Shop);
    bid(Me, Bid, Shop, item(ItemId, Qty), TaskId)[artifact_name(CNPBoard)];
  	.
-default::task(item(ItemId, Qty), CNPBoard, TaskId)[source(X)].
@toolTask[atomic]
+default::task(tool(ItemId), CNPBoard, TaskId)[source(X)]
	: .my_name(Me)
<- 
	-default::task(tool(ItemId), CNPBoard, TaskId)[source(X)];
  	!create_bid_task(tool(ItemId), Bid, Shop);
	bid(Me, Bid, Shop, tool(ItemId), TaskId)[artifact_name(CNPBoard)];
	.
-default::task(tool(ItemId), CNPBoard, TaskId)[source(X)].
@assembleTask[atomic]
+default::task(assemble(StorageId), CNPBoard, TaskId)[source(X)]
	: .my_name(Me)
<- 
	-default::task(assemble(StorageId), CNPBoard, TaskId)[source(X)];
	!create_bid_task(assemble(StorageId), Bid, Shop);
	bid(Me, Bid, Shop, assemble(StorageId), TaskId)[artifact_name(CNPBoard)];
	.
-default::task(assemble(StorageId), CNPBoard, TaskId)[source(X)].

+!create_bid_task(item(ItemId, Qty), Bid, Shop)
	: default::load(MyLoad) & default::role(Role, Speed, LoadCap, _, Tools) & default::item(ItemId,Vol,_,_) & new::shopList(SList)
<-
	if (LoadCap - MyLoad >= Vol * Qty) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		actions.route(Role,Speed,ClosestShop,RouteShop);
		.print("####### Route: ",RouteShop);
		Bid = RouteShop;
		Shop = ClosestShop;
	}
	else { Bid = -1; Shop = null; }
	.
+!create_bid_task(tool(ItemId), Bid, Shop)
	: default::role(Role, Speed, _, _, Tools) & new::shopList(SList)
<-
	if (.member(ItemId,Tools) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		actions.route(Role,Speed,ClosestShop,RouteShop);
		for ( default::tools(_,T) ) {
			if (Role == drone & .member(ItemId,T) & not multiple_roles) { +multiple_roles }
		}
		if (multiple_roles) { -multiple_roles; Bid = RouteShop*10; }
		else { Bid = RouteShop; }
		Shop = ClosestShop;
	}
	else { Bid = -1; Shop = null; }
	.
+!create_bid_task(assemble(StorageId), Bid, Shop)
	: default::role(Role, Speed, _, _, _) & new::workshopList(WList)
<-
	actions.closest(Role,WList,StorageId,ClosestWorkshop);
	actions.route(Role,Speed,ClosestWorkshop,RouteWorkshop);
	Bid = RouteWorkshop;
	Shop = StorageId;
	.
	
+default::winner(TaskList, assist(Storage, Assembler))
<-
	!strategies::not_free;
	.print("I won the tasks ",TaskList);
	!strategies::go_work(TaskList, Storage, Assembler);
	.
+default::winner(TaskList, assemble(Storage, JobId, Members))
<-
	!strategies::not_free;
	?default::get_assemble(TaskList, [], AssembleList);
	.sort(AssembleList,AssembleListSorted);
	.print("I won the tasks to assemble ",AssembleListSorted," and deliver to ",Storage," for ",JobId);
	!strategies::go_assemble(AssembleListSorted, Storage, JobId, Members);
	.