package;

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
	
	public var fullpath : String;
	
	public var docFile : String;
	
	public var docSourceFile : String;
	
	public var name(default, setName) : String;
	
	public var fast : haxe.xml.Fast;
	
	public var parent : Package;
	
	public var relativepath(default, setRelativePath) : String; 
	
}