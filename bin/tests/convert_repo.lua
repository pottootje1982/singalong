require 'load_config'()

function convertRepo()
  os.iterateDir(LYRICS_DIR, nil, function(file)
    local content = os.read(file)
    content = content:gsub([[\\%s*]], '\n')
    os.writeTo(file, content)
  end)
end
