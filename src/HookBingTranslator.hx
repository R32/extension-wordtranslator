package;

import ESXTools.toInt;
import js.html.TextAreaElement;
 using StringTools;

var TIN = document.getElementById("tta_input_ta");
var TOUT = document.getElementById("tta_output_ta");
var TPLAY = document.getElementById("tta_playiconsrc");
var FDIN = TIN.tagName != "TEXTAREA" ? "innerText" : "value";
var FDOUT = TOUT.tagName != "TEXTAREA" ? "innerText" : "value";

var tmp_ens : String;
var lst_ens : String;
inline function ens_push(ens) tmp_ens = ens;
inline function ens_clear() tmp_ens = null;
inline function ens_commit() lst_ens = tmp_ens;
inline function ens_diff(ens) return lst_ens != ens;

var lazy_reply : Dynamic->Void;

function flush( v ) {
	if (lazy_reply == null)
		return;
	lazy_reply(v);
	lazy_reply = null;
	ens_commit();
	ens_clear();
}

/*
 * 0(MIN), 1, (2), 3, 4(MAX)
 */
var level = 2;

var paste = new js.html.InputEvent("input", {bubbles : true});

var sound : Bool;

function run( ens : String ) : Bool {
	var diff = ens_diff(ens);
	if (diff) {
		ens_push(ens);
		sound = detects(ens);
		(TIN : Dynamic)[cast FDIN] = ens;
		// BEWARE : "CE_FINISH" will not be triggered if "ens" equals tta_input_ta.innerText.
		TIN.dispatchEvent(paste);
	} else {
		// when background.js receives an error, there is a chance to respond with the previous value.
		// This handles the case : "The page keeping the extension port is moved into back/forward cache, so the message channel is closed"
		if (tmp_ens == null) {
			tmp_ens = (TOUT : Dynamic)[cast FDOUT];
			lazy_reply(tmp_ens);
		} else {
			lazy_reply(null);
		}
		lazy_reply = null;
	}
	LOG("disable : " + (level > 0xFF) + ", level : " + (level & 0xFF) + ", sound : " + sound + ", diff : " + ens_diff(ens));
	if (sound && level < 0xFF && (navigator : Dynamic).userActivation.hasBeenActive)
		TPLAY.click();
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
	chrome.Storage.local.get([KVOICES, KVSPEED], function( res : StoreObj ) {
		if (NOTNULL(res[KVOICES]))
			level = toInt(res[KVOICES]);
		if (NOTNULL(res[KVSPEED]))
			TPLAY.dispatchEvent(new js.html.CustomEvent(CE_RATE, {detail : toInt(res[KVSPEED])}));
	});
	chrome.Runtime.onMessage.addListener(function( msg : Message, _, ?reply : Dynamic->Void ) {
		LOG(msg);
		switch (msg.kind) {
		case Request:
			if (NOTNULL(lazy_reply)) {
				ens_clear();
				lazy_reply(null);
			}
			lazy_reply = reply;
			return run(ESXTools.trim(msg.value)); // Trim as the original page does
		case Control:
			var args = msg.value.split(":");
			var type = args[0];
			var value = toInt(args[1]);
			if (type == KVOICES) {
				level = value;
			} else if (type == KVSPEED) {
				TPLAY.dispatchEvent(new js.html.CustomEvent(CE_RATE, {detail : value}));
			}
		}
		return false;
	});

	TOUT.addEventListener(CE_FINISH, function() {
		flush(js.Lib.nativeThis[cast FDOUT]);
	});
}
