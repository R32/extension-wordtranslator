package;

import chrome.Storage;
import chrome.DeclarativeNetRequest;

class Popup {

	static inline var DISABLED = "disabled";
	static inline var CHECKED = "checked";
	static inline var RedirectGoogleAPI = "redirect-googleapi";

	static function childIndex( elem : DOMElement ) : Int {
		var index = 0;
		var prev = elem.previousSibling;
		while (prev != null) {
			if (prev.nodeType == Node.ELEMENT_NODE)
				index++;
			prev = prev.previousSibling;
		}
		return index;
	}

	static function updateRedirect( enable : Bool ) {
		var key = enable ? "enableRulesetIds" : "disableRulesetIds";
		var obj = {};
		Reflect.setField(obj, key, [RedirectGoogleAPI]);
		DeclarativeNetRequest.updateEnabledRulesets(obj).catchError(function(_){});
	}

	static function onChecked( label : DOMElement, checked : Bool ) {
		if (checked) {
			label.setAttribute(CHECKED, "");
		} else {
			label.removeAttribute(CHECKED);
		}
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		var ui_redirect = menu.redirect;
		var ui_enable = menu.enable;
		var ui_sound = menu.sound;
		var disabled = !checked;
		switch (childIndex(label)) {
		case 0 if (label == ui_enable):
			setDisabled(ui_sound, disabled);
			setDisabled(ui_redirect, disabled);
			var value : StoreDisabled = {disabled : disabled};
			Storage.local.set(value, function() {
				sendMessage(new Message(Control, KDISBLED + ":" + disabled));
			});
			// update googleapi redirecting
			if (disabled) {
				updateRedirect(false);
			} else {
				Storage.local.get([KREDIRECT], function( stored : StoreRedirect ) {
					updateRedirect(stored.redirect);
				});
			}
		case 1 if (label == ui_sound):
			var value : StoreNoSound = {nosound : disabled};
			Storage.local.set(value, function() {
				sendMessage(new Message(Control, KNOSOUND + ":" + disabled));
			});
		case 2 if (label == ui_redirect):
			var value : StoreRedirect = {redirect : checked};
			Storage.local.set(value, function() {
				updateRedirect(checked);
			});
		default:
		}
	}

	static function setAttribute( label : DOMElement, value : String, enable : Bool ) {
		if (enable) {
			label.setAttribute(value, "");
			label.querySelector("input").setAttribute(value, "");
		} else {
			label.removeAttribute(value);
			label.querySelector("input").removeAttribute(value);
		}
	}
	static inline function setDisabled( label : DOMElement, enable : Bool ) {
		setAttribute(label, DISABLED, enable);
	}
	static inline function setChecked( label : DOMElement, enable : Bool ) {
		setAttribute(label, CHECKED, enable);
	}

	static function main() {
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		menu.dom.onclick = function ( e : PointerEvent ) {
			var target = (cast e.target : js.html.InputElement);
			if (target.tagName != "INPUT")
				return;
			onChecked(target.parentElement, target.checked);
		}
		// init
		Storage.local.get([KNOSOUND, KDISBLED, KREDIRECT], function( stores : StoreAll ) {
			var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
			if (stores.nosound) {
				setChecked(menu.sound, false);
			}
			if (stores.disabled) {
				setChecked(menu.enable, false);
				setDisabled(menu.sound, true);
				setDisabled(menu.redirect, true);
			}
			if (stores.redirect) {
				setChecked(menu.redirect, true);
			}
		});
	}
}

@:build(Nvd.build("build/popup.html", "#menumain", {

	enable : $("label:nth-child(1)"),
	sound  : $("label:nth-child(2)"),
	redirect : $("label:nth-child(3)"),

})) extern abstract MenuUi(nvd.Comp) {
}
