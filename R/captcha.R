# desenhar
# funcao do Julio para desenhar imagem
#
desenhar <- function(d) {
  p <- ggplot2::ggplot(d, ggplot2::aes(x = x, y = y))

  p <- p + ggplot2::coord_fixed()
  p <- p + ggplot2::theme_bw()
  if(!is.null(d$grupo)) {
    p <- p + ggplot2::geom_point()
    p <- p + ggplot2::facet_wrap(~grupo, scales = 'free_y', ncol = 5)
  } else {
    p <- p + ggplot2::geom_point(colour = d$cor)
  }
  p
}

#' ler imagem
#'
#' funcao do Julio para ler imagens
ler <- function(a) {
  img <- png::readPNG(a)
  img_dim <- dim(img)
  img_df <- data.frame(
    x = rep(1:img_dim[2], each = img_dim[1]),
    y = rep(img_dim[1]:1, img_dim[2]),
    r = as.vector(img[,,1]),
    g = as.vector(img[,,2]),
    b = as.vector(img[,,3])
  )
  d <- dplyr::mutate(img_df, cor = rgb(r, g, b), id = 1:n())
  d <- dplyr::filter(d, cor != '#FFFFFF')
  return(d)
}

#' Funcao para limpar imagem
#'
#' funcao do Julio para limpar imagens
limpar <- function(d) {
  d <- dplyr::group_by(d, x)
  d <- dplyr::mutate(d, n = length(y))
  d <- dplyr::ungroup(d)
  d <- dplyr::filter(d, y > 20, y < 38)

  d <- dplyr::group_by(d, cor)
  d <- dplyr::mutate(d, n = length(cor))
  d <- dplyr::ungroup(d)
  d <- dplyr::filter(d, n == max(n))

  d <- dplyr::group_by(d, x)
  d <- dplyr::mutate(d, n = length(y))
  d <- dplyr::ungroup(d)
  d <- dplyr::filter(d, n > 1)

  d
}

