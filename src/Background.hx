package;

import chrome.Tabs;

class Background {

	static inline var TIN  = "tta_input_ta";

	static inline var TOUT = "tta_output_ta";

	static inline var TVOICE = "tta_playiconsrc";

	static function loadpage( href : String, ?callback : Tab->Void ) {
		Tabs.query({ url : href }, function(list) {
			if (list.length > 0) {
				Tabs.update(list[0].id, {active : true}, callback);
				return;
			}
			Tabs.create({url : href}, callback);
		});
	}

	static var bingurl = "https://cn.bing.com/translator";

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
					target : {tabId: list[0].id},
					args : [same ? null : prevMsg],
					func : function(english) {
						// WARINING: the codes of this scope belongs to the target PAGE, NOT Background.
						if (english != null) {
							var input : js.html.TextAreaElement = cast document.getElementById(TIN);
							input.value = english;
							var output : js.html.TextAreaElement = cast document.getElementById(TOUT);
							var old = output.value;
							var rolling : Function = null;
							rolling = function() {
								var cur = output.value;
								var len = cur.length;
								if (cur == old || (cur.charAt(len - 1) == "." && cur.charAt(len - 2) == ".")) {
									window.setTimeout(rolling, 100);
									return;
								}
								// console.log("sended respone");
								chrome.Runtime.sendMessage({value : cur, respone : true});
							}
							input.click();
							window.setTimeout(rolling, 100);
						}
						document.getElementById(TVOICE).click();
					}
				});
			});
			return lazySendResponse != null; // return true to make sendResponse works
		});

		chrome.WebNavigation.onDOMContentLoaded.addListener(function(t) {
			if (t.url.charAt(6) == ":")// if (t.url.includes("chrome://"))
				return;
			chrome.Scripting.executeScript({
				target : {tabId: t.tabId},
				files : ["js/content-script.js"]
			});
		});

		chrome.Action.onClicked.addListener(function(tab) {
			loadpage(chrome.Runtime.getURL("options.html"));
		});
	}
}
