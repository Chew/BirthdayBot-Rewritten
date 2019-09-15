module Bot::DiscordCommands
  # GET THE IRTHDAYSIM AA
  module Get
    extend Discordrb::Commands::CommandContainer
    command(:get) do |event, user|
      target = if user.nil?
                 event.user
               elsif !Bot::BOT.user(user.to_i).nil?
                 Bot::BOT.user(user)
               elsif !Bot::BOT.parse_mention(user).nil?
                 Bot::BOT.parse_mention(user)
               end

      day = Birthday.find_by(userid: target.id)
      if day.nil?
        begin
          event.channel.send_embed do |embed|
            embed.title = "Birthday Information for #{target.distinct}"
            embed.add_field(name: "Birthday", value: "No birthday set!")
            embed.color = 0xFF685F
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      else
        begin
          event.channel.send_embed do |embed|
            embed.title = "Birthday Information for #{target.distinct}"
            embed.add_field(name: "Birthday", value: "#{day.strftime("%B %-d, %Y")} GMT #{day.offset}")
            embed.colour = 0x25E86F
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      end
    end
  end
end
