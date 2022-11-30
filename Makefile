SHELL = bash
LUA := lua5.4
MAIN = main.lua

run = \
	printf "%-18.18s " "$(1)"; \
	start="$$(date +%s%N)"; \
	$(LUA) $(MAIN) "$(1)" || exit 1; \
	end="$$(date +%s%N)"; \
	printf "(%3.f ms) " "$$(expr \( $$end - $$start \) / 1000000)"; \
	echo "OK"

.PHONY: test
test: unit-test integration-test

.PHONY: unit-test
unit-test:
	@ for file in test/*_test.lua; do \
		printf "%-26s  " "$$file"; \
		$(LUA) "$$file" || exit 1; \
		printf "OK\n"; \
	done

.PHONY: integration-test
integration-test:
	@ $(call run,examples/the-little-schemer/run-all.scm)
	@ $(call run,examples/fibo.scm)
	@ $(call run,examples/fibo-tco.scm)

.PHONY: repl
repl:
	@ $(LUA) $(MAIN)

.PHONY: lines
lines:
	@ find . -type f \( -name "*.lua" -not -name "*_test.lua" \) -exec cat {} \; | grep . | wc -l

# requires luastatic: https://github.com/ers35/luastatic
# and lualib5.4-dev
main: *.lua
	luastatic main.lua envir.lua eval.lua parser.lua reader.lua scheme.lua types.lua \
		-l$(LUA) -I/usr/include/$(LUA)

.PHONY: clean
clean:
	@ rm -rf main main.luastatic.c
