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

include Upbuild

describe :split_a do

  before :each do
    @a = [1,2,3,4,5,6,1,2,3,4,5,6,5,4,3,2,1]
  end

  it "splits arrays into multiple, excluding the match" do
    a = Upbuild.split_a(@a, 3)
    a.length.should be(4)
    a[0].should eq([1,2])
    a[1].should eq([4,5,6,1,2])
    a[2].should eq([4,5,6,5,4])
    a[3].should eq([2,1])
  end

  it "returns the original array if no match" do
    a = Upbuild.split_a(@a, 8)
    a.length.should be(1)
    a[0].should eq(@a)
  end

  it "doesn't barf on empty arrays" do
    a = Upbuild.split_a([], 1)
    a.length.should be(1)
    a[0].should eq([])
  end

  it "returns empty arrays when consecutive 'splits'" do
    a = Upbuild.split_a([2,1,1,2,1], 1)
    a.length.should be(4)
    a[0].should eq([2])
    a[1].should eq([])
    a[2].should eq([2])
    a[3].should eq([])
  end

end
