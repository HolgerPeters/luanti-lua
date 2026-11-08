KAPITEL := $(patsubst kapitel/%.md,build/%.tex,$(wildcard kapitel/*.md))
PANDOC := pandoc -f markdown -t latex --highlight-style=luanti.theme

buch.pdf: buch.tex index.ist build/highlight.tex $(KAPITEL)
	latexmk -lualatex -interaction=nonstopmode -halt-on-error buch.tex

build/%.tex: kapitel/%.md links.lua kapitel.tex luanti.theme
	@mkdir -p build
	$(PANDOC) $< --top-level-division=chapter --lua-filter=links.lua --template=kapitel.tex -o $@

# Farbmakros für die Code-Hervorhebung aus dem Theme erzeugen
build/highlight.tex: luanti.theme
	@mkdir -p build
	printf '```lua\nx\n```\n' | $(PANDOC) -s | sed -n '/^\\usepackage{color}/,/WarningTok/p' > $@

clean:
	latexmk -C buch.tex; rm -rf build
