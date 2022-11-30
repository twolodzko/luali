require "reader"

do
    local reader = Reader:fromstring("hello")
    for expected in string.gmatch("hello", ".") do
        assert(reader:char() == expected)
        reader:next()
    end
    assert(reader:char() == nil)
end

do
    local reader = Reader:fromfile("test/reader_test.lua")
    for expected in string.gmatch("require \"reader\"\n\n", ".") do
        assert(reader:char() == expected)
        reader:next()
    end
end
