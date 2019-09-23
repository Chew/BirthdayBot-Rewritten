module Bot::DiscordCommands
  # Commands for how great the bot is uwu
  module About
    extend Discordrb::Commands::CommandContainer

    command(:help, aliases: [:about]) do |event|
      begin
        event.channel.send_embed do |embed|
          embed.title = 'Welcome to the Birthdays Bot'
          embed.colour = '36399A'
          embed.description = "The Birthdays bot helps you and your friends'* birthdays!!\n\n\n*obviously assuming you have friends."

          embed.add_field(name: 'Commands', value: 'Command list can be found with `bday commands`', inline: true)
          embed.add_field(name: 'Invite me!', value: 'You can invite me to your server with [this link](https://discordapp.com/oauth2/authorize?client_id=620430054857506826&permissions=18432&scope=bot).', inline: true)
          embed.add_field(name: 'Help Server', value: 'Click [me](https://discord.gg/FFtFJgb) to join the help server.', inline: true)
          embed.add_field(name: 'More Bot Stats', value: 'Run `bday info` to see more stats!', inline: true)
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Bruh Moment, bot needs Embed Links permissions to function'
      end
    end

    command(:commands) do |event|
      begin
        event.channel.send_embed do |embed|
          embed.title = 'BirthdaysBot Commands'
          embed.description = "Get help on most commands by adding `-h` to the command. E.g. `bday set -h`"
          embed.colour = '36399A'

          embed.add_field(name: 'Bot Commands', value: [
            '`bday help` - Find bot help',
            '`bday commands` - Find bot commands',
            '`bday ping` - Ping the bot',
            '`bday invite` - Invite the bot',
            '`bday info` - Find stats on the bot',
            '`bday servers` - See bot server stats'
          ].join("\n"), inline: false)

          embed.add_field(name: 'Birthday Commands', value: [
            '`bday get (user)` - Get a user\'s Birthday, leave blank for yours.',
            '`bday set [birthday]` - Set your birthday, prefer mm/dd/yyyy gmt. Supply `--help` for more info.',
            '`bday flip` - Flips your Birthday Month/Year, can only be used once.'
          ].join("\n"), inline: false)

          embed.add_field(name: 'Bot Profile Commands', value: [
            '`bday profile` - See your profile.',
            #'`bday set year (hide|show)` - Show/hide your birth year.'
          ].join("\n"), inline: false)
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Bruh Moment, bot needs Embed Links permissions to function'
      end
    end

    command(:donate) do |event|
      begin
        event.channel.send_embed do |embed|
          embed.title = 'Donate to BirthdaysBot!'

          embed.description = 'I have various open donation windows.'

          embed.add_field(name: 'Money', value: 'You can donate money [here](https://donate.chew.pw).')
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Bruh Moment, bot needs Embed Links permissions to function'
      end
    end

    command(:ping, min_args: 0, max_args: 1) do |event, noedit|
      if noedit == 'noedit'
        event.respond "Pong! Time taken: #{((Time.now - event.timestamp) * 1000).to_i} milliseconds."
      else
        m = event.respond('Pinging...')
        m.edit "Pong!! Time taken: #{((Time.now - event.timestamp) * 1000).to_i} milliseconds."
      end
    end

    command(:invite) do |event|
      begin
        event.channel.send_embed do |embed|
          embed.description = "[**Invite Me!**](https://discordapp.com/oauth2/authorize?client_id=620430054857506826&permissions=18432&scope=bot)\n[**Join The Help Server**](https://discord.gg/NFuygsZ)"
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Hello! Invite me to your server here: <https://discordapp.com/oauth2/authorize?client_id=620430054857506826&permissions=18432&scope=bot>. Join my help server here: https://discord.gg/NFuygsZ'
      end
    end

    command(:info, aliases: [:bot]) do |event|
      t = Time.now - Starttime
      mm, ss = t.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      days = format("%d days\n", dd) if dd != 0
      hours = format("%d hours\n", hh) if hh != 0
      mins = format("%d minutes\n", mm) if mm != 0
      secs = format('%d seconds', ss) if ss != 0

      commits = `git rev-list master | wc -l`.to_i

      botversion = if commits.zero?
                     ''
                   else
                     "Commit: #{commits}"
                   end

      begin
        event.channel.send_embed do |e|
          e.title = 'Birthdays Bot Stats!'

          e.add_field(name: 'Author', value: event.bot.user(CONFIG.owner).distinct, inline: true)
          e.add_field(name: 'Code', value: '[Code on GitHub](https://github.com/Chew/BirthdaysBot)', inline: true)
          e.add_field(name: 'Bot Version', value: botversion, inline: true) unless botversion == ''
          e.add_field(name: 'Library', value: 'discordrb 3.3.0', inline: true)
          e.add_field(name: 'Uptime', value: "#{days}#{hours}#{mins}#{secs}", inline: true)
          e.add_field(name: 'Server Count', value: event.bot.servers.count, inline: true)
          # e.add_field(name: 'Commands Ran', value: Commands.get, inline: true)
          e.add_field(name: 'Total User Count', value: event.bot.users.count, inline: true)
          # e.add_field(name: 'Shard', value: event.bot.shard_key[0], inline: true)
          e.color = '36399A'
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Bruh Moment, bot needs Embed Links permissions to function'
      end
    end

    command(:servers) do |event|
      servers = []
      counts = []
      DBL.self.shards.each_with_index do |serv, e|
        servers.push "Shard \##{e}: #{serv} servers"
        counts.push serv
      end
      servers.push ''
      servers.push "Total: #{counts.sum}"
      servers.push "Average: #{counts.average}"
      begin
        event.channel.send_embed do |e|
          e.title = 'HQ Trivia Bot Server Stats!'

          e.description = servers.join("\n")
          e.color = '36399A'
        end
      rescue Discordrb::Errors::NoPermission
        event.respond 'Bruh Moment, bot needs Embed Links permissions to function'
      end
    end
  end
end
