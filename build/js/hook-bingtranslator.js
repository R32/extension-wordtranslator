// Generated by Haxe 5.0.0-alpha.1
var $global = window;
class hookbt {
	static rolling(old,lvl) {
		hookbt.tid = -1;
		if(lvl < 0) {
			chrome.i18n.getMessage("QUERY_FAILED",hookbt.faild);
			return;
		}
		let cur = document.getElementById("tta_output_ta").value;
		let len = cur.length;
		if(cur == old || cur.charCodeAt(len - 1) == 46 && cur.charCodeAt(len - 2) == 46) {
			hookbt.tid = window.setTimeout(hookbt.rolling,100,old,lvl - 1);
			return;
		}
		chrome.runtime.sendMessage({ value : cur, respone : true});
	}
	static faild(s) {
		chrome.runtime.sendMessage({ value : s, respone : true});
	}
	static run(ens) {
		if(ens != null) {
			let input = document.getElementById("tta_input_ta");
			input.value = ens;
			input.click();
			if(hookbt.tid > 0) {
				window.clearTimeout(hookbt.tid);
			}
			hookbt.tid = window.setTimeout(hookbt.rolling,100,document.getElementById("tta_output_ta").value,60);
		}
		document.getElementById("tta_playiconsrc").click();
	}
}
{
}
hookbt.tid = -1;
