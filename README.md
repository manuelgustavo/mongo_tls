# mongo_tls

Mongodb container image with TLS support that requires user name and password.

>Note: For **development purposes**, since it will create self-signed certificates.

## Steps

### Create the docker image

``` bash
./create_image.sh
```

This command should create a local image called `mongo_local`.

It will create self-signed certificates,

Then you can start the mongo_local image.

``` bash
docker run -d -p 27017:27017 --name mymongo mongo_local:latest
```

You can check what's going on within the container with:

``` bash
docker logs -f mymongo 
```

mongosh --tls --host 127.0.0.1 --port 27017 --sslAllowInvalidCertificates --username admin --password 'mysecretpassword*123'

**TODO: Make the users passwords configurable.**
