# Copyright (c) 2012 Martin Donath <md@struct.cc>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

module Finity
  class Event
    attr_accessor :name

    # Initialize a new event and execute the block which holds the
    # transition definitions.
    def initialize name, options = {}, &block
      @name, @transitions = name, {}
      instance_eval &block if block_given?
    end

    # Add a transition to the event.
    def transitions options = {}
      transition = Transition.new options
      [options[:from]].flatten.each do |from|
        @transitions[from] ||= []
        @transitions[from] << transition
      end
    end

    # Handle the current state and execute the first allowed transition.
    def handle object, state
      raise InvalidState, "No match for (:#{state.name}) on (:#{name})" unless
        @transitions.key? state.name
      @transitions[state.name].find do |transition|
        name = transition.handle object
        return name unless name.nil?
      end
    end
  end
end