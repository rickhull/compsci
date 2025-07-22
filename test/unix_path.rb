require 'minitest/autorun'
require 'compsci/unix_path'

include CompSci

# Helper method to run parsing tests
def assert_parsing(cases)
  cases.each { |str, (abs, subdirs, filename)|
    path = UnixPath.parse(str)
    expect(path.abs).must_equal abs
    expect(path.subdirs).must_equal subdirs
    expect(path.filename).must_equal filename
  }
end

def assert_filenames(cases)
  cases.each do |filename, (base, ext)|
    path = UnixPath.parse(filename)
    expect(path.basename).must_equal base
    expect(path.extension).must_equal ext
  end
end

describe UnixPath do
  it "parses absolute paths with leading slash" do
    cases = {
      '/'                      => [true, [], ''],
      '/home/'                 => [true, %w[home], ''],
      '/home/user/documents'   => [true, %w[home user], 'documents'],
      '/home/user/documents/'  => [true, %w[home user documents], ''],
      '/home/user/file.txt'    => [true, %w[home user], 'file.txt'],
      '/home/user/.bashrc'     => [true, %w[home user], '.bashrc'],
      '/home/user/.config/'    => [true, %w[home user .config], ''],
      '/././etc/passwd'        => [true, %w[etc], 'passwd'],
    }
    assert_parsing(cases)
  end

  it "parses relative paths with leading dot-slash" do
    cases = {
      './file.txt'             => [false, [], 'file.txt'],
      './.emacs'               => [false, [], '.emacs'],
      './././././file.txt'     => [false, [], 'file.txt'],
    }
    assert_parsing(cases)
  end

  it "parses relative paths with no leading slash" do
    cases = {
      'relative_dir/'          => [false, %w[relative_dir], ''],
      'relative_file'          => [false, [], 'relative_file'],
      'relative_dir/file.txt'  => [false, %w[relative_dir], 'file.txt'],
      'relative_dir/file.txt/' => [false, %w[relative_dir file.txt], ''],
      'file.txt'               => [false, [], 'file.txt'],
      '.bashrc'                => [false, [], '.bashrc'],
    }
    assert_parsing(cases)
  end

  it "parses directories with trailing slash; filename is empty" do
    cases = {
      '/'                      => [true, [], ''],
      '/home/'                 => [true, %w[home], ''],
      '/home/user/documents/'  => [true, %w[home user documents], ''],
      'relative_dir/'          => [false, %w[relative_dir], ''],
      'relative_dir/file.txt/' => [false, %w[relative_dir file.txt], ''],
      '/home/user/.config/'    => [true, %w[home user .config], ''],
    }
    assert_parsing(cases)
  end

  it "parses filenames with no trailing slash; nonempty filename" do
    cases = {
      '/home/user/documents'   => [true, %w[home user], 'documents'],
      '/home/user/file.txt'    => [true, %w[home user], 'file.txt'],
      'relative_file'          => [false, [], 'relative_file'],
      'relative_dir/file.txt'  => [false, %w[relative_dir], 'file.txt'],
      'file.txt'               => [false, [], 'file.txt'],
      '.bashrc'                => [false, [], '.bashrc'],
      '/home/user/.bashrc'     => [true, %w[home user], '.bashrc'],
      './file.txt'             => [false, [], 'file.txt'],
      './.emacs'               => [false, [], '.emacs'],
      './././././file.txt'     => [false, [], 'file.txt'],
      '/././etc/passwd'        => [true, %w[etc], 'passwd'],
    }
    assert_parsing(cases)
  end

  it "leads with a dot for all relpaths" do
    path = UnixPath.new(abs: false, subdirs: %w[path to], filename: 'file.txt')
    expect(path.to_s.start_with? './').must_equal true
  end

  it "leads with a slash for all abspaths" do
    path = UnixPath.new(abs: true, subdirs: %w[path to], filename: 'file.txt')
    expect(path.to_s.start_with? '/').must_equal true
  end

  it "concatenates paths with chained slash calls" do
    base = UnixPath.parse("./src/")
    expect(base.abs?).must_equal false
    expect(base.dir?).must_equal true

    # check this out!
    full = base / 'components' / 'forms' / 'LoginForm.js'

    expect(full.abs?).must_equal false
    expect(full.dir?).must_equal false

    if base.is_a? MutablePath
      expect(base).must_equal full
    elsif base.is_a? ImmutablePath
      expect(base).wont_equal full
    end

    expect(full.to_s).must_equal "./src/components/forms/LoginForm.js"
  end

  it "slashes other UnixPath objects" do
    path1 = UnixPath.parse('/home/user/')
    path2 = UnixPath.parse('./src/file.txt')
    path3 = path1 / path2
    expect(path3.to_s).must_equal '/home/user/src/file.txt'
  end

  it "slashes liberally, with abspaths and relpaths" do
    abs = UnixPath.parse('/home/user')
    rel = UnixPath.parse('./.emacs')

    absrel = abs / rel
    expect(absrel.to_s).must_equal '/home/user/.emacs'

    relabs = rel / abs
    expect(relabs.to_s).must_equal './.emacs/home/user'
  end

  it "slashes liberally, promoting base filename to a subdir" do
    dot_emacs = UnixPath.parse('/home/user/.emacs')
    init_el = UnixPath.parse('./.config/init.el')
    slashed = dot_emacs / init_el

    expect(dot_emacs.filename).must_equal '.emacs'
    expect(slashed.subdirs).must_include '.emacs'
    expect(slashed.to_s).must_equal '/home/user/.emacs/.config/init.el'
  end

  it "slashes liberally, with Mutable and ImmutablePaths" do
    mu = MutablePath.parse('/etc/systemd')
    immu = ImmutablePath.parse('/var/lib')

    # check Immutable first, mu will not get mutated here
    immumu = immu / mu
    expect(immumu).must_be_kind_of ImmutablePath
    expect(immumu.to_s).must_equal '/var/lib/etc/systemd'
    expect(immumu).wont_equal immu

    # now check the Mutable slash.  mu will get mutated here
    muimmu = mu / immu
    expect(muimmu).must_be_kind_of MutablePath
    expect(muimmu).must_equal mu
    expect(muimmu.to_s).must_equal '/etc/systemd/var/lib'    
  end

  describe 'empty filename' do
    it "indicates a directory when empty" do
      path = UnixPath.parse("/home/user/docs/")
      expect(path.dir?).must_equal true
      expect(path.filename).must_equal ""
    end

    it "has neither basename nor extension" do
      path = UnixPath.parse("/home/user/docs/")
      expect(path.basename).must_be_nil
      expect(path.extension).must_be_nil
    end
  end

  describe 'nonempty filename' do
    it "cannot be a single dot" do
      expect { UnixPath.parse('.') }.must_raise PathMixin::FilenameError
      expect { UnixPath.parse('/etc/.') }.must_raise PathMixin::FilenameError

      # . is fine as dir
      expect(UnixPath.parse('/etc/./').to_s).must_equal '/etc/'
    end

    it "extracts basename and extension for regular files" do
      path = UnixPath.parse("file.txt")
      expect(path.basename).must_equal "file"
      expect(path.extension).must_equal ".txt"
    end

    it "extracts basename and extension for dotfiles" do
      path = UnixPath.parse(".bashrc")
      expect(path.basename).must_equal ""
      expect(path.extension).must_equal ".bashrc"
    end

    it "extracts basename and extension for multiple extensions" do
      path = UnixPath.parse("archive.tar.gz")
      expect(path.basename).must_equal "archive.tar"
      expect(path.extension).must_equal ".gz"
    end

    it "extracts basename and extension for files without extensions" do
      path = UnixPath.parse("/etc/passwd")
      expect(path.basename).must_equal "passwd"
      expect(path.extension).must_equal ""
    end
  end
end
