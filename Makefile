.PHONY: javascript typescript python ruby go rust csharp java zig kotlin swift cpp elixir

javascript:
	node javascript/evm.js

typescript:
	node typescript/evm.test.ts

python:
	python3 python/evm.py

ruby:
	ruby ruby/evm.rb

go:
	cd go && go test -count=1 -v ./...

rust:
	cd rust && cargo run

csharp:
	cd csharp && dotnet run evm.cs

java: java/.deps/gson-2.14.0.jar
	cd java && java --class-path .deps/gson-2.14.0.jar Evm.java

java/.deps/gson-2.14.0.jar:
	mkdir -p java/.deps
	curl -fL https://repo.maven.apache.org/maven2/com/google/code/gson/gson/2.14.0/gson-2.14.0.jar -o $@.tmp
	mv $@.tmp $@

zig:
	cd zig && zig run evm.zig

kotlin: java/.deps/gson-2.14.0.jar
	cd kotlin && kotlin -classpath ../java/.deps/gson-2.14.0.jar evm.kts

swift:
	cd swift && swift run

cpp: cpp/.deps/intx.hpp cpp/.deps/json.hpp
	$(CXX) -std=c++20 -Icpp/.deps cpp/evm.cpp -o cpp/evm
	cd cpp && ./evm

cpp/.deps/intx.hpp:
	mkdir -p cpp/.deps
	curl -fL https://raw.githubusercontent.com/chfast/intx/v0.15.0/include/intx/intx.hpp -o $@.tmp
	mv $@.tmp $@

cpp/.deps/json.hpp:
	mkdir -p cpp/.deps
	curl -fL https://raw.githubusercontent.com/nlohmann/json/v3.12.0/single_include/nlohmann/json.hpp -o $@.tmp
	mv $@.tmp $@

elixir:
	cd elixir && elixir evm.exs
