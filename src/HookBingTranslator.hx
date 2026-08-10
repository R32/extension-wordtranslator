package;

import ESXTools.toInt;
import js.html.TextAreaElement;
 using StringTools;

var TIN = document.getElementById("tta_input_ta");
var TOUT = document.getElementById("tta_output_ta");
var TPLAY = document.getElementById("tta_playiconsrc");

var lst_ens : String;

var lst_reply : Dynamic->Void;

/*
 * 0(MIN), 1, (2), 3, 4(MAX)
 */
var level = 2;

var sound : Bool = js.Lib.undefined;

var paste = new js.html.InputEvent("input", {bubbles : true});

var click = new js.html.MouseEvent("click");

function flush( v ) {
	LOG("(flush) - lst_reply : " + (lst_reply != null) + ", v : " + v);
	if (lst_reply == null)
		return;
	lst_reply(v);
	lst_reply = null;
}

function run( ens : String ) : Bool {
	var diff = lst_ens != ens;
	LOG("( run ) - diff : " + diff);
	if (diff) {
		lst_ens = ens;
		text(TIN) = ens;
		sound = detects(ens);
		TIN.dispatchEvent(paste);
		// BEWARE : "CE_FINISH" will not be triggered if "ens" equals tta_input_ta.innerText.
	} else {
		// When the translation page suddenly refreshes, the execution here will be interrupted,
		// which causes background.js to receive an error.
		// The variable 'sound' is just used to detect if the page has been refreshed,
		// giving it a chance to respond with the previous value.
		var s = text(TOUT);
		if (js.Syntax.strictEq(sound, js.Lib.undefined) || s.endsWith(" ...")) {
			lst_reply(s);
			sound = detects(ens);
		}
		lst_reply = null;
	}
	if (sound && level < 0xFF && (navigator : Dynamic).userActivation.hasBeenActive)
		TPLAY.dispatchEvent(click);
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
	//while (i < len && ens.fastCodeAt(i) == " ".code)
	//	i++;
	// fast trimEnd
	//while (len > i && ens.fastCodeAt(len - 1) == " ".code)
	//	len--;
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
		LOG("(ONMSG) - msg : " + msg.toString() + ", lst_reply : " + (lst_reply != null));
		switch (msg.kind) {
		case Request:
			if (NOTNULL(lst_reply)) {
				lst_reply(null);
			}
			lst_reply = reply;
			return run(msg.value);
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
		LOG("(ONFIN) - output.value : " + text(nativeThis));
		flush(text(nativeThis));
	});

	window.onpagehide = function( e : js.html.PageTransitionEvent ) {
		LOG("(**ONPAGEHIDE**) - persisted : " + e.persisted);
		if (NOTNULL(lst_reply))
			lst_reply("[" + Wrong.locale() + "]");
	}
	// init for refresh
	lst_ens = text(TIN);
	LOG("(main ) - lst_ens : '" + lst_ens + "'");
}
