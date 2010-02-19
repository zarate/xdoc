package;

class Package
{
	
	public function new()
	{
		classes = new Hash<Object>();
		packages = new Hash<Package>();
	}
	
	public function toString() : String
	{
		return 'Package [name=' + name + ', fullpath=' + fullpath + ']';
	}
	
	public static function getNameFromPath(path : String) : String
	{
		return path.split(xa.System.getSeparator()).join('.');
	}
	
	private function setRelativePath(val : String) : String
	{
		relativepath = val;
		name = getNameFromPath(relativepath);
		return relativepath;
	}
	
	public var name : String;
	
	public var classes : Hash<Object>;
	
	public var packages : Hash<Package>;
	
	public var fullpath : String;
	
	public var relativepath(default, setRelativePath) : String; 
	
}