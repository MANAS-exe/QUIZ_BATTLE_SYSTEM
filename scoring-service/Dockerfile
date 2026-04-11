FROM golang:1.25-alpine AS build
WORKDIR /app
COPY shared/ ./shared/
COPY proto/ ./proto/
COPY scoring-service/ ./scoring-service/
WORKDIR /app/scoring-service
RUN go mod download && CGO_ENABLED=0 go build -o /service .

FROM alpine:3.20
COPY --from=build /service /service
ENTRYPOINT ["/service"]
