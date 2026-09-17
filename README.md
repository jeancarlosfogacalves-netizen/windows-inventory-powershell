# Windows Inventory PowerShell

Script em PowerShell para coletar informações básicas de computadores Windows e gerar um inventário em formato CSV.

Criei este projeto com foco em automação de tarefas comuns de suporte e infraestrutura.

## Informações coletadas

O script coleta:

- Nome do computador
- Usuário logado
- Fabricante e modelo
- Versão do Windows
- Processador
- Memória RAM
- Endereço IPv4
- Gateway padrão
- Servidores DNS
- Uptime da máquina
- Capacidade e espaço livre dos discos
- Data da coleta

## Como usar

Clone o repositório ou faça o download do arquivo `inventory.ps1`.

Abra o PowerShell na pasta do projeto e execute:

```powershell
.\inventory.ps1
