FROM golang:1.21-alpine AS build
WORKDIR /app
COPY notification-worker/ ./notification-worker/
WORKDIR /app/notification-worker
RUN go mod tidy && CGO_ENABLED=0 go build -o /service .

FROM alpine:3.20
# ca-certificates required for Firebase HTTPS calls
RUN apk --no-cache add ca-certificates
COPY --from=build /service /service
ENTRYPOINT ["/service"]
