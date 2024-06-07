package;

import js.html.TextAreaElement;
 using StringTools;

@:native("hookbt")
class HookBingTranslator {

	static inline var TIN  = "tta_input_ta";

	static inline var TOUT = "tta_output_ta";

	static inline var TVOICE = "tta_playiconsrc";

	static var paste = new js.html.InputEvent("input", {bubbles : true});

	static var tid = -1;

	static function rolling( lvl : Int ) {
		tid = -1;
		var cur = fromId(TOUT).value;
		if (lvl < 0) {
			cur = null;
		} else {
			var i = 0;
			var len = cur.length;
			while (i < len && cur.fastCodeAt(i) == " ".code)
				i++;
			if (i == len || cur.endsWith("...")) {
				tid = window.setTimeout(rolling, 300, lvl - 1);
				return;
			}
		}
		LOG('(rolling)runtime.sendMessage({value : $cur, kind : respone})');
		sendMessage(new Message(Respone, cur));
	}

	// 0(MIN), 1, 2, 3, 4(MAX)
	static inline var DEFAULT_LEVEL = 2;
	public static var level = DEFAULT_LEVEL;
	static var pass : Bool;

	@:keep public static function run( ens : String ) {
		if (ens != null) {
			pass = detects(ens);
			var input = fromId(TIN);
			input.value = ens;
			input.dispatchEvent(paste);
			if (tid > 0)
				window.clearTimeout(tid);
			tid = window.setTimeout(rolling, 333, 20); // 6 seconds
		}
		LOG("disable : " + (level > 0xFF) + ", level : " + (level & 0xFF) + ", pass : " + pass);
		if (level < 0xFF && pass)
			voice();
	}

	static function detects( ens : String ) {
		var n = (level & 0xFF);
		if (n == 0)
			return false;
		if (n > 3)
			return true;
		var i = 0;
		var len = ens.length;
		var count = (1 << n) - 1; // [2, 4, 8] words
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

	static inline function voice() {
		fromId(TVOICE).click();
	}

	static inline function fromId(id) : TextAreaElement {
		return js.Syntax.code(id);
	}

	static function main() {
		chrome.Storage.local.get(KVOICES, function( attr : StoreVoices ) {
			level = attr.voices != null ? ESXTools.toInt(attr.voices) : DEFAULT_LEVEL;
		});
	}
}

/*
 * https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Sharing_objects_with_page_scripts
 */
#if firefox
@:native("wrappedJSObject") extern var wrappedJSObject : Dynamic;
@:native("tta_input_ta") @:keep var tta_input_ta = wrappedJSObject.tta_input_ta;
@:native("tta_output_ta") @:keep var tta_output_ta = wrappedJSObject.tta_output_ta;
@:native("tta_playiconsrc") @:keep var tta_playiconsrc = wrappedJSObject.tta_playiconsrc;
#end
