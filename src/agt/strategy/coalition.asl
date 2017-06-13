countCenter(0).
coalition1([vehicle1,vehicle5,vehicle6,vehicle13,vehicle14,vehicle21,vehicle22]).
coalition2([vehicle2,vehicle7,vehicle8,vehicle15,vehicle16,vehicle23,vehicle24]).
coalition3([vehicle3,vehicle9,vehicle10,vehicle17,vehicle18,vehicle25,vehicle26]).
coalition4([vehicle4,vehicle11,vehicle12,vehicle19,vehicle20,vehicle27,vehicle28]).

+default::step(0)
	: .my_name(Me) & Me == vehicle28
<-	+minLon(2.26);
	+maxLon(2.41);
	+minLat(48.82);
	+maxLat(48.90);
	.

+minLon(Lon) : X = Lon + 0.001 & countCenter(I) <- -minLon(Lon); +minLonReal(X); -+countCenter(I+1).
+maxLon(Lon) : X = Lon - 0.00001 & countCenter(I) <- -maxLon(Lon); +maxLonReal(X); -+countCenter(I+1).

+minLat(Lat) : X = Lat + 0.001 & countCenter(I)  <- -minLat(Lat); +minLatReal(X); -+countCenter(I+1).
+maxLat(Lat) : X = Lat - 0.00001 & countCenter(I)  <- -maxLat(Lat); +maxLatReal(X); -+countCenter(I+1).

+countCenter(4) 
	: minLonReal(MinLon) & maxLonReal(MaxLon) & minLatReal(MinLat) & maxLatReal(MaxLat) 
<- 
	-countCenter(4);
	+mapCenter((MinLat+MaxLat)/2,(MinLon+MaxLon)/2);
	?mapCenter(CLat,CLon);
	+quad1((MaxLat+CLat)/2,(MinLon+CLon)/2);
	+quad2((MaxLat+CLat)/2,(MaxLon+CLon)/2);
	+quad3((MinLat+CLat)/2,(MinLon+CLon)/2);
	+quad4((MinLat+CLat)/2,(MaxLon+CLon)/2);
	!gotoQuad1;
	!gotoQuad2;
	!gotoQuad3;
	!gotoQuad4;
	.
	
+!gotoQuad1 
	: quad1(Lat,Lon) & coalition1(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))
	}
.
+!gotoQuad2 
	: quad2(Lat,Lon) & coalition2(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))
	}
.
+!gotoQuad3 
	: quad3(Lat,Lon) & coalition3(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))
	}
.
+!gotoQuad4
	: quad4(Lat,Lon) & coalition4(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))
	}
.