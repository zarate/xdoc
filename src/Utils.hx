package;

class Utils
{
	
	public static function beautify(s : String) : String
	{
		
		// Thanks Nicolas for the code below to remove stars!
		
		s = Std.string(s);
		
		s = s.split("\r\n").join("\n").split("\r").join("\n");
		
		// trim stars
		s = ~/^([ \t]*)\*+/gm.replace(s, "$1");
		s = ~/\**[ \t]*$/gm.replace(s, "");

		return s;
		
	}
	
	public static function processList(list : List<String>, ?separator = ', ') : String
	{
		
		var output = '';
		
		for(item in list)
		{
			output += item + separator;
		}
		
		return output;
		
	}
	
}