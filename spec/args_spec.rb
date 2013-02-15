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

describe "arguments" do
  include_context "command run"

  before :all do
    Dir.chdir "spec/root/args"
  end

  after :all do
    Dir.chdir "../../.."
  end

  it "uses all args in default run" do
    l,r = run() 
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("hello world its monday")
  end

  it "replaces arguments after the -- if provided" do
    l,r = run('c\'est', 'moi') 
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("hello world c'est moi")
  end

end
