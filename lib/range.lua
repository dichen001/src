-- # range : simple discretiation
-- View the [source on-line](../range.lua).
require "show"
local the=require "config"
local num=require "num"
local some=require "sample"
----------------------------------
-- Initialize a table for range info
local function create() return {
  _all= some.create(),
  n  = 0,
  hi = -2^63,
  lo =  2^63,
  span = 2^64} end
----------------------------------
-- Update range  _i_  with
-- some numuerc _x_ found from within
-- _one_.
local function update(i,one, x)
  if x ~= the.ignore then
    some.update(i._all, one)
    i.n = i.n + 1
    if x > i.hi then i.hi = x  end
    if x < i.lo then i.lo = x  end
    i.span = i.hi - i.lo
    return x end  end
----------------------------------
-- Update range manager _i_ with
-- a new range _i.now_. Push that
-- range onto the list of all ranges
-- _i.ranges_.
local function nextRange(i) 
  i.now  = create()
  i.ranges[#i.ranges+1] = i.now end
----------------------------------
-- Initialize a range maneger,
local function rangeManager(lst, x)  
  local _ = { 
    x     = x,
    cohen = the.chop.cohen,
    m     = the.chop.m,
    size  = #lst,
    ranges= {} -- list of all known ranges 
  }
  -- Breaks holding under _enough_ are ignored.
  _.enough = _.size^_.m
  nextRange(_)
  _.num = num.updates(lst, _.x)
  _.hi  = _.num.hi
  -- Breaks smaller than _epsilon_ are ignored.
  _.epsilon= _.num.sd * _.cohen
  return _ end
----------------------------------
-- Return a function that 
-- 
-- - Sorts a _lst_ of
--   items according to the values found by
--   the function _x_.
-- - Then divides that sort into _ranges_
--   of size of at least _enough_ which
--   break the _lst_ into items of at least
--   _epsilon_ in size.
return function (lst, x,       last)
  x= x or function (z) return z end -- _x_ defaults to the identity
  table.sort(lst, function (z1,z2) 
                    local one,two=x(z1),x(z2)
                    return one ~=the.ignore and 
                           two ~=the.ignore and 
                           one < two end )
  local i= rangeManager(lst, x)
  for j,one in pairs(lst) do
    local x1 = x(one)
    if x1 ~= the.ignore then
      update(i.now, one, x1)
      if j > 1 and
         x1 > last and
         i.now.n       > i.enough  and
         i.now.span    > i.epsilon and
         i.num.n - j   > i.enough  and
         i.num.hi - x1 > i.epsilon 
      then nextRange(i) end 
      last = x1  end end
  return i.ranges end
