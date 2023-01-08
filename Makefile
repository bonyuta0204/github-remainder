build-image:
	@docker build --tag=bonyuta0204/github-remainder:latest .

publish-image: build-image
	@docker push bonyuta0204/github-remainder

