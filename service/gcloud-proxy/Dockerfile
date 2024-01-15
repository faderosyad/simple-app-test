FROM golang:1.21-alpine as builder

WORKDIR /src/

# Dependencies fetching will be done firstly before build. With this approach, multilayer caching feature in Docker could be implemented.
COPY go.mod go.sum ./
RUN go mod download

COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/app

# Distribution
FROM gcr.io/distroless/static as final

ENV TZ=Asia/Jakarta

WORKDIR /

COPY --from=builder /out/app .

ENTRYPOINT ["./app"]
