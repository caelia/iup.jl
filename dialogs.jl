function message(title::AbstractString, text::AbstractString)
    ccall((:IupMessage, "libiup"), Void,
          (AbstractString, AbstractString), title, text)
end
