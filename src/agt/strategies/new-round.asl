+!new_round
	: true
<-
	+chargingList([]);
//	+dumpList([]);
//	+storageList([]);
	+shopList([]);
	+workshopList([]);
	+max_bid_time(2000);
	+job_bidders(4);
	+coalition_leaders([vehicle1,vehicle2,vehicle3,vehicle4]);
	+tool_types([vehicle1,vehicle5,vehicle13,vehicle21]);
	+vehicle_mission(motorcycle,4);
	+noActionCount(0);
	.

@shopListQty[atomic]
+default::shop(ShopId, Lat, Lon, Restock, Items)
	: .my_name(Me) & Me == vehicle1 & shopList(List) & not .member(ShopId,List)
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

//@dumpList[atomic]
//+default::dump(DumpId,Lat,Lon) 
//	:  dumpList(List) & not .member(DumpId,List) 
//<- 
//	-+dumpList([DumpId|List]);
//	.