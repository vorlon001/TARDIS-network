FROM golang:1.16 AS builder
WORKDIR /app
RUN go get -d -v golang.org/x/net/html  
COPY app.go    ./
COPY go.mod    ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# FROM alpine:latest
FROM sregistry.iblog.pro/labs/alpine/lab.alpine:3.14-v1

RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/app ./
CMD ["./app"]  
