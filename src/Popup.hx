package;

import chrome.Storage;

class Popup {

	static inline var DISABLED = "disabled";
	static inline var CHECKED = "checked";

	static function onChecked( label : DOMElement, checked : Bool ) {
		// update label by input.checked
		if (checked) {
			label.setAttribute(CHECKED, "");
		} else {
			label.removeAttribute(CHECKED);
		}
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		var ui_enable = menu.enable; // ui_onoff, ui_nosound
		var ui_sound = menu.sound;
		if (ui_enable == label) {
			setNone(ui_sound, !checked);
		}
		var on = !checked;
		if (label == ui_enable) {
			var value : StoreDisabled = {disabled : on};
			Storage.local.set(value, function() {
				sendMessage(new Message(Control, KDISBLED + ":" + on));
			});
		} else if (label == ui_sound) {
			var value : StoreNoSound = {nosound : on};
			Storage.local.set(value, function() {
				sendMessage(new Message(Control, KNOSOUND + ":" + on));
			});
		}
	}

	static function setAttribute( label : DOMElement, value : String, on : Bool) {
		if (on) {
			label.setAttribute(value, "");
			label.querySelector("input").setAttribute(value, "");
		} else {
			label.removeAttribute(value);
			label.querySelector("input").removeAttribute(value);
		}
	}
	static inline function setNone( label : DOMElement, on : Bool ) {
		setAttribute(label, DISABLED, on);
	}
	static inline function setChecked( label : DOMElement, on : Bool ) {
		setAttribute(label, CHECKED, on);
	}

	static function uiSync() {
		Storage.local.get([KNOSOUND, KDISBLED], function( stores : StoreAll ) {
			var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
			if (stores.nosound) {
				setChecked(menu.sound, false);
			}
			if (stores.disabled) {
				setChecked(menu.enable, false);
				setNone(menu.sound, true);
			}
		});
	}

	static function main() {
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		menu.dom.onclick = function ( e : PointerEvent ) {
			var target = (cast e.target : js.html.InputElement);
			if (target.tagName != "INPUT")
				return;
			onChecked(target.parentElement, target.checked);
		}
		uiSync();
	}
}

@:build(Nvd.build("build/popup.html", "#menumain", {

	enable : $("label:nth-child(1)"),
	sound  : $("label:nth-child(2)"),

})) extern abstract MenuUi(nvd.Comp) {
}