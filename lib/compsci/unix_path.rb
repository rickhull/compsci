module CompSci
  class UnixPath
    include Comparable
    
    class Error < RuntimeError; end
    class FilenameError < Error; end
    class SlashError < Error; end

    SEP = '/'
    DOT = '.'
    CWD = DOT + SEP
    
    # return a new Path from a string
    def self.parse(path_str)
      abs = path_str.start_with? SEP
      if abs
        path_str = path_str[1..-1]
      elsif path_str.start_with? CWD
        path_str = path_str[2..-1]
      end
      subdirs = path_str.split SEP
      filename = path_str.end_with?(SEP) ? '' : (subdirs.pop || '')
      
      UnixPath.new(abs:, subdirs:, filename:)
    end
    
    # Create absolute UnixPath from UnixPath or string
    def self.absolute(path)
      p = UnixPath.parse(path.to_s)
      UnixPath.new(abs: true, subdirs: p.subdirs, filename: p.filename)
    end
    
    # Create directory UnixPath from UnixPath or string
    def self.directory(path)
      p = UnixPath.parse(path.to_s)
      subdirs = p.subdirs
      subdirs << filename unless filename.empty?
      UnixPath.new(abs: p.abs, subdirs:, filename: '')
    end

    attr_reader :abs, :subdirs, :filename
    attr_accessor :mutate
    
    def initialize(abs: false, subdirs: [], filename: '', mutate: true)
      @abs = abs
      @subdirs = subdirs.reject { |dir| dir == DOT }
      self.filename = filename
      @mutate = mutate
    end

    def filename=(val)
      if !val.is_a?(String) or val == DOT
        raise(FilenameError, "illegal value: #{val.inspect}")
      end
      @filename = val
    end

    # whatever the filename is, up to the last dot; possibly empty: .bashrc
    def basename
      unless @filename.empty?
        idx = @filename.rindex(DOT)
        idx.nil? ? @filename : @filename[0...idx]
      end
    end
    
    # include the dot; empty if there is no extension: /bin/bash
    def extension
      unless @filename.empty?
        idx = @filename.rindex(DOT)
        idx.nil? ? "" : @filename[idx..-1]
      end
    end
    
    # I bet you boil oceans in your spare time
    def reconstruct_filename = self.basename + self.extension
    
    # / or ./
    def sigil = @abs ? SEP : CWD

    # without leading / or ./
    def path
      @subdirs.empty? ? @filename : (@subdirs + [@filename]).join(SEP)
    end

    # Always prefix relative paths with ./
    def to_s = self.sigil + self.path
    
    # assume other is a UnixPath
    def slash_path(other)
      # make sure other is a relpath
      raise(SlashError, "can't slash an absolute path") if other.abs?
      if @mutate
        @subdirs += other.subdirs
        @filename = other.filename
        self
      else
        UnixPath.new(abs: @abs,
                 subdirs: @subdirs + other.subdirs,
                 filename: other.filename)
      end
    end
    
    # Enable path building with slash method
    def slash(other)
      raise(SlashError, "can only slash on dirs") unless self.dir?
      case other
      when String
        other.empty? ? self : self.slash_path(UnixPath.parse(other))
      when UnixPath
        self.slash_path(other)
      else
        raise("unexpected: #{other.inspect}")
      end
    end
    
    # Enable forward slash operator as alias
    alias_method :/, :slash
    
    # Convenience methods
    def abs? = @abs
    def dir? = @filename.empty?
    
    # Equality comparison
    def ==(other)
      other.is_a?(self.class) and
        @abs == other.abs and
        @subdirs == other.subdirs and 
        @filename == other.filename
    end
    
    # Inequality comparison: lexicographic -- relpaths before abspaths
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end

# Example usage and tests
if __FILE__ == $0

  include CompSci
  
  puts "=== UnixPath Examples ==="
  
  # Test cases
  test_paths = [
    "/",                          # Root directory
    "/home/",                     # Absolute directory
    "/home/user/documents/",      # Nested absolute directory
    "/home/user/file.txt",        # Absolute file
    "relative/",                  # Relative directory
    "relative/file.txt",          # Relative file
    "file.txt",                   # File in current directory
    ".bashrc",                    # Dotfile
    "archive.tar.gz",             # Multiple extensions
    "README",                     # No extension
    "/home/user/.config/",        # Hidden directory
    "docs/README.md",             # Relative path with file
    "./",                         # Current directory
    "./file.txt",                 # File in current directory with explicit ./
    "docs/./README.md",           # UnixPath with intermediate .
    "/home/./user/./file.txt"     # Absolute path with intermediate .
  ]
  
  test_paths.each do |path_str|
    path = UnixPath.parse(path_str)
    
    puts "\nUnixPath: '#{path_str}' -> '#{path}'"
    puts "  Parsed - abs: #{path.abs?}, subdirs: #{path.subdirs.inspect}, filename: '#{path.filename}'"
    puts "  Directory?: #{path.dir?}"
    puts "  Basename: #{path.basename.inspect}"
    puts "  Extension: #{path.extension.inspect}"
  end
  
  puts "\n=== Path Building Examples ==="
  
  # Demonstrate / method for path building
  root = UnixPath.parse("/")
  home = root / "home/"
  user_dir = home / "user"
  file = user_dir / "document.txt"
  
  puts "Built path: #{file}"
  puts "Components: abs=#{file.abs?}, subdirs=#{file.subdirs.inspect}, filename='#{file.filename}'"
  
  puts "\n=== Relative Path Examples ==="
  
  # Show how relative paths are normalized
  current = UnixPath.parse("./")
  docs = current / "docs/"
  readme = docs / "README.md"
  
  puts "Current dir: #{current}"
  puts "Docs dir: #{docs}" 
  puts "README file: #{readme}"
  
  # Show parsing flexibility
  puts "\nParsing flexibility:"
  puts "parse('file.txt') -> #{UnixPath.parse('file.txt')}"
  puts "parse('./file.txt') -> #{UnixPath.parse('./file.txt')}"
  puts "parse('docs/file.txt') -> #{UnixPath.parse('docs/file.txt')}"
  
  puts "\n=== Error Handling ==="
  
  begin
    file_path = UnixPath.parse("./file.txt")
    file_path / "another.txt"  # Should error - can't add to file
  rescue UnixPath::SlashError => e
    puts "Caught expected error: #{e.message}"
  end
  
  begin
    rel_path = UnixPath.parse("./docs/")
    rel_path / "/absolute/path"  # Should error - can't add absolute
  rescue UnixPath::SlashError => e
    puts "Caught expected error: #{e.message}"
  end
end
