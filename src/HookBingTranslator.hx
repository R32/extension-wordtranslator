package;

import js.html.TextAreaElement;
 using StringTools;

@:native("hookbt")
class HookBingTranslator {

	static inline var TIN  = "tta_input_ta";

	static inline var TOUT = "tta_output_ta";

	static inline var TVOICE = "tta_playiconsrc";

	static var tid = -1;

	static function rolling( old : String, lvl : Int ) {
		tid = -1;
		if (lvl < 0) {
			chrome.I18n.getMessage("QUERY_FAILED", faild);
			return;
		}
		var out = fromId(TOUT);
		var cur = out.value;
		var len = cur.length;
		if (cur == old || (cur.fastCodeAt(len - 1) == ".".code && cur.fastCodeAt(len - 2) == ".".code)) {
			tid = window.setTimeout(rolling, 100, old, lvl - 1);
			return;
		}
		LOG('(rolling)runtime.sendMessage({value : $cur, respone : true})');
		chrome.Runtime.sendMessage({value : cur, respone : true});
	}

	static function faild( s : String ) {
		chrome.Runtime.sendMessage({value : s, respone : true});
	}

	@:keep public static function run( ens : String ) {
		if (ens != null) {
			var old = fromId(TOUT).value;
			var input = fromId(TIN);
			input.value = ens;
			input.click();
			if (tid > 0)
				window.clearTimeout(tid);
			tid = window.setTimeout(rolling, 100, old, 60); // 6 seconds
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
