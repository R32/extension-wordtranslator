package;

import chrome.Tabs;

inline var BASE_URL = "bing.com/translator";

inline var SCHEME = "https://";

inline function LANG() return chrome.I18n.getUILanguage();

/*
 * TODO : For non-persistent backends, the doc says : "do not rely on global variables",
 * But that seems impossible to do it, because you can't store functions to "Storage.session".
 */
@:native("main") function main()
{
	var tabid = -1;

	var nop = function(_){};

	var bturl = LANG() == "zh-CN" ? '${ SCHEME }cn.${ BASE_URL }' : '${ SCHEME }${ BASE_URL }';

	var enable = true; // Storage.local

	var lazyrep : Dynamic->Void = null;

	var lstword : String = null;

	inline function FLUSH(id) {
		tabid = id; // local
		//// chrome.Storage.session.set({tabid : id}); // session store
	}

	function response( zhs : String ) {
		if (lazyrep == null)
			return;
		lazyrep(zhs);
		lazyrep = null;
		lstword = zhs;
	}

	function translate( ens : String ) {
		if (tabid != -1) {
			chrome.Scripting.executeScript({
				target : {tabId : tabid},
				args : [ens],
				func : function(s) {
					HookBingTranslator.run(s);
				}
			}).catchError(function(_) {
				response(LANG() == "zh-CN" ? "出错了" : "Something is wrong");
			});
			return;
		}
		Tabs.query({ url : '${ SCHEME }*.${ BASE_URL }*'}, function(list) {
			var tab = list[0];
			if (tab == null) {
				response(null); // disconnect
				Tabs.create({url : bturl, pinned : true});
				return;
			}
			FLUSH(tab.id);
			translate(ens);
		});
	}

	chrome.Storage.local.get(KDISBLED, function( res : StoreDisabled ) {
		enable = !res.disabled;
	});

	chrome.Runtime.onMessage.addListener(function( query : Message, _, ?reply : Dynamic->Void ) {
		switch (query.kind) {
		case Respone:
			response(query.value);
		case Request:
			var ens = lstword == query.value ? null : query.value;
			if (ens == null) {
				reply(null); // disconnect the callback from ContentScript
			} else {
				lazyrep = reply;
			}
			translate(ens);
			return lazyrep != null; // return true to make lazyrep available
		case Control:
			var args = query.value.split(":");
			switch (args[0]) {
			case KDISBLED:
				var disabled = args[1] != "true";
				LOG('enable :$enable, disabled : $disabled');
				enable = disabled;
			case KVOICES if (tabid != -1):
				LOG('voices : ${args[1]}');
				chrome.Scripting.executeScript({
					target : {tabId : tabid},
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
		var ishook = t.url.indexOf(BASE_URL, 7) > 0; // "http://".length
		if (!ishook && enable) {
			chrome.Scripting.executeScript({
				target : {tabId : t.tabId},
				files : ["js/content-script.js"],
			}).catchError(nop);
			return;
		}
		// inject hook-bing.js even if enable == false
		if (!ishook)
			return;

		if (tabid == -1)
			FLUSH(t.tabId);

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

	chrome.Tabs.onRemoved.addListener(function(id, _) {
		if (id == tabid)
			FLUSH(-1);
	});
}
