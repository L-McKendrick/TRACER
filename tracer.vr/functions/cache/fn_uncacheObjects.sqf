/*
* uncacheObjects.sqf
* McKendrick | ria_fnc_uncacheObjects
*
* Restores objects from cached data, including simulation, damage, and inventories.
*
* Params:
* 0: ARRAY - Cached data produced by cacheObjects
*
* Returns:
* ARRAY - Restored object references
*
* Public: No
*/

params [["_cacheArray", [], [[]]]];
private _restoredObjects = [];

// Helper: Turn flat arrays into [[item, count], ...]
private _arrayToPairs = {
    private _in = _this select 0;
    private _out = [];
    for "_i" from 0 to (count _in - 1) step 2 do {
        _out pushBack [_in select _i, _in select (_i + 1)];
    };
    _out
};

{
    private _type = _x select 0;
    private _pos = _x select 1;
    private _dir = _x select 2;
    private _vecDir = _x select 3;
    private _vecUp = _x select 4;
    private _dmg = _x select 5;
    private _sim = _x select 6;
    private _dynSim = _x select 7;
    private _inv = _x select 8;

    private _obj = createVehicle [_type, [0,0,0], [], 0, "CAN_COLLIDE"];
    _obj setPosWorld _pos;
    _obj setDir _dir;
    _obj setVectorDirAndUp [_vecDir, _vecUp];

    _obj setDamage _dmg;

    // Will readd if needed
    // if (!isNil "_hitPoints" && {count _hitPoints >= 3}) then {
    //     private _hitNames = _hitPoints select 0;
    //     private _hitValues = _hitPoints select 2;
    //     {
    //         _obj setHitPointDamage [_hitNames select _forEachIndex, _x];
    //     } forEach _hitValues;
    // };

    if (!isNil "_inv" && (count _inv > 0)) then {
        [_obj, _inv] call ria_fnc_restoreInventory;
    };

    _restoredObjects pushBack [_obj, _sim, _dynSim];

} forEach _cacheArray;

// Re-enable simulation after all are placed
{
    private _obj = _x select 0;
    private _sim = _x select 1;
    private _dynSim = _x select 2;

    if (_sim) then {
        _obj enableSimulation true;
    } else {
        if (_dynSim) then {
            _obj enableDynamicSimulation true;
        };
    };
} forEach _restoredObjects;

// Return just the object list
_restoredObjects apply { _x select 0 }
