module Main exposing (main)

import Benchmark exposing (Bench, Suite, bench, suite)
import Benchmark.Program exposing (program)
import Random as ORan
import NewRandom as NRan


main =
    program [mySuite]


oseed : ORan.Seed
oseed =
    ORan.initialSeed 141053960


nseed : NRan.Seed
nseed =
    NRan.initialSeed 141053960

n =
    1000


mySuite : Suite
mySuite =
    suite
        "Random number suite"
        [ bench "OLD: flip a coin" (\_ -> ORan.step ORan.bool oseed)
        , bench "NEW: flip a coin" (\_ -> NRan.step NRan.bool nseed)
        , bench ("OLD: flip " ++ toString n ++ " coins") (\_ -> ORan.step (ORan.list n ORan.bool) oseed)
        , bench ("NEW: flip " ++ toString n ++ " coins") (\_ -> NRan.step (NRan.list n NRan.bool) nseed)
        , bench "OLD: generate an integer 100-200" (\_ -> ORan.step (ORan.int 100 200) oseed)
        , bench "NEW: generate an integer 100-200" (\_ -> NRan.step (NRan.int 100 200) nseed)
        , bench "OLD: generate an integer 0-4094" (\_ -> ORan.step (ORan.int 0 4094) oseed)
        , bench "NEW: generate an integer 0-4094" (\_ -> NRan.step (NRan.int 0 4094) nseed)
        , bench "OLD: generate an integer 0-4095" (\_ -> ORan.step (ORan.int 0 4095) oseed)
        , bench "NEW: generate an integer 0-4095" (\_ -> NRan.step (NRan.int 0 4095) nseed)
        , bench "OLD: generate an integer 0-4096" (\_ -> ORan.step (ORan.int 0 4096) oseed)
        , bench "NEW: generate an integer 0-4096" (\_ -> NRan.step (NRan.int 0 4096) nseed)
        , bench "OLD: generate a massive integer" (\_ -> ORan.step (ORan.int 0 4294967295) oseed)
        , bench "NEW: generate a massive integer" (\_ -> NRan.step (NRan.int 0 4294967295) nseed)
        , bench "OLD: generate a percentage" (\_ -> ORan.step (ORan.float 0 1) oseed)
        , bench "NEW: generate a percentage" (\_ -> NRan.step (NRan.float 0 1) nseed)
        , bench ("OLD: generate " ++ toString n ++ " percentages") (\_ -> ORan.step (ORan.list n (ORan.float 0 1)) oseed)
        , bench ("NEW: generate " ++ toString n ++ " percentages") (\_ -> NRan.step (NRan.list n (NRan.float 0 1)) nseed)
        , bench "OLD: generate an float 100-200" (\_ -> ORan.step (ORan.float 100 200) oseed)
        , bench "NEW: generate an float 100-200" (\_ -> NRan.step (NRan.float 100 200) nseed)
        , bench "OLD: generate a float 0-4094" (\_ -> ORan.step (ORan.float 0 4094) oseed)
        , bench "NEW: generate a float 0-4094" (\_ -> NRan.step (NRan.float 0 4094) nseed)
        , bench "OLD: generate a float 0-4095" (\_ -> ORan.step (ORan.float 0 4095) oseed)
        , bench "NEW: generate a float 0-4095" (\_ -> NRan.step (NRan.float 0 4095) nseed)
        , bench "OLD: generate a float 0-4096" (\_ -> ORan.step (ORan.float 0 4096) oseed)
        , bench "NEW: generate a float 0-4096" (\_ -> NRan.step (NRan.float 0 4096) nseed)
        , bench "OLD: generate a massive float" (\_ -> ORan.step (ORan.float 0 4294967295) oseed)
        , bench "NEW: generate a massive float" (\_ -> NRan.step (NRan.float 0 4294967295) nseed)
        ]
