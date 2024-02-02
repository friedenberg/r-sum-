
local columns = PANDOC_WRITER_OPTIONS.columns

function Pandoc(doc)
  local blocks = pandoc.List()
  blocks:insert(HorizontalRule())
  blocks:extend(doc.blocks)
  doc.blocks = blocks
  doc.meta.trailer = Trailer()
  return doc
end

function Header(el)
  return pandoc.List()
end

function CenterRaw(str)
  local padding = string.rep(" ", math.floor((columns - utf8.len(str)) / 2))
  return padding .. str .. padding
end

function Center(str)
  return pandoc.RawInline("markdown", CenterRaw())
end

function Trailer()
  return pandoc.RawBlock(
    "markdown",
    table.concat(
      {
        HorizontalRuleRaw(),
        "",
        CenterRaw("last updated " .. "$DATE$"),
        CenterRaw("$VERSION$")
      },
      "\n"
    )
  )
end

function HorizontalRuleRaw()
  return string.rep("*", columns)
end

function HorizontalRule()
  return pandoc.RawInline("markdown", HorizontalRuleRaw())
end

function Span(s)
  return s.content
end

function RawBlock(s)
  return pandoc.List()
end

function TextWidthOfList(list)
  local width = 0

  for i,x in pairs(list) do
    if x.t == "Str" then
      width = width + utf8.len(x.text)
    elseif x.t == "Space" then
      width = width + 1
    elseif x.t == "List" then
      width = width + TextWidthOfList(x)
    elseif type(x) == "table" then
      width = width + TextWidthOfList(x)
    else
      -- error("unknown type")
    end
  end

  return width
end

function Table(t)
  if #t.bodies > 1 then
    return t
  end

  local rows = t.bodies[1].body

  if #rows > 1 then
    return t
  end

  local row = rows[1]
  local cells = row.cells
  local buffer = pandoc.List()

  local row_width = 0

  local each_cell = function(i, cell)
    local contents = cell.contents

    if #contents ~= 1 then
      return
    end

    local content = contents[1]

    local local_buffer = pandoc.List()

    local_buffer:extend(content.content)

    if i == 1 then
      local_buffer:insert(pandoc.Str(","))
      row_width = row_width + 1
    end

    for i,x in pairs(local_buffer) do
      if x.t == "Str" then
        row_width = row_width + utf8.len(x.text)
      elseif x.t == "Space" then
        row_width = row_width + 1
      end
    end

    buffer:insert(local_buffer)
  end

  for i, cell in pairs(cells) do
    each_cell(i, cell)
  end

  local adjusted_row_width = row_width - (#buffer - 1)

  table.insert(
    buffer,
    #buffer,
    {pandoc.Str(string.rep(".", columns - adjusted_row_width))}
  )

  local output = {}

  for i, x in pairs(buffer) do
    if i > 1 then
      table.insert(output, " ")
    end

    for j, y in pairs(x) do
      if y.t == "Space" then
        table.insert(output, " ")
      else
        table.insert(output, y.text)
      end
    end
  end

  return pandoc.RawBlock("markdown", table.concat(output, ""))
end
