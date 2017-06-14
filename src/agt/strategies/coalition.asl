countCenter(0).
coalition1([vehicle1,vehicle5,vehicle6,vehicle13,vehicle14,vehicle21,vehicle22]).
coalition2([vehicle2,vehicle7,vehicle8,vehicle15,vehicle16,vehicle23,vehicle24]).
coalition3([vehicle3,vehicle9,vehicle10,vehicle17,vehicle18,vehicle25,vehicle26]).
coalition4([vehicle4,vehicle11,vehicle12,vehicle19,vehicle20,vehicle27,vehicle28]).

@minLon[atomic]
+default::minLon(Lon) : X = Lon + 0.001 & countCenter(I) <- -minLon(Lon); +minLonReal(X); -+countCenter(I+1).
@maxLon[atomic]
+default::maxLon(Lon) : X = Lon - 0.00001 & countCenter(I) <- -maxLon(Lon); +maxLonReal(X); -+countCenter(I+1).
@minLat[atomic]
+default::minLat(Lat) : X = Lat + 0.001 & countCenter(I)  <- -minLat(Lat); +minLatReal(X); -+countCenter(I+1).
@maxLat[atomic]
+default::maxLat(Lat) : X = Lat - 0.00001 & countCenter(I)  <- -maxLat(Lat); +maxLatReal(X); -+countCenter(I+1).

+countCenter(4) 
	: minLonReal(MinLon) & maxLonReal(MaxLon) & minLatReal(MinLat) & maxLatReal(MaxLat) 
<- 
	-countCenter(4);
	+mapCenter(math.ceil(((MinLat+MaxLat)/2) * 100000) / 100000,math.ceil(((MinLon+MaxLon)/2) * 100000) / 100000);
	?mapCenter(CLat,CLon);
	addQuad1(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	addQuad2(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);
	addQuad3(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	addQuad4(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);
	!gotoQuad1;
	!gotoQuad2;
	!gotoQuad3;
	!gotoQuad4;
	.
	
+!gotoQuad1 
	: default::quad1(Lat,Lon) & coalition1(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))}
	.
+!gotoQuad2 
	: default::quad2(Lat,Lon) & coalition2(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))}
	.
+!gotoQuad3 
	: default::quad3(Lat,Lon) & coalition3(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))}
	.
+!gotoQuad4
	: default::quad4(Lat,Lon) & coalition4(L) 
<- 
	for ( .member(A,L) ) {
		.send(A,achieve,action::goto(Lat,Lon))}
	.