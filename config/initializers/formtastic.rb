# encoding: utf-8

# Set the default text field size when input is a string. Default is nil.
# Formtastic::SemanticFormBuilder.default_text_field_size = 50

# Set the default text area height when input is a text. Default is 20.
# Formtastic::SemanticFormBuilder.default_text_area_height = 5

# Set the default text area width when input is a text. Default is nil.
# Formtastic::SemanticFormBuilder.default_text_area_width = 50

# Should all fields be considered "required" by default?
# Rails 2 only, ignored by Rails 3 because it will never fall back to this default.
# Defaults to true.
# Formtastic::SemanticFormBuilder.all_fields_required_by_default = true

# Should select fields have a blank option/prompt by default?
# Defaults to true.
# Formtastic::SemanticFormBuilder.include_blank_for_select_by_default = true

# Set the string that will be appended to the labels/fieldsets which are required
# It accepts string or procs and the default is a localized version of
# '<abbr title="required">*</abbr>'. In other words, if you configure formtastic.required
# in your locale, it will replace the abbr title properly. But if you don't want to use
# abbr tag, you can simply give a string as below
# Formtastic::SemanticFormBuilder.required_string = "(required)"

# Set the string that will be appended to the labels/fieldsets which are optional
# Defaults to an empty string ("") and also accepts procs (see required_string above)
# Formtastic::SemanticFormBuilder.optional_string = "(optional)"

# Set the way inline errors will be displayed.
# Defaults to :sentence, valid options are :sentence, :list, :first and :none
# Formtastic::SemanticFormBuilder.inline_errors = :sentence
# Formtastic uses the following classes as default for hints, inline_errors and error list

# If you override the class here, please ensure to override it in your formtastic_changes.css stylesheet as well
# Formtastic::SemanticFormBuilder.default_hint_class = "inline-hints"
# Formtastic::SemanticFormBuilder.default_inline_error_class = "inline-errors"
# Formtastic::SemanticFormBuilder.default_error_list_class = "errors"

# Set the method to call on label text to transform or format it for human-friendly
# reading when formtastic is used without object. Defaults to :humanize.
# Formtastic::SemanticFormBuilder.label_str_method = :humanize

# Set the array of methods to try calling on parent objects in :select and :radio inputs
# for the text inside each @<option>@ tag or alongside each radio @<input>@. The first method
# that is found on the object will be used.
# Defaults to ["to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]
# Formtastic::SemanticFormBuilder.collection_label_methods = [
#   "to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]

# Formtastic by default renders inside li tags the input, hints and then
# errors messages. Sometimes you want the hints to be rendered first than
# the input, in the following order: hints, input and errors. You can
# customize it doing just as below:
# Formtastic::SemanticFormBuilder.inline_order = [:input, :hints, :errors]

# Additionally, you can customize the order for specific types of inputs.
# This is configured on a type basis and if a type is not found it will
# fall back to the default order as defined by #inline_order
# Formtastic::SemanticFormBuilder.custom_inline_order[:checkbox] = [:errors, :hints, :input]
# Formtastic::SemanticFormBuilder.custom_inline_order[:select] = [:hints, :input, :errors]

# Specifies if labels/hints for input fields automatically be looked up using I18n.
# Default value: false. Overridden for specific fields by setting value to true,
# i.e. :label => true, or :hint => true (or opposite depending on initialized value)
Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true

class GoogleDocStyleBuilder < Formtastic::SemanticFormBuilder
  
  # Overrides the input generator to suppress the normal hint
  # Track source:  https://github.com/justinfrench/formtastic/raw/master/lib/formtastic.rb
  def input(method, options = {})
    options[:required] = method_required?(method) unless options.key?(:required)
    options[:as]     ||= default_input_type(method, options)

    html_class = [ options[:as], (options[:required] ? :required : :optional) ]
    html_class << 'error' if has_errors?(method, options)

    wrapper_html = options.delete(:wrapper_html) || {}
    wrapper_html[:id]  ||= generate_html_id(method)
    wrapper_html[:class] = (html_class << wrapper_html[:class]).flatten.compact.join(' ')

    if options[:input_html] && options[:input_html][:id]
      options[:label_html] ||= {}
      options[:label_html][:for] ||= options[:input_html][:id]
    end

    input_parts = (self.class.custom_inline_order[options[:as]] || self.class.inline_order).dup

    # PATCH: remove hints from sequence; we'll draw them as part of the label
    input_parts = input_parts - [:hints]
    
    input_parts = input_parts - [:errors, :hints] if options[:as] == :hidden

    list_item_content = input_parts.map do |type|
      send(:"inline_#{type}_for", method, options)
    end.compact.join("\n")

    return template.content_tag(:li, Formtastic::Util.html_safe(list_item_content), wrapper_html)
  end
  
  def label(method, options_or_text=nil, options=nil)
    if options_or_text.is_a?(Hash)
      return "" if options_or_text[:label] == false
      options = options_or_text
      text = options.delete(:label)
    else
      text = options_or_text
      options ||= {}
    end

    text = localized_string(method, text, :label) || humanized_attribute_name(method)
    text += required_or_optional_string(options.delete(:required))
    text = Formtastic::Util.html_safe(text)

    # PATCH: add inline hints
    text += inline_hints_for(method, options_for_label(options))

    # special case for boolean (checkbox) labels, which have a nested input
    if options.key?(:label_prefix_for_nested_input)
      text = options.delete(:label_prefix_for_nested_input) + text
    end

    input_name = options.delete(:input_name) || method
    super(input_name, text, options)
  end
  
  def legend_tag(method, options = {})
    if options[:label] == false
      Formtastic::Util.html_safe("")
    else
      text = localized_string(method, options[:label], :label) || humanized_attribute_name(method)
      text += required_or_optional_string(options.delete(:required))
      text = Formtastic::Util.html_safe(text)

      # PATCH: add inline hints
      text += inline_hints_for(method, options_for_label(options))

      template.content_tag :legend, template.label_tag(nil, text, :for => nil), :class => :label
    end
  end
  
end

# You can add custom inputs or override parts of Formtastic by subclassing SemanticFormBuilder and
# specifying that class here.  Defaults to SemanticFormBuilder.
Formtastic::SemanticFormHelper.builder = GoogleDocStyleBuilder
