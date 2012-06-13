require 'class'
class 'list'

RED = '255 150 150'
YELLOW = '255 255 150'
GREEN = '150 255 150'
WHITE = '255 255 255'

function rowColStr(prop, row, col)
  return string.format('%s%d:%d', prop, row, col)
end

function list:list(params)
  self.c = iup.matrix(params)

  self.c.click_cb = function(widget, line, col, status)
    if iup.isdouble(status) then
      self:call('onDouble', line)
    elseif iup.isbutton1(status) and line > 0 then -- we shouldn't be able to drag column headers
      self.addToSel = iup.iscontrol(status)
      local isshift = iup.isshift(status)
      if (not self.addToSel and not isshift) or not widget.selection then
        self:initSelection()
      end
      self.pressed = true
      if isshift then
        self:modifySelection(nil, line)
      else
        self:modifySelection(line)
      end
      self.beginSel = line
      self.itemToDrag = line
    end
  end

  self.c.mousemove_cb = function(widget, line, col)
    self.mouseIsAtRow = line
    if not widget.disableDragging and line > 0 and col > 0 then
      self.dragging = self.pressed
      if self.dragging and self.itemToDrag and self.itemToDrag ~= line then
        self:swapItems('', line, self.itemToDrag)
        self:swapItems('bgcolor', line, self.itemToDrag)
        self:modifySelection(line, nil, true)
        self.itemToDrag = line
      end
    end
  end

  -- status = "SC123 A45"
  -- space is unknown S = shift, C = control, A = alt
  self.c.release_cb = function(widget, line, col, status)
    if iup.isbutton3(status) then
      self:call('onPopup')
    elseif iup.isbutton1(status) then -- left button is pressed
      self.addToSel = false
      if self.dragging then
        self:call('onDraggingStopped', self.beginSel, line)
      end
      self.dragging = false
      self.pressed = false
    end
  end

  local function isKeyOrWithShift(key, id)
    return iup['K_' .. id] == key or iup['K_s' .. id] == key
  end

  self.c.k_any = function(widget, key, press)
    if (key == iup.K_Menu) then
      self:call('onPopup')
    elseif (key == iup.K_ca or key == iup.K_cA) then
      -- Selects everything
      self:modifySelection(1, widget.numlin)
    elseif key >= iup.K_A and key <= iup.K_z then
      -- The following code will enable skipping to the row
      -- of which the focused column matches with the pressed letter (a-z)
      local col = self.c.focus_cell:match('(:%d+)')
      local index
      local found = false
      for i = 0, self.c.numlin-1 do
        index = math.mod(i + self.lastSel, self.c.numlin) + 1
        local cellValue = self.c[index .. col]:lower()
        local keyVal = string.char(key):lower()
        if cellValue:match('^' .. keyVal) then
          found = true
          break
        end
      end
      if found then
        self:modifySelection(index)
        self.c.focus_cell = index .. col
      end
    else
      return self:call('k_any', key, press)
    end
    return iup.IGNORE
  end

  self.droppedFiles = {}
  self.c.dropfiles_cb = function(widget, file, num)
    table.insert(self.droppedFiles, file)
    if num == 0 then
      self:call('dropFiles', self.droppedFiles, self.mouseIsAtRow)
      self.droppedFiles = {}
    end
  end

  -- Used to modify selection when navigating with keys like k_up k_down, k_pgdn & p_pgup
  self.c.enteritem_cb = function(widget, line, col)
    local shift = iup.GetGlobal('MODKEYSTATE'):match('S')
    local control = iup.GetGlobal('MODKEYSTATE'):match('C')
    if not control and line ~= self.lastFocus then
      local newSel = tonumber(self.c.focus_cell:match('(%d+):'))
      if shift then
        self:modifySelection(nil, newSel)
      else
        self:modifySelection(newSel)
      end
    end
    self.lastFocus = line
    return iup.DEFAULT
  end
end

function list:call(func, ...)
  if self[func] then return self[func](self, ...) end
end

function list:initSelection()
  self.c.selection = "L" .. string.rep('0', self.c.numlin)
end

function list:swapItems(prop, line1, line2)
  local widget = self.c
  local column = 1
  while widget[rowColStr(prop, line1, column)] do
    local temp = widget[rowColStr(prop, line1, column)]
    widget[rowColStr(prop, line1, column)] = widget[rowColStr(prop, line2, column)]
    widget[rowColStr(prop, line2, column)] = temp
    column = column + 1
  end
end

function list:modifySelection(startSelection, endSelection, dontCallback)
  if not self.lastFocus then self.lastFocus = startSelection end
  if startSelection then
    self.lastSel = endSelection or startSelection or 1 -- The 1 is necessary in case you click on column, then startSelection & endSelection will be nil
  end
  endSelection = endSelection or startSelection or 1
  local startSel, endSel =
    math.min(tonumber(startSelection or self.lastSel),tonumber(endSelection)),
    math.max(tonumber(startSelection or self.lastSel),tonumber(endSelection))

  local pattern = '(L' .. string.rep('%d', startSel - 1) .. ')' .. string.rep('%d', endSel - startSel + 1)
  if not self.c.selection or self.dragging or (not self.addToSel) then
    self:initSelection()
  end

  local replacement = '%1'
  if self.addToSel then
    for i, v in ipairs({string.byte(self.c.selection, startSel+1, endSel+1)}) do
      replacement = replacement .. (v==48 and '1' or '0')
    end
  else
    replacement = replacement .. string.rep('1', endSel - startSel + 1)
  end

  self.c.marked = string.gsub(self.c.selection, pattern, replacement)

  self.c.selection = self.c.marked

  if not dontCallback then
    self:call('onSelectionChanged', self.lastSel)
  end
end

function list:getSelection(tab)
  local index = 0
  local res = {}
  assert(tab, "Give table as argument to select from!")
  if self.c.marked then
    repeat
      index = self.c.marked:find('1', index + 1)
      if index then
        table.insert(res, tab[index-1])
      end
    until not index
    return tab[tonumber(self.lastSel)], res
  end
end

