#' Começar websrcapping!
#' essa funcao inicia a sessao no site do reclame aqui!
#'
ra_start <- function(){
  # o jeito certo de fazer no pacote
  a <- system.file('python/ra_get_page.py', package = 'raqui')
  # o jeito bom para testar masi rápido
  # a <- "inst/python/ra_get_page.py"
  rPython::python.load(a)
  print("Iniciado!")
}

#' low level get page
#'
#' Obtem o código html renderizado da página do reclame aqui
#' pesquisada e salva em um arquivo
#'
#' @param cons url da página consultada (excluido o dominio)
#' @param arq arquivo em que deseja salvar a página
#' @param message mensagem que deseja exibir se o arquivo for salvo com sucesso
ra_get_page__ <- function(cons, arq, message = "Arquivo obtido com sucesso!"){
  rPython::python.call('acessa', cons, arq, message)
}

#' Cookies da sessão global criada
#'
#'
ra_get_cookie <- function(){
  cookie <- rPython::python.call('get_cookies')
  return(cookie)
}

#' get page
#'
#' Retorna um objeto com a mesma classe de html(url).
#'
#' @param cons pagina consultada
#' @export
ra_get_page_ <- function(cons) {
  f <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".html")
  ra_get_page__(cons, f, message = "__")
  # doc <- xml2::read_html(f)
  doc <- rvest::html(f)
  file.remove(f) # apaga o arquivo criado
  return(doc)
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

ra_get_page <- function(id){

  cons <- ra_create_cons_id(id)
  doc <- ra_get_page_(cons)

  # logica para quando for
  # pag de validação com captcha
  if(ra_test_verif(doc)){
    ra_get_captcha(doc) %>%
      ler() %>%
      desenhar() %>%
      plot
    # criar uma funcao que coloca a reposta do captcha
    # pode ser desenhando e perguntando pro usuario!!
  }
  return(doc)
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


#' função para imprimir o captcha recebido
#'
#'
ra_get_captcha <- function(page){
  cap <- page %>%
    rvest::html_nodes("form") %>%
    rvest::html_nodes("img") %>%
    rvest::html_attr("src")
  tmp <- tempfile()
  rPython::python.call('get_captcha', cap, tmp)
  tmp
}

#' funcao que envia o captcha para a página!
#'
#'
ra_send_captcha <- function(cons, captcha){
  rPython::python.call('send_captcha', cons, captcha)
  ra_get_page(cons)
}

#' Função para criar uma consulta a partir do id a empresa
#'
#'
ra_create_cons_id <- function(id){
  paste0("/indices/lista_reclamacoes/?id=", id, "&tp=9403f4c8cd5af61c485541e9444950c069c79ffa&subtp=c92a9bc341d739044ff5400661d44a60a808be22")
}
