module Bot::DiscordCommands
  # Admins 1
  module Admin
    extend Discordrb::Commands::CommandContainer
    command(:reset) do |event, user|
      unless Bot::BOT.server(473364634301366273).member(event.user.id).roles.include?(Bot::BOT.server(473364634301366273).role(474304351091949578))
        event.respond "NO ADMIN? NO RESET!"
        break
      end

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
            embed.add_field(name: "Birthday", value: "No birthday set for this user!")
            embed.color = 0xFF685F
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      else
        day.destroy!
        begin
          event.channel.send_embed do |embed|
            embed.title = "Birthday Updated for #{target.distinct}"
            embed.add_field(name: "Birthday", value: "Cleared Birthday!")
            embed.colour = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      end
    end
  end
end
