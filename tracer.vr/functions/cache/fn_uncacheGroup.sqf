/*
 * Author: McKendrick 
 * Recreates a previously cached AI group from serialized data including units, group behavior, and waypoints.
 *
 * Arguments:
 * 0: Serialized group data <ARRAY> - As produced by ria_fnc_cacheGroup
 *
 * Return Value:
 * Restored group <GROUP>
 *
 * Example:
 * _cachedGroupData call ria_fnc_uncacheGroup
 *
 * Public: No
 */

params [
    ["_unitData", [], [[]]],
    ["_waypointData", [], [[]]],
    ["_groupSettings", [], [[]]]
];

_groupSettings params ["_groupID", "_side", "_formation", "_behaviour","_groupCombat", "_speedMode", "_currentWaypoint"];

private _group = createGroup [_side, true];
_group setGroupIdGlobal [_groupID];
_group setFormation _formation;
_group setCombatBehaviour _behaviour;
_group setCombatMode _groupCombat;
_group setSpeedMode _speedMode;

private _leaderSet = false;

{
    _x params [
        "_type", "_pos", "_dir", "_damage", "_loadout", "_rank", "_unitCombat",
        "_skill", "_name", "_identity", "_vehicle", "_vehRole", "_featureStates"
    ];

    private _unit = _group createUnit [_type, _pos, [], 0, "CAN_COLLIDE"];
    if (side _unit != _side) then { [_unit] joinSilent _group };
    _unit setDir _dir;
    _unit setDamage _damage;
    _unit setRank _rank;
    _unit setCombatMode _unitCombat;
    _unit setSkill _skill;
    _unit setName _name;

    // Apply init order sensitive data
    [_unit, _name, _identity, _loadout] spawn {
        params ["_unit", "_name", "_identity", "_loadout"];
        _identity insert [0, [_unit]];
        sleep 0.05;
        _unit setVariable ["ACE_Name", _name, true];
        _identity call BIS_fnc_setIdentity;
        _unit setUnitLoadout _loadout;
    };

    { _unit disableAI _x } forEach _featureStates;

    // Vehicle and role handling will be integrated later

} forEach _unitData;

// Restore waypoints
{
    _x params ["_pos", "_type", "_behaviour", "_combatMode", "_speed","_formation", "_completionRadius", "_statements", "_script"];

    private _wp = _group addWaypoint [_pos, 0];
    _wp setWaypointType _type;
    _wp setWaypointBehaviour _behaviour;
    _wp setWaypointCombatMode _combatMode;
    _wp setWaypointSpeed _speed;
    _wp setWaypointFormation _formation;
    _wp setWaypointCompletionRadius _completionRadius;
    _wp setWaypointStatements _statements;
    _wp setWaypointScript _script;

} forEach _waypointData;

_group setCurrentWaypoint [_group, _currentWaypoint min (count _waypointData)];

_group
