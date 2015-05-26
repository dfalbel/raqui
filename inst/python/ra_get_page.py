import dryscrape
import sys

# get arguments form call
arg = sys.argv[1]
arg = arg.split()

# define what is what in call
cons = arg[0]
file = arg[1]
msge = ' '.join(arg[2:])

# set up a web scraping session
sess = dryscrape.Session(base_url = 'http://www.reclameaqui.com.br')

# we don't need images
sess.set_attribute('auto_load_images', False)

# visit
sess.visit(cons)

# save body to file specified
f = open(file,'w')
f.write(sess.body()) # python will convert \n to os.linesep
f.close() # you can omit in most cases as the destructor will call if

# print message
if msge != "__":
  print msge

# # save captcha if there's one
# sess.set_attribute('auto_load_images', True)
# sess.visit("/indices/lista_reclamacoes/captcha.php")
# sess.render("test2.png")





