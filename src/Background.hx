package;

import chrome.Tabs;

class Background {

	static var bingId = -1;

	static var baseUrl = "bing.com/translator";

	static var bingUrl : String;

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
		LOG('(doResponse) lastWords : $ret, lazySendResponse : ${null == lazySendResponse ? "null" : "function"}');
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
		var enablejs = true;
		var nop = function(_){};
		if (chrome.I18n.getUILanguage() == "zh-CN") {
			bingUrl = "https://" + "cn." + baseUrl;
		} else {
			bingUrl = "https://" + baseUrl;
		}
		chrome.Runtime.onMessage.addListener(function( query : Message, _, ?sendResponse ) {
			switch (query.kind) {
			case Respone:
				doResponse(query.value);
			case Request:
				var ens = lastWords == query.value ? null : query.value;
				if (ens == null) {
					sendResponse(null);              // disconnect the callback from ContentScript
				} else {
					lazySendResponse = sendResponse; // do response later
				}
				translate(ens);
				return lazySendResponse != null; // return true to make lazySendResponse available
			case Control:
				var args = query.value.split(":");
				var on = args[1] != "true";
				switch (args[0]) {
				case KDISBLED:
					LOG('enablejs :$enablejs, on : $on');
					enablejs = on;
				case KNOSOUND if (bingId != -1):
					LOG('sound : $on');
					chrome.Scripting.executeScript({
						target : {tabId : bingId},
						args : [on],
						func : function(x) {
							HookBingTranslator.sound = x;
						}
					}).catchError(nop);
				default:
				}
			}
			return false;
		});

		chrome.WebNavigation.onDOMContentLoaded.addListener(function(t) {
			switch(t.url.substring(0, t.url.indexOf(":"))) {
			case "http", "https" , "file":
			default:
				return;
			}
			var injectjs = "js/content-script.js";
			var hookpage = t.url.indexOf(baseUrl, 7) >= 7; // "http://".length
			LOG('enablejs : $enablejs, ishookpage : $hookpage');
			if (!enablejs && !hookpage)
				return;
			if (hookpage) {
				injectjs = "js/hook-bingtranslator.js";
				if (bingId == -1)
					bingId = t.tabId;
			}
			LOG('injectjs : $injectjs, page : ${t.url}');
			chrome.Scripting.executeScript({
				target : {tabId : t.tabId},
				files : [injectjs]
			}).catchError(nop); // some invisible pages that you can't inject
		});

		chrome.Tabs.onRemoved.addListener(function(tid, _) {
			if (tid == bingId)
				bingId = -1;
		});

		chrome.Storage.local.get(KDISBLED, function(attr : StoreDisabled){
			enablejs = !attr.disabled;
		});
	}
}
