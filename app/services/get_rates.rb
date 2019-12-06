require 'mechanize'
require 'date'
require 'csv'
require "json"
require 'open-uri'

class GetRates
  def initialize
    @usd_rate = get_usd_rate
    @agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  end

def fill_form(form, hotel, checkin, checkout)
    form.field_with(name: "ss").value = hotel
  form.field_with(name: "checkin_monthday").value = checkin.day
  form.field_with(name: "checkin_month").value = checkin.month
  form.field_with(name: "checkin_year").value = checkin.year
  form.field_with(name: "checkout_monthday").value = checkout.day
  form.field_with(name: "checkout_month").value = checkout.month
  form.field_with(name: "checkout_year").value = checkout.year
  result_page = form.submit
  begin
    link = result_page.search("#hotellist_inner").first.search("a")[1].attributes["href"].value.gsub("\n", "")
    return link
  rescue

  end

end


def get_info(checkin, link_show, hotel_id, request_date_id)
  price = nil
  @agent.get(link_show) do |result_page|
    begin
      rows = result_page.search('#hprt-table tbody tr')
      rows.each do |row|
        col = row.search("td")
        next if col.size < 5
          type = col[0].text.gsub("\n","").split("  ").first
          price = col[2].search(".bui-price-display__value").text.gsub("\n","")
          amount = price.scan(/[0-9]/).join
          amount = amount.to_i * @usd_rate
          Rate.create(price: amount.round, checkin: checkin, checkout: checkin + 1, room: type, request_date_id: request_date_id)
      end
    rescue
      p "There was an error!"
    end
  end
  price
end





  def get_data
    Hotel.all.each do |hotel|
      request_date = RequestDate.create(date: Date.today, hotel: hotel)
      counter = 0
      while counter < 20
        @agent.get('https://www.booking.com') do |page|
          form = page.forms.first
          checkin = Date.today + counter
          checkout = Date.today + counter + 1
          link_show = fill_form(form, hotel.name, checkin, checkout)
          price = link_show == nil ? 0 : get_info(checkin, link_show, hotel.id, request_date.id)
        end
        counter += 1
      end
    end
  end




  def get_usd_rate
    url = "https://api.exchangeratesapi.io/latest"
    response = open(url).read
    currencies = JSON.parse(response)
    currencies["rates"]["USD"]
  end


end
