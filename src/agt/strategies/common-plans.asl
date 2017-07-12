{ include("action/actions.asl",action) }
free.

+default::actionID(0)
	: true
<-
	.wait({ +coalition::coalition(Quad,Members,Task) });
	if (Task == shoporganiser) {
		?new::shopList(List);
		?default::getQuadShops(Quad, List, Shops);
//		.print("Shops in my quad ",Shops);
		+counter(0);
		.length(Shops,NumberOfShops);
		for ( .member(agent(Agent,shop),Members) ) {
			?counter(I);
			.nth(I,Shops,Shop);
			if (NumberOfShops-1 >= I+1) { -+counter(I+1); }
			else { if (NumberOfShops-1 \== 0) { -+counter(I-1); }}
			.send(Agent, achieve, strategies::exploreShop(Shop));
		}
		-counter(_);
		.nth(NumberOfShops-1,Shops,ShopN);
		!exploreShop(ShopN);
	}
//	if (Task == explore) {-free; !explore(Quad)};
//	if (Task == shop) {-free; !exploreShop(Quad)};
//	if (Task == first) {-free; !exploreTools(Task,Quad,Members)};
//	if (Task == second) {-free; !exploreTools(Task,Quad,Members)};
	if (Task == workshop) {-free; !exploreWorkshop(Quad)};
//	if (Task == resource) {!action::skip};
	.
+default::actionID(X) 
	: free
<-
	!action::skip;
	.

+!exploreShop(Shop)
	: true
<- 
	-free;
	!action::goto(Shop);
	?default::step(S);
	.print("Finished my exploration at step ",S);
	+free; 
	!action::skip;
	.
	
+!exploreWorkshop(Quad)
	: default::role(Role, _, _, _, _) & new::workshopList(List) & default::getQuadLatLon(Quad,Lat,Lon)
<- 
	actions.closest(Role,Lat,Lon,List,_,ClosestWorkshop);
	!action::goto(ClosestWorkshop);
	?default::step(S);
	.print("Finished my exploration at step ",S);
	+free; 
	!action::skip;
	.
	
+!go_assemble(AssembleList,Storage,JobId)
	: default::role(Role, _, _, _, _) & new::workshopList(WList) & coalition::coalition(_,Members,_)
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
	for ( .member(agent(Agent,_),Members) ) {
		.send(Agent,achieve,strategies::stop_assisting);
	}
	.print("Finished assembly all items, ready to deliver.");
	!action::goto(Storage);
	!action::deliver_job(JobId);
	.print("$$$ I have just delivered job ",JobId);
	.member(agent(Agent,shoporganiser),Members);
	.send(Agent,achieve,strategies::job_finished);
	+free;
	!action::skip;
	.
	
+!go_work(TaskList, Storage)
	: default::role(Role, _, _, _, _) & new::workshopList(WList) & new::shopList(SList) & coalition::coalition(_,Members,_)
<-
	-free;
	for ( .member(item(ItemId,Qty),TaskList) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,Shops,ClosestShop);
		if (buyList(ItemId,Qty2,ClosestShop)) {
			-buyList(ItemId,Qty2,ClosestShop);
			+buyList(ItemId,Qty+Qty2,ClosestShop);
		}
		else { +buyList(ItemId,Qty,ClosestShop); }
	}
	!go_buy;
	actions.closest(Role,WList,Storage,ClosestWorkshop);
	!action::goto(ClosestWorkshop);
	+assembling;
	.member(agent(Agent,workshop),Members);
	!action::assist_assemble(Agent);
	+free;
	!action::skip;
	.
	
+!stop_assisting <- -assembling.

+!job_finished <- -default::winner(_).
	
//+!explore(Quad)
//	: coalition::minLonReal(MinLon) & coalition::maxLonReal(MaxLon) & coalition::minLatReal(MinLat) & coalition::maxLatReal(MaxLat) & coalition::mapCenter(CenterLat,CenterLon)
//<- 
//	if (Quad == quad1) {
//		!action::goto(CenterLat,MinLon);
//		!action::goto(MaxLat,MinLon);
//		!action::goto(MaxLat,CenterLon);
//		!action::goto(CenterLat,CenterLon);
//	}
//	if (Quad == quad2) {
//		!action::goto(MaxLat,CenterLon);
//		!action::goto(MaxLat,MaxLon);
//		!action::goto(CenterLat,MaxLon);
//		!action::goto(CenterLat,CenterLon);
//		
//	}
//	if (Quad == quad3) {
//		!action::goto(CenterLat,CenterLon);
//		!action::goto(CenterLat,MinLon);
//		!action::goto(MinLat,MinLon);
//		!action::goto(MinLat,CenterLon);
//	}
//	if (Quad == quad4) {
//		!action::goto(CenterLat,CenterLon);
//		!action::goto(MinLat,CenterLon);
//		!action::goto(MinLat,MaxLon);
//		!action::goto(CenterLat,MaxLon);
//	}
//	?default::step(S);
//	.print("Finished my exploration at step ",S);
//	+free; 
//	!action::skip;
//	.
//+!exploreTools(Task,Quad,Members)
//	: default::role(Role, _, _, _, _) & new::shopList(List) & default::getQuadLatLon(Quad,Lat,Lon)
//<- 
//	getTools(Task,ListTools);
////	.print("Quad #",Quad," Have to buy ",ListTools);
//	for ( .member(ToolS,ListTools) ) {
//		.term2string(Tool,ToolS);
//		?default::find_shops(Tool,List,Shops);
//		actions.closest(Role,Shops,ClosestShop);
//		if (buyList(Tool,Qty,ClosestShop)) {
//			-buyList(Tool,Qty,ClosestShop);
//			+buyList(Tool,Qty+1,ClosestShop);
//		}
//		else { +buyList(Tool,1,ClosestShop); }
//	}
//	!goBuy;
//	?new::workshopList(WList);
//	actions.closest(Role,Lat,Lon,WList,_,ClosestWorkshop);
//	!action::goto(ClosestWorkshop);
//	.sublist([agent(Truck,workshop)],Members);
//	for ( default::hasItem(Tool,Qty) ) {
//		.term2string(Tool,ToolS);
//		.send(Truck,achieve,action::receive(Tool,Qty));
//		!action::give(Truck,Tool,Qty);
//	}
//	.send(Truck,tell,strategies::free);
//	.send(Truck,achieve,action::skip);
//	?default::step(S);
//	.print("Finished my exploration at step ",S);
//	+free; 
//	!action::skip;
//	.
//
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

//+default::resNode(ResourceId,Lat,Lon,Resource)
//<- !checkCoalition(ResourceId,Lat,Lon,Resource).
//
//+!checkCoalition(ResourceId,Lat,Lon,Resource)
//	: coalition::coalition(Quad, Members, resource)
//<- !resNode(ResourceId,Lat,Lon,Resource).
//-!checkCoalition(ResourceId,Lat,Lon,Resource) <- .wait(500); !checkCoalition(ResourceId,Lat,Lon,Resource).

//+!resNode(ResourceId,Lat,Lon,Resource)
//	: coalition::coalition(Quad, Members, resource) & not gathering & default::checkQuadrant(Quad,Lat,Lon) & .term2string(ResT,Resource) & default::item(ResT,Vol,_,_)
//<-
//	-free;
//	+gathering;
//	.print("Resource ",ResourceId," is in my quadrant, moving to gather.");
//	!action::goto(Lat,Lon);
//	?default::step(S);
//	.print("Arrived at ",ResourceId," in step ",S);
//	!action::gather(Vol);
//	+free;
//	!action::skip;
//	.

+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
//+default::hasItem(Item,Qty)
//<- .print("I now have #",Qty," of item ",Item).

//+default::resourceNode(ResourceId,Lat,Lon,Resource)
//	: .term2string(ResourceId,ResourceId2) & not default::resNode(ResourceId2,_,_,_)
//<- 
//	.print("Detected new resource node ",ResourceId," with resource ",Resource);
//	-default::resourceNode(ResourceId,Lat,Lon,Resource);
//	addResourceNode(ResourceId,Lat,Lon,Resource);
//	.
	