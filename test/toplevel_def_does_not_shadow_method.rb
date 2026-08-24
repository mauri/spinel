# A top-level `def` is a private instance method on Object, so a class's own
# method wins for an implicit-self call inside it. Codegen tried the top-level
# free function first and returned before ever consulting self's class, so any
# top-level helper captured every unqualified call to a same-named method.
class Greeter
  def greeting; "from the class"; end
  def render; greeting; end
end

def greeting; "from the top level"; end

p Greeter.new.render
p greeting

# the same through an attr_reader, where the arities also differ
class Labelled
  attr_reader :label
  def initialize(label); @label = label; end
  def render; "<#{label}>"; end
end

def label(prefix); "#{prefix}!"; end

p Labelled.new("a").render
p label("b")

# an inherited method wins too -- the chain is walked, not just the class
class Base
  def kind; "base"; end
end
class Derived < Base
  def describe; kind; end
end

def kind; "top"; end

p Derived.new.describe

# with no method of that name on self's chain, the free function is still the
# one that answers
class Plain
  def call_helper; helper(3); end
end

def helper(n); n * 2; end

p Plain.new.call_helper

# inside a class method, a bare call still reaches the free function rather
# than the same-named instance method
class Factory
  def build; "instance"; end
  def self.make; build_it; end
end

def build_it; "free function"; end

p Factory.make

# a call carrying a block resolves the same way -- the inliner sees self's
# yielding method, not the same-named top-level one
class Collector
  def each_item; yield "class"; end
  def go
    r = []
    each_item { |x| r << x }
    r
  end
end

def each_item; yield "top level"; end

p Collector.new.go

# template method: implemented only in a subclass, still reached from the base
class Step
  def run; step; end
end
class Doubled < Step
  def step; "sub"; end
end

def step; "top"; end

p Doubled.new.run
