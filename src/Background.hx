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

	var NOP = function(_){};

	var BTURL = SCHEME + (LANG() == "zh-CN" ? "cn." : "") + BASE_URL;

	var enable = true; // Storage.local

	var lazy_reply : Dynamic->Void = null;

	inline function REFRESH(id) {
		tabid = id;
		//// chrome.Storage.session.set({tabid : id}); // session store
	}

	var acquired = 0; // the count of chrome.Tabs.sendMessage(...)

	function flush( v : Dynamic ) {
		acquired--;
		if (NOTNULL(lazy_reply) && acquired <= 0) {
			lazy_reply(v);
			lazy_reply = null;
		}
	}

	function run( msg : Message ) {
		if (tabid < 0) {
			untyped tab_query(msg);
			return;
		}
		// BEWARE: on multiple clicks, the HOOK page immediately returns NULL, but Runtime.onMessage(...) has already handled them.
		chrome.Tabs.sendMessage(tabid, msg).then(flush).catchError(flush);
	}

	function tab_query( msg ) {
		Tabs.query({ url : '${ SCHEME }*.${ BASE_URL }*'}, function(tabs) {
			var tab = tabs[0];
			if (tab == null || tab.status == UNLOADED) {
				flush(null);
				if (NOTNULL(tab)) {
					Tabs.update(tab.id, {active : true});
				} else {
					Tabs.create({url : BTURL, pinned : true});
				}
				return;
			}
			REFRESH(tab.id);
			run(msg);
		});
	}

	chrome.Storage.local.get(KDISBLED, function( res : StoreObj ) {
		enable = !res[KDISBLED];
	});

	chrome.Runtime.onMessage.addListener(function( msg : Message, _, ?reply : Dynamic->Void ) {
		LOG(msg);
		switch (msg.kind) {
		case Request:
			acquired++;
			if (NOTNULL(lazy_reply)) {
				// Discard the previous request, but be careful — the previous promise from Tabs.SendMessage(...) still exists and cannot be canceled.
				lazy_reply(null);
			}
			lazy_reply = reply;
			run(msg);
			return true; // keep the connection alive
		case Control:
			var args = msg.value.split(":");
			switch (args[0]) {
			case KDISBLED:
				enable = args[1] != "true";
			case KVOICES, KVSPEED if (tabid != -1):
				chrome.Tabs.sendMessage(tabid, msg).catchError(NOP);
			default:
			}
		}
		return false;
	});

	function exec(tab, file, ?world) {
		chrome.Scripting.executeScript({target : tab, files : [file], world : world}).catchError(NOP);
	}

	chrome.WebNavigation.onDOMContentLoaded.addListener(function(t) {
		LOG('frametype : ${t.frameType}, doc : ${t.documentLifecycle}, url : ${t.url}');
		var sub = t.url.substring(8, 32); // "https://XX.bing.com/translator"
		var ishook = sub.indexOf(BASE_URL) >= 0;

		if (!(enable || ishook)) // inject hook-bing.js even if enable == false
			return;

		var target : chrome.Scripting.InjectionTarget = {tabId : t.tabId};
		if (t.frameId > 0) {
			if (ishook || t.tabId == tabid)
				return;
			target.frameIds = [t.frameId];
		}

		if (!ishook) {
			exec(target, "js/content-script.js");
			return;
		}

		if (tabid == -1)
			REFRESH(t.tabId);
		exec(target, "js/hook-bingaudiospeed.js", MAIN);
		exec(target, "js/hook-bingtranslator.js");
	});

	chrome.Tabs.onRemoved.addListener(function(id, _) {
		if (id == tabid)
			REFRESH(-1);
	});
}
