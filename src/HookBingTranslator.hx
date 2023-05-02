package;

import js.html.TextAreaElement;
 using StringTools;
 using NativeTools;

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

	@:keep public static function run( ens : String ) {
		if (ens != null) {
			var input = fromId(TIN);
			input.value = ens;
			input.click();
			if (tid > 0)
				window.clearTimeout(tid);
			tid = window.setTimeout(rolling, 300, 20); // 6 seconds
		}
		voice();
	}

	static inline function voice() {
		document.getElementById(TVOICE).click();
	}

	static inline function fromId(id) : TextAreaElement {
		return cast document.getElementById(id);
	}
}
