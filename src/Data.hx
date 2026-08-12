package;

extern abstract Message(String) to String {

	private inline function new( msg : String ) this = msg;

	inline function is_control() : Bool return StringTools.fastCodeAt(this, 0) == 0x7F;
	inline function ctlvalue() : String return this.substring(1);

	static inline function normal( msg : String ) return new Message(msg);
	static inline function control( msg : String ) return new Message("\x7F" + msg);
}

extern enum abstract LocaleString(String) to String {
	var Timeout = "TIMEOUT";
	var Wrong = "WRONG";
	inline function locale() : String return chrome.I18n.getMessage(this);
}

extern enum abstract StoreKey(String) to String {
	var KDISBLED = "disabled";
	var KVOICES = "voices";
	var KVSPEED = "vspeed";
	var KREDIRECT = "redirect";
	// BUGBUG : DO NOT USE WITH VARIABLES.
	public inline function combine( v : Dynamic ) : StoreObj {
		return js.Syntax.code("{{0} : {1}}", this, v);
	}
}

typedef StoreObj = haxe.DynamicAccess<Dynamic>;
