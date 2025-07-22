require 'minitest/autorun'
require 'compsci/unix_path_immutable'

include CompSci

CASES = {
  '/'                      => [true, [], ''],
  '/home/'                 => [true, %w[home], ''],
  '/home/user/documents'   => [true, %w[home user], 'documents'],
  '/home/user/documents/'  => [true, %w[home user documents], ''],
  '/home/user/file.txt'    => [true, %w[home user], 'file.txt'],
  'relative_dir/'          => [false, %w[relative_dir], ''],
  'relative_file'          => [false, [], 'relative_file'],
  'relative_dir/file.txt'  => [false, %w[relative_dir], 'file.txt'],
  'relative_dir/file.txt/' => [false, %w[relative_dir file.txt], ''],
  'file.txt'               => [false, [], 'file.txt'],
  '.bashrc'                => [false, [], '.bashrc'],
  '/home/user/.bashrc'     => [true, %w[home user], '.bashrc'],
  '/home/user/.config/'    => [true, %w[home user .config], ''],
  './file.txt'             => [false, [], 'file.txt'],
  './.emacs'               => [false, [], '.emacs'],
  './././././file.txt'     => [false, [], 'file.txt'],
  '/././etc/passwd'        => [true, %w[etc], 'passwd'],
}

describe UnixPath do
  it "parses the most common well-formed cases properly" do
    CASES.each { |str, tuple|
      path = UnixPath.parse(str)
      expect(path.abs).must_equal tuple[0]
      expect(path.subdirs).must_equal tuple[1]
      expect(path.filename).must_equal tuple[2]
    }
  end

  it "leads with a dot for all relpaths" do
    path = UnixPath.new(abs: false, subdirs: %w[path to], filename: 'file.txt')
    expect(path.to_s.start_with? './').must_equal true
  end

  it "leads with a slash for all abspaths" do
    path = UnixPath.new(abs: true, subdirs: %w[path to], filename: 'file.txt')
    expect(path.to_s.start_with? '/').must_equal true
  end
end
