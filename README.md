# Cadastro de Pessoas
Projeto Delphi - API com Horse

## Configuração
- Necessário instalação do Horse: 
    - https://github.com/HashLoad/horse
- Necessário instalação do docker para rodar o Banco de dados: 
    - https://www.docker.com/
- Acessar a pasta **\postgres** e via terminal executar o comando: `docker-compose up -d`
    - Com isso seu banco Postgres está disponível
    - Dados de acesso ao banco estão no arquivo **/docker-compose.yaml**
    - Executar o seguinte script para criação das tabelas **/Criacao_Tabelas.sql**

## Rodar o projeto
- Executar o projeto **Server.exe** e clicar em *start*
  - Portão padrão é `8080`
- Executar o projeto **Cliente.exe** e testar o cadastro via formulário

## Rotas

- Get -> http://localhost:8080/pessoas
- Get -> http://localhost:8080/pessoas/id
- Post -> http://localhost:8080/pessoas
- Put -> http://localhost:8080//pessoas/id
- Delete -> http://localhost:8080/pessoas/id

Exemplo do body para Post e Put:
```
{
	"flnatureza": 1,
	"dsdocumento": "87511330088",
	"nmprimeiro": "Geovane",
	"nmsegundo": "Silva",
	"dtregistro": "2024-12-01",
	"dscep": "12345000"
}
```

Rota para inserir registros em lotes:
- Post -> http://localhost:8080/pessoas/lote
```
[
	{
		"flnatureza": 10,
		"dsdocumento": "23392563056",
		"nmprimeiro": "Juninho",
		"nmsegundo": "Santos",
		"dtregistro": "2024-12-01",
		"dscep": "12345001"
	},
	{
		"flnatureza": 20,
		"dsdocumento": "49223693098",
		"nmprimeiro": "Raul",
		"nmsegundo": "Oliveira",
		"dtregistro": "2024-12-02",
		"dscep": "12345002"
	}
]
```