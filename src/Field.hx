package;

import haxe.rtti.CType;

class Field
{
	
	public function new()
	{
	}
	
	private function setRtti(val : ClassField) : ClassField
	{
		rtti = val;
		
		isPublic = rtti.isPublic;
		isOverride = rtti.isOverride;
		name = rtti.name;
		
		doc = Utils.beautify(rtti.doc);
		
		return rtti;
	}
	
	public var rtti(default, setRtti) : ClassField;
	
	public var isPublic : Bool;
	
	public var isOverride : Bool;
	
	public var platforms : String;
	
	public var doc : String;
	
	public var name : String;
	
}