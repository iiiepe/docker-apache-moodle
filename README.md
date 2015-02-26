# Docker image with Apache and PHP running on Ubuntu 14.04
Docker image with Apache optimized to run Moodle websites

Inclues:

- Composer
- PHP uploadprogress

### Build

		$ make build

		or

		$ docker build --tag=yourname/apache-moodle .

### Use
The website will be loaded from /var/www so make sure you add your files there.

		$ docker run -d -v application:/var/www -p 80:80 iiiepe/apache-moodle

#### With fig

		web:
		  image: iiiepe/apache-moodle
		  volumes:
		    - application:/var/www
		    - logs:/var/log/supervisor
		  ports:
		    - "8000:80"