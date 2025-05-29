/*
 * Author: McKendrick 
 * Serializes a vehicle for later restoration. Captures physical state, damage, inventory, and simulation state.
 * Intended to be used by group caching systems and dynamic object streaming.
 *
 * Arguments:
 * 0: Vehicle to cache <OBJECT>
 *
 * Return Value:
 * Serialized vehicle data <ARRAY>
 *
 * Example:
 * [myVehicle] call ria_fnc_cacheVehicle
 *
 * Public: No
 */

params [
    ["_veh", objNull, [objNull]]
];

if (isNull _veh || {!canMove _veh}) exitWith { [] };

// Handle only vehicles local to machine
if (!local _veh) exitWith { [] };

// Gather cargo data
private _itemCargo     = getItemCargo _veh;
private _magCargo      = getMagazineCargo _veh;
private _weaponCargo   = getWeaponCargo _veh;
private _backpackCargo = getBackpackCargo _veh;

// Gather damage to hitpoints
private _hitpoints = getAllHitPointsDamage _veh;

// Construct vehicle data
private _vehData = [
    typeOf _veh,
    getPosWorld _veh,
    getDir _veh,
    vectorDir _veh,
    vectorUp _veh,
    damage _veh,
    _hitpoints,
    fuel _veh,
    isEngineOn _veh,
    isVehicleRadarOn _veh,
    isLightOn _veh,
    simulationEnabled _veh,
    dynamicSimulationEnabled _veh,
	magazinesAllTurrets _veh,
    [_itemCargo, _magCargo, _weaponCargo, _backpackCargo]
];

// Delete the vehicle after caching
deleteVehicle _veh;

_vehData
