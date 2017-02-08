# Tests for submitting PCG to core

## Performance benchmarks
Clone the `mgold/core` fork locally and check out this branch, `random-pcg-tests`.

`cd benchmark`, then run `elm-reactor`.

In the browser, navigate to `Main.elm`. The tests will start running.

## Randomness tests
This is done with Dieharder (`brew install dieharder`). Unfortunately it needs a
lot of random numbers, which are hard to get out of JavaScript. Ultimately I
ran the Elm code in Node until it ran out of memory.

`cd randomness` then `make` then `mv elm.js old-random.js`. Change `Main.elm` to
import `NewRandom` instead of `Random`, recompile, move it to `new-random.js`.

Run `gcc convert-digits.c`. Now you are ready to start generating a binary file
full of random bits:

```
node old-random.js | ./a.out | xxd -r -p > old-random.bin
```

Do the same for new-random.js piping to a different file. Eventually (half an
hour?) node will run out of memory.

The new-random.bin file will likely be much larger than the old random one; use
`wc -c filename` to find out. Run `head -c INTEGER new-random.bin > new-random-trunc.bin`
to create a file with exactly the same amount of new randomness as the old one.

Even though these files will be 10-40MB, that's still barely enough to run the
first dieharder test. (It still rewinds it, five times in my testing, but new
passes and old fails.) To run that test:

```
dieharder -d 0 -g 201 -f new-random-trunc.bin
```

In my testing, new-random passes in a second, but old-random takes 30 seconds to
fail.


