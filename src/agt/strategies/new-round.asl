+!new_round
	: true
<-
	+chargingList([]);
	+dumpList([]);
	+storageList([]);
	+shopList([]);
	+workshopList([]);
	+noActionCount(0);
	.
	
//@shopList[atomic]
//+default::shop(ShopId, Lat, Lon, Restock, Items)
//	: shopList(List) & not .member(shop(ShopId,_),List)
//<-
////	.print("Adding Shop: ",ShopId," Lat: ",Lat," Lon: ",Lon," Restock: ",Restock," Items: ",Items);
//	-+shopList([shop(ShopId,Items)|List]);
//	.
//			
//@storageList[atomic]
//+default::storage(StorageId, Lat, Lon, TotCap, UsedCap, Items)
//	: storageList(List) & not .member(StorageId,List)
//<-
//	-+storageList([StorageId|List]);
//	.	
//
//@chargingList[atomic]
//+default::chargingStation(ChargingId,Lat,Lon,Rate) 
//	:  chargingList(List) & not .member(ChargingId,List)
//<-
//	-+chargingList([ChargingId|List]);
//	.
//	
//@workshopList[atomic]
//+default::workshop(WorkshopId,Lat,Lon) 
//	:  workshopList(List) & not .member(WorkshopId,List)
//<- 
//	-+workshopList([WorkshopId|List]);
//	.
//
//@dumpList[atomic]
//+default::dump(DumpId,Lat,Lon) 
//	:  dumpList(List) & not .member(DumpId,List) 
//<- 
//	-+dumpList([DumpId|List]);
//	.