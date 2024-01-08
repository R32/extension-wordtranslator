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

	static function updateRedirect( enable : Bool ) {
		var key = enable ? "enableRulesetIds" : "disableRulesetIds";
		var obj = {};
		Reflect.setField(obj, key, [RedirectGoogleAPI]);
		DeclarativeNetRequest.updateEnabledRulesets(obj).catchError(function(_){});
	}

	static function onChecked( label : DOMElement, checked : Bool, ?extra : String ) {
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
		case 1 if (label == ui_redirect):
			var value : StoreRedirect = {redirect : checked};
			Storage.local.set(value, function() {
				updateRedirect(checked);
			});
		case 2:
			var value : StoreVoices = {voices : extra};
			Storage.local.set(value, function() {
				sendMessage(new Message(Control, KVOICES + ":" + extra));
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
			var target : InputElement = cast e.target;
			var parent = target.parentElement;
			var voices = menu.sound;
			if (parent == menu && target == cast voices) {
				e.preventDefault();
				var input : InputElement = cast voices.querySelector("input");
				var checked = !voices.hasAttribute(CHECKED); // manual toggle, because it's not checkbox
				var value = checked ? input.value : "" + (ESXTools.toInt(input.value) + (1 << 8));
				onChecked(voices, checked, value);
				return;
			}
			if (target.type == "checkbox") {
				onChecked(parent, target.checked);
			} else if (parent == voices) {
				onChecked(parent, true, target.value);
			}
		}
		// init
		Storage.local.get([KVOICES, KDISBLED, KREDIRECT], function( stores : StoreAll ) {
			var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
			var ui_voices = menu.sound;
			var ui_redirect = menu.redirect;
			if (stores.disabled) {
				setChecked(menu.enable, false);
				setDisabled(ui_redirect, true);
				setDisabled(ui_voices, true);
			}
			if (stores.redirect) {
				setChecked(ui_redirect, true);
			}
			if (stores.voices != null) {
				var n = ESXTools.toInt(stores.voices);
				if (n > 0xFF) {
					setChecked(ui_voices, false);
				}
				var input : InputElement = cast ui_voices.querySelector("input");
				input.value = "" + (n & 0xFF);
			}
		});
	}
}

@:build(Nvd.build("build/popup.html", "#menumain", {

	enable : $("label:nth-child(1)"),
	redirect : $("label:nth-child(2)"),
	sound  : $("label:nth-child(3)"),

})) extern abstract MenuUi(nvd.Comp) {
}
