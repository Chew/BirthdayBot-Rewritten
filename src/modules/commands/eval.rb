module Bot::DiscordCommands
  # Command for evaluating Ruby code in an active bot.
  # Only the `event.user` with matching discord ID of `CONFIG.owner`
  # can use this command.
  module Eval
    extend Discordrb::Commands::CommandContainer
    command(:eval, help_available: false) do |event, *code|
      break unless event.user.id == CONFIG.owner

      begin
        event.channel.send_embed do |e|
          e.title = '**Evaluated Successfully**'

          prefix = event.message.content.tr("\n", ' ').gsub(code.join(' '), '')

          evaluated = eval event.message.content.gsub(prefix, '').tr("\n", ';')

          e.description = evaluated.to_s
          e.color = '00FF00'
        end
      rescue StandardError, ScriptError => e
        event.channel.send_embed do |embed|
          embed.title = '**Evaluation Failed!**'

          embed.description = e.to_s
          embed.color = 'FF0000'
        end
      end
    end
  end
end
