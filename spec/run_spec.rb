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
require 'enumerator'
require 'pp'

describe "Running" do
  include_context "command run"

  before :all do
    Dir.chdir "spec/root/run"
  end

  after :all do
    Dir.chdir "../../.."
  end

  context "With multiple commands in file" do

    before :all do
      Dir.chdir "multi"
    end

    after :all do
      Dir.chdir ".."
    end

    FILES = ['first', 'second', 'third']

    after :each do
      FILES.each do |f|
        FileUtils.rm(f) if Pathname(f).exist?
      end
    end

    def set_fail(i)
      `touch #{FILES[i]}`
    end

    it "runs all if they all pass" do
      l,r = run() 
      r.should eq(0)
      l.length.should eq(3)
      l.should eq(FILES)
    end

    it "runs just first if first fails" do
      set_fail(0)
      l,r = run() 
      r.should eq(1)            # fail
      l.length.should eq(1)
      l.should eq(FILES[0,1])
    end

    it "runs first two if second fails" do
      set_fail(1)
      l,r = run() 
      r.should eq(1)            # fail
      l.length.should eq(2)
      l.should eq(FILES[0,2])
    end

    it "runs all, but fail if last fails" do
      set_fail(2)
      l,r = run() 
      r.should eq(1)            # fail
      l.length.should eq(3)
      l.should eq(FILES[0,3])
    end

  end

end
