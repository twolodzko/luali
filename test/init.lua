package.path = package.path .. ';../?.lua'

function assert_equal(o1, o2)
    assert(o1 == o2, string.format("%s and %s are not equal", o1, o2))
end

function assert_not_equal(o1, o2)
    assert(o1 ~= o2, string.format("%s and %s are equal", o1, o2))
end
