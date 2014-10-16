
cronfile=cron

install:
	@echo '#min hour mday month wday command' > $(cronfile)
	@echo '0 10 * * * bash $(CURDIR)/bing-wallpaper.sh' >> $(cronfile)
	@crontab $(CURDIR)/$(cronfile)
