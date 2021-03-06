doc.api.textgrid.textgrids = {"api.textgrid.textgrids = {}", "All currently open textgrid windows; do not mutate this at all."}
api.textgrid.textgrids = {}
api.textgrid.textgrids.n = 0

doc.api.textgrid.open = {"api.textgrid.open() -> textgrid", "Opens a new textgrid window."}
function api.textgrid.open()
  local tg = api.textgrid._open()

  local id = api.textgrid.textgrids.n + 1
  tg.__id = id

  api.textgrid.textgrids[id] = tg
  api.textgrid.textgrids.n = id

  return tg
end

doc.api.textgrid.close = {"api.textgrid:close()", "Closes the given textgrid window."}
function api.textgrid:close()
  api.textgrid.textgrids[self.__id] = nil
  return self:_close()
end

doc.api.textgrid.protect = {"api.textgrid:protect()", "Prevents the textgrid from closing when your config is reloaded."}
function api.textgrid:protect()
  api.textgrid.textgrids[self.__id] = nil
  self.__id = nil
end

doc.api.textgrid.closeall = {"api.textgrid.closeall()", "Closes all non-protected textgrids; called automatically when user config is reloaded."}
function api.textgrid.closeall()
  for i, tg in pairs(api.textgrid.textgrids) do
    if tg and i ~= "n" then tg:close() end
  end
  api.textgrid.textgrids.n = 0
end
