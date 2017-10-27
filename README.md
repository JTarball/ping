# ping Ping Service

[![](https://images.microbadger.com/badges/image/newtonsystems/ping:0.0.1.svg)](https://microbadger.com/images/newtonsystems/ping:0.0.1 "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/newtonsystems/ping:0.0.1.svg)](https://microbadger.com/images/newtonsystems/ping:0.0.1 "Get your own version badge on microbadger.com")

Available from docker hub as [newtonsystems/ping](https://hub.docker.com/r/newtonsystems/ping/)

#### Supported tags and respective `Dockerfile` links

-    [`latest` (/Dockerfile*)](https://github.com/newtonsystems/devops/blob/master/tools/ping/Dockerfile)

# What is ping?

A bare knuckle microservice for checking the communication between to gRPC microservices with uses
linkerd as a proxy for communicating against nodes.
The idea is to have a microservice (this one) to ping against that is less likely to fail
due to application error.


## How to use

- Add to Kubernetes with linkerd 
- Add a service
- Send a Ping message to this service via linkerd. (do a grpc dial to linkerd service)

```bash
ping.Ping
```

## How to test a localhost with the outside work

Sometimes this service will need to connect to the outside world when working locally for testing etc.

We use ngrok to create secure tunnels to the localhost

Once you have installed ngrok:

```bash
ngrok http localhost:50000
```



## How to do a release
- Make sure you are using docker-utils
i.e.

```bash
export PATH="~/<LOCATION>/docker-utils/bin:$PATH"
```

```
build-tag-push-dockerfile.py  --image "newtonsystems/ping" --version 0.1.0 --dockerhub_release --github_release
```

## Future

- Not sure at the moment, sorry boss
