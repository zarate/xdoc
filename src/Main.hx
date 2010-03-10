/*
TODO

-- more options:
	-- keep haxedoc.xml
	-- main title, colours, etc?
	-- generate source file?
	-- output file extensions?
	-- generate package files?
	-- carefull with private objects that start with _

-- print current/total info in one single line!
-- embed an "index template" when the package is root

*/

package;

import haxe.rtti.CType;

class Main
{
	
	public function new()
	{
		
		config = new Config();
		
		userClasspaths = [];
		userLibs = [];
		
		parseArgs();
		parseUserClasspaths();
		createHaxedocXml();
		parseHaxedocXml();
		print();
		
		xa.Application.exit(0);
		
	}
	
	private function print() : Void
	{
		
		var p = getPrinter();
		p.config(config);
		p.print();
		
	}
	
	private function getPrinter() : IPrinter
	{
		
		// The idea is having several printers in the future,
		// such as HTML, PDF, CHM, etc.
				
		return new HtmlPrinter();
	}
	
	private function parseHaxedocXml() : Void
	{
		
		var haxedocFile = config.outputFolder + xa.System.getSeparator() + 'haxedoc.xml';
		
		var haxeDocContent = xa.File.read(haxedocFile);
		
		var parser = new haxe.rtti.XmlParser();
		
		var x = Xml.parse(haxeDocContent).firstElement();
		
		parser.process(x, '');
		
		for(tree in parser.root)
		{
			parseTree(tree);
		}
		
	}
	
	private function parseTree(tree : TypeTree) : Void
	{

		switch(tree)
		{
			
			case TPackage(name, full, trees):
				
				var p = getPackage(full);
				
				if(p == null)
				{
					return;
				}
				
				for(tree in trees)
				{
					parseTree(tree);
				}
			
			case TClassdecl(decl):
			
				var inf = TypeApi.typeInfos(tree);
				
				var dotPos = inf.path.lastIndexOf('.');
				var packagePath = (dotPos != -1 )? inf.path.substr(0, dotPos) : inf.path;
				
				var p = getPackage(packagePath);
				
				if(p == null)
				{
					return;
				}
				
				var c = p.classes.get(inf.path);
				
				if(c == null)
				{
				}
				else
				{
					c.tree = decl;
				}
				
			// TODO: need to parse TEnumdecl and TTypedecl
			default:
				
		}
			
	}
	
	private function getPackage(path : String, ?wa : Package) : Package
	{
		
		if(wa == null)
		{
			wa = config.rootPackage;
		}
		
		for(p in wa.packages)
		{
			
			if(p.name == path)
			{
				return p;
			}
			
			return getPackage(path, p);
			
		}
		
		return null;
		
	}
	
	private function createHaxedocXml() : Void
	{
		
		// To automatically create a haxedoc.xml file from sources 
		// we need first to create a class containing a reference to
		// ALL classes in the classpaths. This will force the haxe compiler
		// to include them all in the generated file.
		// The only bit of annoyance is that if the source code uses any library in haxelib
		// (swhx, waxe, systools, xapi, etc) they need to be passed as well to the compiler
		// or it will throw an error because it can't find them.
		// Kind of annoying but makes total sense.
		
		var allFilename = 'All.hx';
		var allFile = config.outputFolder + xa.System.getSeparator() + allFilename;
		var haxedocFile = config.outputFolder + xa.System.getSeparator() + 'haxedoc.xml';
		var allBinary = '';
		
		var content = processPackage(config.rootPackage, '');
		content = 'class All{\n' + content + '}';
		
		xa.File.write(allFile, content);
		
		var libs = [];
		
		for(lib in userLibs)
		{
			
			// neko is a special library for the haXe compiler,
			// it expects a .n folder aftwards
			
			if(lib == 'neko')
			{
				allBinary = config.outputFolder + xa.System.getSeparator() + 'all.n';
				libs.push('-neko');
				libs.push(allBinary);
			}
			else
			{
				libs.push('-lib');
				libs.push(lib);
			}
			
		}
		
		var paths = [];
		
		for(path in userClasspaths)
		{
			paths.push('-cp');
			paths.push(path);
		}
		
		var args = [
			'-xml',
			haxedocFile,
			allFilename,
			'-cp',
			config.outputFolder
		];
		
		args = args.concat(libs).concat(paths);
		
		var haxecomp = new xa.Process('haxe', args);
		
		if(!haxecomp.success())
		{
			xa.Application.exitError(haxecomp.getError());
		}
		
		xa.File.delete(allBinary);
		xa.File.delete(allFile);
		
		var xmlContent = xa.File.read(haxedocFile);

		var docXML = Xml.parse(xmlContent);

		config.docXml = new haxe.xml.Fast(docXML.firstElement());
		
	}
	
	private function processPackage(parent : Package, content : String) : String
	{

		for(p in parent.packages.iterator())
		{
			content += processPackage(p, content);
		}
		
		for(c in parent.classes.iterator())
		{
			content += 'var class_' + classCounter + ' : ' + c.name + ';\n';
			classCounter++;
		}
		
		return content;
		
	}
	
	private function parseUserClasspaths() : Void
	{
		
		for(classpath in userClasspaths)
		{
			
			var p = config.rootPackage;
			
			if(p == null)
			{
				
				p = new Package();
				p.relativepath = '';
				p.fullpath = classpath;
				p.name = 'Index';
				
				config.rootPackage = p;
				
			}
			
			parseClasspath(classpath, p, 0);
			
		}
		
	}
	
	private function parseClasspath(initialpath : String, parent : Package, deep : Int) : Void
	{
		
		if(!xa.Folder.isFolder(initialpath))
		{
			xa.Application.exitError(initialpath + ' does not look like a valid folder.');
		}
		
		var items = xa.Folder.read(parent.fullpath);
		
		for(item in items)
		{
			
			var itemPath = parent.fullpath + xa.System.getSeparator() + item;
			var relativepath = itemPath.substr(initialpath.length + 1);
			var fullpath = initialpath + xa.System.getSeparator() + relativepath;
			
			if(xa.Folder.isFolder(itemPath))
			{
				
				var p = new Package();
				p.relativepath = relativepath;
				p.fullpath = fullpath;
				p.parent = parent;
				
				parent.packages.set(p.name, p);
				parseClasspath(initialpath, p, ++deep);
				
			}
			else
			{
				
				if(xa.File.hasExtension(itemPath, ['.hx']))
				{
					
					var c = new Object();
					c.relativepath = relativepath;
					c.fullpath = fullpath;
					c.parent = parent;
					
					parent.classes.set(c.name, c);

				}
				
			}			
			
		}
		
	}
	
	private function parseArgs() : Void
	{
		
		var args = xa.Application.getArguments();
		
		for(i in 0...args.length)
		{
			
			var arg = args[i];
			
			switch(arg)
			{
				
				case '-assets':
					
					config.userAssetsFolder = args[i+1];
					
					if(!xa.Folder.isFolder(config.userAssetsFolder))
					{
						xa.Application.exitError("Asset folder doesn't look like a valid folder: " + config.userAssetsFolder);
					}
				
				case '-output':
					config.outputFolder = args[i+1];
				
				case '-templates':
					
					config.userTemplateFolder = args[i+1];
				
					if(!xa.Folder.isFolder(config.userTemplateFolder))
					{
						xa.Application.exitError("Templates folder doesn't look like a valid folder: " + config.userTemplateFolder);
					}
				
				case '-cp':
					
					if(!xa.Folder.isFolder(args[i+1]))
					{
						xa.Application.exitError("Classpath doesn't look like a valid folder: " + args[i+1]);
					}
					
					userClasspaths.push(neko.FileSystem.fullPath(args[i+1]));
				
				case '-lib':
					userLibs.push(args[i+1]);
				
				case '-private':
					config.outputPrivate = (args[i+1] == 'true');
				
				case '-help':
					printHelp();
				
			}
			
		}
		
		if(userClasspaths.length <= 0)
		{
			xa.Application.exitError("No classpath(s) defined, nothing to do here.");
		}
		
		if(!xa.Folder.isFolder(config.outputFolder))
		{
			xa.Application.exitError("Can't find output folder: " + config.outputFolder);
		}
		
		// Default assets folder
		config.assetsFolder = neko.FileSystem.fullPath('assets');
		config.templatesFolder = neko.FileSystem.fullPath('templates');
		
	}
	
	private function printHelp() : Void
	{
		xa.Utils.print('Welcome to xDoc!');
		xa.Utils.print('Usage: xdoc -cp path/to/your/code -output path/to/output/folder [-assets /path/to/your/assets] [-templates /path/to/your/templates] [-lib libname] [-private true|false]');
		xa.Utils.print('-cp : add as many classpaths to your files.');
		xa.Utils.print('-output : path to the folder where you want the documentation to be exported.');
		xa.Utils.print('-assets : path to a folder with your own assets. Optional.');
		xa.Utils.print('-templates : path to a folder with your own templates. Optional.');
		xa.Utils.print('-lib: if your code uses any library from haxelib you MUST pass it as well to generate the docs. Optional.');
		xa.Utils.print('-private [true|false]: whether you want to output private classes and members. Optional, defaults to false.');
		xa.Utils.print('-help : show this help.');
	}
	
	public static function main() : Void
	{
		var d = new Main();
	}
	
	private var userClasspaths : Array<String>;
	
	private var userLibs : Array<String>;
	
	private var config : Config;
	
	private static var classCounter : Int = 0;
	
}