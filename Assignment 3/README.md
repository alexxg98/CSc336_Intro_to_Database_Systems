# Assignment: CitiBike Analysis
Design and implement a relational database to help manage the Citibike program in NYC (data from July 2013).

From the data,
+ determine the most frequent trips between any two stations by the day of the week
+ find permanently dormant and vacant stations

The data is split into the following tables:
```
Stations(Id, Name, Latitude, Longitude);

Trips(StationId, MinTripDuration, MaxTripDuration, AvgTripDuration, NumberStartUsers, NumberReturnUsers);

UsageByDay(StationId, NumberWeekdayStartUsers, NumberWeekdayReturnUsers,NumberWeekendStartUsers, NumberWeekendReturnUsers);

UsageByGender(StationId, NumberMaleStartUsers, NumberFemaleStartUsers, NumberMaleReturnUsers, NumberFemaleReturnUsers);

UsageByAge(StationId, NumberMaleUsersUnder18, NumberMaleUsers18To40, NumberMaleUsersOver40, NumberFemaleUsersUnder18, NumberFemaleUsers18To40, NumberFemaleUsersOver40);
```