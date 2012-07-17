# Copyright (c) 2012 Martin Donath <md@struct.cc>

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

module Finity
  class Machine
    attr_accessor :states, :events

    # Initialize a new state machine within the provided class and define
    # methods for querying the current state and initiating transitions.
    # The current state must be bound to the including instance, otherwise
    # there may be problems due to caching between requests.
    def initialize klass, options = {}, &block
      @klass, @states, @events = klass, {}, {}
      instance_eval &block if block_given?
      @initial = current = options.delete(:initial) || initial
      @klass.send :define_method, :current do |*args|
        unless self.instance_variable_defined? :@current
          self.instance_variable_set :@current, current
        end
        self.instance_variable_get :@current
      end
      @klass.send :define_method, :event! do |*args|
        self.instance_variable_set :@current, (
          klass.finity.update self, self.current, *args
        )
      end
      @klass.send :define_method, :state? do |*args|
        klass.finity.current.name.eql? *args
      end
    end

    # Return the name of the initial state.
    def initial
      @initial ||= @states.keys.first unless @states.first.nil?
    end

    # Register a state.
    def state name, options = {}
      @states[name] = State.new name, options
    end

    # Register an event and evaluate the block for transitions.
    def event name, options = {}, &block
      @events[name] = Event.new name, options, &block
    end

    # An event occured, so update the state machine by evaluating the
    # transition functions and notify the left and entered state.
    def update object, current, event
      now ||= @states[current]
      if state = @events[event].handle(object, now)
        if @states[state].nil?
          raise InvalidState, "Invalid state #{state}"
        end
        now.leave object
        now = @states[current = state]
        now.enter object
      end
      current
    end
  end
end