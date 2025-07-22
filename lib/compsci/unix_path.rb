module CompSci

  # ImmutablePath and MutablePath both mix in this module via include
  # N.B. @ivar references will not work with Data.define, so use self.ivar
  module PathMixin
    include Comparable

    class Error < RuntimeError; end
    class FilenameError < Error; end
    class SlashError < Error; end

    SEP = '/'
    DOT = '.'
    CWD = DOT + SEP

    # must be a String != '.'
    def self.valid_filename!(val)
      if !val.is_a?(String) or val == DOT
        raise(FilenameError, "illegal value: #{val.inspect}")
      end
      val
    end

    # ImmutablePath and MutablePath both mix in this module via extend
    # This ensures self.new refers to the base class and not the mixin (module)
    # This extension happens automatically via an included hook on PathMixin
    # PathMixin#slash calls FactoryMethods#parse
    module FactoryMethods
      # return a new Path from a string
      def parse(path_str)
        abs = path_str.start_with? SEP
        if abs
          path_str = path_str[1..-1]
        elsif path_str.start_with? CWD
          path_str = path_str[2..-1]
        end
        subdirs = path_str.split SEP
        filename = path_str.end_with?(SEP) ? '' : (subdirs.pop || '')
        self.new(abs: abs, subdirs: subdirs, filename: filename)
      end

      # Create absolute Path from Path or string
      def absolute(path)
        p = parse(path.to_s)
        self.new(abs: true, subdirs: p.subdirs, filename: p.filename)
      end

      # Create directory Path from Path or string
      def directory(path)
        p = parse(path.to_s)
        subdirs = p.subdirs.dup
        subdirs << p.filename unless p.filename.empty?
        self.new(abs: p.abs, subdirs: subdirs, filename: '')
      end
    end

    # the base class automatically gets FactoryMethods at the "class layer"
    def self.included(base) = base.extend(FactoryMethods)

    # a pseudo-initialize method to be called by the base class #initialize
    # returns a hash
    def handle_init(abs: false, subdirs: [], filename: '')
      PathMixin.valid_filename!(filename)
      { abs: abs,
        subdirs: subdirs.reject { |dir| dir == DOT },
        filename: filename }
    end

    def sigil = self.abs ? SEP : CWD
    def path
      self.subdirs.empty? ? self.filename :
        (self.subdirs + [self.filename]).join(SEP)
    end
    def to_s = self.sigil + self.path

    def abs? = self.abs
    def dir? = self.filename.empty?

    def ==(other)
      other.is_a?(self.class) and
        self.abs == other.abs and
        self.subdirs == other.subdirs and
        self.filename == other.filename
    end

    # Comparable: lexicographic -- relpaths before abspaths
    def <=>(other)
      self.to_s <=> other.to_s
    end

    # Enable path building with slash method
    # !!! base class must implement Klass#slash_path !!!
    def slash(other)
      raise(SlashError, "can only slash on dirs") unless self.dir?
      case other
      when String
        other.empty? ? self : self.slash_path(self.class.parse(other))
      else
        raise("unexpected: #{other.inspect}")
      end
    end
    alias_method :/, :slash

    # whatever the filename is, up to the last dot; possibly empty: e.g. .bashrc
    def basename
      unless self.filename.empty?
        idx = self.filename.rindex(DOT)
        idx.nil? ? self.filename : self.filename[0...idx]
      end
    end

    # include the dot; empty if there is no extension: e.g. /bin/bash
    def extension
      unless self.filename.empty?
        idx = self.filename.rindex(DOT)
        idx.nil? ? "" : self.filename[idx..-1]
      end
    end

    # ocean boiler; don't use this
    def reconstruct_filename = [self.basename, self.extension].join
  end

  class ImmutablePath < Data.define(:abs, :subdirs, :filename)
    include PathMixin # also extends PathMixin::FactoryMethods

    # rely on PathMixin#handle_init for initialize
    def initialize(**kwargs)
      super(**self.handle_init(**kwargs))
    end

    # rely on Data#with for efficient copying
    def slash_path(other)
      raise(SlashError, "can't slash an absolute path") if other.abs?
      self.with(subdirs: subdirs + other.subdirs, filename: other.filename)
    end
  end

  class MutablePath
    include PathMixin # also extends PathMixin::FactoryMethods

    attr_reader :abs, :subdirs, :filename

    # rely on PathMixin#handle_init for initialize
    def initialize(**kwargs)
      @abs, @subdirs, @filename =
        self.handle_init(**kwargs).values_at(:abs, :subdirs, :filename)
    end

    # enforce valid mutable filenames
    def filename=(val)
      @filename = PathMixin.valid_filename!(val)
    end

    # simple update
    def slash_path(other)
      raise(SlashError, "can't slash an absolute path") if other.abs?
      @subdirs += other.subdirs
      @filename = other.filename
      self
    end
  end

  # UnixPath = ImmutablePath
  UnixPath = MutablePath
end
