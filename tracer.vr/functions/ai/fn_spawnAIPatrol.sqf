/*
    Function: ria_fnc_spawnAIPatrol
    Author: McKendrick
    Description:
        Spawns a patrol of AI at a given position, with optional use of LAMBS mod.
        Supports dynamic group definitions via config, specific group class, or array of unit classnames.

    Parameters:
        _position (ARRAY): World position to spawn the patrol.
        _radius (NUMBER): Radius for patrol movement.
        _side (SIDE): The side the units belong to (e.g., east, west, independent).
        _faction (STRING): Faction classname for config-based group definitions.
        _units (VARIANT): Can be:
            - An ARRAY of unit classnames (exact unit composition)
            - A STRING (CfgGroups group classname)
			- A NUMBER of of random units from config unit pool.
            - 0: Pick random from config list of group classnames
            - -1: Random group of 1-8 units from config unit pool
        _behavior (STRING): Can be:
			- "SAFE"
			- "AWARE"
			- "COMBAT"
			- "STEALTH"

    Returns:
        (GROUP): The spawned group.
*/

params [
    ["_position", [0, 0, 0], [[]]],
    ["_radius", 100, [0]],
    ["_side", blufor, [blufor]],
    ["_faction", "", [""]],
    ["_units", 0, [[],"",0]],
    ["_behavior", "AWARE", [""]]
];

private _useLambs = missionNamespace getVariable ["ria_config_ai_useLambs", false];
private _defaultSkill = missionNamespace getVariable ["ria_config_ai_defaultSkill", 0.6];

private _group = createGroup _side;

// Determine unit types
private _unitClassnames = [];

switch (true) do {
    case (typename _units isEqualTo "ARRAY"): {
        _unitClassnames = _units;
    };

    case (typename _units isEqualTo "STRING"): {
        // Use specific group from CfgGroups
        private _groupCfg = configfile >> "CfgGroups" >> str _side >> _faction >> "Infantry" >> _units;
        if (isClass _groupCfg) then {
            {
                _unitClassnames pushBack getText (_x >> "vehicle");
            } forEach ("true" configClasses (_groupCfg >> "Units"));
        } else {
            diag_log format ["[ria] Warning: Invalid CfgGroup classname '%1' for faction '%2'", _units, _faction];
        };
    };

    case (_units isEqualTo 0): {
        // Random group from config-defined group pool
        private _availableGroups = missionNamespace getVariable [format ["ria_config_factions_%1_groups", _faction], []];
        if (!(_availableGroups isEqualTo [])) then {
            private _randomGroup = selectRandom _availableGroups;
            private _groupCfg = configfile >> "CfgGroups" >> str _side >> _faction >> "Infantry" >> _randomGroup;
            {
                _unitClassnames pushBack getText (_x >> "vehicle");
            } forEach ("true" configClasses (_groupCfg >> "Units"));
        };
    };

    case (_units isEqualTo -1): {
        // Random number of units from unit pool
        private _unitPool = missionNamespace getVariable [format ["ria_config_factions_%1_units", _faction], []];
        private _unitCount = 1 + floor random 8;
        for "_i" from 1 to _unitCount do {
            _unitClassnames pushBack (selectRandom _unitPool);
        };
    };

	case (_units > 0): {
		private _unitPool = missionNamespace getVariable [format ["ria_config_factions_%1_units", _faction], []];
        for "_i" from 1 to _units do {
            _unitClassnames pushBack (selectRandom _unitPool);
        };
	};
};

// Spawn units
{
    private _unit = _group createUnit [_x, _position, [], 0, "FORM"]; 
    _unit setSkill _defaultSkill;
} forEach _unitClassnames;

// Behavior
if (!_isStatic) then {
    if (_useLambs) then {
        //_group setVariable ["lambs_danger_disableGroupAI", false];
        [_group, _position, _radius] call lambs_wp_fnc_taskPatrol;
    } else {
        [_group, _position, _radius] call BIS_fnc_taskPatrol;
        _wp setWaypointBehaviour _behavior;
    };
};

_group
