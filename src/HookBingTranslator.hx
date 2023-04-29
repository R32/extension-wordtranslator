package;

import js.html.TextAreaElement;
 using StringTools;

@:native("hookbt")
class HookBingTranslator {

	static inline var TIN  = "tta_input_ta";

	static inline var TOUT = "tta_output_ta";

	static inline var TVOICE = "tta_playiconsrc";

	static function rolling( old : String ) {
		var out = fromId(TOUT);
		var cur = out.value;
		var len = cur.length;
		if (cur == old || (cur.fastCodeAt(len - 1) == ".".code && cur.fastCodeAt(len - 2) == ".".code)) {
			window.setTimeout(rolling, 100, old);
			return;
		}
		// console.log("sended respone");
		chrome.Runtime.sendMessage({value : cur, respone : true});
	}

	@:keep public static function run( ens : String ) {
		if (ens != null) {
			var input = fromId(TIN);
			input.value = ens;
			input.click();
			window.setTimeout(rolling, 100, fromId(TOUT).value);
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
