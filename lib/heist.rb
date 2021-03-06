require 'forwardable'
require 'rational'
require 'complex'

require 'rubygems'
require 'treetop'

# +Heist+ is the root module for all of Heist's components, and hosts a few
# utility methods that don't belong anywhere else. See the README for an
# overview of Heist's features.
module Heist
  VERSION = '0.3.3'
  
  ROOT_PATH    = File.expand_path(File.dirname(__FILE__))
  PARSER_PATH  = ROOT_PATH + '/parser/'
  RUNTIME_PATH = ROOT_PATH + '/runtime/'
  BUILTIN_PATH = ROOT_PATH + '/builtin/'
  LIB_PATH     = ROOT_PATH + '/stdlib/'
  
  require PARSER_PATH + 'ruby'
  require PARSER_PATH + 'scheme'
  require PARSER_PATH + 'nodes'
  require RUNTIME_PATH + 'runtime'
  require ROOT_PATH + '/trie'
  require ROOT_PATH + '/repl'
  
  LOAD_PATH = [BUILTIN_PATH, LIB_PATH]
  FILE_EXTS = [""] + %w[.rb .scm .ss]
  
  class HeistError            < StandardError; end
  class RuntimeError          < HeistError; end
  class UndefinedVariable     < RuntimeError; end
  class SyntaxError           < RuntimeError; end
  class MacroError            < SyntaxError; end
  class MacroTemplateMismatch < MacroError; end
  class TypeError             < RuntimeError; end
  class BadIndexError         < TypeError; end
  class ImmutableError        < TypeError; end
  
  class << self
    # Accepts either a string of Scheme code or an array of Ruby data and parses
    # into a +Cons+ list structure. Scheme code is converted to a +Program+,
    # while a Ruby array is converted to a single list expression. Returns +nil+
    # if the input cannot be parsed successfully.
    def parse(source)
      @scheme ||= SchemeParser.new
      @ruby   ||= RubyParser.new
      parser = (String === source) ? @scheme : @ruby
      parser.parse(source)
    end
    
    # Returns the result of evaluating the given +Expression+ in the given +Scope+.
    # If the first argument is not an +Expression+ it will be returned unaltered.
    def evaluate(expression, scope)
      Runtime::Expression === expression ?
          expression.eval(scope) :
          expression
    end
    
    # Returns the result of dividing the first argument by the second. If both
    # arguments are integers, returns a rational rather than performing
    # integer division as Ruby would normally do.
    def divide(op1, op2)
      [op1, op2].all? { |value| Integer === value } ?
          Rational(op1, op2) :
          op1.to_f / op2
    end
    
    # Returns a string representation of the object suitable for display on the
    # command line. Some built-in Ruby types need special handling to display
    # according to Scheme conventions.
    def stringify(object)
      case object
      when Runtime::Character, String then object.inspect
      when TrueClass  then '#t'
      when FalseClass then '#f'
      else object.to_s
      end
    end
    
  end
end

