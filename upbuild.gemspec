# -*- encoding: utf-8 -*-
#
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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upbuild/version'

Gem::Specification.new do |gem|
  gem.name          = "upbuild"
  gem.version       = Upbuild::VERSION
  gem.authors       = ["Greg Whiteley"]
  gem.email         = ["whitty@users.forge.net"]
  gem.description   = %q{Simple directory tree build helper}
  gem.summary       = %q{Simple directory tree build helper}
  gem.homepage      = "https://github.com/whitty/upbuild"
  gem.license       = "GPL"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", ">= 2.10.0"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
