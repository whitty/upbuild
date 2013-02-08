require "upbuild/version"

module Upbuild

  BUILD_FILE='.upbuild'

  def split_a(array, match)
    ret = []

    rem = array

    while pos = rem.index(match) do
      ret << rem.slice(0, pos)
      rem = rem[pos + 1..-1]
    end
    ret << rem
  end

  def find_build_path(dir)
    path = Pathname(dir).enum_for(:ascend).find do |p|
      (p + BUILD_FILE).exist?
    end
    path = path.relative_path_from(Pathname(Dir.getwd)) if path
  end

  def read_commands(build_file, argv)

    build_lines = File.readlines(build_file).map {|x| x.chomp.gsub(/#.*/,'') }.select {|x| x.length > 0}
    commands = split_a(build_lines, "&&").map do |command_lines|

      command = command_lines.shift
      mandatory = []
      args = command_lines
      split = command_lines.index("--")
      if split
        mandatory = command_lines.slice(0,split)
        args = command_lines[split + 1..-1]
      end

      if argv.length > 0
        args = argv
      end

      args = mandatory + args

      command ? [command, args] : nil
    end.select {|x| x}
  end

end
