package;

import chrome.Storage;
import chrome.DeclarativeNetRequest;
import js.html.InputElement;

inline var DISABLED = "disabled";
inline var CHECKED = "checked";
inline var REDIRECT_GOOGLEAPI = "redirect-googleapi";

var NOP = function(_){};

function childpos( elem : DOMElement ) : Int {
	var index = 0;
	var prev = elem.previousSibling;
	while (prev != null) {
		if (prev.nodeType == Node.ELEMENT_NODE)
			index++;
		prev = prev.previousSibling;
	}
	return index;
}

function set_redirect( enable : Bool ) {
	var key = enable ? "enableRulesetIds" : "disableRulesetIds";
	var obj = {};
	Reflect.setField(obj, key, [REDIRECT_GOOGLEAPI]);
	DeclarativeNetRequest.updateEnabledRulesets(obj).catchError(NOP);
}

function update( label : DOMElement, checked : Bool, ?extra : String ) {
	LOG('label : ${label.firstChild.nodeValue}, check : $checked, extra : $extra');
	if (checked) {
		label.setAttribute(CHECKED, "");
	} else {
		label.removeAttribute(CHECKED);
	}
	var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
	var ui_redirect = menu.redirect;
	var ui_enable = menu.enable;
	var ui_sound = menu.sound;
	switch (childpos(label)) {
	case 0 if (label == ui_enable):
		var disabled = !checked;
		ui_disabled(ui_sound, disabled);
		ui_disabled(ui_redirect, disabled);
		Storage.local.set(KDISBLED.join(disabled), function() {
			chrome.Runtime.sendMessage(new Message(Control, KDISBLED + ":" + disabled)).catchError(NOP);
		});
		// update googleapi redirecting
		if (disabled) {
			set_redirect(false);
		} else {
			Storage.local.get([KREDIRECT], function( res : StoreObj ) {
				set_redirect(res[KREDIRECT]);
			});
		}
	case 1 if (label == ui_redirect):
		Storage.local.set(KREDIRECT.join(checked), function() {
			set_redirect(checked);
		});
	case 2:
		Storage.local.set(KVOICES.join(extra), function() {
			chrome.Runtime.sendMessage(new Message(Control, KVOICES + ":" + extra)).catchError(NOP);
		});
	default:
	}
}

function setattr( label : DOMElement, value : String, enable : Bool ) {
	if (enable) {
		label.setAttribute(value, "");
		label.querySelector("input").setAttribute(value, "");
	} else {
		label.removeAttribute(value);
		label.querySelector("input").removeAttribute(value);
	}
}
inline function ui_disabled( label : DOMElement, enable : Bool ) {
	setattr(label, DISABLED, enable);
}
inline function ui_checked( label : DOMElement, enable : Bool ) {
	setattr(label, CHECKED, enable);
}

function main() {
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
			ui_checked(menu.enable, false);
			ui_disabled(ui_redirect, true);
			ui_disabled(ui_voices, true);
		}
		if (res[KREDIRECT]) {
			ui_checked(ui_redirect, true);
			set_redirect(true);
		}
		if (res[KVOICES] != null) {
			var n = ESXTools.toInt(res[KVOICES]);
			if (n > 0xFF) {
				ui_checked(ui_voices, false);
			}
			var input : InputElement = cast ui_voices.querySelector("input");
			input.value = "" + (n & 0xFF);
		}
	});
}

@:build(Nvd.build("build/popup.html", "#menumain", {

	enable   : $("label:nth-child(1)"),
	redirect : $("label:nth-child(2)"),
	sound    : $("label:nth-child(3)"),

})) extern abstract MenuUi(nvd.Comp) {
}
