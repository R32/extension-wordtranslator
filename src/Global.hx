package;

class Global {

	public static inline var CSS_NONE = "none";

	public static inline var CSS_BLOCK = "block";

	public static inline var CSS_INLINE_BLOCK = "inline-block";

	public static inline var CSS_EMPTY = "";
}

@:native("console") extern var console : js.html.ConsoleInstance;
@:native("document") extern var document : js.html.Document;
@:native("window") extern var window : js.html.Window;
@:native("devicePixelRatio") extern var devicePixelRatio : Float;
