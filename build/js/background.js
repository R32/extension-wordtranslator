// Generated by Haxe 5.0.0-alpha.1+cc105eb
(function ($global) { "use strict";
function main() {
	let tabid = -1;
	let NOP = function(_) {
	};
	let BTURL = chrome.i18n.getUILanguage() == "zh-CN" ? "https://" + "cn." + "bing.com/translator" : "https://" + "bing.com/translator";
	let enable = true;
	let lazy_reply = null;
	let flush = function(v) {
		if(lazy_reply == null) {
			return;
		}
		lazy_reply(v);
		lazy_reply = null;
	};
	let run = null;
	run = function(msg) {
		if(tabid != -1) {
			chrome.tabs.sendMessage(tabid,msg).then(flush).catch(function(_) {
				flush(chrome.i18n.getMessage("WRONG"));
			});
			return;
		}
		chrome.tabs.query({ url : "https://" + "*." + "bing.com/translator" + "*"},function(tabs) {
			let tab = tabs[0];
			if(tab == null || tab.status == "unloaded") {
				flush(null);
				if(tab == null) {
					chrome.tabs.create({ url : BTURL, pinned : true});
				} else {
					chrome.tabs.update(tab.id,{ active : true});
				}
				return;
			}
			tabid = tab.id;
			run(msg);
		});
	};
	chrome.storage.local.get("disabled",function(res) {
		enable = !res["disabled"];
	});
	chrome.runtime.onMessage.addListener(function(msg,_,reply) {
		switch(msg[0]) {
		case 1:
			if(lazy_reply != null) {
				lazy_reply(null);
			}
			lazy_reply = reply;
			run(msg);
			return true;
		case 2:
			let args = msg[1].split(":");
			switch(args[0]) {
			case "disabled":
				enable = args[1] != "true";
				break;
			case "voices":
				if(tabid != -1) {
					chrome.tabs.sendMessage(tabid,msg).catch(NOP);
				}
				break;
			default:
			}
			break;
		}
		return false;
	});
	chrome.webNavigation.onDOMContentLoaded.addListener(function(t) {
		let scheme = t.url.substring(0,4);
		if(!(scheme == "http" || scheme == "file")) {
			return;
		}
		let ishook = t.url.indexOf("bing.com/translator",7) > 0;
		if(!(enable || ishook)) {
			return;
		}
		if(ishook && tabid == -1) {
			tabid = t.tabId;
		}
		chrome.scripting.executeScript({ target : { tabId : t.tabId}, files : [ishook ? "js/hook-bingtranslator.js" : "js/content-script.js"]}).catch(NOP);
	});
	chrome.tabs.onRemoved.addListener(function(id,_) {
		if(id == tabid) {
			tabid = -1;
		}
	});
}
{
}
main();
})(globalThis);
