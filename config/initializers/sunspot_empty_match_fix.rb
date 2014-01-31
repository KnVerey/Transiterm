module Sunspot

module Query
  module Restriction
    class EqualTo
      def to_positive_boolean_phrase
        if @value == ''
          "#{escape(@field.indexed_name)}:[* TO \"\"]"
        elsif !@value.nil?
          super
        else
          "#{escape(@field.indexed_name)}:[* TO *]"
        end
      end
    end
  end
end
end