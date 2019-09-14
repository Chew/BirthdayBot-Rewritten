module Bot::DiscordCommands
  # GET THE IRTHDAYSIM AA
  module Get
    extend Discordrb::Commands::CommandContainer
    command(:get) do |event, user|
      day = Birthday.find_by(userid: user || event.user.id)
      if day.nil?
        event.respond "No birthday for that/you bucko"
      else
        event.respond "yeah yeah your big day is #{day.birthday}"
      end
    end
  end
end
