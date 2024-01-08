package;

import js.html.TextAreaElement;
 using StringTools;

@:native("hookbt")
class HookBingTranslator {

	static inline var TIN  = "tta_input_ta";

	static inline var TOUT = "tta_output_ta";

	static inline var TVOICE = "tta_playiconsrc";

	static var tid = -1;

	static function rolling( lvl : Int ) {
		tid = -1;
		var cur = fromId(TOUT).value;
		var len = cur.length;
		if (lvl < 0) {
			cur = chrome.I18n.getUILanguage() == "zh-CN" ? "查词失败" : "query failed";
		} else if (cur.endsWith("...") || cur == " ") {
			tid = window.setTimeout(rolling, 300, lvl - 1);
			return;
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
			input.click();
			if (tid > 0)
				window.clearTimeout(tid);
			tid = window.setTimeout(rolling, 300, 20); // 6 seconds
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
		document.getElementById(TVOICE).click();
	}

	static inline function fromId(id) : TextAreaElement {
		return cast document.getElementById(id);
	}

	static function main() {
		chrome.Storage.local.get(KVOICES, function( attr : StoreVoices ) {
			level = attr.voices != null ? ESXTools.toInt(attr.voices) : DEFAULT_LEVEL;
		});
	}
}
