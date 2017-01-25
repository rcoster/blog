# Código da postagem 'Identificando emoções em fotos' do blog Dados Aleatórios
# http://www.dadosaleatorios.com.br/2017/01/identificando-emocoes-em-fotos.html
# Baseado no código: https://blog.exploratory.io/analyzing-emotions-using-facial-expressions-in-video-with-microsoft-ai-and-r-8f7585dd0780#.lxd1yptpu

library("httr")
library("gridExtra")
library("ggplot2")
setwd('D:/Blog/')
keyAPI <- '4605b13b949f4bc7ad5f3f43476408ab'

plot_jpeg = function(path, add=FALSE)
{
  # Fonte/Autor: http://stackoverflow.com/a/28729601/2016092
  require('jpeg')
  jpg = readJPEG(path, native=T) # read the file
  res = dim(jpg)[2:1] # get the resolution
  if (!add) # initialize an empty plot area if add==FALSE
    plot(1,1,xlim=c(1,res[1]),ylim=c(1,res[2]),asp=1,type='n',xaxs='i',yaxs='i',xaxt='n',yaxt='n',xlab='',ylab='',bty='n')
  rasterImage(jpg,1,1,res[1],res[2])
  return(res)
}

FuncEMO <- function(urlFoto, key) {
	httr::POST(
	  url = "https://westus.api.cognitive.microsoft.com/emotion/v1.0/recognize",
	  httr::content_type('application/json'),
	  httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
	  body = list(url = urlFoto),
	  encode = 'json'
	)
}


# Foto 1 - Velório
foto <- 'https://goo.gl/dW5x1r'
faceEMO <- FuncEMO(urlFoto = foto, key = keyAPI)
conteudo <- content(faceEMO)

rostos <- mapply(function(x) unlist(x[['faceRectangle']]), conteudo)
pontuacao <- mapply(function(x) unlist(x[['scores']]), conteudo)
colnames(pontuacao) <- 1:ncol(pontuacao)
download.file(foto, 'Foto Temer.jpg', mode = 'wb')
res <- plot_jpeg('Foto Temer.jpg')
jpeg('Foto Temer - Identificado.jpg', w = res[1], h = res[2])
par(mar = c(0, 0, 0, 0))
res <- plot_jpeg('Foto Temer.jpg')
rect(rostos[2, ], res[2] - rostos[3, ] - rostos[1, ], rostos[2, ] + rostos[4, ], res[2] - rostos[3, ], border = 2) # Faz um retângulo em volta dos rostos identificados
text((rostos[2, ] * 2 + rostos[4, ]) / 2, (res[2] * 2 - rostos[3, ] * 2 - rostos[1, ]) / 2, 1:12, col = 2, cex = 2) # Numera os rostos identificados
dev.off()

tabela <- sprintf('%.4f', pontuacao)
dim(tabela) <- dim(pontuacao)
dimnames(tabela) <- dimnames(pontuacao)

qplot(1:10, 1:10, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))

# Foto 2 - Refugiados
foto <- "http://www.esquerda.net/sites/default/files/refu_0.jpg"
faceEMO <- FuncEMO(urlFoto = foto, key = keyAPI)
conteudo <- content(faceEMO)
rostos <- mapply(function(x) unlist(x[['faceRectangle']]), conteudo)
pontuacao <- mapply(function(x) unlist(x[['scores']]), conteudo)
colnames(pontuacao) <- 1:ncol(pontuacao)
download.file(foto, 'Refugiados.jpg', mode = 'wb')
res <- plot_jpeg('Refugiados.jpg')
jpeg('Refugiados - Identificado.jpg', w = res[1], h = res[2])
par(mar = c(0, 0, 0, 0))
res <- plot_jpeg('Refugiados.jpg')
rect(rostos[2, ], res[2] - rostos[3, ] - rostos[1, ], rostos[2, ] + rostos[4, ], res[2] - rostos[3, ], border = 2) # Faz um retângulo em volta dos rostos identificados
text((rostos[2, ] * 2 + rostos[4, ]) / 2, (res[2] * 2 - rostos[3, ] * 2 - rostos[1, ]) / 2, seq_along(conteudo), col = 2, cex = 2) # Numera os rostos identificados
dev.off()

tabela <- sprintf('%.4f', pontuacao)
dim(tabela) <- dim(pontuacao)
dimnames(tabela) <- dimnames(pontuacao)

qplot(1:10, 1:10, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))

# Foto 3 - Copa do Mundo
foto <- "http://ichef.bbci.co.uk/onesport/cps/480/mcs/media/images/76239000/jpg/_76239589_afptrophy.jpg"
faceEMO <- FuncEMO(urlFoto = foto, key = keyAPI)
conteudo <- content(faceEMO)
rostos <- mapply(function(x) unlist(x[['faceRectangle']]), conteudo)
pontuacao <- mapply(function(x) unlist(x[['scores']]), conteudo)
colnames(pontuacao) <- 1:ncol(pontuacao)
download.file(foto, 'Copa.jpg', mode = 'wb')
res <- plot_jpeg('Copa.jpg')
jpeg('Copa - Identificado.jpg', w = res[1], h = res[2])
par(mar = c(0, 0, 0, 0))
res <- plot_jpeg('Copa.jpg')
rect(rostos[2, ], res[2] - rostos[3, ] - rostos[1, ], rostos[2, ] + rostos[4, ], res[2] - rostos[3, ], border = 2) # Faz um retângulo em volta dos rostos identificados
text((rostos[2, ] * 2 + rostos[4, ]) / 2, (res[2] * 2 - rostos[3, ] * 2 - rostos[1, ]) / 2, seq_along(conteudo), col = 2, cex = 2) # Numera os rostos identificados
dev.off()

tabela <- sprintf('%.4f', pontuacao)
dim(tabela) <- dim(pontuacao)
dimnames(tabela) <- dimnames(pontuacao)

qplot(1:10, 1:10, geom = "blank") + theme_bw() + theme(line = element_blank(), text = element_blank()) + annotation_custom(grob = tableGrob(tabela))

