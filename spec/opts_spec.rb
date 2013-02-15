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

end
