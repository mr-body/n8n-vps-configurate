DOMAIN=seudomain
EMAIL=seuemail@exemplo.com

gen_certbot: move_cert
	sudo certbot certonly --standalone \
	-d $(DOMAIN) \
	--agree-tos \
	--email $(EMAIL) \
	--non-interactive

certbot: gen_certbot
	sudo cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem /root/n8n/cert/ 
	sudo cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem /root/n8n/cert/

build:
	docker compose build

clean:
	docker compose down -v --remove-orphans

build--no-cache:
	docker compose build --no-cache

up:
	docker compose up -d

ps:
	docker compose ps

down:
	docker compose down

logs:
	docker compose logs -f

renew:
	sudo certbot renew --quiet