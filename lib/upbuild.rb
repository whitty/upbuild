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

  Command = Struct.new(:command, :args, :opts)

  def read_commands(build_file, argv)
    args, opts = parse_args(argv)
    commands = parse_commands(File.readlines(build_file), args)
    opts = get_global_opts(commands, opts)
    [filter_commands(commands, opts[:select], opts[:reject]), opts]
  end

  # The returned argv is nil if nothing specified or empty [] if just
  # --- specified (ie should replace optional parameters will nothing
  def parse_args(argv)

    truncate = false

    opts = {}
    while arg = argv.first
      case arg
      when /^--ub-select=(.+)$/
        opts[:select]=$1
        if opts[:reject] and opts[:select] == opts[:reject]
          opts.delete(:reject) # override older
        end
      when /^--ub-reject=(.+)$/
        opts[:reject]=$1
        if opts[:select] and opts[:select] == opts[:reject]
          opts.delete(:select) # override older
        end
      when /^--ub-print$/
        opts[:print]=true
      when "---"
        truncate = true
        argv.shift
        break
      when "--"
        argv.shift
        break
      else
        break
      end
      argv.shift
    end

    if argv.length == 0 and !truncate
      argv = nil
    end

    return argv, opts
  end

  def filter_commands(commands, selection, rejection)
    commands.select do |c|
      if c.opts and c.opts[:disable]
        false                   # disabled
      elsif selection or rejection
        if c.opts and c.opts[:tags]
          tags = c.opts[:tags].split(',')
          if selection
            if tags.member?(selection.to_s)
              # select if no rejections, or if rejections present, but we don't match
              !rejection or !tags.member?(rejection.to_s)
            else
              false # not selected
            end
          else # rejection defined (but not selection)
            # if no selection and manual, don't run it
            if c.opts and c.opts[:manual]
              false
            else
              !tags.member?(rejection.to_s) #if not rejected
            end
          end
        else
          if selection and not rejection
            false                 # selection defined, but no tags
          elsif rejection and not selection
            true                  # rejection defined, but no tags - include them
          end
        end
      elsif c.opts and c.opts[:manual]
        false
      else
        true                    # include all others
      end
    end
  end

  def parse_commands(lines, argv)

    build_lines = lines.map {|x| x.chomp.gsub(/#.*/,'') }.select {|x| x.length > 0}
    split_a(build_lines, "&&").map do |command_lines|

      command = command_lines.shift
      mandatory = []
      opts = {}
      args = command_lines
      args = args.reject do |x|
        opt = x.match(/^@(outfile|retmap|tags|cd)=/)
        if opt
          opts[opt[1].to_sym] = opt.post_match
        else
          opt = x.match(/^@(disable|manual|quiet)\s*$/)
          opts[opt[1].to_sym] = true if opt
        end
      end
      split = args.index("--")
      if split
        mandatory = args.slice(0,split)
        args = args[split + 1..-1]
      end

      unless argv.nil?
        args = argv
      end

      args = mandatory + args

      command ? Command.new(command, args, opts) : nil
    end.select {|x| x}
  end

  GLOBAL_OPTS = [:quiet]

  def get_global_opts(commands, opts)
    new_opts = {}
    # don't override command-line opts
    global_opts = GLOBAL_OPTS.select {|x| !opts.member?(x)}
    # last command wins
    commands.each do |x|
      global_opts.each do |global_opt|
        new_opts[global_opt] = x.opts[global_opt] if x.opts.member?(global_opt)
      end
    end
    opts.merge(new_opts)
  end

  def parse_retmap(s)
    h = {}
    s.split(',').each do |rule|
      key_s, value_s = rule.split('=>', 2)
      h[Integer(key_s)] = Integer(value_s)
    end
    h
  end

end
