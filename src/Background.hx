package;

import chrome.Tabs;

class Background {

	static var bingurl = "https://cn.bing.com/translator";

	// Some browsers may report a promise error if there is no callback in executeScript
	static function NOP(){}

	static function loadpage( href : String, ?callback : Tab->Void ) {
		Tabs.query({ url : href }, function(list) {
			if (list.length > 0) {
				Tabs.update(list[0].id, {active : true}, callback);
				return;
			}
			Tabs.create({url : href}, callback);
		});
	}

	static function main() {
		var lazySendResponse : String->Void = null;
		var prevMsg : String = null;
		chrome.Runtime.onMessage.addListener(function( query : Message, sender, ?sendResponse ) {
			if (query.respone) {
				if (lazySendResponse != null)
					lazySendResponse(query.value);
				lazySendResponse = null;
				return false;
			}
			var same = prevMsg == query.value;
			if (same) {
				sendResponse(null);              // disconnect the callback from ContentScript
			} else {
				lazySendResponse = sendResponse; // do response later
				prevMsg = query.value;
			}
			Tabs.query({ url : bingurl + "*" }, function(list) {
				if (list.length == 0) {
					if (lazySendResponse != null)
						lazySendResponse(null);
					lazySendResponse = null;
					prevMsg = null;
					loadpage(bingurl);
					return;
				}
				chrome.Scripting.executeScript({
					target : {tabId : list[0].id},
					args : [same ? null : prevMsg],
					func : function(ens) {
						HookBingTranslator.run(ens);
					}
				}, NOP);
			});
			return lazySendResponse != null; // return true to make sendResponse works
		});

		chrome.WebNavigation.onDOMContentLoaded.addListener(function(t) {
			switch(t.url.substring(0, t.url.indexOf(":"))) {
			case "http", "https" , "file":
			default:
				return;
			}
			var inject = if (t.url.substring(0, bingurl.length) != bingurl) {
				"js/content-script.js";
			} else {
				"js/hook-bingtranslator.js";
			}
			chrome.Scripting.executeScript({
				target : {tabId : t.tabId},
				files : [inject]
			}, NOP);
		});

		chrome.Action.onClicked.addListener(function(tab) {
			loadpage(chrome.Runtime.getURL("options.html"));
		});
	}
}
