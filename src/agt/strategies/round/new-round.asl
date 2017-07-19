{begin namespace(lNewRound, global)}

+!add_initiator_beliefs
	: true
<-
	+initiator::free_agents([vehicle1,vehicle2,vehicle3,vehicle4,vehicle5,vehicle6,vehicle7,vehicle8,vehicle9,vehicle10,vehicle11,vehicle12,vehicle13,vehicle14,vehicle15,vehicle16,vehicle17,vehicle18,vehicle19,vehicle20,vehicle21,vehicle22,vehicle23,vehicle24,vehicle25,vehicle26,vehicle27,vehicle28]);
	+initiator::free_trucks([vehicle21,vehicle22,vehicle23,vehicle24,vehicle25,vehicle26,vehicle27,vehicle28]);
	+initiator::task_id(0);
	. 
+!add_initiator_beliefs.

{end}

{begin namespace(new, global)}

+!new_round
	: .my_name(Me)
<-
	+chargingList([]);
	+dumpList([]);
//	+storageList([]);
	+shopList([]);
	+workshopList([]);
	+max_bid_time(10000);
	+tool_types([vehicle1,vehicle5,vehicle13,vehicle21]);
	+vehicle_job(truck,5);
	+noActionCount(0);
	
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
	for (.member(item(ItemId,_,Qty,_,_,_),Items)) {
		addShopItem(item(ShopId,ItemId),Qty);
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
			
//@storageList[atomic]
//+default::storage(StorageId, Lat, Lon, TotCap, UsedCap, Items)
//	: storageList(List) & not .member(StorageId,List)
//<-
//	-+storageList([StorageId|List]);
//	.	

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