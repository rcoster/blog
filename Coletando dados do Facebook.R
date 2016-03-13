# Coletando dados do Facebook
# http://www.dadosaleatorios.com.br/2016/03/coletando-dados-do-facebook.html

# Graph API Explorer: https://developers.facebook.com/tools/explorer/
library(jsonlite)
library(ggplot2)
library(data.table)

###
# Exemplo 1: Pegando as últimas postagens 
###

token <- 'AAA' # Colar aqui o token!
readLines(sprintf("https://graph.facebook.com/v2.5/me/posts?access_token=%s", token)) # Ignorem a mensagem de warning
fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/me/posts?access_token=%s", token)))
str(fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/me/posts?access_token=%s", token))))

# Pegando todas postagens
url <- sprintf("https://graph.facebook.com/v2.5/me/posts?access_token=%s&limit=200", token)

posts <- list()
i <- 0
repeat {
	i <- i + 1
	posts[[i]] <- suppressWarnings(fromJSON(readLines(url)))
	url <- posts[[i]]$paging$`next`
	if (is.null(url)) { break }
}

dados <- data.table(if (length(posts) > 1) { do.call(rbind, mapply(function(x) x$data, posts)) } else { posts[[1]]$data }) # Junta todos resultados em 1 único data.table
dados[, Data := as.Date(substr(created_time, 1, 10), '%Y-%m-%d') ] # Extrai a data da postagem
dados[, table(format(Data, '%Y'))]
dados[, table(format(Data, '%Y'), factor(format(Data, '%B'), levels = format(ISOdate(2000, 1:12, 1), "%B")))]


###
# Exemplo 2: Pegando as informações de uma postagem
###

id <- 'xxx_yyy' # Colar aqui o id
fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/?access_token=%s", id, token)))
fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/comments?access_token=%s", id, token)))
fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/likes?access_token=%s", id, token)))
fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/sharedposts?access_token=%s", id, token)))

fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/likes?access_token=%s&summary=true", id, token))) 
str(fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/likes?access_token=%s&summary=true", id, token))))

# Juntando com os dados anteriores

nCurtidas <- function(id, token) { 
	if (length(id) > 1 | length(token) > 1) { return(mapply(nCurtidas, id, token)) }
	suppressWarnings(fromJSON(readLines(sprintf("https://graph.facebook.com/v2.5/%s/likes?access_token=%s&summary=true", id, token)))$summary$total_count)
}

dados[, Curtidas := nCurtidas(id, token)] # Demora...

###
# Nuvem de palavras
###

library(wordcloud)
Freq <- as.data.table(table(gsub('(.*)', '\\L\\1', gsub('[^[[:alnum:]]]*', '', unlist(strsplit(dados[, message], ' ')), perl = T), perl = T)))
Freq[nchar(V1) > 3, wordcloud(V1, N)]
