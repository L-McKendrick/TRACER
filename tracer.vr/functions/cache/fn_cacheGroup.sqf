/*
 * Author: McKendrick 
 * Caches an AI group by serializing unit and group data for later restoration. Deletes the group and its members.
 *
 * Arguments:
 * 0: Group to cache <GROUP>
 *
 * Return Value:
 * Serialized group data <ARRAY>
 *
 * Example:
 * [group myAIGroup] call ria_fnc_cacheGroup
 *
 * Public: No
 */

params [
    ["_group", grpNull, [grpNull]]
];

if (isNull _group) exitWith { [] };

// Don't cache if players are in the group
//if ((units _group) findIf { isPlayer _x } > -1) exitWith { [] };

private _cachedUnits = [];
private _aiFeatures = ["AIMINGERROR", "ANIM", "AUTOCOMBAT", "AUTOTARGET", "CHECKVISIBLE", "COVER", "FSM", "LIGHTS", "MINEDETECTION",  "MOVE", "NVG", "PATH", "RADIOPROTOCOL", "SUPPRESSION", "TARGET", "WEAPONAIM", "FIREWEAPON"];

{
    if (isNull _x) then { continue };

    private _unit = _x;
    private _featureStates = [];
    {
        if (!(_unit checkAIFeature _x)) then {
            _featureStates pushBack _x;
        };
    } forEach _aiFeatures;

    _identity = [face _unit, speaker _unit, pitch _unit, nameSound _unit];

    private _unitData = [
        typeOf _x,
        getPosATL _x,
        getDir _x,
        damage _x,
        getUnitLoadout _x,
        rank _x,
        combatMode _x,
        skill _x,
        name _unit,
        _identity,
        leader _group isEqualTo _x,  // Is leader
        vehicle _x,                  // Placeholder for future vehicle handling
        assignedVehicleRole _x,
        _featureStates               // [["AUTOCOMBAT", true], ...]
    ];

    _cachedUnits pushBack _unitData;

    deleteVehicle _x;

} forEach units _group;

// Cache group-level data
private _cachedWaypoints = [];

for "_i" from 0 to (count waypoints _group - 1) do {
    private _wp = (waypoints _group) select _i;

    _cachedWaypoints pushBack [
        waypointPosition _wp,
        waypointType _wp,
        waypointBehaviour _wp,
        waypointCombatMode _wp,
        waypointSpeed _wp,
        waypointFormation _wp,
        waypointCompletionRadius _wp
    ];
};

private _groupData = [
    groupID _group,
    side _group,
    formation _group,
    combatBehaviour _group,
    combatMode _group,
    speedMode _group
];

// Final structure: [units, waypoints, group settings]
private _cachedGroup = [
    _cachedUnits,
    _cachedWaypoints,
    _groupData
];

deleteGroup _group;

_cachedGroup
