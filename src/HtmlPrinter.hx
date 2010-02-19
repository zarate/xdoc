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
		classes(conf.rootPackage);
		
	}
	
	private function packages(parent : Package) : Void
	{
		
		for(p in parent.packages.iterator())
		{
			packages(p);
		}
		
		var list = getIndexList(parent, []);
		
		var indexContent = xa.File.read(conf.assetsFolder + "/package.html");
		var indexTemplate = new haxe.Template(indexContent);
		var indexOutputContent = indexTemplate.execute({wadus : list, breadcrumbs: getBreadcrumbs(parent, false)});
		
		var filename = (parent == conf.rootPackage)? '/index.html' : parent.name + '.html';
		
		writeFile(conf.outputFolder + "/" + filename, indexOutputContent);
		
	}
	
	private function getIndexList(parent : Package, list : Array<Dynamic>) : Array<Dynamic>
	{
		
		for(p in parent.packages.iterator())
		{
			list.concat(getIndexList(p, list));
		}
		
		var classlist = [];
		
		for(c in parent.classes.iterator())
		{
			classlist.push({name: c.name, file: c.docFile});
		}
		
		list.push({name: parent.name, file :parent.name + '.html', classes : classlist});
		
		return list;
		
	}
	
	private function classes(parent : Package) : Void
	{
		
		for(p in parent.packages.iterator())
		{
			classes(p);
		}
		
		for(c in parent.classes.iterator())
		{
			printClass(c);
		}
		
	}
	
	private function printClass(myClass : Object) : Void
	{
		
		// First the file for the class documentation itself		
		
		var classContent = xa.File.read(conf.assetsFolder + '/class.html');
		var classTemplate = new haxe.Template(classContent);
		var classOutput = classTemplate.execute({name : myClass.name, content : "myClass.fast.att", breadcrumbs: getBreadcrumbs(myClass.parent, true)});
		
		writeFile(conf.outputFolder + "/" + myClass.docFile, classOutput, myClass.name);
		
		
		// Then the file for the class source
		var classSourceContent = xa.File.read(conf.assetsFolder + '/source.html');
		var classSourceTemplate = new haxe.Template(classSourceContent);
		
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
		
		var breadContent = xa.File.read(conf.assetsFolder + '/breadcrumbs.html');
		var breadTemplate = new haxe.Template(breadContent);
		return breadTemplate.execute({crumbs: crumbs});

		
	}
	
	private function writeFile(path : String, content : String, ?title : String = "") : Void
	{
		
		var baseContent = xa.File.read(conf.assetsFolder + "/base.html");
		var baseTemplate = new haxe.Template(baseContent);
		var baseOutputContent = baseTemplate.execute({content: content, title: title});
		
		xa.File.write(path, baseOutputContent);
		
	}
	
	private var conf : Config;
	
	private var totalWritten : Int;
	
}