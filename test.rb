require "google_drive"

module Biblioteka

  def row(row_index)
    rows[row_index]
  end

  def rows
    super.select { |row| !ima_kljucnu_rec(row) }
  end

  def each
    rows.each do |row| 
      row.each do |cell|
        p cell  
      end 
    end
  end

def prazan_red(ws)
  prazni_redovi = []
  ws.rows.each_with_index do |row, index|
    red_je_prazan = true
    row.each do |cell|
      if !cell.empty?
        red_je_prazan = false
        break
      end
    end

    prazni_redovi << index if red_je_prazan
  end
  prazni_redovi
end

  def ima_kljucnu_rec(row)
    row.any? { |cell| cell.to_s.downcase.include?('total') || cell.to_s.downcase.include?('subtotal') }
  end

  def heder
    rows.first
  end

  def sum
    map { |cell| cell.to_f }.sum
  end
  
  def avg
    # uzimamo podatke koji nisu prazan string i nisu nula
    podaci = reject { |cell| cell.to_s.strip.empty? || cell.to_f.zero? }
    podaci = podaci.map { |element| element.to_f }

    return 0.0 if podaci.empty?
  
    podaci.sum / podaci.length
  end

  def method_missing(name, *args, &block)
    if name.to_s.match?(/^[a-z]+Kolona$/)
      format_name = name.to_s.split(/(?=[A-Z])/).map(&:capitalize).join(" ")
      kolona(format_name)
    elsif args.empty? && block.nil? && (row = rows.find { |r| r.include?(name.to_s) })
      row
    else
      super
    end
  end
  
  def kolona(naziv_hedera)
    index = heder.index(naziv_hedera)
    rows.map { |row| row[index] }.extend(Biblioteka)
  end

end

session = GoogleDrive::Session.from_config("config.json")
ws = session.spreadsheet_by_key("1lVWuZEyIlnPnRv0iXuH7UUvuxyS0gRtmi6Ay_do2Xbs").worksheets[0]
ws.extend(Biblioteka)

#1.zadatak
#   podaci = []
#  ws.rows.each do |row|
#    podaci << row
#  end
#  p podaci

#2.zadatak
#  t = ws
# p t.row(0) 

#3.zadatak
# ws.each do |cell|
#    cell
#  end

#6.zadatak
  #a)
# t = ws
# druga = t.drugaKolona
# p druga

  #i)
# sum = t.prvaKolona.sum
# p sum

# avg = t.prvaKolona.avg
# p avg

  #ii)

#7.zadatak
#  ws.rows.each do |row|
#    p row
#  end

#10.zadatak
# prazni_redovi = ws.prazan_red(ws)

# ws.rows.each_with_index do |row, indeks|
#  if prazni_redovi.include?(indeks)
#    p "Red na indeksu: #{indeks} je prazan!"
#   else
#    p row
#   end
# end

ws.reload