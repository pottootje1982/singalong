local allSearchSites

function saveSearchSites()
  table.saveToFileText(F(LOCALAPPDATADIR, 'search_sites.lua'), allSearchSites)
end

local function loadSearchSites()
  if not os.exists(F(LOCALAPPDATADIR, 'search_sites.lua')) then
    allSearchSites = require 'search_sites'
  else
    allSearchSites = dofile(F(LOCALAPPDATADIR, 'search_sites.lua'))
  end
  _G.search_sites = {}

  for i, site in ipairs(allSearchSites) do
    if not site.disable then
      table.insert(search_sites, site)
    end
  end
end

loadSearchSites()

