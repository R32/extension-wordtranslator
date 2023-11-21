#if js

import haxe.Constraints.Function;
import Nvd.HXX;
import Data;
import Data.sendMessage;
// js
import js.lib.Error;
import js.lib.Promise;
import js.Lib.nativeThis;
import js.html.URL;
import js.html.Node;
import js.html.Event;
import js.html.DOMElement;
import js.html.MouseEvent;
import js.html.PointerEvent;
import js.html.KeyboardEvent;

// chrome extension

// Macro
import Macros.text;
import Macros.display;
import Macros.clsl;
import Macros.LOG;

// Global
import Global.CSS_INLINE_BLOCK;
import Global.CSS_BLOCK;
import Global.CSS_NONE;
import Global.CSS_EMPTY;

import Global.console;
import Global.document;
import Global.window;
import Global.devicePixelRatio;
#end