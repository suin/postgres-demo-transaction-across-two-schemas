demo:
	docker-compose up -d
	docker-compose exec postgres ./demo.sh

clean:
	docker-compose stop
	docker-compose rm -f
