require 'curses'
require 'terminal-table'
require_relative 'table'
require_relative 'schedule'
require_relative 'game'

game = Game.new
table = Table.new
schedule = Schedule.new

Curses.init_screen
Curses.noecho
begin
  Curses.crmode
  # Define default coordinates
  top, left = (Curses.lines)/100, (Curses.cols) / 100
  height, width = Curses.lines, Curses.cols-2
  y_cp = cm_y_cp = tb_y_cp = sc_y_cp = 1
  x_cp = cm_x_cp = tb_x_cp = sc_x_cp = 0
  # Create background window
  bkg_win = Curses::Window.new(height, width, top, left)
  bkg_win.box(?|, ?-)
  bkg_win.refresh
  # Create window with current match
  cm_win = bkg_win.subwin(height-24, width-90, top+1, left+2)
  cm_win.setpos(cm_y_cp, cm_x_cp)
  cm_win.box(?|, ?-)
  gu = game.update
  if gu.nil?
    cm_win.setpos(cm_y_cp+9, cm_x_cp+24)
    cm_win.addstr('No matches are available at this time!')
  else
    game = gu
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+35)
    cm_win.addstr("#{game[:city]}")
    cm_win.setpos(cm_y_cp+=2, cm_x_cp+35)
    cm_win.addstr("#{game[:home][:name]} #{game[:home][:score]} - #{game[:away][:score]} #{game[:away][:name]}")
    cm_win.setpos(cm_y_cp+=2, cm_x_cp+37)
    cm_win.addstr("Time: #{game[:time]}")
    hs = game[:home][:stats]
    as = game[:away][:stats]
    cm_win.setpos(cm_y_cp+=2, cm_x_cp+32)
    cm_win.addstr("#{hs[:attempts]} Attempts on goal #{as[:attempts]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+35)
    cm_win.addstr("#{hs[:attempts]} On target #{as[:attempts]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+36)
    cm_win.addstr("#{hs[:corners]} Corners #{as[:corners]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+35)
    cm_win.addstr("#{hs[:offsides]} Offsides #{as[:offsides]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+31)
    cm_win.addstr("#{hs[:ball_possesion]} Ball possession #{as[:ball_possesion]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+32)
    cm_win.addstr("#{hs[:pass_accuracy]} Pass accuracy #{as[:pass_accuracy]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+33)
    cm_win.addstr("#{hs[:yellow_cards]} Yellow cards #{as[:yellow_cards]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+35)
    cm_win.addstr("#{hs[:red_cards]} Red cards #{as[:red_cards]}")
    cm_win.setpos(cm_y_cp+=1, cm_x_cp+37)
    cm_win.addstr("#{hs[:fouls]} Fouls #{as[:fouls]}")
  end
  cm_win.refresh
  # Create window with table of results
  table_win = bkg_win.subwin(height-24, width-90, top+1, left+88)
  table_win.setpos(tb_y_cp, tb_x_cp)
  table_win.box(?|, ?-)
  tu = table.update
  (0...tu.length).step(4).each do |group_index|
    lg = tu[group_index]
    fmg = tu[group_index+1]
    smg = tu[group_index+2]
    rg = tu[group_index+3]
    table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
    table_win.addstr("\t        Group #{lg[:name]}          Group #{fmg[:name]}          Group #{smg[:name]}          Group #{rg[:name]}")
    table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
    table_win.addstr("\t+----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+")
    table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
    table_win.addstr("\t|    |W|D|L|P|GD|     |W|D|L|P|GD|     |W|D|L|P|GD|\t|W|D|L|P|GD|")
    table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
    table_win.addstr("\t+----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+")
    (0...lg[:teams].length).each do |team_index|
      lt = lg[:teams][team_index]
      fmt = fmg[:teams][team_index]
      smt = smg[:teams][team_index]
      rt = rg[:teams][team_index]
      table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
      table_win.addstr("\t|#{lt[:name]} |#{lt[:win]}|#{lt[:draw]}|#{lt[:lose]}|#{lt[:point]}|#{lt[:diff].to_s.start_with?('-') ? "#{lt[:diff]}" : " #{lt[:diff]}"}| #{fmt[:name]} |#{fmt[:win]}|#{fmt[:draw]}|#{fmt[:lose]}|#{fmt[:point]}|#{fmt[:diff].to_s.start_with?('-') ? "#{fmt[:diff]}" : " #{fmt[:diff]}"}| #{smt[:name]} |#{smt[:win]}|#{smt[:draw]}|#{smt[:lose]}|#{smt[:point]}|#{smt[:diff].to_s.start_with?('-') ? "#{smt[:diff]}" : " #{smt[:diff]}"}| #{rt[:name]} |#{rt[:win]}|#{rt[:draw]}|#{rt[:lose]}|#{rt[:point]}|#{rt[:diff].to_s.start_with?('-') ? "#{rt[:diff]}" : " #{rt[:diff]}"}|")
    end
    table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
    table_win.addstr("\t+----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+")
    table_win.setpos(tb_y_cp+=1, tb_x_cp+3)
  end
  table_win.refresh
  playoff_win = bkg_win.subwin(height-25, width-90, top+24, left+88)
  playoff_win.box(?|, ?-)
  playoff_win.refresh
  # Create window with schedule
  schedule_win = bkg_win.subwin(height-25, width-90, top+24, left+2)
  schedule_win.setpos(sc_y_cp, sc_x_cp)
  schedule_win.box(?|, ?-)
  su = schedule.update
  not_started = []
  in_progress = []
  completed = []
  su.each do |match|
    if match[:status] == 'in progress'
      in_progress << match
    elsif match[:status] == 'completed'
      completed << match
    else
      not_started << match
    end
  end
  unless not_started.empty?
    schedule_win.setpos(sc_y_cp+=1, sc_x_cp+3)
    schedule_win.addstr('Not started')
    not_started.each do |match|
      schedule_win.setpos(sc_y_cp+=1, sc_x_cp+5)
      schedule_win.addstr("\t#{match[:home_team][:name]} #{match[:home_team][:goals]} - #{match[:away_team][:goals]} #{match[:away_team][:name]} (#{match[:city]})")
    end
  end
  unless in_progress.empty?
    schedule_win.setpos(sc_y_cp+=1, sc_x_cp+3)
    schedule_win.addstr('In progress')
    in_progress.each do |match|
      schedule_win.setpos(sc_y_cp+=1, sc_x_cp+5)
      schedule_win.addstr("\t#{match[:home_team][:name]} #{match[:home_team][:goals]} - #{match[:away_team][:goals]} #{match[:away_team][:name]} (#{match[:city]})")
    end
  end
  unless completed.empty?
    schedule_win.setpos(sc_y_cp+=2, sc_x_cp+3)
    schedule_win.addstr('Completed')
    completed.each do |match|
      schedule_win.setpos(sc_y_cp+=1, sc_x_cp+5)
      schedule_win.addstr("\t#{match[:home_team][:name]} #{match[:home_team][:goals]} - #{match[:away_team][:goals]} #{match[:away_team][:name]} (#{match[:city]})")
    end
  end
  schedule_win.refresh

  bkg_win.getch
  bkg_win.close
ensure
  Curses.close_screen
end
