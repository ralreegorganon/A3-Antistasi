//if ([0.5] call A3A_fnc_fogCheck) exitWith {};
private ["_objetivos","_markersX","_base","_objetivo","_cuenta","_airportX","_datos","_prestigeOPFOR","_scoreLand","_scoreAir","_analyzed","_garrison","_size","_estaticas","_salir"];

_objetivos = [];
_markersX = [];
_cuentaFacil = 0;
_natoIsFull = false;
_csatIsFull = false;
_airportsX = airportsX select {([_x,false] call A3A_fnc_airportCanAttack) and (lados getVariable [_x,sideUnknown] != buenos)};
_objetivos = markersX - controlsX - outpostsFIA - ["Synd_HQ","NATO_carrier","CSAT_carrier"] - destroyedCities;
if (gameMode != 1) then {_objetivos = _objetivos select {lados getVariable [_x,sideUnknown] == buenos}};
//_objectivesSDK = _objetivos select {lados getVariable [_x,sideUnknown] == buenos};
if ((tierWar < 2) and (gameMode <= 2)) then
	{
	_airportsX = _airportsX select {(lados getVariable [_x,sideUnknown] == malos)};
	//_objetivos = _objectivesSDK;
	_objetivos = _objetivos select {lados getVariable [_x,sideUnknown] == buenos};
	}
else
	{
	if (gameMode != 4) then {if ({lados getVariable [_x,sideUnknown] == malos} count _airportsX == 0) then {_airportsX pushBack "NATO_carrier"}};
	if (gameMode != 3) then {if ({lados getVariable [_x,sideUnknown] == muyMalos} count _airportsX == 0) then {_airportsX pushBack "CSAT_carrier"}};
	if (([vehNATOPlane] call A3A_fnc_vehAvailable) and ([vehNATOMRLS] call A3A_fnc_vehAvailable) and ([vehNATOTank] call A3A_fnc_vehAvailable)) then {_natoIsFull = true};
	if (([vehCSATPlane] call A3A_fnc_vehAvailable) and ([vehCSATMRLS] call A3A_fnc_vehAvailable) and ([vehCSATTank] call A3A_fnc_vehAvailable)) then {_csatIsFull = true};
	};
if (gameMode != 4) then
	{
	if (tierWar < 3) then {_objetivos = _objetivos - ciudades};
	}
else
	{
	if (tierWar < 5) then {_objetivos = _objetivos - ciudades};
	};
//lets keep the nearest targets for each AI airbase in the target list, so we ensure even when they are surrounded of friendly zones, they remain as target
_nearestObjectives = [];
{
_lado = lados getVariable [_x,sideUnknown];
_tmpTargets = _objetivos select {lados getVariable [_x,sideUnknown] != _lado};
if !(_tmpTargets isEqualTo []) then
	{
	_nearestTarget = [_tmpTargets,getMarkerPos _x] call BIS_fnc_nearestPosition;
	_nearestObjectives pushBack _nearestTarget;
	};
} forEach _airportsX;
//the following discards targets which are surrounded by friendly zones, excluding airbases and the nearest targets
_objetivosProv = _objetivos - airportsX - _nearestObjectives;
{
_posObj = getMarkerPos _x;
_ladoObj = lados getVariable [_x,sideUnknown];
if (((markersX - controlsX - ciudades - outpostsFIA) select {lados getVariable [_x,sideUnknown] != _ladoObj}) findIf {getMarkerPos _x distance2D _posObj < 2000} == -1) then {_objetivos = _objetivos - [_x]};
} forEach _objetivosProv;

if (_objetivos isEqualTo []) exitWith {};
_objectivesFinal = [];
_basesFinal = [];
_countFinal = [];
_objectiveFinal = [];
_faciles = [];
_easyArray = [];
_seaportCSAT = if ({(lados getVariable [_x,sideUnknown] == muyMalos)} count puertos >0) then {true} else {false};
_seaportNATO = if ({(lados getVariable [_x,sideUnknown] == malos)} count puertos >0) then {true} else {false};
_waves = 1;

{
_base = _x;
_posBase = getMarkerPos _base;
_killZones = killZones getVariable [_base,[]];
_tmpObjectives = [];
_baseNATO = true;
if (lados getVariable [_base,sideUnknown] == malos) then
	{
	_tmpObjectives = _objetivos select {lados getVariable [_x,sideUnknown] != malos};
	_tmpObjectives = _tmpObjectives - (ciudades select {([_x] call A3A_fnc_powerCheck) == buenos});
	}
else
	{
	_baseNATO = false;
	_tmpObjectives = _objetivos select {lados getVariable [_x,sideUnknown] != muyMalos};
	_tmpObjectives = _tmpObjectives - (ciudades select {(((server getVariable _x) select 2) + ((server getVariable _x) select 3) < 90) and ([_x] call A3A_fnc_powerCheck != malos)});
	};

_tmpObjectives = _tmpObjectives select {getMarkerPos _x distance2D _posBase < distanceForAirAttack};
if !(_tmpObjectives isEqualTo []) then
	{
	_cercano = [_tmpObjectives,_base] call BIS_fnc_nearestPosition;
	{
	_esCiudad = if (_x in ciudades) then {true} else {false};
	_proceder = true;
	_posSitio = getMarkerPos _x;
	_esSDK = false;
	_isTheSameIsland = [_x,_base] call A3A_fnc_isTheSameIsland;
	if ([_x,true] call A3A_fnc_fogCheck >= 0.3) then
		{
		if (lados getVariable [_x,sideUnknown] == buenos) then
			{
			_esSDK = true;
			/*
			_valor = if (_baseNATO) then {prestigeNATO} else {prestigeCSAT};
			if (random 100 > _valor) then
				{
				_proceder = false
				}
			*/
			};
		if (!_isTheSameIsland and (not(_x in airportsX))) then
			{
			if (!_esSDK) then {_proceder = false};
			};
		}
	else
		{
		_proceder = false;
		};
	if (_proceder) then
		{
		if (!_esCiudad) then
			{
			if !(_x in _killZones) then
				{
				if !(_x in _easyArray) then
					{
					_sitio = _x;
					if (((!(_sitio in airportsX)) or (_esSDK)) and !(_base in ["NATO_carrier","CSAT_carrier"])) then
						{
						_ladoEny = if (_baseNATO) then {muyMalos} else {malos};
						if ({(lados getVariable [_x,sideUnknown] == _ladoEny) and (getMarkerPos _x distance _posSitio < distanceSPWN)} count airportsX == 0) then
							{
							_garrison = garrison getVariable [_sitio,[]];
							_estaticas = staticsToSave select {_x distance _posSitio < distanceSPWN};
							_puestos = outpostsFIA select {getMarkerPos _x distance _posSitio < distanceSPWN};
							_cuenta = ((count _garrison) + (count _puestos) + (2*(count _estaticas)));
							if (_cuenta <= 8) then
								{
								if (!hayIFA or (_posSitio distance _posBase < distanceForLandAttack)) then
									{
									_proceder = false;
									_faciles pushBack [_sitio,_base];
									_easyArray pushBackUnique _sitio;
									};
								};
							};
						};
					};
				};
			};
		};
	if (_proceder) then
		{
		_times = 1;
		if (_baseNATO) then
			{
			if ({lados getVariable [_x,sideUnknown] == malos} count airportsX <= 1) then {_times = 2};
			if (!_esCiudad) then
				{
				if ((_x in puestos) or (_x in puertos)) then
					{
					if (!_esSDK) then
						{
						if (({[_x] call A3A_fnc_vehAvailable} count vehNATOAttack > 0) or ({[_x] call A3A_fnc_vehAvailable} count vehNATOAttackHelis > 0)) then {_times = 2*_times} else {_times = 0};
						}
					else
						{
						_times = 2*_times;
						};
					}
				else
					{
					if (_x in airportsX) then
						{
						if (!_esSDK) then
							{
							if (([vehNATOPlane] call A3A_fnc_vehAvailable) or (!([vehCSATAA] call A3A_fnc_vehAvailable))) then {_times = 5*_times} else {_times = 0};
							}
						else
							{
							if (!_isTheSameIsland) then {_times = 5*_times} else {_times = 2*_times};
							};
						}
					else
						{
						if ((!_esSDK) and _natoIsFull) then {_times = 0};
						};
					};
				};
			if (_times > 0) then
				{
				_airportNear = [airportsX,_posSitio] call bis_fnc_nearestPosition;
				if ((lados getVariable [_airportNear,sideUnknown] == muyMalos) and (_x != _airportNear)) then {_times = 0};
				};
			}
		else
			{
			_times = 2;
			if (!_esCiudad) then
				{
				if ((_x in puestos) or (_x in puertos)) then
					{
					if (!_esSDK) then
						{
						if (({[_x] call A3A_fnc_vehAvailable} count vehCSATAttack > 0) or ({[_x] call A3A_fnc_vehAvailable} count vehCSATAttackHelis > 0)) then {_times = 2*_times} else {_times = 0};
						}
					else
						{
						_times = 2*_times;
						};
					}
				else
					{
					if (_x in airportsX) then
						{
						if (!_esSDK) then
							{
							if (([vehCSATPlane] call A3A_fnc_vehAvailable) or (!([vehNATOAA] call A3A_fnc_vehAvailable))) then {_times = 5*_times} else {_times = 0};
							}
						else
							{
							if (!_isTheSameIsland) then {_times = 5*_times} else {_times = 2*_times};
							};
						}
					else
						{
						if ((!_esSDK) and _csatIsFull) then {_times = 0};
						};
					}
				};
			if (_times > 0) then
				{
				_airportNear = [airportsX,_posSitio] call bis_fnc_nearestPosition;
				if ((lados getVariable [_airportNear,sideUnknown] == malos) and (_x != _airportNear)) then {_times = 0};
				};
			};
		if (_times > 0) then
			{
			if ((!_esSDK) and (!_esCiudad)) then
				{
				//_times = _times + (floor((garrison getVariable [_x,0])/8))
				_numGarr = [_x] call A3A_fnc_garrisonSize;
				if ((_numGarr/2) < count (garrison getVariable [_x,[]])) then {if ((_numGarr/3) < count (garrison getVariable [_x,[]])) then {_times = _times + 6} else {_times = _times +2}};
				};
			if (_isTheSameIsland) then
				{
				if (_posSitio distance _posBase < distanceForLandAttack) then
					{
					if  (!_esCiudad) then
						{
						_times = _times * 4
						};
					};
				};
			if (!_esCiudad) then
				{
				_esMar = false;
				if ((_baseNATO and _seaportNATO) or (!_baseNATO and _seaportCSAT)) then
					{
					for "_i" from 0 to 3 do
						{
						_pos = _posSitio getPos [1000,(_i*90)];
						if (surfaceIsWater _pos) exitWith {_esMar = true};
						};
					};
				if (_esMar) then {_times = _times * 2};
				};
			if (_x == _cercano) then {_times = _times * 5};
			if (_x in _killZones) then
				{
				_sitio = _x;
				_times = _times / (({_x == _sitio} count _killZones) + 1);
				};
			_times = round (_times);
			_index = _objectivesFinal find _x;
			if (_index == -1) then
				{
				_objectivesFinal pushBack _x;
				_basesFinal pushBack _base;
				_countFinal pushBack _times;
				}
			else
				{
				if ((_times > (_countFinal select _index)) or ((_times == (_countFinal select _index)) and (random 1 < 0.5))) then
					{
					_objectivesFinal deleteAt _index;
					_basesFinal deleteAt _index;
					_countFinal deleteAt _index;
					_objectivesFinal pushBack _x;
					_basesFinal pushBack _base;
					_countFinal pushBack _times;
					};
				};
			};
		};
	if (count _faciles == 4) exitWith {};
	} forEach _tmpObjectives;
	};
if (count _faciles == 4) exitWith {};
} forEach _airportsX;

if (count _faciles == 4) exitWith
	{
	{[[_x select 0,_x select 1,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2];sleep 30} forEach _faciles;
	};
if (hayIFA and (sunOrMoon < 1)) exitWith {};
if ((count _objectivesFinal > 0) and (count _faciles < 3)) then
	{
	_arrayFinal = [];
	/*{
	for "_i" from 1 to _x do
		{
		_arrayFinal pushBack [(_objectivesFinal select _forEachIndex),(_basesFinal select _forEachIndex)];
		};
	} forEach _countFinal;*/
	for "_i" from 0 to (count _objectivesFinal) - 1 do
		{
		_arrayFinal pushBack [_objectivesFinal select _i,_basesFinal select _i];
		};
	//_objectiveFinal = selectRandom _arrayFinal;
	_objectiveFinal = _arrayFinal selectRandomWeighted _countFinal;
	_destino = _objectiveFinal select 0;
	_origen = _objectiveFinal select 1;
	///aquí decidimos las oleadas
	if (_waves == 1) then
		{
		if (lados getVariable [_destino,sideUnknown] == buenos) then
			{
			_waves = (round (random tierWar));
			if (_waves == 0) then {_waves = 1};
			}
		else
			{
			if (lados getVariable [_origen,sideUnknown] == muyMalos) then
				{
				if (_destino in airportsX) then
					{
					_waves = 2 + round (random tierWar);
					}
				else
					{
					if (!(_destino in ciudades)) then
						{
						_waves = 1 + round (random (tierWar)/2);
						};
					};
				}
			else
				{
				if (!(_destino in ciudades)) then
					{
					_waves = 1 + round (random ((tierWar - 3)/2));
					};
				};
			};
		};
	if (not(_destino in ciudades)) then
		{
		///[[_destino,_origen,_waves],"A3A_fnc_wavedCA"] call A3A_fnc_scheduler;
		[_destino,_origen,_waves] spawn A3A_fnc_wavedCA;
		}
	else
		{
		//if (lados getVariable [_origen,sideUnknown] == malos) then {[[_destino,_origen,_waves],"A3A_fnc_wavedCA"] call A3A_fnc_scheduler} else {[[_destino,_origen],"A3A_fnc_CSATpunish"] call A3A_fnc_scheduler};
		if (lados getVariable [_origen,sideUnknown] == malos) then {[_destino,_origen,_waves] spawn A3A_fnc_wavedCA} else {[_destino,_origen] spawn A3A_fnc_CSATpunish};
		};
	};

if (_waves == 1) then
	{
	{[[_x select 0,_x select 1,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]} forEach _faciles;
	};
