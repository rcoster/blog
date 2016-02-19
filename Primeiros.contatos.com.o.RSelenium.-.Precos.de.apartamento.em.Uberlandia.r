# Primeiros contatos com o RSelenium - Preços de apartamento em Uberlandia
# http://www.dadosaleatorios.com.br/2016/02/primeiros-contatos-com-o-rselenium.html

library('RSelenium') # Carrega o pacote
library(plyr)
startServer() # Caso você tenha instalado o Selenium pelo pacote. Se não, terá que iniciar manualmente

remDr <- remoteDriver(browserName = "chrome") # Conecta com o Selenium no Chrome (Siga as intruções para instalar o driver do Chrome: https://cran.r-project.org/web/packages/RSelenium/vignettes/RSelenium-saucelabs.html#id1a)
remDr$open() # Abre o navegador
remDr$navigate("http://www.vivareal.com.br/venda/minas-gerais/uberlandia/apartamento_residencial/#1/") # Abre a página a ser explorada

i <- 0
valores <- desc <- NULL
while (i < 3) { # Pega somente as 3 primeiras páginas
	valores <- c(valores, unlist(sapply(remDr$findElements(using = 'class', 'search-results-property-list__price-value'), function(x) x$getElementText()))) # Procura por elementos de classe 'search-results-property-list__price-value' e pega seu conteúdo (os valores)
	desc <- c(desc, sapply(remDr$findElements(using = 'class', 'search-results-property-list__features'), function(x) x$getElementText())) # Procura por elementos de classe 'search-results-property-list__features' e pega seu conteúdo (as características)
	proximo <- tail(remDr$findElements(using = 'partial link text', 'ximo'), 1)[[1]] # Procura por link com o texto 'ximo'
	proximo$clickElement() # Clica no elemento encontrando no comando anterior
	Sys.sleep(3)
	i <- i+1
}

arruma <- function(x) {
	dados <- sapply(x, function(x) {
		suporte <- strsplit(x, '\n')[[1]]
		as.data.frame(structure(mapply(list, suporte[c(F, T)]), .Names = suporte[c(T, F)]))
	})
	return(rbind.fill(dados))
}
dados <- cbind(arruma(desc), Valor = valores) # 
dados

