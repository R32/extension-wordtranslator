package;

import chrome.Storage;
import chrome.DeclarativeNetRequest;
import js.html.InputElement;

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

	static function flushRedirect( enable : Bool ) {
		var key = enable ? "enableRulesetIds" : "disableRulesetIds";
		var obj = {};
		Reflect.setField(obj, key, [RedirectGoogleAPI]);
		DeclarativeNetRequest.updateEnabledRulesets(obj).catchError(function(_){});
	}

	static function update( label : DOMElement, checked : Bool, ?extra : String ) {
		if (checked) {
			label.setAttribute(CHECKED, "");
		} else {
			label.removeAttribute(CHECKED);
		}
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		var ui_redirect = menu.redirect;
		var ui_enable = menu.enable;
		var ui_sound = menu.sound;
		switch (childIndex(label)) {
		case 0 if (label == ui_enable):
			var disabled = !checked;
			setUiDisabled(ui_sound, disabled);
			setUiDisabled(ui_redirect, disabled);
			Storage.local.set(KDISBLED.join(disabled), function() {
				chrome.Runtime.sendMessage(new Message(Control, KDISBLED + ":" + disabled));
			});
			// update googleapi redirecting
			if (disabled) {
				flushRedirect(false);
			} else {
				Storage.local.get([KREDIRECT], function( res : StoreObj ) {
					flushRedirect(res[KREDIRECT]);
				});
			}
		case 1 if (label == ui_redirect):
			Storage.local.set(KREDIRECT.join(checked), function() {
				flushRedirect(checked);
			});
		case 2:
			Storage.local.set(KVOICES.join(extra), function() {
				chrome.Runtime.sendMessage(new Message(Control, KVOICES + ":" + extra));
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
	static inline function setUiDisabled( label : DOMElement, enable : Bool ) {
		setAttribute(label, DISABLED, enable);
	}
	static inline function setUiChecked( label : DOMElement, enable : Bool ) {
		setAttribute(label, CHECKED, enable);
	}

	static function main() {
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		menu.dom.onclick = function ( e : PointerEvent ) {
			var target : InputElement = cast e.target;
			var parent = target.parentElement;
			var voices = menu.sound;
			if (parent == menu && target == cast voices) {
				e.preventDefault();
				var input : InputElement = cast voices.querySelector("input");
				var checked = !voices.hasAttribute(CHECKED); // manual toggle, because it's not checkbox
				var value = checked ? input.value : "" + (ESXTools.toInt(input.value) + (1 << 8));
				update(voices, checked, value);
				return;
			}
			if (target.type == "checkbox") {
				update(parent, target.checked);
			} else if (parent == voices) {
				update(voices, true, target.value);
			}
		}
		// init
		Storage.local.get([KVOICES, KDISBLED, KREDIRECT], function( res : StoreObj ) {
			var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
			var ui_voices = menu.sound;
			var ui_redirect = menu.redirect;
			if (res[KDISBLED]) {
				setUiChecked(menu.enable, false);
				setUiDisabled(ui_redirect, true);
				setUiDisabled(ui_voices, true);
			}
			if (res[KREDIRECT]) {
				setUiChecked(ui_redirect, true);
				flushRedirect(true);
			}
			if (res[KVOICES] != null) {
				var n = ESXTools.toInt(res[KVOICES]);
				if (n > 0xFF) {
					setUiChecked(ui_voices, false);
				}
				var input : InputElement = cast ui_voices.querySelector("input");
				input.value = "" + (n & 0xFF);
			}
		});
	}
}

@:build(Nvd.build("build/popup.html", "#menumain", {

	enable   : $("label:nth-child(1)"),
	redirect : $("label:nth-child(2)"),
	sound    : $("label:nth-child(3)"),

})) extern abstract MenuUi(nvd.Comp) {
}
