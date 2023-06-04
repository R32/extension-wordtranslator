#
OUT       := build
SRC       := src

HAXEFLAGS := -cp $(SRC)\
	-dce full\
	-D js-es=6\
	-D analyzer-optimize\
	-D no-traces\
	-lib chrome-extension-v3\
	-lib no-vdom\
	--macro exclude\(\'haxe.iterators.ArrayIterator\'\)

BG        := $(OUT)/js/background.js
HOOK      := $(OUT)/js/hook-bingtranslator.js
CONTENT   := $(OUT)/js/content-script.js
# popup.html
POPUPJS   := $(OUT)/js/popup.js
POPUPCSS  := $(OUT)/style/popup.css

# haxe
COMMON    := Data Global Macros ESXTools import
COMMON    := $(COMMON:%=$(SRC)/%.hx)

all: bg content hook popup
bg: $(BG)
hook: $(HOOK)
popup: $(POPUPJS) $(POPUPCSS)
content: $(CONTENT)
clean:
	rm -rf $(BG) $(HOOK) $(CONTENT) $(POPUPJS) $(POPUPCSS)

.PHONY: all bg hook content clean

$(BG): $(SRC)/Background.hx $(COMMON)
	haxe $(HAXEFLAGS) -D js-global=globalThis --js $@ --main Background --macro exclude\(\'HookBingTranslator\'\)

$(HOOK): $(SRC)/HookBingTranslator.hx $(COMMON)
	haxe $(HAXEFLAGS) -D js-global=window --js $@ --main HookBingTranslator -D js-classic

$(CONTENT): $(SRC)/ContentScript.hx $(COMMON)
	haxe $(HAXEFLAGS) -D js-global=window --js $@ --main ContentScript

$(POPUPJS): $(SRC)/Popup.hx $(COMMON)
	haxe $(HAXEFLAGS) -D js-global=window --js $@ --main Popup

$(POPUPCSS): $(POPUPCSS:%.css=%.hss)
	hss $<
