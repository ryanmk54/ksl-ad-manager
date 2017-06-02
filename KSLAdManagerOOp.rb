require 'io/console'
require 'rubygems'
require 'selenium-webdriver'
require 'yaml'


class KSLAdManager
  def initialize
    #username_password = get_username_password

    launch_web_browser
    login_to_ksl username_password[:username], username_password[:password]
  end


  def launch_web_browser
    log 'Launching Web Browser'
    #Selenium::WebDriver::Firefox::Binary.path = 'C:\Program Files (x86)\Firefox Developer Edition\firefox.exe'
    @driver = Selenium::WebDriver.for :firefox
    @driver.manage.timeouts.implicit_wait = 10
    #@driver = Selenium::WebDriver.for :ie
  end


  def get_username_password
    print 'Enter your username: '
    username = STDIN.gets.chomp
    print 'Enter your password: '
    password = STDIN.noecho(&:gets)
    puts

    username_password = {username: username, password: password};
    return username_password
  end


  def login_to_ksl username, password
    login_page = 'https://www.ksl.com/public/member/signin'
    log 'Logging in to KSL'
    @driver.get login_page
    email_field = @driver.find_element name: 'member[email]'
    email_field.send_keys username
    password_field = @driver.find_element name: 'member[password]'
    password_field.click
    password_field.send_keys password
    password_field.submit
  end

  
  def put_ads_in_file_on_ksl filepath
    ads = load_ads filepath
    ads.each_with_index do |ad, index|
      log "Adding ad \##{index}/#{ads.length}"
      put_ad_on_ksl ad
    end
  end


  # Loads ads from a yaml formatted file
  # The file must be in the format:
  # ---
  # - title: title of book
  #   description: description of book
  #   asking_price: $5
  #   image_path: absolute image path
  #   image_description: description of image
  def load_ads filename
    adsFromYaml = YAML.load_file(filename)
    return adsFromYaml
  end


  # An Ad needs to be in the format :
  # {'title' => 'ad_title',
  #  'description' => 'ad_description',
  # }
  def put_ad_on_ksl ad 
    # Category page - pg1
    place_new_ad_page = 'https://www.ksl.com/index.php?nid=1126'
    @driver.get place_new_ad_page
    category_select = Selenium::WebDriver::Support::Select.new(@driver.find_element :name, 'cat')
    category_select.select_by :text, ad['category']
    subcategory_select = Selenium::WebDriver::Support::Select.new(@driver.find_element :name, 
                                                                  'subcat')
    subcategory_wait = Selenium::WebDriver::Wait.new timeout: 10
    subcategory_wait.until {subcategory_select.select_by :text, ad['subcategory']}
    go_button = @driver.find_element id: 'go'
    go_button.click

    # Ad Information - pg2
    asking_price_field = @driver.find_element name: 'form_6'
    asking_price_field.send_keys ad['asking_price']
    ad_title_field = @driver.find_element name: 'form_8'
    ad_title_field.send_keys ad['title']
    ad_type_select = Selenium::WebDriver::Support::Select.new(@driver.find_element :name, 'form_136')
    ad_type_select.select_by :text, 'For Sale'
    ad_type_select = Selenium::WebDriver::Support::Select.new(@driver.find_element :name, 'form_135')
    ad_type_select.select_by :text, 'Private Listing'
    descriptive_text_field = @driver.find_element name: 'form_9'
    descriptive_text_field.send_keys ad['description']
    next_page_button = @driver.find_element name: 'next'
    next_page_button.click

    # pg3
    # Contact and location info are on this page 
    # but there is no need to change them from the default as of now
    next_page_button = @driver.find_element name: 'next'
    display_name = @driver.find_element name: 'form_11'
    display_name.clear
    display_name.send_keys ad['display_name'] 
    email_address = @driver.find_element name: 'form_12'
    email_address.clear
    email_address.send_keys ad['email_address']
    confirm_email_address = @driver.find_element name: 'form_13'
    confirm_email_address.clear
    confirm_email_address.send_keys ad['email_address']
    home_phone_pt1 = @driver.find_element name: 'form_73_a'
    home_phone_pt1.clear
    home_phone_pt1.send_keys ad['home_phone'][0, 3]
    home_phone_pt2 = @driver.find_element name: 'form_73_b'
    home_phone_pt2.clear
    home_phone_pt2.send_keys ad['home_phone'][4, 3]
    home_phone_pt3 = @driver.find_element name: 'form_73_c'
    home_phone_pt3.clear
    home_phone_pt3.send_keys ad['home_phone'][8, 4]
    unless ad['work_phone'].nil?
      work_phone_pt1 = @driver.find_element name: 'form_74_a'
      work_phone_pt1.clear
      work_phone_pt1.send_keys ad['work_phone'][0, 3]
      work_phone_pt2 = @driver.find_element name: 'form_74_b'
      work_phone_pt2.clear
      work_phone_pt2.send_keys ad['work_phone'][4, 3]
      work_phone_pt3 = @driver.find_element name: 'form_74_c'
      work_phone_pt3.clear
      work_phone_pt3.send_keys ad['work_phone'][8, 4]
    end
    unless ad['cell_phone'].nil?
      cell_phone_pt1 = @driver.find_element name: 'form_75_a'
      cell_phone_pt1.clear
      cell_phone_pt1.send_keys ad['cell_phone'][0, 3]
      cell_phone_pt2 = @driver.find_element name: 'form_75_b'
      cell_phone_pt2.clear
      cell_phone_pt2.send_keys ad['cell_phone'][4, 3]
      cell_phone_pt3 = @driver.find_element name: 'form_75_c'
      cell_phone_pt3.clear
      cell_phone_pt3.send_keys ad['cell_phone'][8, 4]
    end
    address_line1 = @driver.find_element name: 'form_34'
    address_line1.send_keys ad['address_line1']
    unless ad['address_line2'].nil?
      address_line2 = @driver.find_element name: 'form_35'
      address_line2.send_keys ad['address_line2']
    end
    city = @driver.find_element name: 'form_36'
    city.clear()
    city.send_keys ad['city']
    state = @driver.find_element name: 'form_37'
    state.send_keys ad['state']
    zip = @driver.find_element name: 'form_38'
    zip.send_keys ad['zip']
    next_page_button = @driver.find_element name: 'next'
    next_page_button.click

    # Photo upload - pg4
    unless ad['image_path'].nil?
      image_file_upload_button = @driver.find_element name: '142'
      image_file_upload_button.send_keys ad['image_path']
      image_upload_button = @driver.find_element name: 's-142'
      image_upload_button.click
      image_description = @driver.find_element name: 'd-142'
      image_description.send_keys ad['image_description']
      next_page_button = @driver.find_element name: 'next'
    end
    next_page_button = @driver.find_element name: 'next'
    next_page_button.click

    #Terms of Use - pg5 - last page
    next_page_button = @driver.find_element name: 'next'
    next_page_button.click
  end


	def delete_all_ads_on_ksl
    log "Deleting all ads"
		my_ads_page = 'https://www.ksl.com/?nid=280'
		@driver.get my_ads_page

    sleep 1
    delete_links = @driver.find_elements link_text: 'Delete'
    num_ads_left_to_delete = delete_links.length
    if num_ads_left_to_delete == 0
      log "Done deleting ads"
      return "Done deleting ads"
    end

    log "#{num_ads_left_to_delete} ads left to delete"
    delete_links[0].click

    confirm_delete_button = @driver.find_element name: 'confirm'
    confirm_delete_button.click

    delete_all_ads_on_ksl
	end


  def close
    puts 'Press Enter to close KSLAdManager'
    gets
    @driver.quit
  end


  def log text
    puts text
  end
end


def print_usage
  puts "usage: KSLAdManager --add_all_ads [filename]"
  puts "  Adds all the ads that are in the given filename to KSL"
  puts "  If no filename is given, it is assumed to be in ./books.yaml"
  puts "  The filename must be in the same format as the sample_books.yaml provided"
  puts "usage: KSLAdManager --delete_all_ads"
  puts "  Deletes all ads on KSL"
end



if ARGV.length == 0
  print_usage
elsif ARGV[0] == "--add_all_ads" && ARGV.length == 2 
  ad_manager = KSLAdManager.new
  ad_manager.put_ads_in_file_on_ksl ARGV[1]
elsif ARGV[0] == '--delete_all_ads'
  ad_manager = KSLAdManager.new
  ad_manager.delete_all_ads_on_ksl
else
  print_usage
end

