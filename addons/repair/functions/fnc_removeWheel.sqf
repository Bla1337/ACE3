/*
 * Author: commy2
 *
 * Start a remove wheel action and open progress bar.
 *
 * Arguments:
 * 0: Unit that does the repairing (Object)
 * 1: vehicle to repair (Object)
 * 2: Selected hitpoint (String)
 *
 * Return Value:
 * NONE
 */
#include "script_component.hpp"

private ["_unit", "_vehicle", "_hitPoint"];

_unit = _this select 0;
_vehicle = _this select 1;
_hitPoint = _this select 2;

// exit if not a valid hitpoint
if !(_hitPoint in ([_vehicle] call EFUNC(common,getHitPoints))) exitWith {};

// calculate time to fully repair the hitpoint
private "_time";
_time = 10;

// open the loading bar
[_time, [_unit, _vehicle, _hitPoint], {(_this select 0) call DFUNC(doRemoveWheel)}, {[localize "STR_ACE_Common_ActionAborted"] call EFUNC(common,displayTextStructured);}, localize "STR_ACE_Repair_RemovingWheel", {(_this select 0) call DFUNC(canRemoveWheel)}, []] call EFUNC(common,progressBar);

// do animation
[_unit] call EFUNC(common,goKneeling);

// @todo play sound