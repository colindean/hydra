doc.api.geometry.rotateccw = {"api.geometry.rotateccw(point, aroundpoint, ntimes = 1) -> point", "Rotates a point around another point N times."}
function api.geometry.rotateccw(point, aroundpoint, ntimes)
  local p = {x = point.x, y = point.y}
  for i = 1, ntimes or 1 do
    local px = p.x
    p.x = (aroundpoint.x - (p.y - aroundpoint.y))
    p.y = (aroundpoint.y + (px - aroundpoint.x))
  end
  return p
end

doc.api.geometry.rectmidpoint = {"api.geometry.rectmidpoint(r) -> point", "Returns the midpoint of a rect."}
function api.geometry.rectmidpoint(r)
  return {
    x = r.x + r.w * 0.5,
    y = r.y + r.h * 0.5,
  }
end

doc.api.geometry.hypot = {"api.geometry.hypot(point) -> number", "Returns hypotenuse of a line defined from 0,0 to point."}
function api.geometry.hypot(p)
  return math.sqrt(p.x * p.x + p.y * p.y)
end

doc.api.geometry.rect = {"api.geometry.rect(x, y, w, y) -> rect", "Convenience function for creating a rect-table."}
function api.geometry.rect(x, y, w, h)
  return {x = x, y = y, w = w, h = h}
end

doc.api.geometry.point = {"api.geometry.point(x, y) -> point", "Convenience function for creating a point-table."}
function api.geometry.point(x, y)
  return {x = x, y = y}
end

doc.api.geometry.size = {"api.geometry.size(w, h) -> size", "Convenience function for creating a size-table."}
function api.geometry.size(w, h)
  return {w = w, h = h}
end
