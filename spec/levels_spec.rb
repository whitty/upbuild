#/usr/bin/env ruby -w

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

#require 'spec_helper'
require 'upbuild'
require 'pp'

describe "basic levels" do

  before :all do
    @base = Dir.getwd
    Dir.chdir "spec/root"
  end

  after :all do
    Dir.chdir "../.."
  end

  def run(*args)
    lines = `env RUBYLIB=#{Pathname(@base) + 'lib'} ruby #{Pathname(@base) + 'bin' + 'upbuild'} #{args.join(' ')}`.split("\n")
    [lines, $?.exitstatus]
  end

  def succeed_1_match(dir, match)
    Dir.chdir dir do 
      l,r = run()
      r.should eq(0)
      l.length.should eq(1)
      l.first.should eq(match)
    end
  end

  describe "Finds build files up the tree" do

    it "Finds build files at each level" do
      succeed_1_match("depth1/depth2/depth3", "depth3")
      succeed_1_match("depth1/depth2", "depth2")
      succeed_1_match("depth1", "depth1")
    end

    it "skips over directories with no buikd file" do
      succeed_1_match("depth1/depth2.1/depth2.2/depth2.3", "depth2.3")
      succeed_1_match("depth1/depth2.1/depth2.2", "depth2.1")
      succeed_1_match("depth1/depth2.1", "depth2.1")
    end

    it "returns failure if nothing found" do
      Dir.chdir "../../.." do
        l,r = run() 
        r.should eq(1)
        l.length.should eq(0)
      end
    end

  end

end
