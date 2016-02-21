# Primeiros contatos com o RSelenium - Observatório do Trabalho de Porto Alegre
# http://www.dadosaleatorios.com.br/2016/02/primeiros-contatos-com-o-rselenium.html
# Para o comando funcionar, o Firefox deve estar configurado para aceitar automaticamente downloads em .xls

# Caso não tenha instalado o RSelenium, instale: install.packages('RSelenium')

library('RSelenium')

# Checar se possui um servidor Selenium instalado. Caso contrário, baixa e instala:
# checkForServer()

# No meu computador deu o seguinte erro: Erro: 1: No such file or directory2: failed to load external entity "http://selenium-release.storage.googleapis.com"
# A solução foi baixar manualmente o servidor standalone do Selenium em http://www.seleniumhq.org/download/

# Se o checkForServer() tiver funcionado, é preciso abrir o servidor através do comando:
# startServer()
# Caso contrário, é preciso rodar o .jar baixado anteriormente no Java, pela linha de comando 'java -jar selenium-server-standalone-2.51.0.jar'

# Conectar no servidor
remDr <- remoteDriver()

# Abrir o servidor:
remDr$open()

# Inicia a navegação no site
remDr$navigate("http://geo.dieese.org.br/poa/tabelas_poa.php")

# A conexão com o site principal estava dando timeout. *ACREDITO* que seja porque ele não sofre alterações, apenas execute scripts
remDr$setTimeout(type = "page load", milliseconds = 1000000)

# Como ainda não sei Selenium suficiente, peguei os comandos a serem executados nessa página por expressão regular.
# A expressão abrirTabela\([^\)]*\) é explicada no link: https://regex101.com/r/vX7gU5/1 ()
dados <- readLines('http://geo.dieese.org.br/poa/tabelas_poa.php') # Baixa o site para o R
dados <- dados[grepl('abrirTabela\\([^\\)]*\\)', dados)][2] # Seleciona apenas as linhas que possuem a ER
pos <- gregexpr('abrirTabela\\([^\\)]*\\)', dados)[[1]] # Retorna a posição e largura de todos correspondências da ES
comandos <- mapply(substr, dados, pos, pos + attr(pos,"match.length") - 1) # Filtra apenas os comandos JS a serem enviados
names(comandos) <- NULL


for (i in comandos) {
	remDr$executeScript(gsub('&quot;', '"', i)) # Executa o comando
	Sys.sleep(2)
	janelas <- remDr$getWindowHandles()[[1]] # Lista as janelas abertas (já que o comando anterior abre uma nova janela)
	remDr$switchToWindow(janelas[2]) # Alterna a janela em atividade para a segunda janela
	
	# Há dois tipos de tabelas: as que podem se baixar todos os anos de uma só vez
	# E as que é necessário baixar 1 ano de cada vez. O comando abaixo procura pelo
	# checkbox que seleciona todos os anos. Se encontrar, ativa o if. O comando foi
	# uma resposta obtida no SO: http://stackoverflow.com/questions/35340253/checking-multiple-checkbox-with-rselenium

	try(selectAll <- remDr$findElement(using = 'css selector', '#anos > #alternar'))
	if (exists('selectAll')) {
		# Para se clicar para selecionar todos os anos, é necessário uma sequências de comandos em Java Script:
		remDr$executeScript("ativarGuia('filtros')") # Ativa a guia 'filtros'
		remDr$executeScript("visualizar('filtros', true)") # Exibe a guia 'filtros'
		remDr$executeScript("visualizarAnos()") # Exibe a aba 'Anos'
	
		selectAll$clickElement() # Clica no checkbox para selecionar todos os anos
		remDr$executeScript("submeter()") # Executa o comando para atualizar a tabela (Equivalente a clicar no botão 'Gerar')
		Sys.sleep(2)
		remDr$executeScript("baixarArquivo(1)") # Baixa o arquivo em .xls

		remDr$closeWindow() # Fecha a janela atual
		remDr$switchToWindow(remDr$getWindowHandles()[[1]][1]) # Ativa a janela principal
		rm('selectAll') # Remove a variável selectAll
	}
	else {
		anos <- remDr$findElements(using = 'xpath', "//input[@name='inputAno'][@type='radio']") # Busca pelo radio dos anos
		for (j in seq_along(anos)) {
			anos <- remDr$findElements(using = 'xpath', "//input[@name='inputAno'][@type='radio']") # Busca pelo radio dos anos (Por algum motivo eu preciso refazer isso a cada iteração)
			try(remDr$executeScript("ativarGuia('filtros')")) # Ativa a guia 'filtros'
			try(remDr$executeScript("visualizar('filtros', true)")) # Exibe a guia 'filtros'
			try(remDr$executeScript("visualizarAnos()")) # Exibe a aba 'Anos'
			anos[[j]]$clickElement() # Seleciona o ano
			try(remDr$executeScript("submeter()")) # Executa o comando para atualizar a tabela (Equivalente a clicar no botão 'Gerar')
			try(remDr$executeScript("baixarArquivo(1)")) # Baixa o arquivo em .xls
			Sys.sleep(3)
		}
		remDr$closeWindow() # Fecha a janela atual
		remDr$switchToWindow(remDr$getWindowHandles()[[1]][1]) # Ativa a janela principal
	} 
}

remDr$closeWindow() # Fecha a janela principal
remDr$close() # Fecha a conexão
