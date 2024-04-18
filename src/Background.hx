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
				doResponse("executeScript error");
			});
			return;
		}
		Tabs.query({ url : "https://*." +  baseUrl + "*" }, function(list) {
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
				switch (args[0]) {
				case KDISBLED:
					var disabled = args[1] != "true";
					LOG('enablejs :$enablejs, disabled : $disabled');
					enablejs = disabled;
				case KVOICES if (bingId != -1):
					LOG('voices : ${args[1]}');
					chrome.Scripting.executeScript({
						target : {tabId : bingId},
						args : [args[1]],
						func : function(s) {
							HookBingTranslator.level = ESXTools.toInt(s);
						}
					}).catchError(nop);
				default:
				}
			}
			return false;
		});

		chrome.WebNavigation.onDOMContentLoaded.addListener(function(t) {
			var scheme = t.url.substring(0, 4);
			if (!(scheme == "http" || scheme == "file"))
				return;
			var ishook = t.url.indexOf(baseUrl, 7) > 0; // "http://".length
			if (!ishook && enablejs) {
				chrome.Scripting.executeScript({
					target : {tabId : t.tabId},
					files : ["js/content-script.js"],
				}).catchError(nop);
				return;
			}
			// inject hook-bing.js even if enablejs == false
			if (!ishook)
				return;

			if (bingId == -1)
				bingId = t.tabId;

			chrome.Scripting.executeScript({
				target : {tabId : t.tabId},
				files : ["js/hook-bingtranslator.js"],
			}).catchError(nop);

			chrome.Scripting.executeScript({
				world : MAIN,
				target : {tabId : t.tabId},
				func : function() {
					var tin : js.html.TextAreaElement = js.Syntax.code("tta_input_ta");
					if (cast tin.onchange)
						return;
					tin.onchange = function( e : Event ) {
						js.Syntax.code("!{0} && sj_evt.fire(RichTranslateHelper.inputTextchanged)", e.isTrusted);
					}
				}
			}).catchError(nop);
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
