import dryscrape

# set up a web scraping session
sess = dryscrape.Session(base_url = 'http://www.google.com.br')

# we don't need images
sess.set_attribute('auto_load_images', True)

# visit
sess.visit("/")

sess.render("google.png")
print sess.at_css('center').body()

