# Código da postagem http://www.dadosaleatorios.com.br/2014/08/visualizando-grandes-bancos-de-dados.html
#
# Para o comando funcionar, devem estar na pasta de trabalho (getwd()) os seguintes arquivos:
# 1) RS2012.txt 		- https://drive.google.com/folderview?id=0ByKsqUnItyBhU2RmdUloTnJGRGM&usp=sharing
#
# Para o comando funcionar, é necessário ter os seguintes pacotes:
# 1) RSQlite 	- Para leitura dos dados
# 2) data.table - Para manipulação dos dados
# 5) tabplot	-  Para fazer os gráficos

require(RSQLite)
require(data.table)
require(tabplot)

con <- dbConnect('SQLite', dbname = "RAIS")
dbWriteTable(conn = con, name = 'RAIS2012', value = 'RS2012.txt', header = TRUE, row.names = FALSE, overwrite = TRUE, eol = '\n', sep = ';')
dados <- data.table(dbGetQuery(con, "select Tempo_Emprego, Raça_Cor, Sexo_Trabalhador, Vl_Remun_Média_Nom, Escolaridade_após_2005, Tipo_Estab_1 from RAIS2012 where Vínculo_Ativo_31_12 = 1")) # Pegando apenas os vínculos ativos em 31/12/2012
dados[,Vl_Remun_Média_Nom := as.double(gsub('\\,' , '\\.', Vl_Remun_Média_Nom))] # Transforma o salário nominal em número
dados[,Sexo_Trabalhador := factor(Sexo_Trabalhador, levels = 1:2, labels = c('Masculino', 'Feminino'))] # Acrescenta os labels da variável Sexo
dados[,Raça_Cor := factor(Raça_Cor, levels = c(1, 2, 4, 6, 8), labels = c("INDIGENA", "BRANCA", "PRETA", "AMARELA", "PARDA"))] # Acrescenta os labels da variável Raça_Cor, descartando as não identificadas
dados[,Escolaridade_após_2005 := factor(Escolaridade_após_2005, levels = 1:11, labels = c("ANALFABETO", "ATE 5.A INC", "5.A CO FUND", "6. A 9. FUND", "FUND COMPL", "MEDIO INCOMP", "MEDIO COMPL", "SUP. INCOMP", "SUP. COMP", "MESTRADO", "DOUTORADO"))] # Acrescenta os labels da variável Escolaridade
dados[,Tempo_Emprego := as.double(gsub('\\,' , '\\.', Tempo_Emprego))] # Transforma o tempo de emprego em número
dados[,Tipo_Estab_1 := factor(Tipo_Estab_1, levels = c("CNPJ                ", "CEI                 "), labels = c("CNPJ", "CEI"))] # Transforma a variavel string em fator
dados[, Vl_Remun_Média_Nom := ifelse(Vl_Remun_Média_Nom > 0, Vl_Remun_Média_Nom, NA)] # Substitui os valores 0 por NA.

tableplot(dados) # Com opções default.
tableplot(dados, select = c(Tempo_Emprego, Vl_Remun_Média_Nom, Sexo_Trabalhador), from = 95, to = 100, sortCol = 2, title = 'RAIS 2012 - RS', subset = Raça_Cor == 'BRANCA')
