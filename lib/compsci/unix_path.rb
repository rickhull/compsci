module CompSci

  # Overview
  # ===
  #
  # This is a simplification of common Unix paths, as used in Linux, OS X, etc.
  # It is intended to cover 99.9% of the "good use cases" and "best practices"
  #   for path and filename conventions on Unix filesystems.
  #
  # Some primary distinctions:
  #   1. Absolute vs Relative paths
  #   2. File vs Directory
  #
  # Absolute paths are indicated with a leading slash (/)
  #   e.g. /etc/passwd or /home/user/.emacs
  #
  # Relative paths are primarily indicated with a leading dot-slash (./)
  #   or they may omit the leading ./ for brevity.
  #   e.g. ./a.out or path/to/file.txt

  # Directories and Files
  # ===
  #
  # In string form, directories are indicated with a trailing slash (/).
  # With no trailing slash, the last segment of a path is treated as a filename.
  #
  # Internally, there is a @file string, and if it is empty, this has
  #   semantic meaning: the UnixPath is a directory.

  # Basename and Extension
  # ===
  #
  # For nonempty @file, it may be further broken down into basename
  #   and extension, with an overly simple rule:
  #
  #                    Look for the last dot.
  #
  # Everything up to the last dot is basename.  Possibly the entire filename.
  # Possibly empty.
  #
  # Everything after the last dot is extension, including the last dot.
  # Possibly the entire filename. Possibly empty.
  #
  # Concatenating basename and extension will always perfectly reconstruct
  #   the filename.
  #
  # If @file is empty, basename and extension are nil.

  # Internal Representation
  # ===
  #
  #   * abs: boolean indicating abspath vs relpath
  #   * dirs: array of strings, like %w[home user docs]
  #   * file: string, possibly empty

  # Strings
  # ===
  #
  # Consume a string path with UnixPath.parse, creating a UnixPath instance.
  # Emit a string with UnixPath#to_s.
  # Relative paths are emitted with leading dot-slash (./)

  # Creation
  # ===
  #
  # Combine path components with `slash`, aliased to /, yielding a UnixPath
  #   * UnixPath.parse('/etc') / 'systemd' / 'system'
  #   * UnixPath.parse('/etc').slash('passwd')
  #   * UnixPath.parse('./') / 'a.out'
  #
  # Or just parse the full string:
  #   * UnixPath.parse('/etc/systemd/system')
  #
  # Or construct by hand:
  #   * UnixPath.new(abs: true, dirs: %w[etc systemd system])

  # Implementation Details
  # ===
  #
  # Most of UnixPath is implemented via PathMixin and its FactoryMethods
  # These modules are mixed in to base classes ImmutablePath and MutablePath.
  # ImmutablePath is based on Ruby's Data.define, using Data.with for efficient
  #   copies.
  # MutablePath may be more efficient and has a simple implementation.
  # UnixPath is itself a constant, currently referring to ImmutablePath.
  # This pattern of assigning a constant can allow you to create your own Path
  #   in your own context.  e.g. MyPath = CompSci::MutablePath

  # Nota Bene
  # ===
  #
  # These are logical paths and have no connection to any filesystem.
  # This library never looks at the local filesystem that it runs on.
  # ImmutablePath and MutablePath both mix in this module via `include`.
  # They also pull in class methods via `extend` via the `included` hook.
  # @ivar references will not work with Data.define, so use self.ivar
  module PathMixin
    include Comparable

    class FilenameError < RuntimeError; end

    SEP = '/'
    DOT = '.'
    CWD = DOT + SEP

    # must be a String != DOT
    def self.valid_filename!(val)
      if !val.is_a?(String) or val == DOT
        raise(FilenameError, "illegal value: #{val.inspect}")
      end
      val
    end

    #
    # module FactoryMethods: create new Paths
    #

    # ImmutablePath and MutablePath both mix in this module via extend
    # This ensures self.new refers to the base class and not the mixin (module)
    # This extension happens automatically via an included hook on PathMixin
    # PathMixin#slash calls FactoryMethods#parse
    #
    module FactoryMethods
      # return a new Path from a string
      def parse(path_str)
        abs = path_str.start_with? SEP
        if abs
          path_str = path_str[1..-1]
        elsif path_str.start_with? CWD
          path_str = path_str[2..-1]
        end
        dirs = path_str.split SEP
        file = path_str.end_with?(SEP) ? '' : (dirs.pop || '')
        self.new(abs: abs, dirs: dirs, file: file)
      end

      # Create absolute Path from Path or string
      def absolute(path)
        p = parse(path.to_s)
        self.new(abs: true, dirs: p.dirs, file: p.file)
      end

      # Create directory Path from Path or string
      def directory(path)
        p = parse(path.to_s)
        dirs = p.dirs.dup
        dirs << p.file unless p.file.empty?
        self.new(abs: p.abs, dirs: dirs, file: '')
      end
    end

    #
    # module PathMixin: provides most of the Path instance behavior
    #

    # the base class automatically gets FactoryMethods at the "class layer"
    def self.included(base) = base.extend(FactoryMethods)

    # a pseudo-initialize method to be called by the base class #initialize
    # returns a hash
    def handle_init(abs: false, dirs: [], file: '')
      PathMixin.valid_filename!(file)
      { abs: abs,
        dirs: dirs.reject { |d| d == DOT },
        file: file }
    end

    def sigil = self.abs ? SEP : CWD
    def path
      self.dirs.empty? ? self.file :
        (self.dirs + [self.file]).join(SEP)
    end
    def to_s = self.sigil + self.path

    def abs? = self.abs
    def dir? = self.file.empty?

    def ==(other)
      other.is_a?(self.class) and
        self.abs == other.abs and
        self.dirs == other.dirs and
        self.file == other.file
    end

    # Comparable: lexicographic -- relpaths before abspaths
    def <=>(other)
      self.to_s <=> other.to_s
    end

    # Enable path building with slash method
    # !!! base class must implement Klass#slash_path !!!
    def slash(other)
      case other
      when String
        other.empty? ? self : self.slash_path(self.class.parse(other))
      when ImmutablePath, MutablePath
        self.slash_path other
      else
        raise("unexpected: #{other.inspect}")
      end
    end
    alias_method :/, :slash

    # whatever the file is, up to the last dot; possibly empty: e.g. .bashrc
    def basename
      unless self.file.empty?
        idx = self.file.rindex(DOT)
        idx.nil? ? self.file : self.file[0...idx]
      end
    end

    # include the dot; empty if there is no extension: e.g. /bin/bash
    def extension
      unless self.file.empty?
        idx = self.file.rindex(DOT)
        idx.nil? ? "" : self.file[idx..-1]
      end
    end

    # ocean boiler; don't use this
    def reconstruct_file = [self.basename, self.extension].join
  end


  #
  # ImmutablePath (Data)
  #

  class ImmutablePath < Data.define(:abs, :dirs, :file)
    include PathMixin # also extends PathMixin::FactoryMethods

    # rely on PathMixin#handle_init for initialize
    def initialize(**kwargs)
      super(**self.handle_init(**kwargs))
    end

    # rely on Data#with for efficient copying
    def slash_path(other)
      # nonempty file is now a subdir
      new_dirs = self.dirs.dup              # dup first
      new_dirs << self.file unless self.file.empty?
      new_dirs += other.dirs
      self.with(dirs: new_dirs, file: other.file)
    end
  end

  class MutablePath
    include PathMixin # also extends PathMixin::FactoryMethods

    attr_reader :abs, :dirs, :file

    # rely on PathMixin#handle_init for initialize
    def initialize(**kwargs)
      @abs, @dirs, @file =
        self.handle_init(**kwargs).values_at(:abs, :dirs, :file)
    end

    # enforce valid mutable files
    def file=(val)
      @file = PathMixin.valid_filename!(val)
    end

    # simple update
    def slash_path(other)
      @dirs << @file unless @file.empty?
      @dirs += other.dirs
      @file = other.file
      self
    end
  end

  # you can do this too, in your own context:
  # MyUnixPath = CompSci::MutablePath

  UnixPath = ImmutablePath
  # UnixPath = MutablePath
end
