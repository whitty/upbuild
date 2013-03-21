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

  it "consumes -- as if it wasn't there" do
    l,r = run('--') 
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("hello world its monday")
  end

  it "consumes -- once then passes all others" do
    l,r = run('--', '--') 
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("hello world --")
  end

  it "consumes known arguments at the start" do
    [ 
     ['--ub-select=5'],
     ['--ub-select=blah', '--'],
    ].each do | args |
      l,r = run(*args) 
      r.should eq(0)
      l.length.should eq(1)
      l.first.should eq("hello world its monday")
    end
  end

  it "passes unknown arguments through" do
    [ 
     ['--ub-unknown'],
     ['--ub-unknown=1'],
    ].each do | args |
      l,r = run(*args)
      r.should eq(0)
      l.length.should eq(1)
      l.first.should eq("hello world #{args.join(' ')}")
    end
  end

  it "passes known arguments after --" do
    [ 
     ['--', '--ub-select=5'],
     ['--', '--ub-select=blah'],
    ].each do | args |
      l,r = run(*args) 
      args.shift                # consume the --
      r.should eq(0)
      l.length.should eq(1)
      l.first.should eq("hello world #{args.join(' ')}")
    end
  end

  it "prints command if --ub-print specified" do
    l,r = run('--ub-print') 
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("echo hello world its monday")
  end

  it "prints command if --ub-print specified including args" do
    l,r = run('--ub-print', 'good', 'morning') 
    r.should eq(0)
    l.length.should eq(1)
    l.first.should eq("echo hello world good morning")
  end

end
