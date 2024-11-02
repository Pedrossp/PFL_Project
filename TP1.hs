import qualified Data.List
import qualified Data.Array
import qualified Data.Bits


-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

cities :: RoadMap -> [City]
cities roadMap = Data.List.nub [city | (c1, c2, _) <- roadMap, city <- [c1, c2]]

areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent roadMap c1 c2 = or [(c1 == c3 && c2 == c4) || (c1 == c4 && c2 == c3) | (c3, c4, w_) <- roadMap] --quando as duas cidades são a mesma é para retornar true or false (|| (c1 == c2))

distance :: RoadMap -> City -> City -> Maybe Distance
distance roadMap c1 c2 =  case [d | (c3, c4, d) <- roadMap, (c1 == c3 && c2 == c4) || (c1 == c4 && c2 == c3)] of
    []      -> Nothing
    (d:_)   -> Just d

adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent roadMap c1 = [(c2, d) | c2 <- cities roadMap, Just d <- [distance roadMap c1 c2],  areAdjacent roadMap c2 c1]

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

rome :: RoadMap -> [City]
rome roadMap = [city | (city, x) <- citiesDegrees, x == maximum[b | (_, b) <- citiesDegrees]]
    where citiesDegrees = [(city, fromIntegral (length (adjacent roadMap city))) | city <- cities roadMap]

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected roadMap = let allCities = cities roadMap
    in case allCities of
        []      -> True  -- Um grafo vazio é fortemente conexo
        (c:_)   -> let reachable = reachableFrom roadMap c
                   in all (`elem` reachable) allCities 

shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath roadMap start end
    | start == end = [[start]]  -- Caso especial onde o ponto inicial é o mesmo que o destino
    | otherwise    = filterMinPaths (bfs [[start]] roadMap end) roadMap

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


travelSales :: RoadMap -> Path
travelSales = undefined

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

-- Helper function to find the route with the minimum distance
findMinDistance :: [(Path, Distance)] -> (Path, Distance)
findMinDistance (x:xs) = foldl minByDistance x xs
  where
    minByDistance acc@(route1, dist1) current@(route2, dist2) =
        if dist2 < dist1 then current else acc
-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]

gTest4 :: RoadMap
gTest4 = [("A", "B", 5), ("A", "C", 10), ("A", "D", 8), ("A", "E", 15),
          ("B", "C", 7), ("B", "D", 12), ("B", "E", 9),
          ("C", "D", 4), ("C", "E", 11),
          ("D", "E", 6)]
test :: RoadMap -> City -> [City]
test roadMap = undefined

--type Graph = [(City,[City],Bool)]

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
