package;

import haxe.rtti.CType;

class Object
{
	
	public function new()
	{	
	}
	
	public function toString() : String
	{
		return 'Object [name=' + name + ', fullpath=' + fullpath + ']';
	}
	
	public static function getNameFromPath(path : String) : String
	{
		path = path.split(xa.System.getSeparator()).join('.');
		return path.substr(0, path.indexOf('.hx'));
	}
	
	private function setName(val : String) : String
	{
		
		name = val;
		
		var filename = name.split('.').join('-');
		
		docFile = filename + '.html';
		docSourceFile = filename + '-source.html';
		
		return name;
		
	}
	
	private function setRelativePath(val : String) : String
	{
		relativepath = val;
		name = getNameFromPath(relativepath);
		return relativepath;
	}
	
	private function setTree(val : Classdef) : Classdef
	{
		
		tree = val;
		
		doc = Utils.beautify(tree.doc);
		platforms = Utils.processList(tree.platforms);
		
		isPrivate = tree.isPrivate;
		isInterface = tree.isInterface;
		isExtern = tree.isExtern;
		module = tree.module;
		
		return tree;
		
	}
	
	public var isPrivate : Bool;
	
	public var isExtern : Bool;
	
	public var isInterface : Bool;
	
	public var platforms : String;
	
	public var module : String;
	
	public var tree(default, setTree) : Classdef;
	
	public var fullpath : String;
	
	public var docFile : String;
	
	public var docSourceFile : String;
	
	public var doc : String;
	
	public var name(default, setName) : String;
	
	public var parent : Package;
	
	public var relativepath(default, setRelativePath) : String; 
	
}