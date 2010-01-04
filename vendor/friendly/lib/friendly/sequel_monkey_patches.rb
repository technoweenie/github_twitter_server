require 'sequel'

# Out of the box, Sequel uses IS TRUE/FALSE for boolean parameters
# This prevents MySQL from using indexes.
#
# This patch fixes that.
module Sequel
  module SQL
    class BooleanExpression
      def self.from_value_pairs(pairs, op=:AND, negate=false)
        pairs = pairs.collect do |l,r|
          ce = case r
          when Range
            new(:AND, new(:>=, l, r.begin), new(r.exclude_end? ? :< : :<=, l, r.end))
          when Array, ::Sequel::Dataset, SQLArray
            new(:IN, l, r)
          when NegativeBooleanConstant
            new(:"IS NOT", l, r.constant)
          when BooleanConstant
            new(:IS, l, r.constant)
          when NilClass
            new(:IS, l, r)
          when Regexp
            StringExpression.like(l, r)
          else
            new(:'=', l, r)
          end
          negate ? invert(ce) : ce
        end
        pairs.length == 1 ? pairs.at(0) : new(op, *pairs)
      end
    end
  end
end
