module Bot::DiscordCommands
  # SET THEB IRTHDAYSIM AA
  module Set
    extend Discordrb::Commands::CommandContainer
    command(:set, min_args: 1) do |event, *input|
      yourday = Birthday.find_by(userid: event.user.id)
      if yourday.nil?
        m = event.respond "No birthday for that/you bucko, let';s set one!"

        year = 2019
        daye = nil
        month = nil
        gmt = 0

        day = input.join(' ')

        if day.match?(/(.+)\/(.+)\/(.+) (\+|-|)(.+)/)
          date = day.split('/')[0..2].map(&:to_i)
          year = date.max
          date.delete_if { |e| e == year }
          month = date[0]
          daye = date[1]
          gmt = date.split(' ')[1].to_i
        elsif day.split(',').length.between?(3, 4)
          date = day.split(',').map(&:to_i)
          year = date.max
          date.delete_if { |e| e == year }
          month = date[0]
          daye = date[1]
          gmt = date[2]
        elsif day.split(' ').length.between?(3, 4)
          date = day.split(' ').map(&:to_i)
          year = date.max
          date.delete_if { |e| e == year }
          month = date[0]
          daye = date[1]
          gmt = date[2]
        else
          event.respond "Yeah so big brain time. your format isn't supported. kinda sucks. anyway, like and subscribe and try a new format"
          break
        end

        bigdeal = Time.new(year, month, daye, 0, 0, 0)
        message = event.respond "Set your birthday to #{bigdeal.strftime("%B %-d, %Y")} with gmt big boy of GMT #{gmt}. Not what you meant? well wait until i add a way to make sure BTW IT WASNT SAVED THE DB COMMAND IS NO HERE"

        nil
      else
        event.respond "You have a birthday set already... wtf."
      end
    end
  end
end
