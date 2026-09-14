.PHONY: javascript typescript python ruby go rust

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
