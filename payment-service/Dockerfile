FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY shared/ shared/
COPY payment-service/ payment-service/
WORKDIR /app/payment-service
RUN go mod download && go build -o payment-service .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/payment-service/payment-service .
EXPOSE 8081
CMD ["./payment-service"]
