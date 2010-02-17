class Config 
{
	
	public function new()
	{
		totalFiles = 0;
	}
	
	public var outputFolder : String;
	
	public var assetsFolder : String;
	
	public var totalFiles : Int;
	
	public var rootPackage : Package;
	
	public var docXml : haxe.xml.Fast;
	
}