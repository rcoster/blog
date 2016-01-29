# Após carregar as funções, basta utilizar o comando downloadAno('usuário', ano) (Por exemplo, downloadAno('rcoster', 2015))
# Para cada foto serão salvos 3 arquivos: um .txt com título e descrição da foto, um .csv com os comentários e um .jpg

downloadFoto <- function(url, data) {
	dados <- suppressWarnings(readLines(url))
	tituloPos <- gregexpr('</?title>', dados[1])[[1]]
	titulo <- iconv(substr(dados[1], tituloPos[1] + 7, tituloPos[2] - 1), 'UTF8', 'latin1')
	foto <- substr(dados[1], regexpr('<meta property="og:image" content="', dados[1]) + 35, regexpr('"><meta property="og:url"', dados[1]) - 1)
	descricao <- gsub('&lt;BR&gt;', '\n', iconv(substr(dados[1], regexpr('<meta name="description" content="', dados[1]) + 34, regexpr('<meta property="og:type" content="article">', dados[1]) - 1), 'UTF8', 'latin1'))
	descricao <- substr(descricao, 0, tail(regexpr('\\|', descricao), 1) - 2)
	comentariosApoio <- paste(iconv(dados[grep('Entrar para comentar', dados):grep('wall_img_container_big', dados)[2]], 'UTF8', 'latin1'), collapse = '')
	quandoPos <- gregexpr('</b> ligado', comentariosApoio)[[1]]
	
	if (quandoPos[1] > -1) { 
		autores <- gsub('<[^>]*>', '', mapply(substr, comentariosApoio, gregexpr('<b>', comentariosApoio)[[1]] + 3, gregexpr('</b>', comentariosApoio)[[1]] -1))
		quando <- as.Date(mapply(substr, comentariosApoio, quandoPos + 12, quandoPos + 23), '%d/%m/%Y')
		gregexpr('</p><br class="clear">', comentariosApoio)
		comentarios <- mapply(substr, comentariosApoio, quandoPos + 30, tail(gregexpr('</p><br class="clear">', comentariosApoio)[[1]], -1) - 1)
	}
	arq <- format(data, '%Y%m%d')
	download.file(foto, destfile = sprintf('%s.jpg', arq), mode = 'wb')
	cat(titulo, '\n\n', descricao, file = sprintf('%s.txt', arq))
	if (quandoPos[1] > -1) { write.csv2(data.table(Autor = autores, Data = quando, Comentario = comentarios), sprintf('%s.csv', arq), row.names = FALSE) }
}

downloadAno <- function(user, ano) {
	for (mes in 1:12) {
		dados <- suppressWarnings(readLines(sprintf('http://www.fotolog.com/%s/archive/%d/%d/', user, mes, ano)))
		dados <- grep('Grupos</a></li></ul>', dados, value = TRUE)
		if (length(gregexpr('<a href="', dados)[[1]]) > 1) {
			links <- mapply(substr, dados, head(gregexpr('<a href="', dados)[[1]], -1) + 9, gregexpr('"><img', dados)[[1]] - 1)
			datas <- as.double(gsub('[^0-9]', '', mapply(substr, dados, head(gregexpr('<a href="', dados)[[1]], -1) - 8, head(gregexpr('<a href="', dados)[[1]], -1))))
			datas <- as.Date(sprintf('%d/%d/%d', datas, mes, ano), '%d/%m/%Y')
			mapply(downloadFoto, links, datas)
		}
	}
}
