# (C) Copyright Greg Whiteley 2013
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

require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => [:spec]

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/*_spec.rb'
  t.rspec_opts = ['-fd']
  t.ruby_opts = ['-w']
end
