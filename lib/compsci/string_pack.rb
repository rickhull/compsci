module StringPack
  refine String do
    def pack(directive, **kwargs, &blk)
      [self].pack(directive, **kwargs, &blk)
    end
  end
end
