# PFL_Project
Group T06_G04
- Eduardo Santos, up202207521
- Pedro Pedro, up202206961
- Renata Simão, up202205124

#### Distribuição do trabalho
- Eduardo Santos:
- Pedro Pedro:
- Renata Simão:

## Implementação da Função shortestPath
### Definição da Função
A função shortestPath inicia-se verificando se a cidade de partida é a mesma que a cidade de chegada. Se for, retorna uma lista contendo apenas essa cidade, pois não há necessidade de percorrer o mapa. 
No caso em que as cidades são diferentes, a função utiliza a busca em largura (BFS) para encontrar todos os caminhos possíveis entre as duas cidades e, em seguida, filtra os caminhos encontrados para identificar os de menor distância.


### Algoritmo Utilizado - Busca em Largura (BFS)

A busca em largura é utilizada para explorar todos os caminhos possíveis a partir da cidade de partida até encontrar a cidade de destino. O algoritmo funciona utilizando uma fila de caminhos, iniciando com o caminho que contém apenas a cidade de partida. À medida que percorre a fila, explora cada caminho atual, adicionando novos caminhos baseados nas cidades adjacentes à cidade atual. Essa abordagem assegura que todos os caminhos são considerados, evitando ciclos.

#### Filtragem de Caminhos de Menor Distância

Após a execução da BFS, é utilizada uma função de filtragem para selecionar apenas os caminhos que possuem a menor distância. Esta filtragem é realizada ao calcular a distância de cada caminho e identificar qual é a mínima. Com isso, a função retorna apenas os caminhos que correspondem a essa distância mínima.

### Justificação das Estruturas de Dados Auxiliares
A utilização de listas para armazenar os caminhos permite uma manipulação simples e eficiente durante a busca. Além disso, a lista de distâncias é criada a partir da aplicação da função que calcula a distância de cada caminho. O uso de listas possibilita obter facilmente a distância mínima e filtrar os caminhos correspondentes.


## Implementação da Função TravelSales