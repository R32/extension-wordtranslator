// Generated by Haxe 5.0.0-alpha.1+cc105eb
(function ($global) { "use strict";
function main() {
	let tabid = -1;
	let nop = function(_) {
	};
	let bturl = chrome.i18n.getUILanguage() == "zh-CN" ? "https://" + "cn." + "bing.com/translator" : "https://" + "bing.com/translator";
	let enable = true;
	let lazyrep = null;
	let lstword = null;
	let response = function(zhs) {
		if(lazyrep == null) {
			return;
		}
		lazyrep(zhs);
		lazyrep = null;
		lstword = zhs;
	};
	let translate = null;
	translate = function(ens) {
		if(tabid != -1) {
			chrome.scripting.executeScript({ target : { tabId : tabid}, args : [ens], func : function(s) {
				hookbt.run(s);
			}}).catch(function(_) {
				response(chrome.i18n.getUILanguage() == "zh-CN" ? "出错了" : "something is wrong");
			});
			return;
		}
		chrome.tabs.query({ url : "https://*." + "bing.com/translator" + "*"},function(list) {
			let tab = list[0];
			if(tab == null) {
				response(null);
				chrome.tabs.create({ url : bturl, pinned : true});
				return;
			}
			tabid = tab.id;
			translate(ens);
		});
	};
	chrome.storage.local.get("disabled",function(res) {
		enable = !res.disabled;
	});
	chrome.runtime.onMessage.addListener(function(query,_,reply) {
		switch(query[0]) {
		case 0:
			let ens = lstword == query[1] ? null : query[1];
			if(ens == null) {
				reply(null);
			} else {
				lazyrep = reply;
			}
			translate(ens);
			return lazyrep != null;
		case 1:
			response(query[1]);
			break;
		case 2:
			let args = query[1].split(":");
			switch(args[0]) {
			case "disabled":
				enable = args[1] != "true";
				break;
			case "voices":
				if(tabid != -1) {
					chrome.scripting.executeScript({ target : { tabId : tabid}, args : [args[1]], func : function(s) {
						hookbt.level = (s | 0);
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
		let scheme = t.url.substring(0,4);
		if(!(scheme == "http" || scheme == "file")) {
			return;
		}
		let ishook = t.url.indexOf("bing.com/translator",7) > 0;
		if(!ishook && enable) {
			chrome.scripting.executeScript({ target : { tabId : t.tabId}, files : ["js/content-script.js"]}).catch(nop);
			return;
		}
		if(!ishook) {
			return;
		}
		if(tabid == -1) {
			tabid = t.tabId;
		}
		chrome.scripting.executeScript({ target : { tabId : t.tabId}, files : ["js/hook-bingtranslator.js"]}).catch(nop);
		chrome.scripting.executeScript({ world : "MAIN", target : { tabId : t.tabId}, func : function() {
			let tin = tta_input_ta;
			if(tin.onchange) {
				return;
			}
			tin.onchange = function(e) {
				!e.isTrusted && sj_evt.fire(RichTranslateHelper.inputTextchanged);
			};
		}}).catch(nop);
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
