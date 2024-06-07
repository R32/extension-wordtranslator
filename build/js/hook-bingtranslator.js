// Generated by Haxe 5.0.0-alpha.1+cc105eb
var $global = window;
class hookbt {
	static rolling(lvl) {
		hookbt.tid = -1;
		let cur = tta_output_ta.value;
		if(lvl < 0) {
			cur = null;
		} else {
			let i = 0;
			let len = cur.length;
			while(i < len && cur.charCodeAt(i) == 32) ++i;
			if(i == len || cur.endsWith("...")) {
				hookbt.tid = window.setTimeout(hookbt.rolling,300,lvl - 1);
				return;
			}
		}
		chrome.runtime.sendMessage([1,cur]);
	}
	static run(ens) {
		if(ens != null) {
			hookbt.pass = hookbt.detects(ens);
			let input = tta_input_ta;
			input.value = ens;
			input.dispatchEvent(hookbt.paste);
			if(hookbt.tid > 0) {
				window.clearTimeout(hookbt.tid);
			}
			hookbt.tid = window.setTimeout(hookbt.rolling,333,20);
		}
		if(hookbt.level < 255 && hookbt.pass) {
			tta_playiconsrc.click();
		}
	}
	static detects(ens) {
		let n = hookbt.level & 255;
		if(n == 0) {
			return false;
		}
		if(n > 3) {
			return true;
		}
		let i = 0;
		let len = ens.length;
		let count = (1 << n) - 1;
		while(i < len && ens.charCodeAt(i) == 32) ++i;
		while(len > i && ens.charCodeAt(len - 1) == 32) --len;
		if(i < len && ens.charCodeAt(i) > 255) {
			return len - i <= count + 1;
		}
		while(i < len) {
			if(ens.charCodeAt(i) == 32) {
				if(count-- == 0) {
					return false;
				}
			}
			++i;
		}
		return true;
	}
	static main() {
		chrome.storage.local.get("voices",function(attr) {
			hookbt.level = attr.voices != null ? (attr.voices | 0) : 2;
		});
	}
}
{
}
hookbt.paste = new InputEvent("input",{ bubbles : true});
hookbt.tid = -1;
hookbt.level = 2;
hookbt.main();
