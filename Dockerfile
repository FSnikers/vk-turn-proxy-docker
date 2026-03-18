FROM golang:1.25 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o /out/client ./client && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o /out/server ./server

FROM debian:bookworm-slim AS runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*
COPY docker/entrypoint-client.sh /usr/local/bin/entrypoint-client.sh
COPY docker/entrypoint-server.sh /usr/local/bin/entrypoint-server.sh
COPY --from=build /out/client /usr/local/bin/vk-turn-client
COPY --from=build /out/server /usr/local/bin/vk-turn-server
RUN chmod +x /usr/local/bin/entrypoint-client.sh /usr/local/bin/entrypoint-server.sh

FROM runtime AS client
ENTRYPOINT ["/usr/local/bin/entrypoint-client.sh"]

FROM runtime AS server
ENTRYPOINT ["/usr/local/bin/entrypoint-server.sh"]
