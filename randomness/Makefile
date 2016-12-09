CONTEXT =

build: elm.js

elm.js: Main.elm ../vendor/Benchmark/Stats.elm ../vendor/Benchmark.elm ../vendor/Benchmark/Program.elm ../vendor/Native/Benchmark.js
	$(CONTEXT) elm package install --yes
	$(CONTEXT) elm make --yes Main.elm --output=elm.js
