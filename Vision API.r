# Código da postagem 'Google Vision API' do blog Dados Aleatórios
# http://www.dadosaleatorios.com.br/2017/02/google-vision-api.html
# As fotos utlizadas podem ser baixadas em: https://drive.google.com/open?id=0B_OX1FlzVrSxV0RnMzRjUmF6Q1U

setwd('D:/Blog/Vision API')
library(httr)
library(RCurl)
library(gridExtra)
library(ggplot2)

key <- "AIzayDbS4EcWFtyEILqcMZ0azY8WZlq7Bo" # Substitua pela sua key

# Função de apoio, para transformar a imagem no formato necessário.
imageToText <- function(imagePath) {
  # Autor: https://github.com/cloudyr/RoogleVision/blob/master/R/googleVision-LIB.R
  if (stringr::str_count(imagePath, "http")>0) {### its a url!
    content <- RCurl::getBinaryURL(imagePath)
    txt <- RCurl::base64Encode(content, "txt")
  } else {
    txt <- RCurl::base64Encode(readBin(imagePath, "raw", file.info(imagePath)[1, "size"]), "txt")
  }
  return(paste(txt))
}

# Foto 1: Hamburger

resultado1 <- httr::POST(url = sprintf("https://vision.googleapis.com/v1/images:annotate?key=%s", key),
			httr::content_type('text/csv'),
			body = list(requests = list(
				image = list(content = imageToText('Hamburger.jpg')),
				features = list(type = 'LABEL_DETECTION', maxResults = 10))),
			encode = 'json')
			
tabela <- Reduce(function(x, y) merge(x, y, all = T), mapply(as.data.frame, content(resultado1)$responses[[1]]$labelAnnotations, SIMPLIFY = FALSE))
qplot(1, 1, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela, rows = NULL))

# Foto 2: Borboleta

resultado2 <- httr::POST(url = sprintf("https://vision.googleapis.com/v1/images:annotate?key=%s", key),
			httr::content_type('text/csv'),
			body = list(requests = list(
				image = list(content = imageToText('Borboleta.jpg')),
				features = list(type = 'LABEL_DETECTION', maxResults = 10))),
			encode = 'json')
			
tabela <- Reduce(function(x, y) merge(x, y, all = T), mapply(as.data.frame, content(resultado2)$responses[[1]]$labelAnnotations, SIMPLIFY = FALSE))
qplot(1, 1, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela, rows = NULL))

# Foto 3: Serra

resultado3 <- httr::POST(url = sprintf("https://vision.googleapis.com/v1/images:annotate?key=%s", key),
			httr::content_type('text/csv'),
			body = list(requests = list(
				image = list(content = imageToText('Serra.jpg')),
				features = list(type = 'LANDMARK_DETECTION', maxResults = 10))),
			encode = 'json')
			
tabela <- cbind(unlist(content(resultado3)$responses[[1]]$landmarkAnnotations))
qplot(1, 1, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))

# Foto 4: Igreja

resultado4 <- httr::POST(url = sprintf("https://vision.googleapis.com/v1/images:annotate?key=%s", key),
			httr::content_type('text/csv'),
			body = list(requests = list(
				image = list(content = imageToText('Igreja.jpg')),
				features = list(type = 'LANDMARK_DETECTION', maxResults = 10))),
			encode = 'json')
			
tabela <- cbind(unlist(content(resultado4)$responses[[1]]$landmarkAnnotations))
qplot(1, 1, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))


# Foto 5: Cerveja

resultado5 <- httr::POST(url = sprintf("https://vision.googleapis.com/v1/images:annotate?key=%s", key),
			httr::content_type('text/csv'),
			body = list(requests = list(
				image = list(content = imageToText('Cerveja.jpg')),
				features = list(type = 'TEXT_DETECTION', maxResults = 10))),
			encode = 'json')
			
tabela <- cbind(unlist(content(resultado5)$responses[[1]]$textAnnotations[[1]]))
qplot(1, 1, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))
			

# Foto 6: Carros

resultado6 <- httr::POST(url = sprintf("https://vision.googleapis.com/v1/images:annotate?key=%s", key),
			httr::content_type('text/csv'),
			body = list(requests = list(
				image = list(content = imageToText('Carros.jpg')),
				features = list(type = 'TEXT_DETECTION', maxResults = 10))),
			encode = 'json')
			
tabela <- cbind(unlist(content(resultado6)$responses[[1]]$textAnnotations[[1]]))
qplot(1, 1, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))
