module Bot::DiscordCommands
  # Command for evaluating Ruby code in an active bot.
  # Only the `event.user` with matching discord ID of `CONFIG.owner`
  # can use this command.
  module Sync
    extend Discordrb::Commands::CommandContainer
    Scheduler.cron('*/30 * * * *') do
      total = Bot::BOT.servers.count
      m = Bot::BOT.channel(625812110781317120).send "Syncing every server's Birthdays!\nStatus: 0/#{total}"

      ays = Server.all
      sids = []
      ays.each do |e|
        sids.push e.serverid
      end
      bigbois = Bot::BOT.servers
      bigbois.delete_if { |e, _f| !sids.include?(e) }

      i = 0
      no = 0
      bigbois.each do |id, serv|
        i += 1
        server = Server.find_by(serverid: id)
        if server.nil? || server.roleid.nil?
          m.edit "Syncing every server's Birthdays!\nStatus: #{i+1}/#{total}"
          break
        end

        given = 0
        taken = 0
        unchanged = 0

        days = Birthday.all
        uids = {}
        days.each do |e|
          uids[e.userid] = [e.birthday, e.time_friendly_offset]
        end
        goodguys = serv.members
        goodguys.delete_if { |e| !uids.include?(e.id) }

        goodguys.each do |u|
          user = uids[u.id]

          userday = user[0]
          now = Time.now.getlocal(user[1])
          if user[0].nil?
            next
            unchanged += 1
          end
          day = Time.new(now.year, userday.month, userday.day, 0, 0, 0, user[1]).to_i
          day2 = (day + 86_399).to_i
          if Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec, user[1]).to_i.between?(day, day2)
            if u.roles.include?(serv.role(server.roleid))
              unchanged += 1
            else
              serv.member(user.id).add_role(server.roleid)
              given += 1
            end
          else
            if u.roles.include?(serv.role(server.roleid))
              serv.member(user.id).remove_role(server.roleid)
              taken += 1
            else
              unchanged += 1
            end
          end
        end

        m.edit "Syncing every server's Birthdays!\nStatus: #{i+1}/#{total}"
      end
      m.edit "Syncing complete. All servers synced, however #{no} servers didn't have a role."
    end

    command(:sync) do |event|
      m = event.respond 'Syncing your role in this server...'
      user = Birthday.find_by(userid: event.user.id)
      if user.nil?
        m.edit "You haven't set your birthday! Type `bday set` to get started."
        break
      end

      server = Server.find_by(serverid: event.server.id)
      if server.nil? || server.roleid.nil?
        m.edit 'This server does not have a Birthday role set up!'
        break
      else
        userday = user.birthday
        now = Time.now.getlocal(user.time_friendly_offset)
        day = Time.new(now.year, userday.month, userday.day, 0, 0, 0, user.time_friendly_offset).to_i
        day2 = (day + 86_399).to_i
        if Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec, user.time_friendly_offset).to_i.between?(day, day2)
          event.user.add_role(server.roleid)
          m.edit 'Happy Birthday! Role given.'
        else
          event.user.remove_role(server.roleid)
          m.edit "Party's over! Role taken."
        end
      end
    end

    command(:syncall) do |event|
      m = event.respond 'Syncing all people with the Birthday role!'
      unless event.user.permission?(:manage_server)
        event.respond 'Only people with Manage Server can force a full sync.'
        break
      end

      server = Server.find_by(serverid: event.server.id)
      if server.nil? || server.roleid.nil?
        m.edit 'This server does not have a Birthday role set up!'
        break
      end

      given = 0
      taken = 0
      unchanged = 0

      days = Birthday.all
      uids = {}
      days.each do |e|
        uids[e.userid] = [e.birthday, e.time_friendly_offset]
      end
      goodguys = event.server.members
      goodguys.delete_if { |e| !uids.include?(e.id) }

      goodguys.each do |u|
        user = uids[u.id]

        userday = user[0]
        now = Time.now.getlocal(user[1])
        if user[0].nil?
          next
          unchanged += 1
        end
        day = Time.new(now.year, userday.month, userday.day, 0, 0, 0, user[1]).to_i
        day2 = (day + 86_399).to_i
        if Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec, user[1]).to_i.between?(day, day2)
          if u.roles.include?(event.server.role(server.roleid))
            unchanged += 1
          else
            event.server.member(user.id).add_role(server.roleid)
            given += 1
          end
        else
          if u.roles.include?(event.server.role(server.roleid))
            event.server.member(user.id).remove_role(server.roleid)
            taken += 1
          else
            unchanged += 1
          end
        end
      end

      m.edit "Force Sync Completed, Status:\nUpdated: [+#{given}/-#{taken}/±#{unchanged}]\n#{event.server.members.count - (given + taken + unchanged)} members don't have a Birthday! Tell them to set one!"
    end

    command(:syncglobal) do |event|
      total = event.bot.servers.count
      m = event.respond "Syncing every server's Birthdays!\nStatus: 0/#{total}"
      unless Bot::BOT.server(473364634301366273).member(event.user.id).roles.include?(Bot::BOT.server(473364634301366273).role(474304351091949578))
        event.respond "NO ADMIN? NO SYNCGLOBAL!"
        break
      end

      ays = Server.all
      sids = []
      ays.each do |e|
        sids.push e.serverid
      end
      bigbois = event.bot.servers
      bigbois.delete_if { |e, _f| !sids.include?(e) }

      i = 0
      no = 0
      bigbois.each do |id, serv|
        i += 1
        server = Server.find_by(serverid: id)
        if server.nil? || server.roleid.nil?
          m.edit "Syncing every server's Birthdays!\nStatus: #{i+1}/#{total}"
          break
        end

        given = 0
        taken = 0
        unchanged = 0

        days = Birthday.all
        uids = {}
        days.each do |e|
          uids[e.userid] = [e.birthday, e.time_friendly_offset]
        end
        goodguys = serv.members
        goodguys.delete_if { |e| !uids.include?(e.id) }

        goodguys.each do |u|
          user = uids[u.id]

          userday = user[0]
          now = Time.now.getlocal(user[1])
          if user[0].nil?
            next
            unchanged += 1
          end
          day = Time.new(now.year, userday.month, userday.day, 0, 0, 0, user[1]).to_i
          day2 = (day + 86_399).to_i
          if Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec, user[1]).to_i.between?(day, day2)
            if u.roles.include?(serv.role(server.roleid))
              unchanged += 1
            else
              serv.member(user.id).add_role(server.roleid)
              given += 1
            end
          else
            if u.roles.include?(serv.role(server.roleid))
              serv.member(user.id).remove_role(server.roleid)
              taken += 1
            else
              unchanged += 1
            end
          end
        end

        m.edit "Syncing every server's Birthdays!\nStatus: #{i+1}/#{total}"
      end
      m.edit "Syncing complete. All servers synced, however #{no} servers didn't have a role."
    end
  end
end
