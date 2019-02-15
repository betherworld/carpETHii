//Target coordinates
float in_lat = 44.4325; //Latitude in deg
float in_lng = 26.103889; //Longitude in deg
float in_alt = 80; //Altitude in m

float delta_lat_rad = abs( int_lat - gps.location.lat() )
float delta_lng_rad = abs( int_lng - gps.location.lng() )
float delta_alt = abs( int_alt - gps.altitude.meters() )

//Trigonometry: Radians to degrees for tan() function
float delta_lat_deg = ( delta_lat_rad / 180 ) * pi
float delta_lng_deg = ( delta_lng_rad / 180 ) * pi

//Trigonometry: Horizontal distance from angle via earth radius (6370km), Assumption: prefect Geoid, all units in m
float delta_lat_m = 6370000 * tan( delta_lat_deg / 2 )*2; //trigonometry: earth radius (6370km), assumption: prefect geoid
float delta_lng_m = 6370000 * tan( delta_lng_deg / 2 )*2;

//Geofence, all units in m

float r_tol = 2000 //Tolerance radius ("fence")
float r_pos= sqrt( ( delta_lat_m )^2 + ( delta_lng_m )^2 + ( float delta_alt )^2 ) //Distance from target to position, vector length

int time_counter=0; //Counts number of time increments of sensor in fenced area
int time_limit=100; //Number of time increments for completion of task

while ( r_pos < r_tol ) {
  time_counter++;
}

if ( time_counter > time_limit ) {
 //SOME ACTION!!!
}
