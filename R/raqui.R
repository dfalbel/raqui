#' get page
#'
#' Retorna um objeto com a mesma classe de html(url).
#'
#' @param cons pagina consultada
#' @export
ra_get_page <- function(cons) {
  f <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".html")
  cook <- ra_get_page_(cons, f, message = "__")
  h <- xml2::read_html(f)
  return(list(doc = h, cookies = cook))
}

#' low level get page
#'
#' Obtem o código html renderizado da página do reclame aqui
#' pesquisada e salva em um arquivo
#'
#' @param cons url da página consultada (excluido o dominio)
#' @param arq arquivo em que deseja salvar a página
#' @param message mensagem que deseja exibir se o arquivo for salvo com sucesso
ra_get_page_ <- function(cons, arq, message = "Arquivo obtido com sucesso!"){
  a <- system.file('python/ra_get_page.py', package = 'raqui')
  rPython::python.load(a)
  cook <- rPython::python.call('acessa', cons, arq, message)
  cook
}

#' pipe connection to python
ra_pipe_connection <- function() {
  NULL
}

#' parse pagina
#' Faz o parse da página
#'
#' @param page página em html do R (formato retornato por html(url))
ra_parse_page <- function(page){

  reclamacoes <- page %>%
    rvest::html_nodes(".box-todas-as-reclamacoes-listagem") %>%
    rvest::html_nodes("li")

  titulo <- reclamacoes %>%
    rvest::html_nodes("h3") %>%
    rvest::html_nodes("a") %>%
    rvest::html_text() %>%
    stringr::str_trim()

  resumo <- reclamacoes %>%
    rvest::html_nodes("p") %>%
    rvest::html_text() %>%
    stringr::str_trim()

  link <- reclamacoes %>%
    rvest::html_nodes("h3") %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href")

  status <- reclamacoes %>%
    rvest::html_nodes(".status-reclamacao") %>%
    rvest::html_attr("title")

  data_hora_lugar <- reclamacoes %>%
    rvest::html_nodes(".dados-reclamacao-fanpage") %>%
    rvest::html_text()

  d <- data.frame(link, titulo, resumo, data_hora_lugar, status)
  return(d)
}

#' next page
#' busca o link da próxima página de reclamacoes
#'
ra_next_page <- function(page){
  pags <- page %>%
    rvest::html_nodes(".pagination") %>%
    rvest::html_nodes("li") %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href")
  if(length(pags) >=2 ){
    ind_na <- (1:length(pags))[is.na(pags)]
    pags <- pags[(1:length(pags))>ind_na]
    if(length(pags) >= 1){
      stringr::str_replace(pags[1] , "http://www.reclameaqui.com.br", "")
    }
  }
}


#' test validação
#' testa se é uma página com captcha
#'
#'
ra_test_verif <- function(page){
  v <- page %>%
    rvest::html_nodes(".title_16_verde") %>%
    rvest::html_text() %>%
    stringr::str_trim()
  if(length(v) > 0) {
    TRUE
  } else {
    FALSE
  }
}


#' função para imprimir o captcha recebido
#' não funciona!!!
#'
ra_print_captcha <- function(page, cookies){
  cap <- page$doc %>%
    rvest::html_nodes("form") %>%
    rvest::html_nodes("img") %>%
    rvest::html_attr("src")
  tmp <- tempfile()
  rPython::python.call('get_captcha', cap, cookies, tmp)
  tmp
}


#' download captchas
ra_download_captchas <- function(n) {
  system(paste("xvfb-run python inst/python/ra_render_captcha.py", n))
}
