with import <nixpkgs> {};
ruby.withPackages (ps: with ps; [ rake ])
