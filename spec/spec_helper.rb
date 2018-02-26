# (C) Copyright Greg Whiteley 2010-2013
#
#  This is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation, either version 3 of
#  the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'enumerator'
require 'tmpdir'
require 'pp'
require 'pathname'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]  # default, enables both `should` and `expect`
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]  # default, enables both `should` and `expect`
  end
end

shared_context "command run" do
  before :all do
    @base = Dir.getwd
  end

  before :all do
    raise RuntimeError.new "Failed to restore path environment" if @base != Dir.getwd
  end

  # Run upbuild with given optional args
  # If block provided yield the pid to it.
  # After proc is complete block waiting on completion.
  def run(*args, &block)

    command = ['env', "PATH=#{Pathname(@base) + 'bin'}:#{ENV['PATH']}", "RUBYLIB=#{Pathname(@base) + 'lib'}", 'ruby', (Pathname(@base) + 'bin' + 'upbuild').to_s]
    command.concat(args)

    result = nil
    lines = []
    begin
      r,w = IO.pipe
      err_r, err_w = IO.pipe
      pid = Process.spawn(*command, :out => w, :err=> err_w);
      w.close
      err_w.close
      if block
        if block.parameters.length > 1
          block.call(pid, r)
        else
          block.call(pid)
        end
      end

      result = Process.wait2(pid)
      if result
        lines = r.enum_for(:each_line).map {|x| x.chomp}
      end
      if result
        err = err_r.enum_for(:each_line).map {|x| x.chomp}
      end
    ensure
      w.close unless w.closed?
      r.close
      err_w.close unless err_w.closed?
      err_r.close
    end

    if result
      [lines, result.last.exitstatus, err]
    end
  end
end
