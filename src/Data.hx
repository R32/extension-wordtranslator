package;

extern private enum abstract Kind(Int) to Int {
	var Request = 1;
	var Control = 2;
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

extern enum abstract LocaleString(String) to String {
	var Timeout = "TIMEOUT";
	var Wrong = "WRONG";
	inline function locale() : String return chrome.I18n.getMessage(this);
}

extern enum abstract StoreKey(String) to String {
	var KDISBLED = "disabled";
	var KVOICES = "voices";
	var KREDIRECT = "redirect";
	public inline function join( v : Dynamic ) : StoreObj
		return js.Syntax.code("{{0} : {1}}", this, v);
}

typedef StoreObj = haxe.DynamicAccess<Dynamic>;
