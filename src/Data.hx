package;

extern private enum abstract Kind(Int) to Int {
	var Request = 0;
	var Respone = 1;
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

@:native("chrome.runtime.sendMessage")
extern function sendMessage( msg : Message, ?callback : Dynamic->Void ) : Void;

enum abstract StoreKey(String) to String {
	var KDISBLED = "disabled";
	var KVOICES = "voices";
	var KREDIRECT = "redirect";
}
typedef StoreVoices = {
	voices : String // if "0x100" then disabled,
}
typedef StoreDisabled = {
	disabled : Bool
}
typedef StoreRedirect = {
	redirect : Bool
}
typedef StoreAll = StoreVoices & StoreDisabled & StoreRedirect;
