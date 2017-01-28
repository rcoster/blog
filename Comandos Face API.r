# Código da postagem "Identificando pessoas em fotos" do blog Dados Aleatórios
# http://www.dadosaleatorios.com.br/2017/01/identificando-pessoas-em-fotos.html

setwd('D:/Blog')
library(httr)

# Variáveis Universais
key <- 'a9552de324fd4d6425014d64250b4d58' # Chave de acesso da API'. Você deve substituir pela a sua chave.
GrupoID <- 'atoresharrypotter' # ID do grupo de pessoas que iremos criar. Possui algumas limitações de caracteres, como não permitir letras maiusculas

# Fonte das fotos:
# Foto Harry: http://www.imdb.com/title/tt1201607/mediaviewer/rm318488320
# Foto Hermione: http://www.imdb.com/title/tt1201607/mediaviewer/rm1341898496
# Foto Rony: http://www.imdb.com/title/tt1201607/mediaviewer/rm1710997248
# Foto trio: http://www.imdb.com/title/tt1201607/mediaviewer/rm2974529536
# Harry + McGonagall: http://www.imdb.com/title/tt1201607/mediaviewer/rm402374400
# Harry + Muita gente: http://www.imdb.com/title/tt1201607/mediaviewer/rm3653877504

# Cria o grupo

httr::PUT( 	url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s", GrupoID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(name = "Harry Potter e as Relíquias da Morte - Parte 2",
						userData = "Grupo com os principais personagens de Harry Potter e as Relíquias da Morte - Parte 2"),
			encode = 'json') # Não é necessário armazenar a resposta
			
# Cria a pessoa dos 3 personagens

HarryPotter <- httr::POST(
			url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/persons", GrupoID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(name = "Harry Potter",
						userData = "Personagem que da nome a série de livros."),
			encode = 'json') # Aqui é preciso armazenar pois temos como resposta o ID dessa pessoa.
			
HarryPotterID <- content(HarryPotter)$personId

RonyWeasley <- httr::POST(
			url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/persons", GrupoID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(name = "Rony Weasley",
						userData = "Melhor amigo de Harry Potter."),
			encode = 'json') # Aqui é preciso armazenar pois temos como resposta o ID dessa pessoa.
			
RonyWeasleyID <- content(RonyWeasley)$personId

HermioneGranger <- httr::POST(
			url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/persons", GrupoID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(name = "Hermione Granger",
						userData = "Melhor amiga de Harry Potter."),
			encode = 'json') # Aqui é preciso armazenar pois temos como resposta o ID dessa pessoa.
			
HermioneGrangerID <- content(HermioneGranger)$personId

# Informa uma face para a pessoa

httr::POST(	url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/persons/%s/persistedFaces", GrupoID, HarryPotterID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(url = "https://goo.gl/6qYGKG"),
			encode = 'json') # Não vamos usar o resultado.
			
httr::POST(	url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/persons/%s/persistedFaces", GrupoID, RonyWeasleyID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(url = "https://goo.gl/xGL4nD"),
			encode = 'json') # Não vamos usar o resultado.
			
httr::POST(	url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/persons/%s/persistedFaces", GrupoID, HermioneGrangerID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			body = list(url = "https://goo.gl/1KfYoX"),
			encode = 'json') # Não vamos usar o resultado.
			
# Treina a API

httr::POST(	url = sprintf("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/%s/train", GrupoID),
			httr::content_type('application/json'),
			httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
			encode = 'json')
			

###
# Testes 
###

##
# Foto 1: Trio
##
# Localizando faces na fotos
fotoAlvo_1 <- httr::POST(url = "https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false",
				httr::content_type('application/json'),
				httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
				body = list(url = "https://goo.gl/5k77Hq",
					returnFaceLandmarks = TRUE),
				encode = 'json') 
				
idAlvos_1 <- mapply(function(x) unlist(x['faceId']), content(fotoAlvo_1))
faces_1 <- mapply(function(x) unlist(x['faceRectangle']), content(fotoAlvo_1))

# Identificando as faces localizadas na foto
resultado_1 <- httr::POST(url = "https://westus.api.cognitive.microsoft.com/face/v1.0/identify",
				httr::content_type('application/json'),
				httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
				body = list(personGroupId = GrupoID, # Para informar em qual grupo de pessoas eu quero procurar
				faceIds = idAlvos_1, # Para informar quais rostos eu quero identificar. Limitado a 10 ids.
				maxNumOfCandidatesReturned = 1, # Para informar quantos 'chutes' eu quero. Limitado a 5. (Padrão 1)
				confidenceThreshold = 0.5), # Confiança mínima para a identificação (Padrão 0.5)
				encode = 'json') 
chute_1 <- mapply(function(x) { out <- unlist(x[['candidates']])['personId'] ; return(if (is.null(out)) { NA } else { out })} , content(resultado_1))
score_1 <- mapply(function(x) { out <- unlist(x[['candidates']])['confidence'] ; return(if (is.null(out)) { '' } else { out })} , content(resultado_1))
chute_1 <- factor(chute_1, levels = c(HarryPotterID, RonyWeasleyID, HermioneGrangerID), labels = c('Harry Potter', 'Rony Weasley', 'Hermione Granger'))

##
# Foto 2: Harry + McGonagall: http://www.imdb.com/title/tt1201607/mediaviewer/rm402374400
##
# Localizando faces na fotos
fotoAlvo_2 <- httr::POST(url = "https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false",
				httr::content_type('application/json'),
				httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
				body = list(url = "https://goo.gl/BwTWbq"),
				encode = 'json') 
				
idAlvos_2 <- mapply(function(x) unlist(x['faceId']), content(fotoAlvo_2))
faces_2 <- mapply(function(x) unlist(x['faceRectangle']), content(fotoAlvo_2))

# Identificando as faces localizadas na foto
resultado_2 <- httr::POST(url = "https://westus.api.cognitive.microsoft.com/face/v1.0/identify",
				httr::content_type('application/json'),
				httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
				body = list(personGroupId = GrupoID, # Para informar em qual grupo de pessoas eu quero procurar
				faceIds = idAlvos_2, # Para informar quais rostos eu quero identificar. Limitado a 10 ids.
				maxNumOfCandidatesReturned = 1, # Para informar quantos 'chutes' eu quero. Limitado a 5. (Padrão 1)
				confidenceThreshold = 0.5), # Confiança mínima para a identificação (Padrão 0.5)
				encode = 'json') 
chute_2 <- mapply(function(x) { out <- unlist(x[['candidates']])['personId'] ; return(if (is.null(out)) { NA } else { out })} , content(resultado_2))
score_2 <- mapply(function(x) { out <- unlist(x[['candidates']])['confidence'] ; return(if (is.null(out)) { '' } else { out })} , content(resultado_2))
chute_2 <- factor(chute_2, levels = c(HarryPotterID, RonyWeasleyID, HermioneGrangerID), labels = c('Harry Potter', 'Rony Weasley', 'Hermione Granger'))

##
# Foto 3: Harry + muita gente
##
# Localizando faces na fotos
fotoAlvo_3 <- httr::POST(url = "https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false",
				httr::content_type('application/json'),
				httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
				body = list(url = "https://goo.gl/CXl2wd"),
				encode = 'json') 
				
idAlvos_3 <- mapply(function(x) unlist(x['faceId']), content(fotoAlvo_3))
faces_3 <- mapply(function(x) unlist(x['faceRectangle']), content(fotoAlvo_3))[, 1:10]

# Identificando as faces localizadas na foto
resultado_3 <- httr::POST(url = "https://westus.api.cognitive.microsoft.com/face/v1.0/identify",
				httr::content_type('application/json'),
				httr::add_headers(.headers = c('Ocp-Apim-Subscription-Key' = key)),
				body = list(personGroupId = GrupoID, # Para informar em qual grupo de pessoas eu quero procurar
				faceIds = head(idAlvos_3, 10), # Para informar quais rostos eu quero identificar. Limitado a 10 ids.
				maxNumOfCandidatesReturned = 1, # Para informar quantos 'chutes' eu quero. Limitado a 5. (Padrão 1)
				confidenceThreshold = 0.5), # Confiança mínima para a identificação (Padrão 0.5)
				encode = 'json') 
chute_3 <- mapply(function(x) { out <- unlist(x[['candidates']])['personId'] ; return(if (is.null(out)) { NA } else { out })} , content(resultado_3))
score_3 <- mapply(function(x) { out <- unlist(x[['candidates']])['confidence'] ; return(if (is.null(out)) { '' } else { out })} , content(resultado_3))
chute_3 <- factor(chute_3, levels = c(HarryPotterID, RonyWeasleyID, HermioneGrangerID), labels = c('Harry Potter', 'Rony Weasley', 'Hermione Granger'))
				
# Imagens utilizadas na postagem

plot_jpeg = function(path, add = FALSE)
{
  # Fonte/Autor: http://stackoverflow.com/a/28729601/2016092
  require('jpeg')
  jpg = readJPEG(path, native=T)
  res = dim(jpg)[2:1]
  if (!add)
	par(mar = rep(0, 4))
    plot(1, 1, xlim = c(1, res[1]), ylim = c(1, res[2]), asp = 1,type = 'n', xaxs = 'i', yaxs = 'i', xaxt ='n', yaxt = 'n', xlab = '', ylab = '', bty = 'n')
  rasterImage(jpg, 1, 1, res[1], res[2])
  return(res)
}

# Trio identificado
download.file("https://goo.gl/5k77Hq", mode = "wb", destfile = 'Trio.jpg')
res <- plot_jpeg('Trio.jpg')
jpeg('Trio - Identificado.jpg', w = res[1], h = res[2])
plot_jpeg('Trio.jpg')
rect(faces_1['faceRectangle.left', ], res[2] - faces_1['faceRectangle.height', ] - faces_1['faceRectangle.top', ], faces_1['faceRectangle.left', ] + faces_1['faceRectangle.width', ], res[2] - faces_1['faceRectangle.top', ], border = ifelse(is.na(chute_1), 'red', 'green')) # Faz um retângulo em volta dos rostos identificados
text((faces_1['faceRectangle.left', ] * 2 + faces_1['faceRectangle.width', ]) / 2, (res[2] * 2 - faces_1['faceRectangle.top', ] * 2 - faces_1['faceRectangle.height', ]) / 2, ifelse(is.na(chute_1), 'N/I', sprintf("%s\n%s", chute_1, score_1)), col = ifelse(is.na(chute_1), 'red', 'green'), cex = 3) # Numera os rostos identificados
dev.off()

# Harry + McGonagall identificado
download.file("https://goo.gl/BwTWbq", mode = "wb", destfile = 'Harry_1.jpg')
res <- plot_jpeg('Harry_1.jpg')
jpeg('Harry_1 - Identificado.jpg', w = res[1], h = res[2])
plot_jpeg('Harry_1.jpg')
rect(faces_2['faceRectangle.left', ], res[2] - faces_2['faceRectangle.height', ] - faces_2['faceRectangle.top', ], faces_2['faceRectangle.left', ] + faces_2['faceRectangle.width', ], res[2] - faces_2['faceRectangle.top', ], border = ifelse(is.na(chute_2), 'red', 'green')) # Faz um retângulo em volta dos rostos identificados
text((faces_2['faceRectangle.left', ] * 2 + faces_2['faceRectangle.width', ]) / 2, (res[2] * 2 - faces_2['faceRectangle.top', ] * 2 - faces_2['faceRectangle.height', ]) / 2, ifelse(is.na(chute_2), 'N/I', sprintf("%s\n%s", chute_2, score_2)), col = ifelse(is.na(chute_2), 'red', 'green'), cex = 3) # Numera os rostos identificados
dev.off()

# Harry + Multidão identificado
download.file("https://goo.gl/CXl2wd", mode = "wb", destfile = 'Harry_2.jpg')
res <- plot_jpeg('Harry_2.jpg')
jpeg('Harry_2 - Identificado.jpg', w = res[1], h = res[2])
plot_jpeg('Harry_2.jpg')
rect(faces_3['faceRectangle.left', ], res[2] - faces_3['faceRectangle.height', ] - faces_3['faceRectangle.top', ], faces_3['faceRectangle.left', ] + faces_3['faceRectangle.width', ], res[2] - faces_3['faceRectangle.top', ], border = ifelse(is.na(chute_3), 'red', 'green')) # Faz um retângulo em volta dos rostos identificados
text((faces_3['faceRectangle.left', ] * 2 + faces_3['faceRectangle.width', ]) / 2, (res[2] * 2 - faces_3['faceRectangle.top', ] * 2 - faces_3['faceRectangle.height', ]) / 2, ifelse(is.na(chute_3), 'N/I', sprintf("%s\n%s", chute_3, score_3)), col = ifelse(is.na(chute_3), 'red', 'green'), cex = 3) # Numera os rostos identificados
dev.off()
