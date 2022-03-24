RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

BACKUPS_PATH := ./data/backups/postgres

run:
	docker-compose -f docker-compose.yml up --build -d

psql:
	docker-compose exec postgres psql -U postgres postgres

pg_dump:
	mkdir -p data/backups/postgres && docker-compose exec -T postgres pg_dump -U postgres postgres --no-owner \
	| gzip -9 > data/backups/postgres/backup-$(shell date +%Y-%m-%d_%H-%M-%S).sql.gz

pg_restore:
	mkdir -p data/backups/postgres && bash ./bin/pg_restore.sh ${BACKUPS_PATH}

exec:
	docker-compose exec bot /bin/bash

logs:
	docker-compose logs -f bot

restart:
	docker-compose restart bot

stop:
	docker-compose stop

pybabel_extract:
	pybabel extract --input-dirs=. -o data/locales/bot.pot --project=bot

pybabel_init:
	pybabel init -i data/locales/bot.pot -d data/locales -D bot -l ${RUN_ARGS}

pybabel_compile:
	pybabel compile -d data/locales -D bot --statistics

pybabel_update:
	pybabel update -i data/locales/bot.pot -d data/locales -D bot