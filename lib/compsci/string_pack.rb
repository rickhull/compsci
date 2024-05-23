# wrap the string in an array to call Array#pack
module StringPack
  refine String do
    def pack(directive, **kwargs, &blk)
      [self].pack(directive, **kwargs, &blk)
    end
  end
end
