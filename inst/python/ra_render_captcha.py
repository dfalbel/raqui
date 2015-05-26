import dryscrape
import sys


args = sys.argv[1]
args = args.split()
i = args[0]

for num in range(int(i)):
  # set up a web scraping session
  sess = dryscrape.Session(base_url = 'http://www.reclameaqui.com.br')

  # we don't need images
  sess.set_attribute('auto_load_images', True)

  # visit
  sess.visit("/indices/lista_reclamacoes/?screen=1&tp=9403f4c8cd5af61c485541e9444950c069c79ffa&subtp=c92a9bc341d739044ff5400661d44a60a808be22&id=902")

  # save captcha
  sess.set_attribute('auto_load_images', True)
  sess.visit("/indices/lista_reclamacoes/captcha.php")
  sess.render('data/captchas/captcha' + str(num) + '.png')

