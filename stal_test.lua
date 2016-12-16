local function assert_equal(expected, command)
  local f = io.popen(command)
  assert(f:read('*a') == expected)
end

local function redis(command)
  assert(os.execute("redis-cli " .. command .. " > /dev/null"))
end

local function solve(str)
  return "redis-cli --eval stal.lua , '" .. str .. "'"
end

-- Operations with sets
redis("FLUSHDB")
redis("SADD A 1 2 3")
redis("SADD B 2 3 4")
redis("SADD C 3 4 5")

assert_equal("2\n3\n", solve('["SINTER", "A", "B"]'))
assert_equal("1\n5\n", solve('["SDIFF", ["SUNION", "A", "C"], "B"]'))

-- Verify there's no keyspace pollution
assert_equal("B\nC\nA\n", solve('["KEYS", "*"]'))

-- Operations with sorted sets
redis("FLUSHDB")
redis("ZADD A 1 a 2 b 3 c")
redis("ZADD B 1 b 2 c 3 d")
redis("ZADD C 1 d 2 e 3 f")

assert_equal("b\nc\n", solve('["ZRANGE", ["ZINTER", "2", "A", "B"], "0", "-1"]'))

-- Verify there's no keyspace pollution
assert_equal("B\nC\nA\n", solve('["KEYS", "*"]'))

-- Operations with sorted and unsorted sets
redis("FLUSHDB")
redis("ZADD A 1 a 2 b 3 c")
redis("SADD B b c d")

assert_equal("b\nc\n", solve('["ZRANGE", ["ZINTER", "2", "A", "B"], "0", "-1"]'))

-- Verify there's no keyspace pollution
assert_equal("B\nA\n", solve('["KEYS", "*"]'))
