/*
 * Author: McKendrick
 * Serializes and deletes a list of objects to be cached for later restoration. 
 * Saves simulation and dynamic simulation states, position, direction, and type.
 *
 * Arguments:
 * 0: Objects to cache <ARRAY> - Array of object references to be cached
 *
 * Return Value:
 * Array of serialized object data <ARRAY>
 *
 * Example:
 * [_someObjectsArray] call ria_fnc_cacheObjects
 *
 * Public: No
 */


params [
    ["_group", grpNull, [grpNull]],
    ["_cacheID", format ["ria_cache_%1", diag_tickTime], [""]]
];

if (isNull _group) exitWith {
    diag_log "[ria_fnc_cacheGroup] ERROR: Group is null";
};

private _units = units _group;
private _groupData = [];

{
    private _unit = _x;
    if (!alive _unit) exitWith {};

    _groupData pushBack [
        typeOf _unit,
        getPosATL _unit,
        getDir _unit,
        getUnitLoadout _unit,
        side _unit,
        behaviour _unit,
        combatMode _unit,
        rank _unit,
        unitPos _unit,
        skill _unit,
        (vehicle _unit == _unit) // Is on foot
        //_unit call BIS_fnc_getRespawnPosition
    ];
} forEach _units;

// Save group composition and meta
private _groupCache = [
    _groupData,
    side _group,
    formation _group,
    combatMode _group
];

// Store in missionNamespace
missionNamespace setVariable [_cacheID, _groupCache];

// Delete units and group
{
    deleteVehicle _x;
} forEach _units;
deleteGroup _group;

if (missionNamespace getVariable ["ria_debugMode", true]) then {
    systemChat format ["[ria] Cached group with ID: %1", _cacheID];
};

_cacheID
