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
  class Transition

    # A transition must define at least one original state (:from) and
    # a state it transitions to (:to).
    def initialize options
      @from, @to, @if, @do = options.values_at(:from, :to, :if, :do)
      if @from.nil? or @to.nil?
        raise MissingCallback, 'A transition demands states at least one original ' +
                               'state (:from) and a state it transitions to (:to)'
      end
    end

    # Check, whether the current transition is allowed and execute it.
    def handle object
      if @if.nil? or execute object, @if
        execute object, @do unless @do.nil?
        @to
      end
    end

    private

    # Internal method to execute a provided action on a given object. The
    # action can be a symbol, string, proc or lambda function.
    def execute object, action
      case action
      when Symbol, String
        object.send action
      when Proc
        action.lambda? and action.call object or object.instance_eval &action
      else
        raise InvalidCallback, 'Only symbols, strings, procs and lambdas may ' +
                               'be passed as callbacks'
      end
    end
  end
end