// Generated by Haxe 4.3.1
(function ($global) { "use strict";
class ContentScript {
	static main() {
		if(document.body == null) {
			return;
		}
		let movpos_y;
		let movpos_x = 0;
		movpos_y = 0;
		let range = null;
		let query = [0,""];
		let button = document.getElementById("yangmaowords");
		if(button != null) {
			return;
		}
		let node = document.createElement("div");
		node.id = "yangmaowords";
		node.innerText = "翻译";
		button = node;
		button.style.cssText = "\r\n\t\t\tposition : absolute;\r\n\t\t\tpadding : 2px 4px;\r\n\t\t\tmargin : 0;\r\n\t\t\tdisplay : none;\r\n\t\t\tborder : 1px solid #00bcd4;\r\n\t\t\tborder-left-width : 12pt;\r\n\t\t\tbackground-color : inherit;\r\n\t\t\tfont-size : 10pt;\r\n\t\t\tcursor : pointer;\r\n\t\t\tcolor : inherit;\r\n\t\t\tz-index : 101;\r\n\t\t";
		let onmove = function(e) {
			e.stopPropagation();
			button.style.left = movpos_x + e.screenX + "px";
			button.style.top = movpos_y + e.screenY + "px";
		};
		let updating = function(s) {
			if(s != null) {
				button.innerText = s;
			}
		};
		button.onclick = function(e) {
			e.stopPropagation();
			if(e.layerX < devicePixelRatio * 16) {
				return;
			}
			if(range != null) {
				let sel = document.getSelection();
				if(!sel.isCollapsed && sel.anchorNode.parentNode == button) {
					return;
				}
				sel.removeAllRanges();
				sel.addRange(range);
			}
			chrome.runtime.sendMessage(query,updating);
		};
		button.oncontextmenu = function(e) {
			let sel = document.getSelection();
			if(!sel.isCollapsed && sel.anchorNode.parentNode == button) {
				return;
			}
			ContentScript.halt(e);
			button.style.display = "none";
		};
		let moving = false;
		button.onmousedown = function(e) {
			if(!(e.layerX < devicePixelRatio * 16)) {
				return;
			}
			ContentScript.halt(e);
			movpos_x = button.offsetLeft - e.screenX;
			movpos_y = button.offsetTop - e.screenY;
			document.removeEventListener("mousemove",onmove,true);
			document.addEventListener("mousemove",onmove,true);
			button.style.cursor = "move";
			moving = true;
		};
		document.onmouseup = function(e) {
			if(moving) {
				moving = false;
				document.removeEventListener("mousemove",onmove,true);
				button.style.cursor = "pointer";
				return;
			}
			let sel = document.getSelection();
			if(sel.isCollapsed || sel.anchorNode.parentNode == button) {
				return;
			}
			let value = sel.toString().trimStart();
			if(value == "" || query[1] == value) {
				return;
			}
			button.style.display = "inline-block";
			range = sel.getRangeAt(0);
			let rect = range.getClientRects()[0];
			button.style.left = rect.left + window.pageXOffset + "px";
			button.style.top = Math.max(rect.top + window.pageYOffset - button.offsetHeight - 2,0) + "px";
			query[1] = value;
		};
		document.body.appendChild(button);
	}
	static halt(e) {
		e.preventDefault();
		e.stopPropagation();
	}
}
{
}
ContentScript.main();
})(window);
