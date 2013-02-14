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

shared_context "command run" do
  before :all do
    @base = Dir.getwd
  end

  def run(*args)
    lines = `env RUBYLIB=#{Pathname(@base) + 'lib'} ruby #{Pathname(@base) + 'bin' + 'upbuild'} #{args.join(' ')}`.split("\n")
    [lines, $?.exitstatus]
  end
end
