#/usr/bin/env ruby -w

# (C) Copyright Greg Whiteley 2010-2018
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

describe "--ub-add" do
  include_context "command run"

  before :all do
    Dir.chdir "spec/root/add"
    FileUtils.rm_f(".upbuild")
  end

  after :all do
    Dir.chdir "../../.."
  end

  after :each do
    FileUtils.rm_f(".upbuild")
  end

  describe "adds args to .upbuild file" do

    it "creates file if .upbuild doesn't exist" do
      File.exist?(".ubuild").should be(false)
      l,r = run("--ub-add", "echo", "abcd")
      r.should eq(0)
      l.should be_empty
      File.read(".upbuild").split.should eq(["echo", "abcd"])
    end

    it "appends additional lines with &&" do
      File.exist?(".ubuild").should be(false)

      l,r = run("--ub-add", "echo", "abcd")
      r.should eq(0)
      l.should be_empty
      File.read(".upbuild").split.should eq(["echo", "abcd"])

      l,r = run("--ub-add", "echo", "1234")
      r.should eq(0)
      l.should be_empty
      File.read(".upbuild").split.should eq(["echo", "abcd", "&&", "echo", "1234"])

      l,r = run()
      r.should eq(0)
      l.should eq(["abcd", "1234"])
    end

    it "but fails if no args provided" do
      l,r = run("--ub-add")
      r.should eq(250)
      l.should be_empty
    end

  end
end
