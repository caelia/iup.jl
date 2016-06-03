function iup_app(f::Function)
    ccall((:IupOpen, "libiup"), Int32, (Int32, Array{AbstractString}), 0, [])
    f()
    ccall((:IupClose, "libiup"), Void, ())
end

function say_hello()
    iup_app(
        function()
            ccall((:IupMessage, "libiup"), Void, (AbstractString, AbstractString), "Hello World 1", "Hello, World, from IUP/Julia!")
        end
    )
end
