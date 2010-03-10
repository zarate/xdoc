package;

import haxe.rtti.CType;

class Function extends Field
{
	
	public function new(arguments : List<{t : CType, opt : Bool, name : String}>, ret : CType)
	{
		
		super();
		
		args = new List<Argument>();
		
		for(argument in arguments)
		{
			var a = new Argument();
			a.type = argument.t;
			a.optional = argument.opt;
			a.name = argument.name;
			args.add(a);
		}
		
		this.ret = ret;
		
	}
	
	public var args : List<Argument>;
	
	public var ret : CType;
	
}