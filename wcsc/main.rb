require 'curses'
require 'terminal-table'
require_relative 'table'
require_relative 'schedule'
require_relative 'game'
require_relative 'playoff'

game = Game.new
table = Table.new
schedule = Schedule.new
playoff = Playoff.new

def generate_table_row(title, sym_name, home_stat, away_stat)
  result_string = ''
  if home_stat[sym_name].to_s.length == 1
    result_string << "|  #{home_stat[sym_name]} |"
  elsif home_stat[sym_name].to_s.length == 2
    result_string << "| #{home_stat[sym_name]} |"
  else
    result_string << "| #{home_stat[sym_name]}|"
  end

  spaces = 18 - title.to_s.length
  spaces_wrap = spaces/2
  if spaces.even?
    result_string << ' '*spaces_wrap+title+' '*spaces_wrap
  else
    result_string << ' '*spaces_wrap+title+' '*(spaces_wrap+1)
  end

  if away_stat[sym_name].to_s.length == 1
    result_string << "|  #{away_stat[sym_name]} |"
  elsif away_stat[sym_name].to_s.length == 2
    result_string << "| #{away_stat[sym_name]} |"
  else
    result_string << "| #{away_stat[sym_name]}|"
  end
  result_string
end


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
    hs = game[:home][:stats]
    as = game[:away][:stats]
    window.setpos(cm_y_cp+=1, cm_x_cp+35)
    window.addstr("#{game[:city]}")
    window.setpos(cm_y_cp+=2, cm_x_cp+35)
    window.addstr("#{game[:home][:name]} #{game[:home][:score]} - #{game[:away][:score]} #{game[:away][:name]}")
    window.setpos(cm_y_cp+=2, cm_x_cp+37)
    window.addstr("Time: #{game[:time]}")
    window.setpos(cm_y_cp+=2, cm_x_cp+32)
    window.addstr('+'+'-'*28+'+')
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr('|         Statistics         |')
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr('+'+'-'*4+'+'+'-'*18+'+'+'-'*4+'+')
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Attempts on goal', :attempts, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('On targets', :on_target, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Corners', :corners, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Offsides', :offsides, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Ball possesion', :ball_possesion, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Pass accuracy', :pass_accuracy, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Yellow cards', :yellow_cards, hs, as))
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Red cards', :red_cards, hs, as))
    window.addstr("#{hs[:red_cards]} Red cards #{as[:red_cards]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr(generate_table_row('Fouls', :fouls, hs, as))
    window.addstr("#{hs[:fouls]} Fouls #{as[:fouls]}")
    window.setpos(cm_y_cp+=1, cm_x_cp+32)
    window.addstr('+'+'-'*4+'+'+'-'*18+'+'+'-'*4+'+')
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


def render_playoff_window(window, x_position, y_position, playoff)
  pu = playoff.update
  po_y_cp = y_position
  po_x_cp = x_position
  window.clear
  window.box(?|, ?-)
  window.setpos(po_y_cp, po_x_cp+35)
  window.addstr('Playoff table')
  window.setpos(po_y_cp+=1, po_x_cp+5)
  window.addstr('+'+'-'*13+'+'+'-'*15+'+'+'-'*12+'+'+'-'*17+'+'+'-'*11+'+')
  window.setpos(po_y_cp+=1, po_x_cp+5)
  window.addstr('| Round of 16 | Quarterfinals | Semifinals | 3rd place match |   Final   |')
  window.setpos(po_y_cp+=1, po_x_cp+5)
  window.addstr('+'+'-'*13+'+'+'-'*15+'+'+'-'*12+'+'+'-'*17+'+'+'-'*11+'+')
  (0...pu[:r16].length).each do |m|
    window.setpos(po_y_cp+=1, po_x_cp+5)
    window.addstr("|#{pu[:r16][m][:home_team].length == 2 ? "   #{pu[:r16][m][:home_team]} - #{pu[:r16][m][:away_team]}   " : "  #{pu[:r16][m][:home_team]} - #{pu[:r16][m][:away_team]}  "}|#{pu[:qf][m].nil? ? ' '*15 : "   #{pu[:qf][m][:home_team]} - #{pu[:qf][m][:away_team]}   "}|#{pu[:sf][m].nil? ? ' '*12 : " #{pu[:sf][m][:home_team]} - #{pu[:sf][m][:away_team]}  "}|#{pu[:tp][m].nil? ? ' '*17 : "    #{pu[:tp][m][:home_team]} - #{pu[:tp][m][:away_team]}    "}|#{pu[:f][m].nil? ? ' '*11 : " #{pu[:f][m][:home_team]} - #{pu[:f][m][:away_team]} "}|")
    window.setpos(po_y_cp+=1, po_x_cp+5)
    window.addstr('+'+'-'*13+'+'+'-'*15+'+'+'-'*12+'+'+'-'*17+'+'+'-'*11+'+')
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
  y_cp = cm_y_cp = tb_y_cp = sc_y_cp = po_y_cp = 1
  x_cp = cm_x_cp = tb_x_cp = sc_x_cp = po_x_cp = 0
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
  thread_group << Thread.new do
    every_n_seconds(3600) do
      render_playoff_window(playoff_win, po_x_cp, po_y_cp, playoff)
    end
  end
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
