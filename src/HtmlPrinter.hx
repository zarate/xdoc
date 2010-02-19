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
		
		var indexTemplate = new haxe.Template(conf.getTemplate(Config.PACKAGE_TPL));
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
		
		var classTemplate = new haxe.Template(conf.getTemplate(Config.OBJECT_TPL));
		var classOutput = classTemplate.execute({name : myClass.name, content : "myClass.fast.att", breadcrumbs: getBreadcrumbs(myClass.parent, true)});
		
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
		
		var breadTemplate = new haxe.Template(conf.getTemplate(Config.CRUMBS_TPL));
		return breadTemplate.execute({crumbs: crumbs});

		
	}
	
	private function writeFile(path : String, content : String, ?title : String = "") : Void
	{
		
		var baseTemplate = new haxe.Template(conf.getTemplate(Config.BASE_TPL));
		var baseOutputContent = baseTemplate.execute({content: content, title: title});
		
		xa.File.write(path, baseOutputContent);
		
	}
	
	private var conf : Config;
	
	private var totalWritten : Int;
	
}