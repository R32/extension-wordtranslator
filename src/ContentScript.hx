package;

class ContentScript {
	public static function main() {
		if (document.body == null)
			return;
		var id = "yangmaowords";
		var movpos = {x : 0, y : 0} // position of button for moving
		var range : js.html.Range = null;
		var query = new Message(Request, "");
		var button = document.getElementById(id);
		if (button != null)
			return;
		button = HXX( <div id="{{ id }}">翻译</div> ); // TODO: a random word from localStorage wordlist
		button.style.cssText = "
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
		";
		inline function onitself( sel : js.html.Selection ) return sel.anchorNode.parentNode == button;
		var onmove = function( e : MouseEvent ) {
			e.stopPropagation();
			button.style.left = movpos.x + e.screenX + "px";
			button.style.top  = movpos.y + e.screenY + "px";
		}
		var update = function( s : String ) {
			if (s != null)
				text(button) = s;
		}
		button.onclick = function( e : PointerEvent ) {
			e.stopPropagation();
			if (headerhit(e))
				return;
			if (range != null) {
				var sel = document.getSelection();
				if (!sel.isCollapsed && onitself(sel))
					return;
				sel.removeAllRanges();
				sel.addRange(range);
			}
			chrome.Runtime.sendMessage(query, update);
		}
		button.oncontextmenu = function( e : MouseEvent ) {
			var sel = document.getSelection();
			if (!sel.isCollapsed && onitself(sel)) // if you want to copy the result
				return;
			halt(e);
			display(button) = CSS_NONE;
		}
		button.onpointerdown = function( e : PointerEvent ) {
			e.stopPropagation();
			if (!headerhit(e))
				return;
			document.onselectstart = halt;
			// move button
			movpos.x = Std.parseInt(button.style.left) - e.screenX;
			movpos.y = Std.parseInt(button.style.top) - e.screenY;
			document.removeEventListener("mousemove", onmove, true);
			document.addEventListener("mousemove", onmove, true);
			button.style.cursor = "move";
		};
		document.onpointerup = function( e : PointerEvent ) {
			if (document.onselectstart != null) {
				document.onselectstart  = null;
				document.removeEventListener("mousemove", onmove, true);
				button.style.cursor = "pointer";
				return;
			}
			var sel = document.getSelection();
			if (sel.isCollapsed || onitself(sel))
				return;
			var value = (sel : Dynamic).toString(); // no toString?
			if (query.value == value || value.length < 2)
				return;
			display(button) = CSS_INLINE_BLOCK;
			button.style.left = e.pageX + "px";
			button.style.top = Math.max(e.pageY - 50, 0) + "px";
			query.value = value;
			range = sel.getRangeAt(0);
		};
		document.body.appendChild(button);
	}
	// border-left-width is 12pt then (12/72 * 96px) == 16px
	static inline function headerhit( e : PointerEvent ) return e.layerX < (devicePixelRatio * 16);

	static function halt( e : Event ) {
		e.preventDefault();
		e.stopPropagation();
	}
}
