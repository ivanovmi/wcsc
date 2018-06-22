require 'curses'
require 'terminal-table'
require_relative 'table'
require_relative 'schedule'
require_relative 'game'

game = Game.new
table = Table.new
schedule = Schedule.new


def every_n_seconds(n)
  loop do
    before = Time.now
    yield
    interval = n-(Time.now-before)
    sleep(interval) if interval > 0
  end
end


def render_game_window(window, x_position, y_posiiton, game)
  gu = game.update
  cm_y_cp = y_posiiton
  cm_x_cp = x_position
  window.clear
  window.box(?|, ?-)
  if gu.nil?
    window.setpos(cm_y_cp+9, cm_x_cp+24)
    window.addstr('No matches are available at this time!')
  else
    game = gu
    window.setpos(cm_y_cp+=1, cm_x_cp+35)
    window.addstr("#{game[:city]}")
    window.setpos(cm_y_cp+=2, cm_x_cp+35)
    window.addstr("#{game[:home][:name]} #{game[:home][:score]} - #{game[:away][:score]} #{game[:away][:name]}")
    window.setpos(cm_y_cp+=2, cm_x_cp+37)
    window.addstr("Time: #{game[:time]}")
    hs = game[:home][:stats]
    as = game[:away][:stats]
    window.setpos(cm_y_cp+=2, cm_x_cp+32)
    window.addstr("#{hs[:attempts]} Attempts on goal #{as[:attempts]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+35)
    window.addstr("#{hs[:attempts]} On target #{as[:attempts]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+36)
    window.addstr("#{hs[:corners]} Corners #{as[:corners]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+35)
    window.addstr("#{hs[:offsides]} Offsides #{as[:offsides]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+31)
    window.addstr("#{hs[:ball_possesion]} Ball possession #{as[:ball_possesion]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr("#{hs[:pass_accuracy]} Pass accuracy #{as[:pass_accuracy]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+33)
    window.addstr("#{hs[:yellow_cards]} Yellow cards #{as[:yellow_cards]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+35)
    window.addstr("#{hs[:red_cards]} Red cards #{as[:red_cards]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+37)
    window.addstr("#{hs[:fouls]} Fouls #{as[:fouls]}")
  end
  window.refresh
end


def render_table_window(window, x_position, y_position, table)
  tb_x_cp = x_position
  tb_y_cp = y_position
  window.clear
  window.box(?|, ?-)
  tu = table.update
  (0...tu.length).step(4).each do |group_index|
    lg = tu[group_index]
    fmg = tu[group_index+1]
    smg = tu[group_index+2]
    rg = tu[group_index+3]
    window.setpos(tb_y_cp+=1, tb_x_cp+3)
    window.addstr("\t        Group #{lg[:name]}          Group #{fmg[:name]}          Group #{smg[:name]}          Group #{rg[:name]}")
    window.setpos(tb_y_cp+=1, tb_x_cp+3)
    window.addstr("\t+----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+")
    window.setpos(tb_y_cp+=1, tb_x_cp+3)
    window.addstr("\t|    |W|D|L|P|GD|     |W|D|L|P|GD|     |W|D|L|P|GD|\t|W|D|L|P|GD|")
    window.setpos(tb_y_cp+=1, tb_x_cp+3)
    window.addstr("\t+----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+")
    (0...lg[:teams].length).each do |team_index|
      lt = lg[:teams][team_index]
      fmt = fmg[:teams][team_index]
      smt = smg[:teams][team_index]
      rt = rg[:teams][team_index]
      window.setpos(tb_y_cp+=1, tb_x_cp+3)
      window.addstr("\t|#{lt[:name]} |#{lt[:win]}|#{lt[:draw]}|#{lt[:lose]}|#{lt[:point]}|#{lt[:diff].to_s.start_with?('-') ? "#{lt[:diff]}" : " #{lt[:diff]}"}| #{fmt[:name]} |#{fmt[:win]}|#{fmt[:draw]}|#{fmt[:lose]}|#{fmt[:point]}|#{fmt[:diff].to_s.start_with?('-') ? "#{fmt[:diff]}" : " #{fmt[:diff]}"}| #{smt[:name]} |#{smt[:win]}|#{smt[:draw]}|#{smt[:lose]}|#{smt[:point]}|#{smt[:diff].to_s.start_with?('-') ? "#{smt[:diff]}" : " #{smt[:diff]}"}| #{rt[:name]} |#{rt[:win]}|#{rt[:draw]}|#{rt[:lose]}|#{rt[:point]}|#{rt[:diff].to_s.start_with?('-') ? "#{rt[:diff]}" : " #{rt[:diff]}"}|")
    end
    window.setpos(tb_y_cp+=1, tb_x_cp+3)
    window.addstr("\t+----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+-----+-+-+-+-+--+")
    window.setpos(tb_y_cp+=1, tb_x_cp+3)
  end
  window.refresh
end


def render_schedule_window(window, x_position, y_position, schedule)
  su = schedule.update
  sc_y_cp = y_position
  sc_x_cp = x_position
  window.clear
  window.box(?|, ?-)
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
    window.setpos(sc_y_cp+=1, sc_x_cp+3)
    window.addstr('Not started')
    not_started.each do |match|
      window.setpos(sc_y_cp+=1, sc_x_cp+5)
      window.addstr("\t#{match[:home_team][:name]} #{match[:home_team][:goals]} - #{match[:away_team][:goals]} #{match[:away_team][:name]} (#{match[:city]})")
    end
  end
  unless in_progress.empty?
    window.setpos(sc_y_cp+=1, sc_x_cp+3)
    window.addstr('In progress')
    in_progress.each do |match|
      window.setpos(sc_y_cp+=1, sc_x_cp+5)
      window.addstr("\t#{match[:home_team][:name]} #{match[:home_team][:goals]} - #{match[:away_team][:goals]} #{match[:away_team][:name]} (#{match[:city]})")
    end
  end
  unless completed.empty?
    window.setpos(sc_y_cp+=2, sc_x_cp+3)
    window.addstr('Completed')
    completed.each do |match|
      window.setpos(sc_y_cp+=1, sc_x_cp+5)
      window.addstr("\t#{match[:home_team][:name]} #{match[:home_team][:goals]} - #{match[:away_team][:goals]} #{match[:away_team][:name]} (#{match[:city]})")
    end
  end
  window.refresh
end


Curses.init_screen
Curses.noecho
begin
  Curses.crmode
  # Define default coordinates
  top, left = (Curses.lines)/100, (Curses.cols) / 100
  height, width = Curses.lines, Curses.cols-2
  y_cp = cm_y_cp = tb_y_cp = sc_y_cp = 1
  x_cp = cm_x_cp = tb_x_cp = sc_x_cp = 0
  thread_group = []
  # Create background window
  bkg_win = Curses::Window.new(height, width, top, left)
  bkg_win.box(?|, ?-)
  bkg_win.refresh
  # Create window with current match
  cm_win = bkg_win.subwin(height-24, width-90, top+1, left+2)
  cm_win.setpos(cm_y_cp, cm_x_cp)
  thread_group << Thread.new do
    every_n_seconds(60) do
      render_game_window(cm_win, cm_y_cp, cm_x_cp, game)
    end
  end

  # Create window with table of results
  table_win = bkg_win.subwin(height-24, width-90, top+1, left+88)
  table_win.setpos(tb_y_cp, tb_x_cp)
  thread_group << Thread.new do
    every_n_seconds(3600) do
      render_table_window(table_win, tb_x_cp, tb_y_cp, table)
    end
  end
  playoff_win = bkg_win.subwin(height-25, width-90, top+24, left+88)
  playoff_win.box(?|, ?-)
  playoff_win.refresh
  # Create window with schedule
  schedule_win = bkg_win.subwin(height-25, width-90, top+24, left+2)
  schedule_win.setpos(sc_y_cp, sc_x_cp)
  thread_group << Thread.new do
    every_n_seconds(3600) do
      render_schedule_window(schedule_win, sc_x_cp, sc_y_cp, schedule)
    end
  end

  thread_group.each {|thread| thread.join}

  bkg_win.getch
  bkg_win.close
ensure
  Curses.close_screen
end
