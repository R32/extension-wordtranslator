package;

using ESXTools;

@:native("halt") function halt( e : Event ) {
	e.preventDefault();
	e.stopPropagation();
}

inline function skipped() {
	return document.documentElement.lang.startsWith("zh") && chrome.I18n.getUILanguage().startsWith("zh");
}

@:native("main") function main() {
	if (document.body == null || skipped())
		return;
	var id = "yangmaowords";
	var pos = {x : 0, y : 0};
	var msg = new Message(Request, "");
	var range : js.html.Range = null;
	var view = document.getElementById(id);
	if (view != null)
		return;
	view = HXX( <div id="{{ id }}">翻译</div> ); // TODO: a random word from localStorage wordlist

	if (view.style == null) // for XML file
		return;

	view.style.cssText = Macros.noCRLF("
		position : absolute;
		padding : 2px 4px;
		margin : 0;
		display : none;
		border : 1px solid #00bcd4;
		border-left-width : 12pt;
		background-color : inherit;
		font-size : 10pt;
		cursor : pointer;
		color : inherit;
		z-index : 101;
	");

	var headwidth = Std.int(devicePixelRatio * 16); // (border-left-width : 12pt) then (12/72 * 96px) == 16px

	inline function hithead( e : MouseEvent ) return e.layerX < headwidth;

	inline function hitself( sel : js.html.Selection ) return sel.anchorNode.parentNode == view;

	var onmove = function( e : MouseEvent ) {
		e.stopPropagation();
		view.style.left = pos.x + e.screenX + "px";
		view.style.top  = pos.y + e.screenY + "px";
	}
	var flush = function( s : String ) {
		if (s != null)
			text(view) = s;
	}
	view.onclick = function( e : PointerEvent ) {
		e.stopPropagation();
		if (hithead(e))
			return;
		if (range != null) {
			var sel = document.getSelection();
			if (!sel.isCollapsed && hitself(sel))
				return;
			sel.removeAllRanges();
			sel.addRange(range);
		}
		chrome.Runtime.sendMessage(msg, flush);
	}
	view.oncontextmenu = function( e : MouseEvent ) {
		var sel = document.getSelection();
		if (!sel.isCollapsed && hitself(sel)) // if you want to copy the result
			return;
		halt(e);
		display(view) = CSS_NONE;
	}
	var moving = false;
	view.onmousedown = function( e : MouseEvent ) {
		if (!hithead(e))
			return;
		// prevents text selection
		halt(e);
		// moving start
		pos.x = view.offsetLeft - e.screenX;
		pos.y = view.offsetTop - e.screenY;
		document.removeEventListener("mousemove", onmove, true);
		document.addEventListener("mousemove", onmove, true);
		view.style.cursor = "move";
		moving = true;
	};
	document.onmouseup = function( e : MouseEvent ) {
		if (moving) {
			moving = false;
			document.removeEventListener("mousemove", onmove, true);
			view.style.cursor = "pointer";
			return;
		}
		var sel = document.getSelection();
		if (sel.isCollapsed || hitself(sel))
			return;
		var value = sel.toString().trimStart();
		if (value == "" || msg.value == value)
			return;
		display(view) = CSS_INLINE_BLOCK;
		range = sel.getRangeAt(0);
		var rect = range.getClientRects()[0];
		view.style.left = rect.left + window.pageXOffset + "px";
		view.style.top = Math.max(rect.top + window.pageYOffset - view.offsetHeight - 2, 0) + "px";
		msg.value = value;
	};
	document.body.appendChild(view);
}
