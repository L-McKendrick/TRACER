/*
* restoreInventory.sqf
* McKendrick | ria_fnc_restoreInventory
*
* Restores inventory to an object from saved cargo arrays.
*
* Params:
* 0: OBJECT - The object to receive the inventory
* 1: ARRAY - The inventory data in form: [items, mags, weapons, backpacks]
*
* Public: No
*/
params [
	["_obj", objNull], 
	["_inv", [], [[]]]
];
if (isNull _obj || {count _inv != 4}) exitWith {};

// Local helper: Converts flat arrays to pairs
private _arrayToPairs = {
    params ["_cargo"];
    private _types = _cargo select 0;
    private _counts = _cargo select 1;
    private _result = [];

    for "_i" from 0 to ((count _types) - 1) do {
        _result pushBack [_types select _i, _counts select _i];
    };
    _result
};

private _itemCargo     = _inv select 0;
private _magCargo      = _inv select 1;
private _weaponCargo   = _inv select 2;
private _backpackCargo = _inv select 3;

clearItemCargoGlobal _obj;
{ _obj addItemCargoGlobal _x } forEach ([_itemCargo] call _arrayToPairs);

clearMagazineCargoGlobal _obj;
{ _obj addMagazineCargoGlobal _x } forEach ([_magCargo] call _arrayToPairs);

clearWeaponCargoGlobal _obj;
{ _obj addWeaponCargoGlobal _x } forEach ([_weaponCargo] call _arrayToPairs);

clearBackpackCargoGlobal _obj;
{ _obj addBackpackCargoGlobal _x } forEach ([_backpackCargo] call _arrayToPairs);
