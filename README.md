# Finity

**Finity** tries to be an extremly lightweight state machine implementation
with an easily readable syntax. At the time of this writing, **Finity** is
comprised of only ~160 lines of code. It is inspired by [transitions][], a
great state machine implementation tightly integrated with ActiveRecord by
Jakub Kuźma and Timo Rößner.

The aim of **Finity** is to provide a state machine implementation which is as
slim and fast as possible while maintaining a beautiful and readable syntax.
However, if you need ActiveModel/ActiveRecord integration, [transitions][] may
be your weapon of choice.

## Installation

If you use Rails, include this into your Gemfile and run `bundle install` via
command line:

``` ruby
gem 'finity'
```

Otherwise you can install **Finity** with `gem` via command
line:

```
gem install finity
```

## Example

**Finity** can transform any class into a state machine. For example, consider
a state machine modelling an *elevator* in a building with 3 floors: `ground`,
`first` and `second`. The *elevator* can perform the following actions:

* On floors `ground` and `first`, it can go `up` to the floor above.
* On floors `first` and `second`, it can go `down` to the floor below.

*Leaving* (*entering*) a floor, the doors need to `close` (`open`). Also, when
entering a floor or pressing `down` (`up`) on the `ground` (`second`) floor, a
bell should `ring`. The following class models the *elevator*:

``` ruby
class Elevator
  include Finity

  finity :init => :ground do

    state :ground,
      :enter => :open,
      :cycle => :ring,
      :leave => :close

    state :first,
      :enter => :open,
      :leave => :close

    state :second,
      :enter => :open,
      :cycle => :ring,
      :leave => :close

    event :up do
      transitions :from => [:ground], :to => :first
      transitions :from => [:first, :second], :to => :second
    end

    event :down do
      transitions :from => [:ground, :first], :to => :ground
      transitions :from => [:second], :to => :first
    end
  end

  def up
    event! :up
  end
  
  def down
    event! :down
  end

  private

  def open
    ring and puts "Doors opening on the #{@current} floor."
  end

  def ring
    puts "Ring!"
  end

  def close
    puts "Doors closing..."
  end
end
```

While the different floors are modelled as *states*, the actions `up` and
`down` are modelled as *events*. The *elevator* is initialized on the `ground`
floor, which in this case is redundant, since, by default, **Finity** treats
the first state as the initial state. The instance variable `@current` holds
the current floor/state. The methods which are invoked upon entering, leaving
or cycling (staying in a state) are declared private, as they should not be
accessible from the outside. Only `up` and `down` are public.

We can now create an instance of the *elevator* and play with it:

``` ruby
elevator = Elevator.new
elevator.down # => Ring!
elevator.up   # => Doors closing...
              # => Ring!
              # => Doors opening on the first floor.
elevator.up   # => Doors closing...
              # => Ring!
              # => Doors opening on the second floor.
elevator.up   # => Ring!
elevator.down # => Doors closing.
              # => Ring!
              # => Doors opening on the first floor.
```

While this example is very basic, it clearly shows the power of finite state
machines to model complex systems with a finite set of states and events
triggering transitions between them.

## States, Events and Transitions

### States

A state is uniquely identified by its name and *can* define functions to be
executed upon entering, leaving and cycling (staying inside). These functions
can be referenced as *Symbols*, *Strings*, *Procs* or *Lambdas*:

``` ruby
state :ground,
  :enter => :open,                           # Symbols must reference (private) methods
  :cycle => proc { ring },                   # Procs are evaluated in the context of the instance
  :leave => -> elevator { elevator.close }   # Lambdas are provided with the instance as an argument
```

If there are several states with the same set of transition functions, they can
be defined in a single run. Considering our example, the `ground` and the
`second` floor bear the same set of actions, so we can combine them:

``` ruby
state [:ground, :second],
  :enter => :open,
  :cycle => :ring,
  :leave => :close
```

### Events and Transitions

Events are like states identified by their name and may define an arbitrary
number of transitions between different states. The transitions are evaluated
in the order in which they are defined. A transition is executed, if it is found
to be valid, which means that it contains the current state in `from` and the
`if`-guard, if defined, returns `true`. If no valid transition is found for a
given event, **Finity** will raise an error. Starting with our example, the
minimal information needed for the `up`-event is:

``` ruby
event :up do
  transitions :from => [:ground], :to => :first
  transitions :from => [:first, :second], :to => :second
end
```

Like for states, multiple events can be defined in a single run with the same
set of transitions:

``` ruby
event [:up, :down] do
  ...
end
```

In case of an event, we sometimes want to take different actions from the same
state, so we need to specify *guards*. If a transition specifies a guard, it is
only considered valid if the guard returns `true`. For example, if we want to
deactivate the buttons when the elevator is `stuck`, we do the following:

``` ruby
event :up do
  transitions :from => [:ground], :to => :first,
    :if => :not_stuck?
  transitions :from => [:first, :second], :to => :second,
    :if => :not_stuck?
  transitions :from => [:ground, :first, :second, :stuck], :to => :stuck
end
```

This implies, that we defined a new state called `stuck` and a method to
determine whether the elevator is stuck at the moment. Unless `not_stuck?`
returns `true`, the elevator will keep working as in our original example.
Otherwise, only the last transition is valid and the elevator will enter
the `stuck` state from any other state.

Additionally, we can define functions to be executed for specific transitions
only. This can be achieved with `do`:

``` ruby
event :up do
  transitions :from => [:ground], :to => :first,
    :if => :not_stuck?
  transitions :from => [:first, :second], :to => :second,
    :if => :not_stuck?
  transitions :from => [:ground, :first, :second, :stuck], :to => :stuck,
    :do => proc { puts "The elevator is stuck" }
end
```

Now, if the elevator is stuck, a message is displayed everytime a button is
pushed. Like for states, all functions can be defined as *Symbols*, *Strings*,
*Procs* or *Lambdas*.

### Definitions

**Finity** defines two methods on the including instance:

* `state? name`: Returns `true` if the state machine is in state `name`.
* `event! name`: Triggers event `name`.

Those methods can also be accessed from the outside. The current state is held
within the instance variable `@current`, contained in the including instance.

## License

Copyright (c) 2012 Martin Donath

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[transitions]: https://github.com/troessner/transitions