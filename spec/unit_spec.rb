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

describe :parse_args do

  it "passes through unknown args" do
    in_args = ['a','b','c']
    args, opts = parse_args(in_args)
    args.should eq(in_args)
    opts.should be_empty
  end

  it "just -- leave nothing" do
    in_args = ['--']
    args, opts = parse_args(in_args)
    args.should be_nil
    opts.should be_empty
  end

  it "consumes known args at the front" do
    in_args = ['a','b','c']
    args, opts = parse_args(['--ub-print'] + in_args)
    args.should eq(in_args)
    opts.should eq({:print => true})
  end

  it "passes known args after unknown args" do
    in_args = ['a','b','c', '--ub-print']
    args, opts = parse_args(in_args)
    args.should eq(in_args)
    opts.should be_empty
  end

  it "passes known args after --" do
    in_args = ['--ub-print', 'a','b','c']
    args, opts = parse_args(['--'] + in_args)
    args.should eq(in_args)
    opts.should be_empty
  end

  it "understands --ub-select=<something>" do
    in_args = ['a','b','c']
    args, opts = parse_args(['--ub-select=<something>'] + in_args)
    args.should eq(in_args)
    opts.should eq({:select => '<something>'})
  end

  it "just --- works like --" do
    in_args = ['---']
    args, opts = parse_args(in_args)
    args.should be_empty
    opts.should be_empty
  end

end

describe :parse_commands do

  it "generates full command with no args", :foo => true do
    in_args = []
    args, _ = parse_args(in_args)
    commands = parse_commands(['echo', 'hello', '--', 'world'], args)
    commands.length.should eq(1)
    commands.first.args.should eq(['hello', 'world'])
  end

  it "generates full command with --", :foo => true do
    in_args = ['--']
    args, _ = parse_args(in_args)
    commands = parse_commands(['echo', 'hello', '--', 'world'], args)
    commands.length.should eq(1)
    commands.first.args.should eq(['hello', 'world'])
  end

  it "truncates command with ---", :foo => true do
    in_args = ['---']
    args, _ = parse_args(in_args)
    commands = parse_commands(['echo', 'hello', '--', 'world'], args)
    commands.length.should eq(1)
    commands.first.args.should eq(['hello'])
  end

  it "truncates command with ---, wth trailing args", :foo => true do
    in_args = ['---', 'there']
    args, _ = parse_args(in_args)
    commands = parse_commands(['echo', 'hello', '--', 'world'], args)
    commands.length.should eq(1)
    commands.first.args.should eq(['hello', 'there'])
  end

end
