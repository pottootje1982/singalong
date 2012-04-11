require 'playlist_api'

function levenshtein(string1, string2)
  if not string1 or not string2 then
    if not string1 and not string2 then return -1 end
    if not string1 or string1 == '' then return string2:len() end
    if not string2 or string2 == '' then return string1:len() end
  end
  string1 = string1:lower()
  string2 = string2:lower()
  local str1, str2, distance = {}, {}, {};
  str1.len, str2.len = string.len(string1), string.len(string2);
  string.gsub(string1, "(.)", function(s) table.insert(str1, s); end);
  string.gsub(string2, "(.)", function(s) table.insert(str2, s); end);
  for i = 0, str1.len do distance[i] = {}; distance[i][0] = i; end
  for i = 0, str2.len do distance[0][i] = i; end
  for i = 1, str1.len do
    for j = 1, str2.len do
      local tmpdist = 1;
      if(str1[i] == str2[j]) then tmpdist = 0; end
      distance[i][j] = math.min(distance[i-1][j] + 1, distance[i][j-1]+1, distance[i-1][j-1] + tmpdist);
    end
  end
  local maxLength = math.max(str1.len, str2.len)
  local minLength = math.min(str1.len, str2.len)
  -- returns normalized Levenshtein distance, whether one string was substring of the other
  return 1-(distance[str1.len][str2.len]/maxLength), maxLength - minLength == distance[str1.len][str2.len];
end

function comparePlaylists(playlist1, playlist2)
  mp3s1 = playlist.gatherMp3Info(playlist1)
  mp3s2 = playlist.gatherMp3Info(playlist2)
  local mp3Strings = {}
  local doubleMp3s = {}
  for index, mp31 in pairs(mp3s1) do
    local found = false
    for _, mp32 in pairs(mp3s2) do
      if levenshtein(mp31.artist, mp32.artist) > 0.9 and
        levenshtein(mp31.title, mp32.title) > 0.9
        then
          table.insert(mp3Strings, mp31.artist .. ' - ' .. mp31.title)
          table.insert(doubleMp3s, index)
          found = true
          break
      end
    end
    if not found then
      print(mp31.artist .. ' - ' .. mp31.title)
    end
  end
  return doubleMp3s, mp3Strings
end

--comparePlaylists('top 2000 zang.m3u', 'bla.m3u')
--print(levenshtein('balifornia','Hotel california'))
