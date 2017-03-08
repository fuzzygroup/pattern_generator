class <%= class_name %>
  
=begin
  parser = <%= class_name %>.new("https://")
  parser.parse(Account.first)
=end
  
  def self.url_patterns
    [//]
  end
  
  def self.account_name
    ""
  end
  
  def self.account_type
    ""
  end

  def self.description
    ""
  end
  
  def self.category
    ""
  end
  
  def self.font_awesome_icon
    ""
  end

  def initialize(url)
    @url = url
  end

  def parse(account = nil, return_type=:karma_hash)
    status, page = UrlCommon.get_page(@url)
    results = {}

    return results unless status == :ok

    # if return_type == :karma_hash
    #
    #   debugger
    # end

    #results = self.parse_as_html(page, results)
    results = self.parse_as_nokogiri(page, results)

    return results
  end

  def parse_as_html(page, results)
    stripped_body = TextCommon.strip_breaks(page.body)

    rating = /itemprop="ratingValue">([0-9\.]+)</.match(stripped_body)
    if rating
      rating = rating[1] 
    end

    results[:itunes_podcast__rating] = MetricCommon.make_metric_array(rating, "rating")
    return results
  end

  def parse_as_nokogiri(page, results)
  
    raw_data = page.parser.css('li.line').css('a.block').text

    member_count = /Scripters\n([0-9,]+)/.match(raw_data)
    member_count = member_count[1] if member_count

    reviews = /Group reviews\n\n([0-9,]+)\n\n/.match(raw_data)
    reviews = reviews[1] if reviews

    past_meetups = /Past Meetups\n([0-9,]+)\n\n/.match(raw_data)
    past_meetups = past_meetups[1] if past_meetups

    upcoming_meetups = /Upcoming Meetups\n([0-9,]+)\n\n/.match(raw_data)
    upcoming_meetups = upcoming_meetups[1] if upcoming_meetups

    #"Scripters\n1,043\nGroup reviews\n\n14\n\nUpcoming Meetups\n1\n\nPast Meetups\n68\n\nOur calendar\n\n"
  
    # upcoming_and_past_meetups = page.parser.css('li.line').css('a.page-meetups').text
    #
    # group_reviews = page.parser.css('li.line').css('a.bottom').text
    #
    # reader_count = spans[0].text.gsub(/,/,'') if spans[0]

    results[:meetup__member_count] = MetricCommon.make_metric_array(member_count, "count")
    results[:meetup__reviews] = MetricCommon.make_metric_array(reviews, "count")
    results[:meetup__past_meetups] = MetricCommon.make_metric_array(past_meetups, "count")
    results[:meetup__upcoming_meetups] = MetricCommon.make_metric_array(upcoming_meetups, "count")

    return results
  end
end
  
  
=begin
  data example here

=end
