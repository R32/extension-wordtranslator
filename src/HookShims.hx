package;

import js.html.AudioElement;

@:native("sj_evt") extern var sj_evt : { bind : haxe.Constraints.Function };

var TPLAY = document.getElementById("tta_playiconsrc");
var TOUT = document.getElementById("tta_output_ta");
var finish = new js.html.CustomEvent(CE_FINISH);
var irate = 100;

function NOP(_){}

function rate_play() {
	nativeThis.playbackRate = irate / 100.;
	// Browsers released before 2019 may not return a value from play()
	(nativeThis.origin_play() : Promise<Any>)?.catchError(NOP);
}

inline function rate_attach() {
	(AudioElement : Dynamic).prototype.play = rate_play;
}
inline function rate_detach() {
	(AudioElement : Dynamic).prototype.play = (AudioElement : Dynamic).prototype.origin_play;
}

function main() {
	(AudioElement : Dynamic).prototype.origin_play = (AudioElement : Dynamic).prototype.play;

	TPLAY.addEventListener(CE_RATE, function( e : js.html.CustomEvent ) {
		irate = e.detail;
		if (irate < 100) {
			rate_attach();
		} else {
			rate_detach();
		}
	});

	// bing.com/translator::sj_evt.bind(RichTranslateHelper.domStabilizedEvent, ...);
	sj_evt.bind("tt.domStable", function() {
		TOUT.dispatchEvent(finish);
	});
}
