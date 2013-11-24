/*
	DayZ Lock Safe
	Usage: [_obj] spawn player_unlockVault;
	Made for DayZ Epoch please ask permission to use/edit/distrubute email vbawol@veteranbastards.com.
*/
private ["_objectID","_objectUID","_obj","_ownerID","_dir","_pos","_holder","_weapons","_magazines","_backpacks","_alreadyPacking","_lockedClass","_text","_playerNear"];

if(TradeInprogress) exitWith { cutText [(localize "str_epoch_player_10") , "PLAIN DOWN"]; };
TradeInprogress = true;

_obj = _this;

_lockedClass = getText (configFile >> "CfgVehicles" >> (typeOf _obj) >> "lockedClass");
_text = 		getText (configFile >> "CfgVehicles" >> (typeOf _obj) >> "displayName");

// Silently exit if object no longer exists
if(isNull _obj) exitWith { TradeInprogress = false; };

_playerNear = _obj call dze_isnearest_player;
if(_playerNear) exitWith { TradeInprogress = false; cutText [(localize "str_epoch_player_11") , "PLAIN DOWN"];  };

_ownerID = _obj getVariable["CharacterID","0"];
_objectID 	= _obj getVariable["ObjectID","0"];
_objectUID	= _obj getVariable["ObjectUID","0"];
player playActionNow "Medic";

player removeAction s_player_lockvault;
s_player_lockvault = 1;

if((_ownerID != dayz_combination) and (_ownerID != dayz_playerUID)) exitWith {TradeInprogress = false; s_player_lockvault = -1; cutText [format[(localize "str_epoch_player_115"),_text], "PLAIN DOWN"]; };

_alreadyPacking = _obj getVariable["packing",0];

if (_alreadyPacking == 1) exitWith {TradeInprogress = false; s_player_lockvault = -1; cutText [format[(localize "str_epoch_player_116"),_text], "PLAIN DOWN"]};

_obj setVariable["packing",1];

_dir = direction _obj;
// _pos = getposATL _obj;
_pos	= _obj getVariable["OEMPos",(getposATL _obj)];
[player,"tentpack",0,false] call dayz_zombieSpeak;
sleep 3;

if(!isNull _obj) then {

	// force vault save just before locking
	PVDZE_veh_Update = [_obj,"gear"];
	publicVariableServer "PVDZE_veh_Update";

	//place tent (local)
	_holder = createVehicle [_lockedClass,_pos,[], 0, "CAN_COLLIDE"];
	_holder setdir _dir;
	_holder setPosATL _pos;
	player reveal _holder;
	
	_holder setVariable["CharacterID",_ownerID,true];
	_holder setVariable["ObjectID",_objectID,true];
	_holder setVariable["ObjectUID",_objectUID,true];
	_holder setVariable ["OEMPos", _pos, true];

	_weapons = 		getWeaponCargo _obj;
	_magazines = 	getMagazineCargo _obj;
	_backpacks = 	getBackpackCargo _obj;
	
	// remove vault
	deleteVehicle _obj;

	// Fill variables with loot
	if (count _weapons > 0) then {
		_holder setVariable ["WeaponCargo", _weapons, true];
	};
	if (count _magazines > 0) then {
		_holder setVariable ["MagazineCargo", _magazines, true];
	};
	if (count _backpacks > 0) then {
		_holder setVariable ["BackpackCargo", _backpacks, true];
	};
	
	cutText [format[(localize "str_epoch_player_117"),_text], "PLAIN DOWN"];

	s_player_lockvault = -1;
};
TradeInprogress = false;