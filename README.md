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
A função shortestPath foi criada para encontrar todos os caminhos mais curtos entre duas cidades num mapa representado como um grafo. Primeiro, a função verifica se a cidade de partida é a mesma que a cidade de destino. Se for, não há necessidade de percorrer o mapa, pois o caminho mais curto é apenas essa própria cidade, e a função devolve uma lista com a mesma. Caso contrário, a função aplica o algoritmo de busca em largura (BFS) para explorar todos os possíveis caminhos entre as cidades e, no final, filtra esses caminhos e identifica aqueles que têm a menor distância.

### Algoritmo Utilizado - Busca em Largura (BFS)
Para encontrar todos os caminhos mais curtos, é utilizado o algoritmo de Busca em Largura (BFS). A BFS explora os caminhos pouco a pouco, expandindo um nível de cada vez e garantindo que encontra sempre os caminhos mais curtos primeiro. A função começa com uma fila de caminhos, onde cada caminho é uma lista de cidades, iniciada apenas com a cidade de partida. À medida que a BFS expande, ela acrescenta à fila novos caminhos com base nas cidades adjacentes à cidade atual, formando um novo caminho ao adicionar essa cidade ao final da lista. Esta abordagem é eficaz para evitar ciclos e assegurar que todos os caminhos viáveis até à cidade de destino sejam considerados de maneira sistemática.

#### Filtragem de Caminhos de Menor Distância
Após a execução da BFS, recorremos a uma função de filtragem para seleccionar apenas os caminhos que têm a menor distância total entre a cidade de partida e a cidade de destino. Para isso, calcula-se a distância de cada caminho encontrado e identifica-se o valor mínimo. Em seguida, são seleccionados apenas os caminhos que correspondem a essa distância mínima, garantindo que todos os caminhos mais curtos possíveis sejam incluídos na resposta final. Desta forma, a função devolve uma lista com todos os caminhos que correspondem a essa distância mínima.

### Justificação das Estruturas de Dados Auxiliares
A escolha de listas para representar os caminhos durante a execução do BFS facilita a manipulação dos dados, permitindo adicionar e expandir caminhos de maneira simples e eficiente. Em cada iteração, a lista de caminhos é atualizada com as cidades adjacentes, permitindo manter o controlo sobre quais caminhos já foram explorados e quais ainda estão em expansão. Adicionalmente, ao utilizar listas para armazenar as distâncias dos caminhos, é possível calcular rapidamente a menor distância e realizar a filtragem necessária para seleccionar apenas os caminhos mínimos.

## Implementação da Função TravelSales
