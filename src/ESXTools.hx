package;

@:pure
extern class ESXTools {
#if js
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

	// does it safe?
	static inline function toString( d : Dynamic ) : String
	{
		return d.toString();
	}
#end
}
