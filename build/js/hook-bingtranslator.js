// Generated by Haxe 4.3.1
var $global = window;
class hookbt {
	static rolling(lvl) {
		hookbt.tid = -1;
		let cur = document.getElementById("tta_output_ta").value;
		if(lvl < 0) {
			cur = chrome.i18n.getUILanguage() == "zh-CN" ? "查词失败" : "query failed";
		} else if(cur.endsWith("...") || cur == " ") {
			hookbt.tid = window.setTimeout(hookbt.rolling,300,lvl - 1);
			return;
		}
		chrome.runtime.sendMessage([1,cur]);
	}
	static run(ens) {
		if(ens != null) {
			let input = document.getElementById("tta_input_ta");
			input.value = ens;
			input.click();
			if(hookbt.tid > 0) {
				window.clearTimeout(hookbt.tid);
			}
			hookbt.tid = window.setTimeout(hookbt.rolling,300,20);
		}
		if(hookbt.sound) {
			document.getElementById("tta_playiconsrc").click();
		}
	}
	static main() {
		chrome.storage.local.get("nosound",function(attr) {
			hookbt.sound = !attr.nosound;
		});
	}
}
{
}
hookbt.tid = -1;
hookbt.sound = true;
hookbt.main();
