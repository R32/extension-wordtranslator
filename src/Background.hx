package;

import chrome.Tabs;

class Background {

	static var bingId = -1;

	static var bingUrl = "https://cn.bing.com/translator";

	static var lastWords : String;

	static var lazySendResponse : String->Void;

	static function loadpage( href : String, ?callback : Tab->Void ) {
		Tabs.query({ url : href }, function(list) {
			if (list.length > 0) {
				Tabs.update(list[0].id, {active : true}, callback);
				return;
			}
			Tabs.create({url : href}, callback);
		});
	}

	static function doResponse( ret : String ) {
		if (lazySendResponse != null)
			lazySendResponse(ret); // disconnect
		lazySendResponse = null;
		lastWords = ret;
	}

	static function translate( ens : String ) {
		if (bingId != -1) {
			chrome.Scripting.executeScript({
				target : {tabId : bingId},
				args : [ens],
				func : function(s) {
					HookBingTranslator.run(s);
				}
			}).catchError(function(_) {
				bingId = -1;
				doResponse(null);
			});
			return;
		}
		Tabs.query({ url : bingUrl + "*" }, function(list) {
			if (list.length == 0) {
				doResponse(null);
				loadpage(bingUrl);
				return;
			}
			bingId = list[0].id;
			translate(ens);
		});
	}

	static function main() {
		chrome.Runtime.onMessage.addListener(function( query : Message, _, ?sendResponse ) {
			if (query.respone) {
				doResponse(query.value);
				return false;
			}
			var ens = lastWords == query.value ? null : query.value;
			if (ens == null) {
				sendResponse(null);              // disconnect the callback from ContentScript
			} else {
				lazySendResponse = sendResponse; // do response later
			}
			translate(ens);
			return lazySendResponse != null; // return true to make sendResponse works
		});

		chrome.WebNavigation.onDOMContentLoaded.addListener(function(t) {
			switch(t.url.substring(0, t.url.indexOf(":"))) {
			case "http", "https" , "file":
			default:
				return;
			}
			var inject = "js/content-script.js";
			if (t.url.substring(0, bingUrl.length) == bingUrl) {
				inject = "js/hook-bingtranslator.js";
				if (bingId == -1)
					bingId = t.tabId;
			}
			chrome.Scripting.executeScript({
				target : {tabId : t.tabId},
				files : [inject]
			}).catchError(function(_){}); // some invisible pages that you can't inject
		});

		chrome.Tabs.onRemoved.addListener(function(tid, _) {
			if (tid == bingId)
				bingId = -1;
		});

		chrome.Action.onClicked.addListener(function(tab) {
			loadpage(chrome.Runtime.getURL("options.html"));
		});
	}
}
