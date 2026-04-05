package;

import js.html.AudioElement;

var TPLAY = document.getElementById("tta_playiconsrc");
var irate = 100;

function rate_play() {
	var frate = irate / 100.;
	nativeThis.playbackRate = frate;
	nativeThis.origin_play();
}

inline function rate_attach() {
	(AudioElement : Dynamic).prototype.play = rate_play;
}
inline function rate_detach() {
	(AudioElement : Dynamic).prototype.play = (AudioElement : Dynamic).prototype.origin_play;
}

function main() {
	(AudioElement : Dynamic).prototype.origin_play = (AudioElement : Dynamic).prototype.play;
	TPLAY.addEventListener("playbackRate", function( e : js.html.CustomEvent ) {
		irate = e.detail;
		if (irate < 100) {
			rate_attach();
		} else {
			rate_detach();
		}
	});
}
