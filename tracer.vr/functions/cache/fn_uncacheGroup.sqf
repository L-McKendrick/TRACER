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
 * [_cachedGroupData] call ria_fnc_uncacheGroup
 *
 * Public: No
 */

params [
    ["_cachedGroup", [], [[]]]
];

if (count _cachedGroup != 3) exitWith { grpNull };

private _unitData      = _cachedGroup select 0;
private _waypointData  = _cachedGroup select 1;
private _groupSettings = _cachedGroup select 2;

_groupSettings params [
    "_groupID", "_side", "_formation", "_behaviour",
    "_groupCombat", "_speedMode"
];

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
        "_skill", "_name", "_identity", "_isLeader", "_vehicle", "_vehRole", "_featureStates"
    ];

    private _unit = _group createUnit [_type, _pos, [], 0, "CAN_COLLIDE"];
    _unit setDir _dir;
    _unit setDamage _damage;
    _unit setUnitLoadout _loadout;
    _unit setRank _rank;
    _unit setCombatMode _unitCombat;
    _unit setSkill _skill;
    _unit setName _name;

    // _identity insert [0, [_unit]];
    // systemChat str _name;
    // copyToClipboard str _identity;
    // _identity remoteExecCall ["BIS_fnc_setIdentity", 2];

    [_unit, _name, _identity] spawn {
        params ["_unit", "_name", "_identity"];
        _identity insert [0, [_unit]];
        waitUntil { !isNull _unit };
        sleep 2;
        hint str _identity;
        _unit setVariable ["ACE_Name", _name, true];
        _identity call BIS_fnc_setIdentity;
    };

    {
        _unit disableAI _x;
    } forEach _featureStates;


    // if (_isLeader && !_leaderSet) then {
    //     _group selectLeader _unit;
    //     _leaderSet = true;
    // };

    // Vehicle and role handling will be integrated later

} forEach _unitData;

// Restore waypoints
{
    _x params [
        "_pos", "_type", "_behaviour", "_combatMode", "_speed",
        "_formation", "_completionRadius"
    ];

    private _wp = _group addWaypoint [_pos, 0];
    _wp setWaypointType _type;
    _wp setWaypointBehaviour _behaviour;
    _wp setWaypointCombatMode _combatMode;
    _wp setWaypointSpeed _speed;
    _wp setWaypointFormation _formation;
    _wp setWaypointCompletionRadius _completionRadius;

} forEach _waypointData;

_group
