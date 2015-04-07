/**
 * fn_handleDamage_CMS.sqf
 * @Descr: N/A
 * @Author: Glowbal
 *
 * @Arguments: []
 * @Return:
 * @PublicAPI: false
 */

private ["_unit","_selectionName","_amountOfDamage","_sourceOfDamage", "_typeOfProjectile","_bodyPartn","_newDamage","_typeOfDamage","_caliber", "_hitPointName", "_returnDamage", "_varCheck"];
_unit = _this select 0;
_selectionName = _this select 1;
_amountOfDamage = _this select 2;
_sourceOfDamage = _this select 3;
_typeOfProjectile = _this select 4;
_returnDamage = _amountOfDamage;

_bodyPartn = [_selectionName] call cse_fnc_getBodyPartNumber_CMS;


// Check for vehicle crash
if (vehicle _unit != _unit && {_bodyPartn < 0} && {isNull _sourceOfDamage} && {_typeOfProjectile == ""} && {_selectionName == ""}) then {
	if (CSE_ALLOW_VEH_CRASH_INJURIES_CMS) then {
		_bodyPartn = if (random(1)>=0.5) then { 0 } else { 1 };
		_typeOfProjectile = "VehicleCrash";
	};
};

// If it is not a valid bodyPart number, exit because we cannot do anything with it.
if (_bodyPartn < 0) exitwith {0};

// Most likely taking exessive fire damage. Lets exit.
if (isNull _sourceOfDamage && (_selectionName == "head" || isBurning _unit) && _typeOfProjectile == "" && vehicle _unit == _unit) exitwith {
	0
}; // Prefent excessive fire damage

if (local _unit && {([_unit] call cse_fnc_hasMedicalEnabled_CMS)}) then {
	if (_amountOfDamage < 0) then {
		_amountOfDamage = 0;
	};

	// Ensure damage is being handled correctly.
	[_unit, _bodyPartn, _amountOfDamage] call cse_fnc_damageBodyPart_CMS;
	_newDamage = [_unit, _amountOfDamage, _bodyPartn] call cse_fnc_getNewDamageBodyPart_CMS;

	// figure out the type of damage so we can use that to determine what injures should be given.
	_typeOfDamage = [_typeOfProjectile] call cse_fnc_getTypeOfDamage_CMS;

	if !([_unit, _newDamage, _typeOfDamage, _bodyPartn] call cse_fnc_assignOpenWounds_CMS) then {
		_returnDamage = 0;
	};

	//[_unit,_newDamage,_typeOfDamage,_bodyPartn] call cse_fnc_assignFractures_CMS;
	if (CSE_ALLOW_AIRWAY_INJURIES_CMS) then {
		[_unit, _amountOfDamage, _typeOfDamage, _bodyPartn] call cse_fnc_assignAirwayStatus_CMS;
	};
	[_unit,_newDamage,_bodyPartn] call cse_fnc_increasePain_CMS;

	if (([_unit, _bodyPartn] call cse_fnc_determineIfFatal_CMS) || !(alive (vehicle _unit))) then {
		[_unit] call cse_fnc_setDead_CMS;
		_returnDamage = 1;
	} else {
		[_unit] call cse_fnc_unitLoop_CMS;
		if ([_unit, _bodyPartn] call cse_fnc_determineIfUnconscious_CMS) then {
			[_unit] call cse_fnc_setUnconsciousState;
		} else {
			[_unit,_newDamage] call cse_fnc_reactionToHit_CMS;
		};
		if (_returnDamage > 0.95) then {
			_returnDamage = 0.95;
		};
	};

	if (!(alive (vehicle _unit))) then {
		_returnDamage = 1;
		[_unit] call cse_fnc_setDead_CMS;
	};
};

_returnDamage