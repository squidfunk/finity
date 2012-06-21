# Copyright (c) 2012 Martin Donath

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'finity/event'
require 'finity/machine'
require 'finity/state'
require 'finity/transition'
require 'finity/version'

module Finity
  class InvalidCallback   < StandardError; end
  class MissingCallback   < StandardError; end
  class InvalidTransition < StandardError; end

  # Class methods to be injected into the including class upon inclusion.
  module ClassMethods
    attr_accessor :machines

    # When inheriting this module, pass the registered machines to the
    # inheriting class after executing potential parent inheritance logic.
    def inherited klass
      super and klass.machines = machines
    end

    # Instantiate a new (optionally named) state machine by accepting a block
    # with state and event (and subsequent transition) definitions.
    def finity name = :default, options = {}, &block
      @machines ||= {}
      @machines[name] = Machine.new self, name, options, &block
    end
  end

  # Inject methods into the including class upon inclusion.
  def self.included base
    base.extend ClassMethods
  end
end