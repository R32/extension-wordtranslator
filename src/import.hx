#if js

import haxe.Constraints.Function;
import Nvd.HXX;
import Data;
// js
import js.lib.Error;
import js.lib.Promise;
import js.Lib.nativeThis;
import js.html.URL;
import js.html.DOMElement;
import js.html.Event;
import js.html.MouseEvent;
import js.html.KeyboardEvent;

// chrome extension
import chrome.Tabs;
import chrome.Storage;

// Macro
import Macros.text;
import Macros.display;
import Macros.clsl;

// Global
import Global.CSS_INLINE_BLOCK;
import Global.CSS_BLOCK;
import Global.CSS_NONE;
import Global.CSS_EMPTY;

import Global.console;
import Global.document;
import Global.window;
#end