cdb_arma_inventory_compressArrayCounts = {
	private ["_counts"];
	_counts = [];
	{
		_item = _x;
		_count = { _item isEqualTo _x } count (_this select 0);
		if({[_count, _item] isEqualTo _x} count _counts == 0) then {
			_counts = _counts + [[_count, _item]];
		};
	} forEach (_this select 0);
	
	_counts;
};

cdb_arma_inventory_load = {
	_obj = (_this select 0);
	_load = (_this select 1);
	
	{
		_qty = (_x select 0);
		_record = (_x select 1);
		if((_record select 0) == "weapon") then {
			_obj addItemCargo [_record select 1, _qty];
		};
		if((_record select 0) == "magazine") then {
			_obj addMagazineAmmoCargo [_record select 1, _qty, (_record select 2)];
		};
		if((_record select 0) == "item" || (_record select 0) == "assignedItem" || (_record select 0) == "container") then {
			_obj addItemCargo [_record select 1, _qty];
		};
	} forEach _load;
};

cdb_arma_inventory_getAll = {
	private ["_object", "_inventory"];
	_object = (_this select 0);
	_inventory = [];
	
	{
		_subinventory = [_x select 1] call cdb_arma_inventory_getAll;
		_inventory = _inventory + _subinventory;
	} forEach everyContainer _object;
	{
		_inventory = _inventory + [["weapon", [(_x select 0)] call BIS_fnc_baseWeapon, ""]];
		_x = _x - [_x select 0];
		{
			if((typeName _x) == "STRING") then {
				if(!(_x == "")) then {
					_inventory = _inventory + [["item", _x, ""]];
				}
			};
			if((typeName _x) == "ARRAY") then {
				if(!(_x select 0 == "")) then {
					_inventory = _inventory + [["magazine", _x select 0, _x select 1]];
				}
			};
		} forEach _x;
	} forEach weaponsItemsCargo _object;
	{
		_inventory = _inventory + [["item", _x, ""]];
	} forEach itemCargo _object;
	{
		_inventory = _inventory + [["magazine", _x select 0, _x select 1]];
	} forEach magazinesAmmo _object;
	
	[_inventory] call cdb_arma_inventory_compressArrayCounts;
};

cdb_arma_inventory_getAllUnit = {
	private ["_unit", "_inventory"];
	_unit = (_this select 0);
	_inventory = [];
	
	{
		_inventory = _inventory + [["weapon", [(_x select 0)] call BIS_fnc_baseWeapon, ""]];
		_x = _x - [_x select 0];
		{
			if((typeName _x) == "STRING") then {
				if(!(_x == "")) then {
					_inventory = _inventory + [["item", _x, ""]];
				}
			};
			if((typeName _x) == "ARRAY") then {
				if(!(_x select 0 == "")) then {
					_inventory = _inventory + [["magazine", _x select 0, _x select 1]];
				}
			};
		} forEach _x;
	} forEach weaponsItems _unit;
	{
		_inventory = _inventory + [["assignedItem", _x, ""]];
	} forEach assignedItems _unit;
	{
		_inventory = _inventory + [["magazine", _x select 0, _x select 1]];
	} forEach magazinesAmmo _unit;
	if(!(uniform _unit == "")) then {
		_inventory = _inventory + [["container", uniform _unit, "uniform"]];
	};
	if(!(vest _unit == "")) then {
		_inventory = _inventory + [["container", vest _unit, "vest"]];
	};
	if(!(backpack _unit == "")) then {
		_inventory = _inventory + [["container", backpack _unit, "backpack"]];
	};
	if(!(headgear _unit == "")) then {
		_inventory = _inventory + [["container", headgear _unit, "headgear"]];
	};
	if(!(goggles _unit == "")) then {
		_inventory = _inventory + [["container", goggles _unit, "goggles"]];
	};
	
	if(count _this == 2) then {
		if(_this select 1) then {
			removeAllWeapons _unit;
			removeAllAssignedItems _unit;
			removeUniform _unit;
			removeVest _unit;
			removeBackpackGlobal _unit;
			removeHeadgear _unit;
			removeGoggles _unit;
		};
	};
	
	[_inventory] call cdb_arma_inventory_compressArrayCounts;
};