# RAQUI não é um pacote ainda!!!
#
#


#' low level get page
#' Obtem o código html renderizado da página do reclame aqui
#' pesquisada e salva em um arquivo
#'
#' @param cons url da página consultada (excluido o dominio)
#' @param arq arquivo em que deseja salvar a página
#' @param message mensagem que deseja exibir se o arquivo for salvo com sucesso
ra_get_page_ <- function(cons, arq, message = "Arquivo obtido com sucesso!"){
  system(paste("xvfb-run python inst/python/ra_get_page.py '",
               cons,
               arq,
               message, "'"
               )
         )
}

#' pipe connection to python
#'
#'
ra_pipe_connection <- function()


#' get page
#' Retorna um objeto com a mesma classe de html(url).
#'
#' @param cons página consultada
ra_get_page <- function(cons){
  f <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".html")
  ra_get_page_(cons, f, message = "__")
  rvest::html(f)
}


#' parse pagina
#' Faz o parse da página
#'
#' @param page página em html do R (formato retornato por html(url))
#'
ra_parse_page <- function(page){

  reclamacoes <- page %>% html_nodes(".box-todas-as-reclamacoes-listagem") %>%
    html_nodes("li")

  titulo <- reclamacoes %>%
    html_nodes("h3") %>%
    html_nodes("a") %>%
    html_text %>%
    str_trim

  resumo <- reclamacoes %>%
    html_nodes("p") %>%
    html_text %>%
    str_trim

  link <- reclamacoes %>%
    html_nodes("h3") %>%
    html_nodes("a") %>%
    html_attr("href")

  status <- reclamacoes %>%
    html_nodes(".status-reclamacao") %>%
    html_attr("title")

  data_hora_lugar <- reclamacoes %>%
    html_nodes(".dados-reclamacao-fanpage") %>%
    html_text

  d <- data.frame(link, titulo, resumo, data_hora_lugar, status)
  return(d)
}

#' next page
#' busca o link da próxima página de reclamacoes
#'
ra_next_page <- function(page){
  pags <- page %>%
    html_nodes(".pagination") %>%
    html_nodes("li") %>%
    html_nodes("a") %>%
    html_attr("href")
  if(length(pags) >=2 ){
    ind_na <- (1:length(pags))[is.na(pags)]
    pags <- pags[(1:length(pags))>ind_na]
    if(length(pags) >= 1){
      str_replace(pags[1] , "http://www.reclameaqui.com.br", "")
    }
  }
}

ra_next_page(page)


#' test validação
#' testa se é uma página com captcha
#'
#'
ra_test_verif <- function(page){

  v <- page %>%
    html_nodes(".title_16_verde") %>%
    html_text %>%
    str_trim

  if(length(v) > 0){
    T
  } else {
    F
  }
}


#' função para imprimir o captcha recebido
#' não funciona!!!
#'
#'
#'
ra_print_captcha <- function(page){
  cap <- page %>%
    html_nodes("form") %>%
    html_nodes("img") %>%
    html_attr("src")

  f <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".png", quiet = T)
  download.file(url = cap, destfile = "hi.png", method = 'wget', quiet = T)
  ima <- png::readPNG(f)
  rasterImage(as.raster(ima), 100, 300, 150, 350, interpolate = FALSE)
}


#' download captchas
#'
#'
#'
ra_download_captchas <- function(n){

    system(paste("xvfb-run python inst/python/ra_render_captcha.py",
                 n
    ))
  }
}

# ra_download_captchas(100)

#
#
#
# uso
consulta <- "/indices/lista_reclamacoes/?id=902&tp=9403f4c8cd5af61c485541e9444950c069c79ffa&subtp=c92a9bc341d739044ff5400661d44a60a808be22"

page1 <- ra_get_page(consulta)
reclamacoes_pag1 <- page1 %>% ra_parse_page()

page2 <- ra_get_page(ra_next_page(page1))
ra_test_verif(page2) # indica que é uma página de verificação!!


