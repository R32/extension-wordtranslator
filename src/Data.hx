package;

extern private enum abstract Kind(Int) to Int {
	var Request = 0;
	var Respone = 1;
}

extern abstract Message(Array<Dynamic>) {
	var kind(get, set) : Kind;
	var value(get, set) : String;
	inline function new( kind : Kind, value : String ) this = [kind, value];
	private inline function get_kind() : Kind return this[0];
	private inline function set_kind( k : Kind ) : Kind return this[0] = k;
	private inline function get_value() : String return this[1];
	private inline function set_value( v : String ) : String return this[1] = v;
}

@:native("chrome.runtime.sendMessage")
extern function sendMessage( msg : Message, ?callback : Dynamic->Void ) : Void;
