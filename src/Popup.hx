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
	while (NOTNULL(prev)) {
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
	var ui_speed = menu.speed;
	switch (childpos(label)) {
	case 0:
		var disabled = !checked;
		ui_disabled(ui_speed, disabled);
		ui_disabled(ui_sound, disabled);
		ui_disabled(ui_redirect, disabled);
		Storage.local.set(KDISBLED.combine(disabled), function() {
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
	case 1:
		Storage.local.set(KREDIRECT.combine(checked), function() {
			set_redirect(checked);
		});
	case 2, 3:
		var key = label == ui_sound ? KVOICES : KVSPEED;
		var obj = new haxe.DynamicAccess<String>();
		obj[key] = extra;
		Storage.local.set(obj, function() {
			chrome.Runtime.sendMessage(new Message(Control, key + ":" + extra)).catchError(NOP);
		});
	default:
	}
}

function attrset( label : DOMElement, value : String, enable : Bool ) {
	if (enable) {
		label.setAttribute(value, "");
		label.querySelector("input").setAttribute(value, "");
	} else {
		label.removeAttribute(value);
		label.querySelector("input").removeAttribute(value);
	}
}
inline function ui_disabled( label : DOMElement, enable : Bool ) {
	attrset(label, DISABLED, enable);
}
inline function ui_checked( label : DOMElement, enable : Bool ) {
	attrset(label, CHECKED, enable);
}
function mapspan( k : String ) {
	var map : haxe.DynamicAccess<String> = {"1" : "2", "2" : "4", "3" : "8", "4" : "inf"};
	var v = map[k];
	return v == null ? k : v;
}
function main() {
	var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
	menu.dom.onclick = function ( e : PointerEvent ) {
		var label : js.html.LabelElement = cast e.target;
		var voice = menu.sound;
		var speed = menu.speed;
		var parent = label.parentElement;
		if (parent == menu && (label == voice || label == speed)) { // disable/enable
			e.preventDefault();
			var input : InputElement = cast label.querySelector("input");
			var checked = !label.hasAttribute(CHECKED);
			var value = checked ? input.value : "" + (ESXTools.toInt(input.value) + (1 << 8));
			update(label, checked, value);
			text(label.querySelector("span")) = mapspan(input.value);
			return;
		}
		var input : InputElement = cast label;
		if (input.type == "checkbox") {
			update(parent, input.checked);
		} else if (input.type == "range") {
			update(parent, true, input.value);
			text(parent.querySelector("span")) = mapspan(input.value);
		}
	}
	// init
	Storage.local.get([KVOICES, KVSPEED, KDISBLED, KREDIRECT], function( res : StoreObj ) {
		var menu = MenuUi.ofSelector(MenuUi.SELECTOR);
		var ui_speed = menu.speed;
		var ui_voices = menu.sound;
		var ui_redirect = menu.redirect;
		if (res[KDISBLED]) {
			ui_checked(menu.enable, false);
			ui_disabled(ui_redirect, true);
			ui_disabled(ui_voices, true);
			ui_disabled(ui_speed, true);
		}
		if (res[KREDIRECT]) {
			ui_checked(ui_redirect, true);
			set_redirect(true);
		}
		var aui = [ui_voices, ui_speed];
		var akey = [KVOICES, KVSPEED];
		var i = 0;
		while (i < aui.length) {
			var ui = aui[i];
			var key = akey[i++];
			var svalue = res[key];
			if (svalue == null)
				continue;
			var iv = ESXTools.toInt(svalue);
			if (iv > 0xFF)
				ui_checked(ui, false);
			var svalue = "" + (iv & 0xFF);
			var input : InputElement = cast ui.querySelector("input");
			input.value = svalue;
			text(ui.querySelector("span")) = mapspan(svalue);
		}
	});
}

@:build(Nvd.build("build/popup.html", "#menumain", {

	enable   : $("label:nth-child(1)"),
	redirect : $("label:nth-child(2)"),
	sound    : $("label:nth-child(3)"),
	speed    : $("label:nth-child(4)"),

})) extern abstract MenuUi(nvd.Comp) {
}
