package;

class HtmlPrinter implements IPrinter
{
	
	public function new()
	{
	}
	
	public function config(config : Config) : Void
	{
		this.conf = config;
	}
	
	public function print() : Void
	{
		
		totalWritten = 1;
		packages(conf.rootPackage);
		assets();
		
	}
	
	private function packages(myPackage : Package) : Void
	{
		
		for(p in myPackage.packages.iterator())
		{
			packages(p);
		}
		
		var packageList = getChildren(myPackage, []);
		
		var classList = [];
		
		for(c in myPackage.classes.iterator())
		{
			printClass(c);
			classList.push({name : c.name, file: c.docFile});
		}
		
		var indexTemplate = new haxe.Template(conf.getTemplate(Config.PACKAGE_TPL));
		var indexOutputContent = indexTemplate.execute({name : myPackage.name, packages: packageList, classes: classList, breadcrumbs: getBreadcrumbs(myPackage, false)});
		
		var filename = (myPackage.parent == null)? '/index.html' : myPackage.name + '.html';
		
		writeFile(conf.outputFolder + "/" + filename, indexOutputContent, myPackage.name);
		
	}
	
	private function getChildren(parent : Package, list : Array<Dynamic>) : Array<Dynamic>
	{
		
		for(p in parent.packages.iterator())
		{

			var classlist = new Array<Dynamic>();

			for(c in p.classes.iterator())
			{
				classlist.push({name: c.name, file: c.docFile});
			}
			
			list.push({name: p.name, file: p.name + '.html', classes : classlist});
			
			list.concat(getChildren(p, list));
			
		}
		
		return list;
		
	}
	
	private function printClass(myClass : Object) : Void
	{
		
		// First the file for the class documentation itself		
		
		var classTemplate = new haxe.Template(conf.getTemplate(Config.OBJECT_TPL));
		var classOutput = classTemplate.execute({myClass : myClass, breadcrumbs: getBreadcrumbs(myClass.parent, true)});
		
		writeFile(conf.outputFolder + "/" + myClass.docFile, classOutput, myClass.name);
		
		// Then the file for the class source
		var classSourceTemplate = new haxe.Template(conf.getTemplate(Config.OBJECT_SRC_TPL));
		
		var classSource = xa.File.read(myClass.fullpath);
		
		var sourceLines = classSource.split('\n');
		var lines = [];
		
		for(i in 0...sourceLines.length)
		{
			var line = StringTools.htmlEscape(StringTools.trim(sourceLines[i]));
			lines.push({source: line, number: i});
		}
		
		var classSourceOutput = classSourceTemplate.execute({name : myClass.name, lines: lines});
		
		
		writeFile(conf.outputFolder + "/" + myClass.docSourceFile, classSourceOutput, myClass.name + ' source');
		
		totalWritten++;
		
	}
	
	private function getBreadcrumbs(p : Package, isClass : Bool) : String
	{
		
		var name = p.name;
		var crumbs = [];
		
		while(true)
		{
			
			if(p.parent == null)
			{
				break;
			}
			else
			{
				
				if(isClass && crumbs.length == 0)
				{
					crumbs.push({name : p.name, file: p.name + '.html'});
				}
				
				p = p.parent;
				
				crumbs.push({name : p.name, file: p.name + '.html'});
				
			}
			
		}
		
		crumbs.reverse();
		
		var breadTemplate = new haxe.Template(conf.getTemplate(Config.CRUMBS_TPL));
		return breadTemplate.execute({name: name, crumbs: crumbs});
		
	}
	
	private function writeFile(path : String, content : String, ?title : String = "") : Void
	{
		
		var baseTemplate = new haxe.Template(conf.getTemplate(Config.BASE_TPL));
		var baseOutputContent = baseTemplate.execute({content: content, title: title});
		
		xa.File.write(path, baseOutputContent);
		
	}
	
	private function assets() : Void
	{
		
		var destinationPath = conf.outputFolder + xa.System.getSeparator() + 'assets';
		
		if(xa.Folder.isFolder(destinationPath))
		{
			xa.Folder.forceDelete(destinationPath);
		}
		
		xa.Folder.copy(conf.assetsFolder, destinationPath);
		
		// TODO: copy user assets
		
	}
	
	private var conf : Config;
	
	private var totalWritten : Int;
	
}