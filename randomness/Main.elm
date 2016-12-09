module Main exposing (..)

import Html
import Random as Ran
import String

main =
    let
        ceiling = 2^32 - 1
        gen = Ran.int 0 ceiling
        seed0 = Ran.initialSeed 2089634570
        generate seed =
            let
                (val, newSeed) = Ran.step gen seed
                padded = String.padLeft 10 '0' (toString val)
                _ = Debug.log padded ""
            in
                generate newSeed
        _ = generate seed0
        -- vals = Ran.step (Ran.list n gen) seed |> Tuple.first |> Debug.log ""
    in
        Html.text "Check the console!"
