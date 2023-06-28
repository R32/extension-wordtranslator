// Generated by Haxe 4.3.1
(function ($global) { "use strict";
class Background {
	static loadpage(href,callback) {
		chrome.tabs.query({ url : href},function(list) {
			if(list.length > 0) {
				chrome.tabs.update(list[0].id,{ active : true},callback);
				return;
			}
			chrome.tabs.create({ url : href},callback);
		});
	}
	static doResponse(ret) {
		if(Background.lazySendResponse != null) {
			Background.lazySendResponse(ret);
		}
		Background.lazySendResponse = null;
		Background.lastWords = ret;
	}
	static translate(ens) {
		if(Background.bingId != -1) {
			chrome.scripting.executeScript({ target : { tabId : Background.bingId}, args : [ens], func : function(s) {
				hookbt.run(s);
			}}).catch(function(_) {
				Background.bingId = -1;
				Background.doResponse(null);
			});
			return;
		}
		chrome.tabs.query({ url : "https://*." + Background.baseUrl + "*"},function(list) {
			if(list.length == 0) {
				Background.doResponse(null);
				Background.loadpage(Background.bingUrl);
				return;
			}
			Background.bingId = list[0].id;
			Background.translate(ens);
		});
	}
	static main() {
		let enablejs = true;
		let nop = function(_) {
		};
		if(chrome.i18n.getUILanguage() == "zh-CN") {
			Background.bingUrl = "https://" + "cn." + Background.baseUrl;
		} else {
			Background.bingUrl = "https://" + Background.baseUrl;
		}
		chrome.runtime.onMessage.addListener(function(query,_,sendResponse) {
			switch(query[0]) {
			case 0:
				let ens = Background.lastWords == query[1] ? null : query[1];
				if(ens == null) {
					sendResponse(null);
				} else {
					Background.lazySendResponse = sendResponse;
				}
				Background.translate(ens);
				return Background.lazySendResponse != null;
			case 1:
				Background.doResponse(query[1]);
				break;
			case 2:
				let args = query[1].split(":");
				let on = args[1] != "true";
				switch(args[0]) {
				case "disabled":
					enablejs = on;
					break;
				case "nosound":
					if(Background.bingId != -1) {
						chrome.scripting.executeScript({ target : { tabId : Background.bingId}, args : [on], func : function(x) {
							hookbt.sound = x;
						}}).catch(nop);
					}
					break;
				default:
				}
				break;
			}
			return false;
		});
		chrome.webNavigation.onDOMContentLoaded.addListener(function(t) {
			switch(t.url.substring(0,t.url.indexOf(":"))) {
			case "file":case "http":case "https":
				break;
			default:
				return;
			}
			let injectjs = "js/content-script.js";
			let hookpage = t.url.indexOf(Background.baseUrl,7) >= 7;
			if(!enablejs && !hookpage) {
				return;
			}
			if(hookpage) {
				injectjs = "js/hook-bingtranslator.js";
				if(Background.bingId == -1) {
					Background.bingId = t.tabId;
				}
			}
			chrome.scripting.executeScript({ target : { tabId : t.tabId}, files : [injectjs]}).catch(nop);
		});
		chrome.tabs.onRemoved.addListener(function(tid,_) {
			if(tid == Background.bingId) {
				Background.bingId = -1;
			}
		});
		chrome.storage.local.get("disabled",function(attr) {
			enablejs = !attr.disabled;
		});
	}
}
{
}
Background.bingId = -1;
Background.baseUrl = "bing.com/translator";
Background.main();
})(globalThis);
