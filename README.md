# Finity

**Finity** tries to be an extremly lightweight state machine implementation with an easily readable syntax
which is essential if you have tens or hundreds of transitions. It is inspired by [transitions][], 
a great state machine implementation tightly integrated with ActiveRecord by Jakub Kuźma and Timo Rößner.

[https://github.com/troessner/transitions][transitions]

The goal of **Finity** is to provide a state machine implementation which is as slim and fast as possible
while maintaining a beautiful and readable syntax. If you need ActiveModel/ActiveRecord integration,
*transitions* is your weapon of choice. However, if you only need a plain state machine implementation
which is optimized for readability and efficiency, give **Finity** a spin.

## Installation

If you use Rails, include this into your Gemfile and run `bundle install` via command line:

```
gem 'finity'
```

If you're not using Rails, you can install **Finity** with `gem` via command line:

```
gem install finity
```

## Usage

**Finity** can transform any class into a state machine. The only thing you have to do is to include it
and define some transitions. For example, consider a state machine modelling the different states of reading
the contents of a file:

```
class Example
  include Finity

  finity :init => :opened do

    state :opened,
      :enter => proc { @file = File.open '...' }

    state :reading
      :enter => proc { process @file.readline }

    state :closed
      :enter => proc { @file.close '...' }

    event :read do
      transitions :from => [:opened, :reading], :to => :reading,
        :if => proc { not @file.eof? }
        :do => proc { log 'reading next line...' }

      transitions :from => [:opened, :reading], :to => :reading,
        :do => proc { log 'reached end of file...' }
    end

    event :close do
      transitions :from => [:opened, :reading], :to => :closed,
        :do => proc { log 'closing...' }
    end
  end
end
```

## States

A state is defined by its name and can define transition functions upon entering and leaving the state.
These functions can be either referenced as Symbols, Strings, Procs or Lambda:

```
state :some_state_,
  :enter => proc { do_something and some_other_thing },
  :leave => :execute_leave_action!
```

## Events and Transitions

Events are like states defined by their names and can trigger several transitions from several states 
to other states. The transitions are evaluated in the order they are defined. If a valid transition is
found, the execution is stopped and the transition performed:

```
event :some_event do
  transitions :from => [:some_state, :another_state], :to => :another_state,
    :if => proc { is_some_condition_true? },
    :do => :execute_something_upon_transition

  transitions :from => [:some_state], :to => :another_state,
    :do => :execute_something_else
end
```

Transitions can be guarded by decision functions (`:if`) and execute another function upon successful
matching (`:do`). Transitions are triggered by the method `event!` which is defined for the including
object. Many other state machine implementations define one method for each event and for each state,
however, **Finity** tries to be as minimally invasive as possible:

```
  object = Example.new
  if object.state? :some_state
    object.event! :some_event
  end
```

[transitions]: https://github.com/troessner/transitions