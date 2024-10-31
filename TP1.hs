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
areAdjacent roadMap c1 c2 = or [(c1 == c3 && c2 == c4) || (c1 == c4 && c2 == c3) | (c3, c4, _) <- roadMap] --quando as duas cidades são a mesma é para retornar true or false (|| (c1 == c2))

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
isStronglyConnected = undefined

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
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]