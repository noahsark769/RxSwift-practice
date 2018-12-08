.PHONY: bundle
bundle:
	bundle install --path vendor/bundle

.PHONY: pods
pods:
	bundle exec pod install

.PHONY: clean
clean:
	rm -rf Pods
