class AttachmentValidator < ActiveModel::EachValidator
  include ActiveSupport::NumberHelper

  def validate_each(record, attribute, value)
    return if value.blank? || !value.attached?
    # この時点で空であれば処理が終了となる。バリデーションの処理自体がスキップされる

    if value.is_a?(ActiveStorage::Attached::Many)
      value.each do |file|
        validate_file(record, attribute, file)
      end
    else
      validate_file(record, attribute, value)
      # ここで value が直接 file 引数に渡される
    end
  end

  private
  
  def validate_file(record, attribute, file)

    has_error = false

    if options[:maximum]
      has_error = true unless validate_maximum(record, attribute, file)
    end

    if options[:content_type]
      has_error = true unless validate_content_type(record, attribute, file)
    end

    file.purge if options[:purge] && has_error
  end


  def validate_maximum(record, attribute, file)
    if file.byte_size > options[:maximum]
      record.errors[attribute] << (options[:message] || "は#{number_to_human_size(options[:maximum])}以下にしてください")
      false
    else
      true
    end
  end

  def validate_content_type(record, attribute, file)
    if file.content_type.match?(options[:content_type])
      true
    else
      record.errors[attribute] << (options[:message] || 'は対応できないファイル形式です')
      false
    end
  end
end
