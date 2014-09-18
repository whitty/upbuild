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

require 'spec_helper'
require 'upbuild'
require 'pp'

describe "basic levels" do
  include_context "command run"

  before :all do
    Dir.chdir "spec/root"
  end

  after :all do
    Dir.chdir "../.."
  end

  def succeed_1_match(dir, match)
    Dir.chdir dir do
      l,r = run()
      r.should eq(0)

      # allow for Entering directory notice
      l.length.should be >= 1
      if l.first =~ /Entering directory/
        l.first.should match(/^upbuild: Entering directory `.*#{match}'$/)
        l.shift
      end

      l.length.should eq(1)
      l.first.should eq(match.to_s)
    end
  end

  describe "Finds build files up the tree" do

    it "Finds build files at each level" do
      succeed_1_match("depth1/depth2/depth3", "depth3")
      succeed_1_match("depth1/depth2", "depth2")
      succeed_1_match("depth1", "depth1")
    end

    it "skips over directories with no build file" do
      succeed_1_match("depth1/depth2.1/depth2.2/depth2.3/depth2.4", "depth2.3")
      succeed_1_match("depth1/depth2.1/depth2.2/depth2.3", "depth2.3")
      succeed_1_match("depth1/depth2.1/depth2.2", "depth2.1")
      succeed_1_match("depth1/depth2.1", "depth2.1")
    end

    it "runs in the right directory" do
      wd = Pathname(Dir.getwd)
      # Nothing in 4 - pwd is 3
      succeed_1_match("wd/1/2/3/4", wd + 'wd/1/2/3')
      succeed_1_match("wd/1/2/3", wd + 'wd/1/2/3')
      # Nothing in 2 - pwd is 1
      succeed_1_match("wd/1/2", wd + 'wd/1')
      succeed_1_match("wd/1", wd + 'wd/1')
    end

    it "returns failure if nothing found" do
      Dir.chdir "../../.." do
        l,r = run()
        r.should eq(1)
        l.length.should eq(0)
      end
    end

  end

  describe "emits 'Entering directory'" do

    it "when path changes" do
      base = Pathname(Dir.getwd)
      expected = base + 'depth1' + 'depth2.1'
      Dir.chdir "depth1/depth2.1/depth2.2" do
        l,r = run()
        r.should eq(0)

        l.length.should eq(2)
        l.first.should eq("upbuild: Entering directory `#{expected}'")
        l.last.should eq("depth2.1")
      end
    end

    it "but not when it doesn't" do
      Dir.chdir "depth1/depth2.1" do
        l,r = run()
        r.should eq(0)

        l.length.should eq(1)
        l.first.should eq("depth2.1")
      end
    end

  end

  describe "@quiet option" do

    it "Should emit normally" do
      Dir.chdir 'quiet' do
        l,r = run()
        r.should eq(0)

        l.length.should eq(1)
        l.first.should eq('quiet')
      end
    end

    it "Should suppress 'entering directory' when moving up the tree" do
      Dir.chdir 'quiet/deeper' do
        l,r = run()
        r.should eq(0)

        l.length.should eq(1)
        l.first.should eq('quiet')
      end
    end

  end

end

describe "level recursion" do
  include_context "command run"

  before :all do
    Dir.chdir "spec/root/recurse"
    @recurse_root = Pathname(Dir.getwd)
  end

  after :all do
    Dir.chdir "../../.."
  end

  it "runs normally at the top level" do
    l,r = run()
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("hello world")
  end

  it "allows upbuild to be run from a higher level to call a lower level" do
    Dir.chdir('higher') do
      l,r = run()
      r.should eq(0)
      l.length.should eq(2)
      l.first.should eq("upbuild: Entering directory `#{@recurse_root}'")
      l.last.should eq("hello there")
    end
  end

  it "allows upbuild to be run from a higher level to call a lower level with args" do
    Dir.chdir('higher') do
      l,r = run('all')
      r.should eq(0)
      l.length.should eq(2)
      l.first.should eq("upbuild: Entering directory `#{@recurse_root}'")
      l.last.should eq("hello there all")
    end
  end

  it "works when original directory has no .upbuild file, each level gives an entering notification" do
    higher_root = @recurse_root + 'higher'
    Dir.chdir('higher/still') do
      l,r = run('all')
      r.should eq(0)

      l.length.should eq(3)
      l.first.should eq("upbuild: Entering directory `#{higher_root}'")
      l[1].should eq("upbuild: Entering directory `#{@recurse_root}'")
      l.last.should eq("hello there all")
    end
  end

end
