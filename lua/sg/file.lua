local Job = require "plenary.job"

local once = require("sg.utils").once
local src_cli = vim.fn.exepath "src"

local get_access_token = once(function()
  return os.getenv "SRC_ACCESS_TOKEN"
end)

local get_endpoint = once(function()
  return os.getenv "SRC_ENDPOINT"
end)

local file = {}

file.read = function(remote, hash, path)
  local query = string.format("repo:^%s$", remote)
  if hash then
    query = query .. string.format("@%s", hash)
  end
  query = query .. string.format(" file:^%s$", path)

  vim.schedule(function()
    print(query)
  end)

  local j = Job:new {
    src_cli,
    "search",
    "-json",
    query,
    env = {
      SRC_ACCESS_TOKEN = get_access_token(),
      SRC_ENDPOINT = get_endpoint(),
    },
  }

  local output = vim.fn.json_decode((j:sync()))
  if not output.Results then
    error("no results: " .. vim.inspect(output))
  end

  local first = output.Results[1]
  if not first then
    error("no first: " .. vim.inspect(output))
  end

  if not first.file then
    error("no file: " .. vim.inspect(first))
  end

  return first.file.content
end

return file
