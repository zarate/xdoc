class Config 
{
	
	public function new()
	{
		totalFiles = 0;
	}
	
	/**
	* <p>Returns the content of the given template. First looks into user's defined assets folder.
	* If not found, looks for default template. If not found, returns null.</p> 
	**/
	
	public function getTemplate(name : String) : String
	{
		
		var content : String = null;
		
		var path = userTemplateFolder + xa.System.getSeparator() + name;
		
		if(!xa.File.isFile(path))
		{
			
			path = templatesFolder + xa.System.getSeparator() + name;
			
			if(xa.File.isFile(path))
			{
				content = xa.File.read(path);
			}
			
		}
		else
		{
			content = xa.File.read(path);
		}
		
		return content;
		
	}
	
	
	public var outputFolder : String;
	
	public var assetsFolder : String;
	
	public var userAssetsFolder : String;
	
	public var templatesFolder : String;
	
	public var userTemplateFolder : String;
	
	public var totalFiles : Int;
	
	public var rootPackage : Package;
	
	public var docXml : haxe.xml.Fast;
	
	public static var PACKAGE_TPL : String = 'package.html';
	
	public static var OBJECT_TPL : String = 'object.html';
	
	public static var OBJECT_SRC_TPL : String = 'source.html';
	
	public static var CRUMBS_TPL : String = 'breadcrumbs.html';
	
	public static var BASE_TPL : String = 'base.html';
	
}