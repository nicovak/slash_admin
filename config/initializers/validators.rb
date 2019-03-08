class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || I18n.t('slash_admin.view.json_not_valid')) unless valid_json?(value) 
  end

  def valid_json?(string)
    # handle parsed already string
    if string.is_a? Hash
      return true
    end
    begin
      !!JSON.parse(string)
    rescue JSON::ParserError
      false
    end
  end
end
