package;

@:pure
extern class ESXTools {
#if js
	// es3
	static inline function replace( s : String, sub : String, by : String ) : String
	{
		return (cast s).replace(sub, by);
	}

	// es5
	static inline function trim( s : String ) : String
	{
		return (cast s).trim();
	}

	// chrome 66, firefox 61, edge 79, safari 12, nodejs 10.0 ...
	static inline function trimStart( s : String ) : String
	{
		return (cast s).trimStart();
	}

	static inline function trimEnd( s : String ) : String
	{
		return (cast s).trimEnd();
	}

	// chrome 41, firefox 17, edge 12, safari 9, nodejs 4.0
	overload static inline function startsWith( s : String, sub : String ) : Bool
	{
		return (cast s).startsWith(sub);
	}
	overload static inline function startsWith( s : String, sub : String , pos : Int ) : Bool
	{
		return (cast s).startsWith(sub, pos);
	}
	overload static inline function endsWith( s : String, sub : String ) : Bool
	{
		return (cast s).endsWith(sub);
	}
	// endpos : (the index of searchString's last character plus 1). Defaults to str.length
	overload static inline function endsWith( s : String, sub : String, endpos : Int ) : Bool
	{
		return (cast s).endsWith(sub, endpos);
	}

	// chrome 41, firefox 40, edge 12, safari 9, nodejs 4.0
	overload static inline function includes( s : String, sub : String ) : Bool
	{
		return (cast s).includes(sub);
	}
	overload static inline function includes( s : String, sub : String, pos : Int ) : Bool
	{
		return (cast s).includes(sub, pos);
	}

	// does it safe?
	static inline function toString( d : Dynamic ) : String
	{
		return d.toString();
	}
#end
}
