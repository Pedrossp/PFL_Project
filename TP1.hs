import qualified Data.List
import qualified Data.Array
import qualified Data.Bits
import Data.Maybe


-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

--1.Cities
cities :: RoadMap -> [City]
cities roadMap = Data.List.nub [city | (c1, c2, _) <- roadMap, city <- [c1, c2]]

--2.areAdjacent
areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent roadMap c1 c2 = or [(c1 == c3 && c2 == c4) || (c1 == c4 && c2 == c3) | (c3, c4, w_) <- roadMap] --quando as duas cidades são a mesma é para retornar true or false (|| (c1 == c2))

--3.Distance
distance :: RoadMap -> City -> City -> Maybe Distance
distance roadMap c1 c2 =  case [d | (c3, c4, d) <- roadMap, (c1 == c3 && c2 == c4) || (c1 == c4 && c2 == c3)] of
    []      -> Nothing
    (d:_)   -> Just d

--4.Adjacent
adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent roadMap c1 = [(c2, d) | c2 <- cities roadMap, Just d <- [distance roadMap c1 c2],  areAdjacent roadMap c2 c1]

--5.PathDistance
pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance roadMap [] = Just 0
pathDistance roadMap [_] = Just 0
pathDistance roadMap (c1:c2:path) = if areAdjacent roadMap c1 c2
    then case distance roadMap c1 c2 of
        Nothing -> Nothing  -- Se não houver distância entre c1 e c2, retorna Nothing
        Just d  -> case pathDistance roadMap (c2:path) of
            Nothing  -> Nothing  -- Se não houver distância no caminho subsequente, retorna Nothing
            Just ds  -> Just (d + ds)  -- Soma a distância atual com a distância acumulada
    else Nothing

--6. Rome
rome :: RoadMap -> [City]
rome roadMap = [city | (city, x) <- citiesDegrees, x == maximum[b | (_, b) <- citiesDegrees]]
    where citiesDegrees = [(city, fromIntegral (length (adjacent roadMap city))) | city <- cities roadMap]

--7. isStronglyConnected
isStronglyConnected :: RoadMap -> Bool
isStronglyConnected roadMap = let allCities = cities roadMap
    in case allCities of
        []      -> True  -- Um grafo vazio é fortemente conexo
        (c:_)   -> let reachable = reachableFrom roadMap c
                   in all (`elem` reachable) allCities 

--8. ShorestPath
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath roadMap start end
    | start == end = [[start]]  -- Caso especial onde o ponto inicial é o mesmo que o destino
    | otherwise    = filterMinPaths (bfs [[start]] roadMap end) roadMap

--9. Tsp DynammicProgramming
travelSales :: RoadMap -> Path
travelSales roadmap =
  let citiesList = cities roadmap                            -- Extrair todas as cidades do roadmap
      cityCount = length citiesList                          -- Contar o número de cidades

      -- Caso de grafo vazio
      finalPath
        | cityCount == 0 = []                                -- Retorna caminho vazio se não houver cidades
        | otherwise =
            let adjMatrix = createAdjacencyMatrix citiesList roadmap  -- Construir a matriz de adjacência para distâncias

                -- Tabela de memoização para programação dinâmica, armazenando tuplas (Distância, Caminho)
                memoTable = Data.Array.array ((0, 0), (2 ^ cityCount - 1, cityCount - 1)) 
                              [((mask, pos), computeDP mask pos) | mask <- [0 .. 2 ^ cityCount - 1], pos <- [0 .. cityCount - 1]]

                -- Função de programação dinâmica usando mascaramento de bits
                computeDP :: Int -> Int -> Maybe (Distance, [Int])   -- (Distância, Caminho)
                computeDP mask pos
                  | allVisited mask = returnToStart
                  | otherwise = findMinimum validOptions
                  where
                    allVisited m = m == (1 `Data.Bits.shiftL` cityCount) - 1
                    returnToStart = case adjMatrix Data.Array.! (pos, 0) of
                                      Just dist -> Just (dist, [0])  -- Retornar à cidade inicial com a distância final
                                      Nothing -> Nothing

                    validOptions = [ 
                      let nextDist = adjMatrix Data.Array.! (pos, next)
                      in case nextDist of
                          Just distance -> do
                              (existingDist, existingPath) <- memoTable Data.Array.! (mask Data.Bits..|. (1 `Data.Bits.shiftL` next), next)
                              Just (distance + existingDist, next : existingPath)
                          Nothing -> Nothing
                      | next <- [0 .. cityCount - 1], 
                        next /= pos, 
                        not (Data.Bits.testBit mask next) 
                      ]

                -- Função auxiliar para obter o mínimo a partir das opções válidas
                findMinimum :: [Maybe (Distance, [Int])] -> Maybe (Distance, [Int])
                findMinimum opts =
                    let validOpts = [v | Just v <- opts]   -- Filtrar apenas os valores Just
                    in case validOpts of
                        [] -> Nothing                      -- Retornar Nothing se não houver opções válidas
                        _  -> Just $ Data.List.minimumBy comparePaths validOpts

                -- Função de comparação para as opções
                comparePaths :: (Distance, [Int]) -> (Distance, [Int]) -> Ordering
                comparePaths (dist1, _) (dist2, _) = compare dist1 dist2

                -- Obter o resultado final da tabela de memoização
                finalResult = memoTable Data.Array.! (1, 0)

            in case finalResult of
                Nothing -> []
                Just (_, path) -> map (citiesList !!) (0 : path)
  in finalPath

--10. TSP Brute Force 
tspBruteForce :: RoadMap -> Path
tspBruteForce roadmap =
    let cityList = cities roadmap
        startCity = head cityList  -- Use the first city as the starting point
        -- Generate all permutations of cities except the starting city to ensure round-trip routes
        allRoutes = [startCity : route ++ [startCity] | route <- Data.List.permutations (tail cityList)]
        -- Calculate distances for valid routes and filter out any invalid routes (i.e., Nothing distances)
        validRoutes = [(route, pathDistance roadmap route) | route <- allRoutes]
        -- Filter to only include routes with valid distances
        validDistances = [(route, d) | (route, Just d) <- validRoutes]
    in case validDistances of
        [] -> []  -- Return an empty path if no valid routes are found
        _  -> fst $ findMinDistance validDistances




-- FUNÇÕES AUXILIARES 

-- Usadas no 7.isStronglyConnected

-- Função auxiliar para encontrar todas as cidades acessíveis a partir de uma cidade inicial
reachableFrom :: RoadMap -> City -> [City]
reachableFrom roadMap start = dfs roadMap [start] []

-- Implementação de DFS para percorrer o grafo e encontrar cidades acessíveis
dfs :: RoadMap -> [City] -> [City] -> [City]
dfs _ [] visited = visited
dfs roadMap (c:cs) visited
    | c `elem` visited = dfs roadMap cs visited  -- Cidade já visitada, continuar
    | otherwise = dfs roadMap (adjacentCities ++ cs) (c:visited)
    where
        adjacentCities = [neighbor | (neighbor, _) <- adjacent roadMap c]

-- Usadas no 8.ShortestPath

-- Função BFS para explorar todos os caminhos possíveis
bfs :: [Path] -> RoadMap -> City -> [Path]
bfs [] _ _ = [] -- quando não houver mais caminhos na "fila" retorna 
bfs (currentPath:pathsQueue) roadMap end
    | last currentPath == end = currentPath : bfs pathsQueue roadMap end -- se o caminho atual tiver chegado ao destino,adiciona-o e continua com o próximo caminho na "fila"
    | otherwise = bfs (pathsQueue ++ newPaths) roadMap end -- 
  where
    currentCity = last currentPath
    adjacentCities = adjacent roadMap currentCity
    newPaths = [currentPath ++ [nextCity] | (nextCity, _ ) <- adjacentCities,  nextCity `notElem` currentPath] -- adicionar novos caminhos com base nas cidades adjacentes

-- Função para filtrar os caminhos de menor distância encontrados
filterMinPaths :: [Path] -> RoadMap -> [Path]
filterMinPaths paths roadMap =
    let distances = [d | Just d <- map (pathDistance roadMap) paths]
    in case distances of
        [] -> []
        _  -> let minDist = minimum distances
              in [path | path <- paths, pathDistance roadMap path == Just minDist]


-- Usada no 10. TspBruteForce
-- Helper function to find the route with the minimum distance
findMinDistance :: [(Path, Distance)] -> (Path, Distance)
findMinDistance (x:xs) = foldl minByDistance x xs
  where
    minByDistance acc@(route1, dist1) current@(route2, dist2) =
        if dist2 < dist1 then current else acc


--Usada no 9.TravelSales
type AdjMatrix = Data.Array.Array (Int, Int) (Maybe Distance)

createAdjacencyMatrix :: [City] -> RoadMap -> AdjMatrix
createAdjacencyMatrix citiesList roadMap = Data.Array.array ((0, 0), (n-1, n-1)) elements
  where
    n = length citiesList
    cityIndex = zip citiesList [0..]  -- Associa cada cidade a um índice numérico
    indexToCityList = [(idx, city) | (city, idx) <- cityIndex]  -- Lista invertida

    -- Função auxiliar simples para converter um índice numérico em uma cidade
    indexToCity idx = lookup idx indexToCityList

    elements = [((i, j), distanceBetween i j) | i <- [0..n-1], j <- [0..n-1]]

    -- Função que retorna a distância entre duas cidades, se existir
    distanceBetween i j =
      case (indexToCity i, indexToCity j) of
        (Just city1, Just city2) -> distance roadMap city1 city2
        _                        -> Nothing


-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = []

gTest4 :: RoadMap
gTest4 = [("A", "B", 5), ("A", "C", 10), ("A", "D", 8), ("A", "E", 15),
          ("B", "C", 7), ("B", "D", 12), ("B", "E", 9),
          ("C", "D", 4), ("C", "E", 11),
          ("D", "E", 6)]

gTest5 :: RoadMap
gTest5 = [("A", "B", 5), ("A", "C", 10), ("B", "C", 2), ("B", "D", 1), ("C", "D", 3)]

-- Grafo com 7 cidades
gTestMedium :: RoadMap
gTestMedium = 
  [ ("A", "B", 10)
  , ("A", "C", 15)
  , ("A", "D", 20)
  , ("A", "E", 30)
  , ("B", "C", 35)
  , ("B", "D", 25)
  , ("B", "E", 20)
  , ("C", "D", 30)
  , ("C", "E", 5)
  , ("C", "F", 25)
  , ("D", "E", 15)
  , ("D", "F", 20)
  , ("E", "F", 10)
  , ("F", "G", 30)
  , ("G", "A", 50)
  , ("G", "B", 40)
  , ("G", "C", 35)
  , ("G", "D", 30)
  , ("G", "E", 25)
  ]

    -- Grafo com 10 cidades
gTestLarge :: RoadMap
gTestLarge = 
  [ ("A", "B", 10)
  , ("A", "C", 15)
  , ("A", "D", 20)
  , ("A", "E", 25)
  , ("A", "F", 30)
  , ("B", "C", 35)
  , ("B", "D", 25)
  , ("B", "E", 40)
  , ("B", "F", 20)
  , ("C", "D", 30)
  , ("C", "E", 5)
  , ("C", "F", 20)
  , ("D", "E", 15)
  , ("D", "F", 10)
  , ("E", "F", 5)
  , ("A", "G", 50)
  , ("B", "G", 45)
  , ("C", "G", 40)
  , ("D", "G", 35)
  , ("E", "G", 30)
  , ("F", "G", 25)
  , ("G", "H", 30)
  , ("H", "I", 20)
  , ("I", "J", 15)
  , ("H", "A", 25)
  , ("I", "B", 35)
  , ("J", "C", 30)
  , ("J", "D", 20)
  , ("J", "E", 10)
  , ("J", "F", 5)
  ]
