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

require 'rspec'

require 'spec_helper'
require 'upbuild'
require 'pp'

include Upbuild

describe "options" do
  include_context "command run"

  before :all do
    Dir.chdir "spec/root/opts"
  end

  after :all do
    Dir.chdir "../../.."
  end

  context "When option present" do
    it "won't emit option without args" do
      l,r = run() 
      r.should eq(0)
      l.length.should eq(1)
      l.first.should eq("hello world its monday")
    end

    it "won't emit option with args" do
      l,r = run('c\'est', 'moi') 
      r.should eq(0)
      l.length.should eq(1)
      l.first.should eq("hello world c'est moi")
    end
  end

  context "outfile" do

    # clean up log-files
    after :each do
      base = Pathname(Dir.getwd) + 'outfile'
      [
       base + 'out.txt',
       base + 'fail' + 'log.txt',
       base + 'fail' + 'out.txt',
      ].each do |x|
        FileUtils.rm(x) if x.exist?
      end
    end

    it "will emit the file at the end" do
      Dir.chdir "outfile" do
        l,r = run() 
        r.should eq(0)
        l.length.should eq(1)
        l.first.should eq("hello world into file")
      end
    end
    it "will emit the file at the end - with args" do
      Dir.chdir "outfile" do
        l,r = run('its a', 'file') 
        r.should eq(0)
        l.length.should eq(1)
        l.first.should eq("hello world its a file")
      end
    end
    it "will emit the file at the end even on failure" do
      Dir.chdir "outfile/fail" do
        l,r = run() 
        r.should eq(1)
        l.length.should eq(1)
        l.first.should eq("error: badness")
      end
    end
  end

  context "retmap" do

    context "parsing" do
      it "parses some simple mappings" do
        [
         ['1=>0', {1=>0}],
         [' 1 => 0 ', {1=>0}],
         [' 1=>44 ', {1=>44}],
         ['55 => 0', {55=>0}],
         ['10=>100', {10=>100}],
         ['1=>0,2=>4,4=>100', {1=>0, 2=>4, 4=>100}],
         [' 1=> 0 , 2 => 4 ,4 =>100', {1=>0, 2=>4, 4=>100}],
        ].each do |s, exp|
          Upbuild.parse_retmap(s).should eq(exp)
        end
      end
    end

    before :all do
      Dir.chdir "retmap"
    end

    after :all do
      Dir.chdir ".."
    end

    def run_result(*args)
      run(*args)[1]
    end

    it "unmapped zero is unchanged" do
      r = run_result('0')
      r.should eq(0)
    end
    it "one is mapped to zero (success)" do
      r = run_result('1') 
      r.should eq(0)
    end
    it "two is mapped to 4 (fail)" do
      r = run_result('2') 
      r.should eq(4)
    end
    it "four is mapped to 100 (fail)" do
      r = run_result('4') 
      r.should eq(100)
    end

    it "Bad formats are reported with fail" do
      Dir.chdir "error" do
        l,r,err = run('4') 
        r.should eq(253)
        # no output on stdout
        l.length.should eq(0)
        # Error message on stderr
        err.length.should eq(1)
        err.first.should match(/Unable to parse '@retmap=.*'/)
        # should include the bit that failed to parse
        err.first.should match(/bad=>0/)
      end
    end

  end

  context "disable" do

    before :all do
      Dir.chdir "disable"
    end

    after :all do
      Dir.chdir ".."
    end

    it "will skip the single command marked as @disable" do
      Dir.chdir "one" do
        l,r = run() 
        r.should eq(0)
        l.length.should eq(2)
        l.first.should eq("one")
        l.last.should eq("three")
      end
    end

    it "will skip the only command if marked @disable" do
      Dir.chdir "all_one" do
        l,r = run() 
        r.should eq(255)
        l.length.should eq(0)
      end
    end

    it "will skip all commands if all marked @disable" do
      Dir.chdir "all" do
        l,r = run() 
        r.should eq(255)
        l.length.should eq(0)
      end
    end
  end

  context "tags" do

    before :all do
      Dir.chdir "tags"
    end

    after :all do
      Dir.chdir ".."
    end

    it "is ignored by default" do
      l,r = run() 
      r.should eq(0)
      l.should eq(['one', 'two', 'three', 'four'])
    end

    it "selects tags that match (1)" do
      l,r = run('--ub-select=odd') 
      r.should eq(0)
      l.should eq(['one', 'three'])
    end
    it "selects tags that match (2)" do
      l,r = run('--ub-select=even') 
      r.should eq(0)
      l.should eq(['two', 'four'])
    end
    it "selects tags that match (3)" do
      l,r = run('--ub-select=last') 
      r.should eq(0)
      l.should eq(['four'])
    end
    it "selects tags that match (4)" do
      l,r = run('--ub-select=prime') 
      r.should eq(0)
      l.should eq(['one', 'two', 'three'])
    end

  end
end
