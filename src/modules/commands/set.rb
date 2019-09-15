module Bot::DiscordCommands
  # SET THEB IRTHDAYSIM AA
  module Set
    extend Discordrb::Commands::CommandContainer
    command(:set, min_args: 1) do |event, *input|
      yourday = Birthday.find_by(userid: event.user.id)
      if yourday.nil?
        m = event.respond "No birthday for that/you bucko, let's set one!"

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
          m.edit "Yeah so big brain time. your format isn't supported. kinda sucks. anyway, like and subscribe and try a new format"
          break
        end

        bigdeal = Time.new(year, month, daye, 0, 0, 0)
        Birthday.create(userid: event.user.id, birthday: bigdeal, offset: gmt)
        begin
          m.delete
          event.channel.send_embed do |embed|
            embed.title = "Birthday Updated for #{event.user.distinct}"
            embed.add_field(name: "Birthday", value: "Set to #{bigdeal.strftime("%B %-d, %Y")} GMT #{gmt}")
            embed.footer = { text: "Meant day, month? Type bday flip" }
            embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      else
        event.respond "You have a birthday set already... See it with `bday get`."
      end
    end

    command(:flip) do |event|
      yourday = Birthday.find_by(userid: event.user.id)
      if yourday.nil?
        event.respond "You don't have a Birthday set, set one with `bday set`."
      else
        if yourday.flipped?
          event.respond "You have already flipped your Birthday once. If you need help, go to the support server with `bday support`"
          break
        end

        if (yourday.created.to_i - Time.now.to_i) > 600
          event.respond "You set your Birthday too long ago and can no longer flip it. If you need help, go to the support server with `bday support`"
          break
        end

        newday = Time.new(yourday.birthday.year, yourday.birthday.day, yourday.birthday.month)
        yourday.birthday = newday
        yourday.flipped = 1
        yourday.save!

        begin
          event.channel.send_embed do |embed|
            embed.title = "Birthday Updated for #{event.user.distinct}"
            embed.add_field(name: "Birthday", value: "Set to #{newday.strftime("%B %-d, %Y")} GMT #{yourday.offset}")
            embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      end
    end
  end
end
