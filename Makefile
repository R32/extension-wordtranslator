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
HOOK1     := $(OUT)/js/hook-bingaudiospeed.js
HOOK2     := $(OUT)/js/hook-bingtranslator.js
CONTENT   := $(OUT)/js/content-script.js
# popup.html
POPUPJS   := $(OUT)/js/popup.js
POPUPCSS  := $(OUT)/style/popup.css

# haxe
COMMON    := Data Global Macros ESXTools import
COMMON    := $(COMMON:%=$(SRC)/%.hx)

all: bg content hook popup
bg: $(BG)
hook: $(HOOK1) $(HOOK2)
popup: $(POPUPJS) $(POPUPCSS)
content: $(CONTENT)
hss: $(POPUPCSS)

clean:
	rm -rf $(BG) $(HOOK) $(CONTENT) $(POPUPJS) $(POPUPCSS)

.PHONY: all bg hook popup content hss clean

$(BG): $(SRC)/Background.hx $(COMMON)
	haxe $(HAXEFLAGS) -D js-global=globalThis --js $@ --main Background

$(HOOK1): $(SRC)/HookBingAudioSpeed.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main HookBingAudioSpeed --macro maux.ModuleLevel.strip\([\'HookBingAudioSpeed\']\)

$(HOOK2): $(SRC)/HookBingTranslator.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main HookBingTranslator --macro maux.ModuleLevel.strip\([\'HookBingTranslator\']\)

$(CONTENT): $(SRC)/ContentScript.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main ContentScript

$(POPUPJS): $(SRC)/Popup.hx $(COMMON)
	haxe $(HAXEFLAGS) --js $@ --main Popup --macro maux.ModuleLevel.strip\([\'Popup\']\)

$(POPUPCSS): hss/popup.hss
	hss -output $(dir $@) $<
