-- Links für den Druck: externe URLs als Fußnote, interne Links als Kapitelverweis.
function Link(el)
  local url = el.target
  local text = pandoc.utils.stringify(el.content)
  if url:match("^https?://") then
    local u = url:gsub("([#%%])", "\\%1")  -- \url im Fußnoten-Argument
    if url:gsub("^https?://", ""):gsub("/$", "") == text then
      return pandoc.RawInline("latex", "\\url{" .. u .. "}")
    end
    local note = pandoc.Note(pandoc.Plain(pandoc.RawInline("latex", "\\url{" .. u .. "}")))
    return el.content .. {note}  -- ponytail: no dedup of repeated URLs, add if a chapter repeats links
  end
  if url:match("^#") then return el.content end  -- Anker im selben Kapitel
  local label = url:gsub("^%.%./", ""):gsub("%.html.*$", ""):gsub("_", "-")
  return el.content .. {pandoc.RawInline("latex", "~(Kapitel~\\ref{ch:" .. label .. "})")}
end

-- Inline-Code als \texttt mit Umbruchstellen nach / . _ (lstinline kann nicht umbrechen).
local esc = { ["\\"]="\\textbackslash{}", ["{"]="\\{", ["}"]="\\}", ["$"]="\\$", ["&"]="\\&",
  ["#"]="\\#", ["%"]="\\%", ["~"]="\\textasciitilde{}", ["^"]="\\textasciicircum{}", ["_"]="\\_", ['"']="\\textquotedbl{}" }
function Code(el)
  local s = el.text:gsub('[\\{}$&#%%~^_"]', esc):gsub("([/.]+)", "%1\\allowbreak{}"):gsub("\\_", "\\_\\allowbreak{}")
  return pandoc.RawInline("latex", "\\texttt{" .. s .. "}")
end

-- Code ohne Sprache trotzdem im grauen Kasten setzen
function CodeBlock(el)
  if #el.classes == 0 then el.classes = {"default"} return el end
end

-- Lua-Code einheitlich mit StyLua formatieren. Fragmente aus Tabellenfeldern
-- (z. B. `paramtype = "light",`) werden dafür kurz in eine Tabelle gepackt.
local function stylua(code)
  local ok, out = pcall(pandoc.pipe, "sh", {"-c", "stylua --config-path stylua.toml - 2>/dev/null"}, code)
  return ok and out or nil
end

local function format_lua(code)
  local out = stylua(code)
  if out then return (out:gsub("\n$", "")) end
  out = stylua("local _ = {\n" .. code .. "\n}\n")
  if not out then return nil end
  out = out:gsub("^local _ = {\n", ""):gsub("\n}\n$", "")
  return (out:gsub("\n    ", "\n"):gsub("^    ", ""))
end

local function format_block(el)
  if el.classes[1] ~= "lua" then return nil end
  if el.classes:includes("keep") then return el end  -- bewusst von Hand gesetzt
  local out = format_lua(el.text)
  if out then el.text = out
  else io.stderr:write("stylua: nicht formatierbar:\n" .. el.text .. "\n\n") end
  return el
end

local plain_block = CodeBlock
function CodeBlock(el)
  return format_block(el) or plain_block(el)
end

-- Hinweiskästen: ::: {.warning title="..."} bzw. {.tip} → Umgebung "hinweis"
function Div(el)
  local kind = el.classes[1]
  if kind ~= "warning" and kind ~= "tip" then return nil end
  local title = el.attributes.title or (kind == "warning" and "Achtung" or "Tipp")
  title = title:gsub('[\\{}$&#%%~^_]', esc)
  local blocks = pandoc.Blocks({pandoc.RawBlock("latex", "\\begin{hinweis}{" .. title .. "}")})
  blocks:extend(el.content)
  blocks:insert(pandoc.RawBlock("latex", "\\end{hinweis}"))
  return blocks
end

-- Stichwortverzeichnis: erste Nennung je Kapitel im Fließtext (keine Überschriften,
-- Codeblöcke, Tabellen, Bildunterschriften) mit \index versehen.
local terms = {
  ["Abbautyp"] = "abbautyp abbautypen",
  ["ABM"] = "abm abms",
  ["Abhängigkeit"] = "abhängigkeit abhängigkeiten",
  ["Abnutzung"] = "abnutzung",
  ["Alias"] = "alias aliase",
  ["Benutzerdatenverzeichnis"] = "benutzerdatenverzeichnis",
  ["Biom"] = "biom biome biomen bioms",
  ["Busted"] = "busted",
  ["Callback"] = "callback callbacks",
  ["Chatbefehl"] = "chatbefehl chatbefehle chatbefehlen chatbefehls",
  ["Content-ID"] = "content-id content-ids",
  ["ContentDB"] = "contentdb",
  ["Craftitem"] = "craftitem craftitems",
  ["Craftingrezept"] = "craftingrezept craftingrezepte craftingrezepten craftingrezepts",
  ["Dekoration"] = "dekoration dekorationen",
  ["Entity"] = "entity entities",
  ["Formspec"] = "formspec formspecs",
  ["Gruppe"] = "gruppe gruppen",
  ["Gültigkeitsbereich"] = "gültigkeitsbereich",
  ["HUD"] = "hud",
  ["Inventar"] = "inventar inventare inventars",
  ["ItemStack"] = "itemstack itemstacks",
  ["Kartengenerierung"] = "kartengenerierung kartengenerator mapgen",
  ["Lebenspunkte"] = "lebenspunkte",
  ["Lizenz"] = "lizenz lizenzen",
  ["Luacheck"] = "luacheck",
  ["LVM"] = "lvm lvms",
  ["Mapblock"] = "mapblock mapblocks mapblöcke mapblöcken",
  ["Mesh"] = "mesh meshes",
  ["Metadaten"] = "metadaten node-metadaten",
  ["Mocking"] = "mocking",
  ["Mod-Paket"] = "mod-paket mod-pakete mod-paketen modpack modpacks",
  ["Mod-Speicher"] = "mod-speicher",
  ["Model-View-Controller"] = "mvc model-view-controller",
  ["Namensraum"] = "namensraum",
  ["Node-Timer"] = "node-timer node-timern node-timers",
  ["Nodebox"] = "nodebox nodeboxen",
  ["ObjectRef"] = "objectref",
  ["Privileg"] = "privileg privilegien",
  ["Schadensgruppe"] = "schadensgruppe schadensgruppen",
  ["Textdomain"] = "textdomain",
  ["Textur"] = "textur texturen",
  ["Übersetzung"] = "übersetzung übersetzungen übersetzungsdateien",
  ["Unit-Test"] = "unit-test unit-tests",
  ["Voronoi-Diagramm"] = "voronoi-diagramm",
  ["VoxelArea"] = "voxelarea",
  ["Zeichnungstyp"] = "zeichnungstyp zeichnungstypen drawtype",
  -- Dateien, als Inline-Code im Text
  ["mod.conf"] = "mod.conf", ["game.conf"] = "game.conf", ["modpack.conf"] = "modpack.conf",
  ["init.lua"] = "init.lua", ["settingtypes.txt"] = "settingtypes.txt", ["dofile"] = "dofile",
}
local lookup = {}
for entry, variants in pairs(terms) do
  for v in variants:gmatch("%S+") do lookup[v] = entry end
end

local function sortkey(s)
  return (s:lower():gsub("ä", "a"):gsub("ö", "o"):gsub("ü", "u"):gsub("Ä", "a"):gsub("Ö", "o"):gsub("Ü", "u"):gsub("ß", "ss"))
end
local function tt(s) return "\\texttt{" .. s:gsub("_", "\\_\\allowbreak{}"):gsub("%.", ".\\allowbreak{}") .. "}" end

local function index_for(word, is_code)
  if is_code then
    local fn = word:match("^(core%.[%w_%.]+[%w_])")
    if fn then return "core@\\texttt{core}!" .. fn:sub(6) .. "@" .. tt(fn) end
    local cb = word:match("^((on_[%w_]+))") or word:match("^(after_[%w_]+)")
    if cb then return "callback@Callback!" .. cb .. "@" .. tt(cb) end
  end
  local entry = lookup[word:lower()]
  if not entry then return nil end
  local shown = entry:match("%.%w+$") or ({dofile=1, ItemStack=1, ObjectRef=1, VoxelArea=1})[entry] -- Dateien, Klassen
  return sortkey(entry) .. "@" .. (shown and tt(entry) or entry)
end

local function add_index(doc)
  local seen = {}
  local function mark(word, is_code)
    local key = index_for(word, is_code)
    if not key or seen[key] then return nil end
    seen[key] = true
    return pandoc.RawInline("latex", "\\index{" .. key .. "}")
  end
  local inl = {
    Str = function(el)
      local w = el.text:gsub("^[%p„“»«–]+", ""):gsub("[%p„“»«–]+$", "")
      local idx = mark(w, false)
      if idx then return {el, idx} end
    end,
    Code = function(el)
      local idx = mark(el.text, true)
      if idx then return {el, idx} end
    end,
  }
  local function blocks(bs)
    for _, b in ipairs(bs) do
      local t = b.t
      if t == "Para" or t == "Plain" then b.content = b.content:walk(inl)
      elseif t == "BulletList" or t == "OrderedList" then for _, item in ipairs(b.content) do blocks(item) end
      elseif t == "Div" or t == "BlockQuote" then blocks(b.content)
      end
    end
  end
  blocks(doc.blocks)
  return doc
end

return {
  { Pandoc = add_index },
  { Link = Link, Code = Code, CodeBlock = CodeBlock, Div = Div },
}
