{begin namespace(lNewRound, global)}

+!add_initiator_beliefs
	: true
<-
	+initiator::completed_jobs(0); // debugging
	+initiator::countCenter(0);
	+initiator::free_agents([]);
	+initiator::free_trucks([]);
	. 
+!add_initiator_beliefs.

{end}

{begin namespace(new, global)}

+!new_round
	: .my_name(Me)
<-
	+chargingList([]);
	+dumpList([]);
	+storageList([]);
	+shopList([]);
	+workshopList([]);
	+max_bid_time(10000);
	+tool_types([vehicle1,vehicle5,vehicle13,vehicle21]);
	+vehicle_job(truck,2);
	+noActionCount(0);
	
	+metrics::noAction(0);
	+metrics::jobHaveWorked(0);
	+metrics::jobCompletedMyPart(0);
	
	+metrics::money(0);
	+metrics::completedJobs(0);
	+metrics::failedJobs(0);
	+metrics::completedAuctions(0);
	+metrics::failedAuctions(0);
	+metrics::completedMissions(0);
	+metrics::failedMissions(0);
	+metrics::finePaid(0);
	
	+default::separateItemTool([],[],[]);
	+default::removeDuplicateTool([],[]);
	
	if (Me == vehicle1) { !lNewRound::add_initiator_beliefs; }
	.

@shopListQty[atomic]
+default::shop(ShopId, Lat, Lon, Restock, Items)
	: .my_name(vehicle1) & shopList(List) & not .member(ShopId,List)
<-
//	.print("Adding Shop: ",ShopId," Lat: ",Lat," Lon: ",Lon," Restock: ",Restock," Items: ",Items);
//	-+shopList([shop(ShopId,Items)|List]);
	for (.member(item(ItemId,Price,Qty,_,_,_),Items)) {
		addShopItem(item(ShopId,ItemId),Qty,ItemId,Price);
	}
	-+shopList([ShopId|List]);
	.
@shopList[atomic]
+default::shop(ShopId, Lat, Lon, Restock, Items)
	: shopList(List) & not .member(ShopId,List)
<-
//	.print("Adding Shop: ",ShopId," Lat: ",Lat," Lon: ",Lon," Restock: ",Restock," Items: ",Items);
//	-+shopList([shop(ShopId,Items)|List]);
	-+shopList([ShopId|List]);
	.

@storageListInit[atomic]
+default::storage(StorageId, Lat, Lon, TotCap, UsedCap, Items)
	: .my_name(vehicle1) & storageList(List) & not .member(StorageId,List)
<-
	createAvailableList(StorageId);
	-+storageList([StorageId|List]);
	.
@storageList[atomic]
+default::storage(StorageId, Lat, Lon, TotCap, UsedCap, Items)
	: storageList(List) & not .member(StorageId,List)
<-
	-+storageList([StorageId|List]);
	.
//+default::storage(StorageId, _, _, TotCap, UsedCap, Items)
//	: .my_name(vehicle1)
//<-
//	.print("ZZZZZZZZZZZZZZZ Items in storage: ",Items).

@chargingList[atomic]
+default::chargingStation(ChargingId,Lat,Lon,Rate) 
	:  chargingList(List) & not .member(ChargingId,List)
<-
	-+chargingList([ChargingId|List]);
	.
	
@workshopList[atomic]
+default::workshop(WorkshopId,Lat,Lon) 
	:  workshopList(List) & not .member(WorkshopId,List)
<- 
	-+workshopList([WorkshopId|List]);
	.

@dumpList[atomic]
+default::dump(DumpId,Lat,Lon) 
	:  dumpList(List) & not .member(DumpId,List) 
<- 
	-+dumpList([DumpId|List]);
	.
	
{end}