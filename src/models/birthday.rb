class Birthday < ActiveRecord::Base
  def pretty
    gmt = offset
    gmt = "+#{gmt}" if offset.positive?
    if gmt.zero?
      gmt = ''
    end

    formatstring = if hideyear
                     "%B %-d"
                   else
                     "%B %-d, %Y"
                   end

    "#{birthday.strftime(formatstring)} GMT#{gmt}"
  end
end
