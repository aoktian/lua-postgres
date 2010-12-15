package.cpath = "./?.so"
package.path = string.format("test/?.lua;%s", package.path)

require "postgres"

local config = require "test_config"
local conn, err = postgres.connection(config.connection_string)
if err then error(err) end

local function emit(query)
  local result, err = conn:execute(query)
  if not result then error(err) end
  return result
end

emit(config.drop_table)
emit(config.create_table)
emit "insert into people (name) values ('Joe Schmoe')"
emit "insert into people (name) values ('John Doe')"
emit "insert into people (name) values ('Jim Beam')"

for i=1,1000 do
  local conn = postgres.connection(config.connection_string)
  local result, err = conn:execute("SELECT * FROM people WHERE id < $1", {1000})
  local row = result:fetch()
  local row = result:fetch_assoc()
  conn:close()
end