/*
 * Author: McKendrick 
 * Restores a previously cached vehicle from serialized data. Rebuilds physical state, damage, simulation, and inventory.
 *
 * Arguments:
 * 0: Serialized vehicle data <ARRAY> - As produced by ria_fnc_cacheVehicle
 *
 * Return Value:
 * Recreated vehicle <OBJECT>
 *
 * Example:
 * [_cachedVehicle] call ria_fnc_uncacheVehicle
 *
 * Public: No
 */

params [
    ["_vehData", [], [[]]]
];

//if (count _vehData < 15) exitWith { objNull };

_vehData params [
    "_type", "_pos", "_dir", "_vecDir", "_vecUp",
    "_dmg", "_hitpoints", "_fuel", "_engineOn",
    "_radarOn", "_lightsOn", "_sim", "_dynSim", "_magAmmo", "_inv"
];

// Spawn vehicle at placeholder position, then set world space
private _veh = createVehicle [_type, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_veh setPosWorld _pos;
_veh setDir _dir;
_veh setVectorDirAndUp [_vecDir, _vecUp];


// Restore magazine ammo states (turrets, partial mags, etc.)
if (_magAmmo isEqualType [] && {count _magAmmo > 0}) then {
    {
		_x params ["_mag", "_turret", "_ammo"];
        //_veh addMagazineTurret [_mag, _turret];
        _veh setMagazineTurretAmmo [_mag, _ammo, _turret];
    } forEach _magAmmo;
};

// Restore physical state
_veh setDamage _dmg;
if (_hitpoints isEqualType [] && {count _hitpoints >= 3}) then {
    private _hitNames = _hitpoints select 0;
    private _hitValues = _hitpoints select 2;
    {
        _veh setHitPointDamage [_hitNames select _forEachIndex, _x];
    } forEach _hitValues;
};

// Restore simulation
_veh enableSimulationGlobal false;
if (_sim) then {
    _veh enableSimulationGlobal true;
} else {
    if (_dynSim) then {
        _veh enableDynamicSimulation true;
    };
};

// Restore systems
_veh setFuel _fuel;
if (_engineOn) then { _veh engineOn true };
if (_radarOn) then { _veh setVehicleRadar 1 };
if (_lightsOn) then { _veh setPilotLight true };

// Restore inventory
[_veh, _inv] call ria_fnc_restoreInventory;

_veh
