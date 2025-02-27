package;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Macros {

	macro public static function NOTNULL(obj)
		return macro @:pos(obj.pos) ($obj : Dynamic);

	macro public static function text(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).innerText;

	macro public static function display(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).style.display;

	macro public static function clsl(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).classList;

	macro public static function LOG( args : Array<Expr> ) {
		// if no "-D no-traces" or "--debug"
		if (!Context.defined("no_traces") || Context.defined("debug"))
			return macro @:pos(args[0].pos) console.log($a{ args });
		return macro {};
	}

	macro public static function noCRLF(css) {
		switch (css.expr) {
		case EConst(CString(s)):
			var s = ~/\r|\n|\t+|/g.replace(s, "");
			return macro @:pos(css.pos) $v{s};
		default:
			return css;
		}
	}
#if macro

#end
}
