class Birthday < ActiveRecord::Base
  def pretty
    gmt = offset
    if gmt - gmt.to_i == 0.5
      gmt = "#{offset.to_i}:30"
    else
      gmt = offset.to_i
    end

    gmt = "+#{gmt}" if offset.positive?
    if offset.zero?
      gmt = '0'
    end

    formatstring = if hideyear
                     "%B %-d"
                   else
                     "%B %-d, %Y"
                   end

    "#{birthday.strftime(formatstring)} GMT#{gmt}"
  end

  def time_friendly_offset
    gmt = offset
    hour = "00"
    minute = "00"
    if offset - offset.to_i == 0.5
      minute = "30"
    end
    if offset.to_i.abs.to_s.length == 2
      hour = offset.to_i.abs.to_s
    else
      hour = "0#{offset.to_i.abs}"
    end
    if offset.negative?
      hour = "-#{hour}"
    else
      hour = "+#{hour}"
    end
    "#{hour}:#{minute}"
  end
end
