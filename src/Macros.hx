package;

#if macro
import haxe.macro.Context;
#end

class Macros {

	macro public static function text(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).innerText;

	macro public static function display(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).style.display;

	macro public static function clsl(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).classList;

	macro public static function LOG(args) {
		// if no "--no-traces" or "--debug"
		if (!Context.defined("no_traces") || Context.defined("debug"))
			return macro @:pos(args.pos) console.log($args);
		return macro {};
	}
#if macro

#end
}
