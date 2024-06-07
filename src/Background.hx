package;

import chrome.Tabs;

inline var BASE_URL = "bing.com/translator";

inline var SCHEME = "https://";

inline function LANG() return chrome.I18n.getUILanguage();

inline function is_undefined( v : Dynamic ) return js.Syntax.strictEq(v, js.Lib.undefined);

/*
 * TODO : For non-persistent backends, the doc says : "do not rely on global variables",
 * But that seems impossible to do it, because you can't store functions to "Storage.session".
 */
@:native("main") function main()
{
	var tabid = -1;

	var NOP = function(_){};

	var BTURL = LANG() == "zh-CN" ? '${ SCHEME }cn.${ BASE_URL }' : '${ SCHEME }${ BASE_URL }';

	var enable = true; // Storage.local

	var lazy_reply : Dynamic->Void = null;

	var tmp_ens : String = null;
	var lst_ens : String;

	inline function FLUSH(id) {
		tabid = id;
		//// chrome.Storage.session.set({tabid : id}); // session store
	}

	function response( zhs : String, ?reason : LocaleMessage ) {
		if (lazy_reply == null)
			return;
		if (zhs == null) {
			tmp_ens = null; // clear up
			zhs = LocaleMessage.get(is_undefined(reason) ? Fails : reason);
		}
		lazy_reply(zhs);
		lazy_reply = null;
		lst_ens = tmp_ens;
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
				response(null, Wrong);
			});
			return;
		}
		Tabs.query({ url : '${ SCHEME }*.${ BASE_URL }*'}, function(list) {
			var tab = list[0];
			if (tab == null || tab.status == UNLOADED) {
				response(null, Disconnect);
				if (tab == null)
					Tabs.create({url : BTURL, pinned : true});
				else
					Tabs.update(tab.id, {active : true});
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
			var ens = lst_ens == query.value ? null : query.value;
			if (ens == null) {
				reply(null);     // disconnect the callback from ContentScript
				translate(null); // sound only
			} else {
				if (lazy_reply != null)
					lazy_reply(null);
				lazy_reply = reply;
				tmp_ens = ens;
				translate(ens);
				return true;     // keep the connection alive
			}
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
				}).catchError(NOP);
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

		if (!(enable || ishook)) // inject hook-bing.js even if enable == false
			return;

		if (ishook && tabid == -1)
			FLUSH(t.tabId);

		var script = ishook ? "js/hook-bingtranslator.js" : "js/content-script.js";

		chrome.Scripting.executeScript({
			target : {tabId : t.tabId},
			files : [script],
		}).catchError(NOP);
	});

	chrome.Tabs.onRemoved.addListener(function(id, _) {
		if (id == tabid)
			FLUSH(-1);
	});
}

extern enum abstract LocaleMessage(String) to String {
	var Fails = "FAILED";
	var Wrong = "WRONG";
	var Disconnect = null;
	static inline function get( m : LocaleMessage ) : String {
		return m != null ? chrome.I18n.getMessage(m) : m;
	}
}
