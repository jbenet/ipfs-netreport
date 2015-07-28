lgway="http://localhost:8080/ipfs/"
ggway="http://gateway.ipfs.io/ipfs/"

publish: report
	@echo "--> publishing report"
	@export hash=$(shell ipfs add -r -q report | tail -n1); \
		echo "$$hash" >>reports; \
		echo "published report $$hash"; \
		echo "$(lgway)$$hash"; \
		echo "$(ggway)$$hash"

check-ipfs:
	@ipfs version >/dev/null || (echo "please install ipfs and run: ipfs daemon" && exit 1)
	@ipfs swarm peers >/dev/null 2>&1 || (echo "ipfs is offline. please run: ipfs daemon" && exit 1)

report: check-ipfs
	@echo "--> generating report"
	mkdir -p report
	ipfs id >report/id
	ipfs swarm peers >report/peers
	ipfs swarm addrs >report/addrs
	ipfs swarm filters >report/filters
	ipfs bitswap stat >report/bitswap-stat
	ifconfig | grep inet >report/ifconfig
	cp Makefile report/Makefile # to spread the love

bootstrap: check-ipfs
	@echo "--> publishing netreport"
	@export ipath=$(shell ipfs add -q -w Makefile | tail -n1 | sed s/\\/Makefile// ); \
		echo "published netreport $$ipath"; \
		echo "$(lgway)$$ipath"; \
		echo "$(ggway)$$ipath"; \
		echo "tell the user to run:"; \
		echo "\n\tipfs get -o netreport /ipfs/$$ipath"; \
		echo "\tcd netreport"; \
		echo "\tmake";

clean:
	rm reports
	rm -rf report

.PHONY: clean bootstrap check-ipfs publish report
