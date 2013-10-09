#Rusche

##Introduction

Rusche is a Ruby-to-Scheme transcompiler. It is pronounced "ROO-skee".

The following are supported features:
* Conditionals, converted from ```&&```, ```||``` format to ```(and a b)```, ```(or a b)```.
* Constants defined using either functions or the const construct.
* Conditional branches, converted from ```if elsif else``` format to ```cond```.
* Math expressions, converted from ```a + b``` format to ```(+ a b)```.
* n-level deep nesting of conditions, expressions, and function calls.

Rusche doesn't support all features of either language. It can only transcompile a small, restricted
subset of Ruby. These restrictions are:
* No state variables (thus no mutation).
* All code must be contained within one module.
* All code must be within instance methods of that one module.
* Most Ruby standard library functions cannot be transcompiled. Exceptions are: Array.push => cons val List
* All method definitions must contain only one expression. Any expressions after the first are ignored.

##Requirements

* [Ruby Parser gem.](https://rubygems.org/gems/ruby_parser)

##Examples

###General Test

```ruby
module ToCC
  SOME_CONST = 5
  MY_CONSTANT = (SOME_CONST * (3 - SOME_CONST)) / 72

  def testme
    sleep
  end

  def othertest(myp)
    ham(MY_CONSTANT, sandwich(SOME_CONST, myp))
  end

  def test
    if a > 3
      1
    elsif b < 2
      2
    else
      3
    end
  end

  def dat_shit_cray
    if ((5 && 2 && 3) || 7) && !9
      8
    else
      5
    end
  end
end
```

```scheme
(define (SOME_CONST 5))

(define (MY_CONSTANT (/ (* SOME_CONST (- 3 SOME_CONST)) 72)))

(define (testme)
  (sleep))

(define (othertest myp)
  (ham MY_CONSTANT (sandwich SOME_CONST myp)))

(define (test)
  (cond
    [(> (a) 3) 1]
    [(< (b) 2) 2]
    [else (3)]))

(define (dat_shit_cray)
  (cond
    [(and (or (and 5 (and 2 3)) 7) (not 9)) 8]
    [else (5)]))
```

### Fibonacci (Unoptimized)

```ruby
module Fibonacci
  def fib(n)
    if n == 0
      0
    elsif n == 1
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end
end
```

```scheme
(define (fib n)
  (cond
    [(= n 0) 0]
    [(= n 1) 1]
    [else (+ (fib (- n 1)) (fib (- n 2)))]))
```

##How to Use

Some tests are included in this repo. The main code is in ```rusche.rb```. To run:
```ruby rusche.rb```

To select a different file to transcompile (defaults to test.rb), edit the source near the bottom.
