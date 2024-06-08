package;

import js.html.TextAreaElement;
 using StringTools;

/*
 * https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Sharing_objects_with_page_scripts
 */
#if firefox
@:native("wrappedJSObject") extern var wrappedJSObject : Dynamic;
@:native("tta_input_ta") @:keep var tta_input_ta = wrappedJSObject.tta_input_ta;
@:native("tta_output_ta") @:keep var tta_output_ta = wrappedJSObject.tta_output_ta;
@:native("tta_playiconsrc") @:keep var tta_playiconsrc = wrappedJSObject.tta_playiconsrc;
#end

inline var TIN  = "tta_input_ta";
inline var TOUT = "tta_output_ta";
inline var TPLAY = "tta_playiconsrc";

var tmp_ens : String;
var lst_ens : String;
inline function ens_add(ens) tmp_ens = ens;
inline function ens_clear() tmp_ens = null;
inline function ens_commit() lst_ens = tmp_ens;
inline function ens_diff(ens) return lst_ens != ens;

var lazy_reply : Dynamic->Void;
function flush(v) {
	ens_commit();
	if (lazy_reply == null)
		return;
	lazy_reply(v);
	lazy_reply = null;
}

inline function from_id(id) : TextAreaElement return js.Syntax.code(id);

inline function play() from_id(TPLAY).click();

var tid = -1;
function polling( lvl : Int ) {
	tid = -1;
	var cur = from_id(TOUT).value;
	if (lvl < 0) {
		ens_clear();
		cur = Timeout.locale();
	} else {
		var i = 0;
		var len = cur.length;
		while (i < len && cur.fastCodeAt(i) == " ".code)
			i++;
		if (i == len || cur.endsWith("...")) {
			tid = window.setTimeout(polling, 600, lvl - 1);
			return;
		}
	}
	flush(cur);
}

inline var DEFAULT_LEVEL = 2;

/*
 * 0(MIN), 1, (2), 3, 4(MAX)
 */
var level = DEFAULT_LEVEL;

var paste = new js.html.InputEvent("input", {bubbles : true});

var sound : Bool;

function run( ens : String ) : Bool {
	var diff = ens_diff(ens);
	if (diff) {
		ens_add(ens);
		sound = detects(ens);
		var input = from_id(TIN);
		input.value = ens;
		input.dispatchEvent(paste);
		if (tid > 0)
			window.clearTimeout(tid);
		tid = window.setTimeout(polling, 500, 10);
	}
	LOG("disable : " + (level > 0xFF) + ", level : " + (level & 0xFF) + ", sound : " + sound + ", diff : " + ens_diff(ens));
	if (sound && level < 0xFF)
		play();
	return diff;
}

function detects( ens : String ) {
	var n = (level & 0xFF);
	if (n == 0)
		return false;
	if (n > 3)
		return true;
	var i = 0;
	var len = ens.length;
	var count = (1 << n) - 1; // spaces count
	// fast trimStart
	while (i < len && ens.fastCodeAt(i) == " ".code)
		i++;
	// fast trimEnd
	while (len > i && ens.fastCodeAt(len - 1) == " ".code)
		len--;
	// characters count for chinese, not tested yet
	if (i < len && ens.fastCodeAt(i) > 255) {
		return len - i <= count + 1;
	}
	// spaces count for english
	while (i < len) {
		var c = ens.fastCodeAt(i);
		if (c == " ".code) {
			if (count-- == 0)
				return false;
		}
		i++;
	}
	return true;
}

function main() {
	chrome.Storage.local.get(KVOICES, function( res : StoreObj ) {
		level = res[KVOICES] != null ? ESXTools.toInt(res[KVOICES]) : DEFAULT_LEVEL;
	});
	chrome.Runtime.onMessage.addListener(function( msg : Message, _, ?reply : Dynamic->Void ) {
		LOG(msg);
		switch (msg.kind) {
		case Request:
			if (lazy_reply != null)
				lazy_reply(null);
			lazy_reply = reply;
			return run(msg.value);
		case Control:
			var args = msg.value.split(":");
			if (args[0] == KVOICES)
				level = ESXTools.toInt(args[1]);
		}
		return false;
	});
}
