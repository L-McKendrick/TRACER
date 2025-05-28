/*
    cacheObjects.sqf
    McKendrick | ria_fnc_cacheObjects

    Description:
    Serializes and deletes a list of static objects for later restoration.

    Params:
    0: ARRAY of OBJECTS - The objects to cache

    Returns:
    ARRAY of cached data

    Public: No
*/

params [["_objects", [], [[]]]];
private _cacheArray = [];

{
    if (isNull _x) then { continue };

    private _inv = [];
    if (_x isKindOf "ReammoBox_F") then {
        _inv = [
            getItemCargo _x,
            getMagazineCargo _x,
            getWeaponCargo _x,
            getBackpackCargo _x
        ];
    };

    private _entry = [
        typeOf _x,
        getPosWorld _x,
        getDir _x,
        vectorDir _x,
        vectorUp _x,
        damage _x,
        // getAllHitPointsDamage _x,
        simulationEnabled _x,
        dynamicSimulationEnabled _x,
        _inv
    ];

    _cacheArray pushBack _entry;
    deleteVehicle _x;

} forEach _objects;

_cacheArray
