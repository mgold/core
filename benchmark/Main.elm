module Main exposing (main)

import Benchmark exposing (Benchmark, describe, benchmark2)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Random as ORan
import NewRandom as NRan


main =
    program mySuite


oseed : ORan.Seed
oseed =
    ORan.initialSeed 141053960


nseed : NRan.Seed
nseed =
    NRan.initialSeed 141053960


n =
    1000


comparison : String -> ORan.Generator a -> NRan.Generator a -> Benchmark
comparison description ogen ngen =
    Benchmark.compare description
        (benchmark2 "OLD" ORan.step ogen oseed)
        (benchmark2 "NEW" NRan.step ngen nseed)


mySuite : Benchmark
mySuite =
    describe
        "Random number suite"
        [ comparison "flip a coin" ORan.bool NRan.bool
        , comparison ("flip " ++ toString n ++ " coins") (ORan.list n ORan.bool) (NRan.list n NRan.bool)
        , comparison "generate an integer 100-200" (ORan.int 100 200) (NRan.int 100 200)
        , comparison "generate an integer 0-4094" (ORan.int 0 4094) (NRan.int 0 4094)
        , comparison "generate an integer 0-4095" (ORan.int 0 4095) (NRan.int 0 4095)
        , comparison "generate an integer 0-4096" (ORan.int 0 4096) (NRan.int 0 4096)
        , comparison "generate a massive integer" (ORan.int 0 4294967295) (NRan.int 0 4294967295)
        , comparison "generate a percentage" (ORan.float 0 1) (NRan.float 0 1)
        , comparison ("generate " ++ toString n ++ " percentages") (ORan.list n (ORan.float 0 1)) (NRan.list n (NRan.float 0 1))
        , comparison "generate an float 100-200" (ORan.float 100 200) (NRan.float 100 200)
        , comparison "generate a float 0-4094" (ORan.float 0 4094) (NRan.float 0 4094)
        , comparison "generate a float 0-4095" (ORan.float 0 4095) (NRan.float 0 4095)
        , comparison "generate a float 0-4096" (ORan.float 0 4096) (NRan.float 0 4096)
        , comparison "generate a massive float" (ORan.float 0 4294967295) (NRan.float 0 4294967295)
        ]
