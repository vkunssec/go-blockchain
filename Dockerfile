FROM golang:alpine AS builder
WORKDIR /app
COPY . /app/
RUN GOPROXY="https://goproxy.io,direct" go mod download
RUN go install github.com/swaggo/swag/cmd/swag@latest
RUN swag init -g cmd/main.go --parseDependency --parseInternal
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o application ./cmd/main.go

FROM alpine:latest AS prd
RUN apk add ca-certificates dumb-init
WORKDIR /app
COPY --from=builder /app/.env .
COPY --from=builder /app/application .
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["./application"]
