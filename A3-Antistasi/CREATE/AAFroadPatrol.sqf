private ["_soldados","_vehiculos","_grupos","_base","_posBase","_roads","_tipoCoche","_arrayAirports","_arrayDestinations","_tam","_road","_veh","_vehCrew","_grupoVeh","_grupo","_grupoP","_distanceX","_spawnPoint"];

_soldados = [];
_vehiculos = [];
_grupos = [];
_base = "";
_roads = [];

_arrayAirports = if (hayIFA) then {(airportsX + puestos) select {((spawner getVariable _x != 0)) and (lados getVariable [_x,sideUnknown] != buenos)}} else {(puertos + airportsX + puestos) select {((spawner getVariable _x != 0)) and (lados getVariable [_x,sideUnknown] != buenos)}};

_arrayAirports1 = [];
if !(isMultiplayer) then
	{
	{
	_airportX = _x;
	_pos = getMarkerPos _airportX;
	//if (allUnits findIf {(_x getVariable ["spawner",false]) and (_x distance2d _pos < distanceForLandAttack)} != -1) then {_arrayAirports1 pushBack _airportX};
	if ([distanceForLandAttack,1,_pos,buenos] call A3A_fnc_distanceUnits) then {_arrayAirports1 pushBack _airportX};
	} forEach _arrayAirports;
	}
else
	{
	{
	_airportX = _x;
	_pos = getMarkerPos _airportX;
	if (playableUnits findIf {(side (group _x) == buenos) and (_x distance2d _pos < distanceForLandAttack)} != -1) then {_arrayAirports1 pushBack _airportX};
	} forEach _arrayAirports;
	};
if (_arrayAirports1 isEqualTo []) exitWith {};

_base = selectRandom _arrayAirports1;
_tipoCoche = "";
_lado = malos;
_typePatrol = "LAND";
if (lados getVariable [_base,sideUnknown] == malos) then
	{
	if ((_base in puertos) and ([vehNATOBoat] call A3A_fnc_vehAvailable)) then
		{
		_tipoCoche = vehNATOBoat;
		_typePatrol = "SEA";
		}
	else
		{
		if (random 100 < prestigeNATO) then
			{
			_tipoCoche = if (_base in airportsX) then {selectRandom (vehNATOLight + [vehNATOPatrolHeli])} else {selectRandom vehNATOLight};
			if (_tipoCoche == vehNATOPatrolHeli) then {_typePatrol = "AIR"};
			}
		else
			{
			_tipoCoche = selectRandom [vehPoliceCar,vehFIAArmedCar];
			};
		};
	}
else
	{
	_lado = muyMalos;
	if ((_base in puertos) and ([vehCSATBoat] call A3A_fnc_vehAvailable)) then
		{
		_tipoCoche = vehCSATBoat;
		_typePatrol = "SEA";
		}
	else
		{
		_tipoCoche = if (_base in airportsX) then {selectRandom (vehCSATLight + [vehCSATPatrolHeli])} else {selectRandom vehCSATLight};
		if (_tipoCoche == vehCSATPatrolHeli) then {_typePatrol = "AIR"};
		};
	};

_posbase = getMarkerPos _base;


if (_typePatrol == "AIR") then
	{
	_arrayDestinations = markersX select {lados getVariable [_x,sideUnknown] == _lado};
	_distanceX = 200;
	}
else
	{
	if (_typePatrol == "SEA") then
		{
		_arrayDestinations = seaMarkers select {(getMarkerPos _x) distance _posbase < 2500};
		_distanceX = 100;
		}
	else
		{
		_arrayDestinations = markersX select {lados getVariable [_x,sideUnknown] == _lado};
		_arrayDestinations = [_arrayDestinations,_posBase] call A3A_fnc_patrolDestinations;
		_distanceX = 50;
		};
	};

if (count _arrayDestinations < 4) exitWith {};

AAFpatrols = AAFpatrols + 1;

if (_typePatrol != "AIR") then
	{
	if (_typePatrol == "SEA") then
		{
		_posbase = [_posbase,50,150,10,2,0,0] call BIS_Fnc_findSafePos;
		}
	else
		{
		_indice = airportsX find _base;
		if (_indice != -1) then
			{
			_spawnPoint = spawnPoints select _indice;
			_posBase = getMarkerPos _spawnPoint;
			}
		else
			{
			_posbase = position ([_posbase] call A3A_fnc_findNearestGoodRoad);
			};
		};
	};

_vehicle=[_posBase, 0,_tipoCoche, _lado] call bis_fnc_spawnvehicle;
_veh = _vehicle select 0;
[_veh] call A3A_fnc_AIVEHinit;
[_veh,"Patrol"] spawn A3A_fnc_inmuneConvoy;
_vehCrew = _vehicle select 1;
{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
_grupoVeh = _vehicle select 2;
_soldados = _soldados + _vehCrew;
_grupos = _grupos + [_grupoVeh];
_vehiculos = _vehiculos + [_veh];


if (_tipoCoche in vehNATOLightUnarmed) then
	{
	sleep 1;
	_grupo = [_posbase, _lado, groupsNATOSentry] call A3A_fnc_spawnGroup;
	{_x assignAsCargo _veh;_x moveInCargo _veh; _soldados pushBack _x; [_x] joinSilent _grupoveh; [_x] call A3A_fnc_NATOinit} forEach units _grupo;
	deleteGroup _grupo;
	};
if (_tipoCoche in vehCSATLightUnarmed) then
	{
	sleep 1;
	_grupo = [_posbase, _lado, groupsCSATSentry] call A3A_fnc_spawnGroup;
	{_x assignAsCargo _veh;_x moveInCargo _veh; _soldados pushBack _x; [_x] joinSilent _grupoveh; [_x] call A3A_fnc_NATOinit} forEach units _grupo;
	deleteGroup _grupo;
	};

//if (_typePatrol == "LAND") then {_veh forceFollowRoad true};

while {alive _veh} do
	{
	if (count _arrayDestinations < 2) exitWith {};
	_destino = selectRandom _arrayDestinations;
	if (debug) then {player globalChat format ["Patrulla AI generada. Origen: %2 Destino %1", _destino, _base]; sleep 3};
	_posDestination = getMarkerPos _destino;
	if (_typePatrol == "LAND") then
		{
		_road = [_posDestination] call A3A_fnc_findNearestGoodRoad;
		_posDestination = position _road;
		};
	_Vwp0 = _grupoVeh addWaypoint [_posDestination, 0];
	_Vwp0 setWaypointType "MOVE";
	_Vwp0 setWaypointBehaviour "SAFE";
	_Vwp0 setWaypointSpeed "LIMITED";
	_veh setFuel 1;

	waitUntil {sleep 60; (_veh distance _posDestination < _distanceX) or ({[_x] call A3A_fnc_canFight} count _soldados == 0) or (!canMove _veh)};
	if !(_veh distance _posDestination < _distanceX) exitWith {};
	if (_typePatrol == "AIR") then
		{
		_arrayDestinations = markersX select {lados getVariable [_x,sideUnknown] == _lado};
		}
	else
		{
		if (_typePatrol == "SEA") then
			{
			_arrayDestinations = seaMarkers select {(getMarkerPos _x) distance position _veh < 2500};
			}
		else
			{
			_arrayDestinations = markersX select {lados getVariable [_x,sideUnknown] == _lado};
			_arrayDestinations = [_arrayDestinations,position _veh] call A3A_fnc_patrolDestinations;
			};
		};
	};

_enemigos = if (_lado == malos) then {muyMalos} else {malos};

{_unit = _x;
waitUntil {sleep 1;!([distanceSPWN,1,_unit,buenos] call A3A_fnc_distanceUnits) and !([distanceSPWN,1,_unit,_enemigos] call A3A_fnc_distanceUnits)};deleteVehicle _unit} forEach _soldados;

{_veh = _x;
if (!([distanceSPWN,1,_veh,buenos] call A3A_fnc_distanceUnits) and !([distanceSPWN,1,_veh,_enemigos] call A3A_fnc_distanceUnits)) then {deleteVehicle _veh}} forEach _vehiculos;
{deleteGroup _x} forEach _grupos;
AAFpatrols = AAFpatrols - 1;