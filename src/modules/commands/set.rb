module Bot::DiscordCommands
  # SET THEB IRTHDAYSIM AA
  module Set
    extend Discordrb::Commands::CommandContainer
    def self.parsedate(day)
      year = 2019
      daye = nil
      month = nil
      gmt = 0

      if day.match?(/(.+)\/(.+)\/(.+) (\+|-|)(.+)/)
        date = day.split('/')[0..2].map(&:to_i)
        month = date[0]
        daye = date[1]
        year = date[2].to_i
        gmt = date.split(' ')[1]
        if gmt.include?(':')
          gmts = gmt.split(':')
          if gmts[1].to_i == 30
            gmt = gmts[0].to_i + 0.5
          end
        end
      elsif day.split(',').length.between?(3, 4)
        date = day.split(',')
        month = date[0]
        daye = date[1]
        year = date[2].to_i
        if date.length > 3
          gmt = date[3]
          if gmt.include?(':')
            gmts = gmt.split(':')
            if gmts[1].to_i == 30
              gmt = gmts[0].to_i + 0.5
            end
          end
        end
      elsif day.split(' ').length.between?(3, 4)
        date = day.split(' ')
        month = date[0]
        daye = date[1]
        year = date[2].to_i
        if date.length > 3
          gmt = date[3]
          if gmt.include?(':')
            gmts = gmt.split(':')
            if gmts[1].to_i == 30
              gmt = gmts[0].to_i + 0.5
            end
          end
        end

        if year.to_s.length <= 2
          if year <= Time.now.year % 100
            year += 2000
          else
            year += 1999
          end
        end

        return [Time.new(year, month, daye, 0, 0, 0), gmt]
      else
        return nil
      end
    end

    command(:set) do |event, *input|
      if input.nil? || input.empty? || input.join(' ').include?('--help') || input.join(' ').include?('-h')
        begin
          event.channel.send_embed do |embed|
          embed.title = "Help for `bday set`"
          embed.add_field(name: "bday set [day], [month], [year], [gmt offset]", value: [
            'Enters your birthday into the system.',
            '**You cannot change this once it has been set!**',
            '',
            "If you don't know what a GMT offset is, [click here](https://www.timeanddate.com/time/map/) and hover over your location on the map. Your GMT offset is the value at the bottom that is highlighted (if the highlighted value at the bottom simply says `UTC`, then your GMT offset is 0).",
            '',
            'Example: `bday set 9, 30, 1999, -4`',
            '',
            "If you mess up setting your birthday, e.g. flipping month and day, type `bday flip` to flip the month and day.",
            '',
            'To test your input, type `bday test [date]`'
          ].join("\n"))
          embed.footer = { text: "Meant day, month? Type bday flip" }
          embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
        break
      end

      yourday = Birthday.find_by(userid: event.user.id)
      if yourday.nil?
        m = event.respond "No birthday for that/you bucko, let's set one!"

        day = input.join(' ')

        output = parsedate(day)

        if output.nil?
          event.respond "Yeah so big brain time. your format isn't supported. kinda sucks. anyway, like and subscribe and try a new format"
          break
        end

        bigdeal = output[0]
        gmt = output[1]

        if gmt > 14
          gmt = 14
        elsif gmt < -11
          gmt = -11
        end

        bigdeal = Time.new(year, month, daye, 0, 0, 0)
        Birthday.create(userid: event.user.id, birthday: bigdeal, offset: gmt)
        begin
          m.delete
          event.channel.send_embed do |embed|
          embed.title = "Birthday Updated for #{event.user.distinct}"
          embed.add_field(name: "Birthday", value: "Set to #{Birthday.find_by(userid: event.user.id).pretty}")
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
          embed.add_field(name: "Birthday", value: "Set to #{yourday.pretty}")
          embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      end
    end

    command(:test) do |event, *input|
      if input.nil? || input.empty?
        event.respond "Please enter a test case."
        break
      end

      day = input.join(' ')

      output = parsedate(day)

      if output.nil?
        event.respond "Yeah so big brain time. your format isn't supported. kinda sucks. anyway, like and subscribe and try a new format"
        break
      end

      bigdeal = output[0]
      gmt = output[1]

      if bigdeal.nil?
        event.respond "Yeah so big brain time. your format isn't supported. kinda sucks. anyway, like and subscribe and try a new format"
        break
      end

      event.respond "Birthday parsed as: #{bigdeal.strftime("%B %-d, %Y")} GMT#{gmt}"
    end
  end
end
