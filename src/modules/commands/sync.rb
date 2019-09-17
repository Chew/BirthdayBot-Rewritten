module Bot::DiscordCommands
  # Command for evaluating Ruby code in an active bot.
  # Only the `event.user` with matching discord ID of `CONFIG.owner`
  # can use this command.
  module Sync
    extend Discordrb::Commands::CommandContainer
    command(:sync) do |event|
      m = event.respond "Syncing your role in this server..."
      user = Birthday.find_by(userid: event.user.id)
      if user.nil?
        m.edit "You haven't set your birthday! Type `bday set` to get started."
        break
      end

      server = Server.find_by(serverid: event.server.id)
      if server.nil? || server.roleid.nil?
        m.edit "This server does not have a Birthday role set up!"
        break
      else
        userday = user.birthday
        now = Time.now.getlocal(user.time_friendly_offset)
        day = Time.new(now.year, userday.month, userday.day, 0, 0, 0, user.time_friendly_offset).to_i
        day2 = (day + 86399).to_i
        if Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec, user.time_friendly_offset).to_i.between?(day, day2)
          event.user.add_role(server.roleid)
          m.edit "Happy Birthday! Role given."
        else
          event.user.remove_role(server.roleid)
          m.edit "Party's over! Role taken."
        end
      end
    end

    command(:syncall) do |event|
      m = event.respond "Syncing all people with the Birthday role!"
      unless event.user.permission?(:manage_server)
        event.respond "Only people with Manage Server can force a full sync."
        break
      end

      server = Server.find_by(serverid: event.server.id)
      if server.nil? || server.roleid.nil?
        m.edit "This server does not have a Birthday role set up!"
        break
      end

      given = 0
      taken = 0
      unchanged = 0

      days = Birthday.all
      uids = []
      days.each { |e| uids.push e.userid }
      goodguys = event.server.members
      goodguys.delete_if { |e| !uids.include?(e.id) }

      goodguys.each do |u|
        user = Birthday.find_by(userid: u.id)

        userday = user.birthday
        now = Time.now.getlocal(user.time_friendly_offset)
        day = Time.new(now.year, userday.month, userday.day, 0, 0, 0, user.time_friendly_offset).to_i
        day2 = (day + 86399).to_i
        if Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec, user.time_friendly_offset).to_i.between?(day, day2)
          unless u.roles.include?(event.server.role(server.roleid))
            event.user.add_role(server.roleid)
            given += 1
          else
            unchanged += 1
          end
        else
          if u.roles.include?(event.server.role(server.roleid))
            event.user.remove_role(server.roleid)
            taken += 1
          else
            unchanged += 1
          end
        end
      end

      m.edit "Force Sync Completed, Status:\nUpdated: [+#{given}/-#{taken}/±#{unchanged}]\n#{event.server.members.count - (given+taken+unchanged)} members don't have a Birthday! Tell them to set one!"
    end
  end
end
