#
OUT       := build
SRC       := src

HAXEFLAGS := -cp $(SRC)\
	-dce full\
	-D js-es=6\
	-D js-global=window\
	-D analyzer-optimize\
	-D no-traces\
	-lib chrome-extension-v3\
	-lib macro-aux\
	-lib no-vdom\
	--macro exclude\(\'haxe.iterators.ArrayIterator\'\)

BG        := $(OUT)/js/background.js
HOOK_SHIMS:= $(OUT)/js/hook-shims.js
HOOK_MAIN := $(OUT)/js/hook-main.js
CONTENT   := $(OUT)/js/content-script.js
# popup.html
POPUPJS   := $(OUT)/js/popup.js
POPUPCSS  := $(OUT)/style/popup.css

# haxe
COMMON    := Data Global Macros ESXTools import
COMMON    := $(COMMON:%=$(SRC)/%.hx)

all: bg content hook popup
bg: $(BG)
hook: $(HOOK_SHIMS) $(HOOK_MAIN)
popup: $(POPUPJS) $(POPUPCSS)
content: $(CONTENT)
hss: $(POPUPCSS)

clean:
	rm -rf $(BG) $(HOOK) $(CONTENT) $(POPUPJS) $(POPUPCSS)

.PHONY: all bg hook popup content hss clean

$(BG): $(SRC)/Background.hx $(COMMON)
	haxe $(HAXEFLAGS) -D js-global=globalThis --js $@ --main Background --macro maux.ModuleLevel.strip\([\'Background\']\)

$(HOOK_SHIMS): $(SRC)/HookShims.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main HookShims --macro maux.ModuleLevel.strip\([\'HookShims\']\)

$(HOOK_MAIN): $(SRC)/HookMain.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main HookMain --macro maux.ModuleLevel.strip\([\'HookMain\']\)

$(CONTENT): $(SRC)/ContentScript.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main ContentScript

$(POPUPJS): $(SRC)/Popup.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main Popup --macro maux.ModuleLevel.strip\([\'Popup\']\)

$(POPUPCSS): hss/popup.hss
	hss -output $(dir $@) $<
