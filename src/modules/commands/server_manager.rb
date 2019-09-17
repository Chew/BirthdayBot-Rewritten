module Bot::DiscordCommands
  # CoS
  module ServerManager
    extend Discordrb::Commands::CommandContainer
    command(:server) do |event, *args|
      unless event.user.permission?(:manage_server)
        event.respond "Only people with Manage Server can see Server stuff."
        break
      end

      if args.join(' ').include?('-h')
        begin
          event.channel.send_embed do |embed|
            embed.title = "Help for `bday server`"
            embed.add_field(name: "Birthday Role", value: "The role given to people on their Birthday.", inline: true)
            embed.add_field(name: "Announcement ChanID", value: "The channel for announcements for people's birthdays.", inline: true)
            embed.add_field(name: "Log Channel ID", value: "The channel for Logs. Will log: Birthday role given, taken, announced by the bot.", inline: true)
            embed.color = 0xFF685F
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
        break
      end

      us = Server.find_by(serverid: event.server.id)
      if us.nil?
        us = Server.create(serverid: event.server.id)
      end

      if us.roleid.nil?
        roid = "None set! Set with `bday role [name or mention or `--clear` to remove]`"
      else
        roid = event.server.role(us.roleid).mention
      end

      if us.announceid.nil?
        anid = "None set! Set with `bday announceid [name or mention or `--clear` to remove]`"
      else
        anid = "<\##{us.announceid}>"
      end

      if us.logid.nil?
        lid = "None set! Set with `bday logid [name or mention or `--clear` to remove]`"
      else
        lid = "<\##{us.logid}>"
      end

      begin
        event.channel.send_embed do |embed|
          embed.title = "Server Information for #{event.server.name}"
          embed.add_field(name: "Birthday Role", value: roid, inline: true)
          embed.add_field(name: "Announcement ChanID", value: anid, inline: true)
          embed.add_field(name: "Log Channel ID", value: lid, inline: true)
          embed.footer = { text: "Type `bday server -h` to see what each option does." }
          embed.color = 0xFF685F
        end
      rescue Discordrb::Errors::NoPermission
        event.user.dm "I need Embed Links permissions to send messages"
      end
    end

    command(:role) do |event, *args|
      us = Server.find_by(serverid: event.server.id)
      if us.nil?
        us = Server.create(serverid: event.server.id)
      end

      if us.roleid.nil? && event.user.permission?(:manage_server)
        roid = "None set! Set with `bday role [name or mention or `--clear` to remove]`"
      elsif us.roleid.nil?
        roid = "None set!"
      else
        roid = event.server.role(us.roleid).mention
      end

      if args.empty?
        begin
          event.channel.send_embed do |embed|
            embed.title = "Birthday Role Information for #{event.server.name}"
            embed.add_field(name: "Birthday Role", value: roid, inline: true)
            embed.footer = { text: "Type `bday server` to see all server info." }
            embed.color = 0xFF685F
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
        break
      end

      unless event.user.permission?(:manage_server)
        event.respond "Only people with Manage Server can see Server stuff."
        break
      end

      if args.join(' ').include?('-h')
        begin
          event.channel.send_embed do |embed|
            embed.title = "Help for `bday role`"
            embed.add_field(name: "Set a Bday Role", value: "Mention or put a Role ID", inline: true)
            embed.add_field(name: "Create a Bday Role", value: "To create a role, add `--create (name)`. If you do not provide a name, a cake emoji will be used, if you do, that name will be used instead.")
            embed.color = 0xFF685F
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
        break
      end

      if args.join(' ').include?('--clear')
        us.roleid = nil
        us.save!
        begin
          event.channel.send_embed do |embed|
            embed.title = "Server Information Updated for #{event.server.name}"
            embed.add_field(name: "Birthday Role", value: "Removed the role.", inline: true)
            embed.footer = { text: "Type `bday role -h` for help." }
            embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
        break
      end

      if args.join(' ').include?('--create')
        ar = args.join(' ').gsub('--create ', '').gsub('--create', '')
        if ar.length >= 1
          name = ar
        else
          name = "🎂"
        end
        role = event.server.create_role(name: name, colour: Discordrb::ColourRGB.new('f1c40f'), reason: "BirthdayBot Role")
        us.roleid = role.id
        us.save!

        begin
          event.channel.send_embed do |embed|
            embed.title = "Server Information Updated for #{event.server.name}"
            embed.add_field(name: "Birthday Role", value: "Set to #{role.mention}", inline: true)
            embed.footer = { text: "Type `bday role -h` for help." }
            embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      else
        role = event.server.roles.find { |role| role.name == args.join(' ') }
        if role.nil?
          event.respond "Could not find role with name `#{args.join(' ')}`"
          break
        end

        us.roleid = role.id
        us.save!

        begin
          event.channel.send_embed do |embed|
            embed.title = "Server Information Updated for #{event.server.name}"
            embed.add_field(name: "Birthday Role", value: "Set to #{role.mention}", inline: true)
            embed.footer = { text: "Type `bday role -h` for help." }
            embed.color = 0xFFDF9C
          end
        rescue Discordrb::Errors::NoPermission
          event.user.dm "I need Embed Links permissions to send messages"
        end
      end
    end
  end
end
