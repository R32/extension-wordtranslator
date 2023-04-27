package;

class ContentScript {

	static var button : DOMElement;

	static var srange : js.html.Range;

	static var query : Message = {value : ""};

	static var btnpos = {x : 0, y : 0}; // position of button for moving

	public static function main() {
		if (document.body == null)
			return;
		var id = "bing_trans_btn";
		var button = document.getElementById(id);
		if (button != null)
			return;
		document.onpointerup = mouseup;
		button = HXX( <div id="{{ id }}">文</div> ); // TODO: a random word from localStorage wordlist
		button.style.cssText = "
			position : absolute;
			padding : 2px 4px;
			margin : 0;
			display : none;
			border : 1px solid #bf1d1d;
			background-color : inherit;
			font-size : 10pt;
			cursor : pointer;
			color : inherit;
			z-index : 100;
		";
		button.onclick = function( e : MouseEvent ) {
			e.stopPropagation();
			if (srange != null) {
				var sel = document.getSelection();
				sel.removeAllRanges();
				sel.addRange(srange);
			}
			chrome.Runtime.sendMessage(query, update);
		}
		button.oncontextmenu = function( e : MouseEvent ) {
			halt(e);
			display(button) = CSS_NONE;
		}
		button.onpointerdown = function( e : MouseEvent ) {
			e.stopPropagation();
			document.onselectstart = halt;
			// move button
			btnpos.x = Std.parseInt(button.style.left) - e.screenX;
			btnpos.y = Std.parseInt(button.style.top) - e.screenY;
			document.removeEventListener("mousemove", onmove, true);
			document.addEventListener("mousemove", onmove, true);
			button.style.cursor = "move";
		};
		document.body.appendChild(button);
		ContentScript.button = button;
	}

	static function update(zhs) {
		if (zhs != null)
			text(button) = zhs;
	}

	static function onmove( e : MouseEvent ) {
		e.stopPropagation();
		button.style.left = btnpos.x + e.screenX + "px";
		button.style.top  = btnpos.y + e.screenY + "px";
	}

	static function halt( e : Event ) {
		e.preventDefault();
		e.stopPropagation();
	}

	static function mouseup( e : js.html.PointerEvent ) {
		if (document.onselectstart != null) {
			document.onselectstart  = null;
			document.removeEventListener("mousemove", onmove, true);
			button.style.cursor = "pointer";
			return;
		}
		var sel = document.getSelection();
		if (sel.rangeCount < 1)
			return;
		var value = (sel : Dynamic).toString(); // no toString?
		if (query.value == value || value.length < 2)
			return;
		display(button) = CSS_INLINE_BLOCK;
		button.style.left = e.pageX + 20 + "px";
		button.style.top = e.pageY - 50 + "px";
		query.value = value;
		srange = sel.getRangeAt(0);
	}
}
