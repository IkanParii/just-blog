# Stage 1: Build Jekyll
FROM ruby:3.3-alpine AS builder

RUN apk add --no-cache \
    build-base \
    gcc \
    cmake \
    git

WORKDIR /srv/jekyll

COPY Gemfile* ./
RUN bundle config set --local without 'test' && bundle install

COPY . .

# url dan baseurl diatur di _config.yml (jangan di-hardcode di sini).
ENV JEKYLL_ENV=production
RUN bundle exec jekyll build -d _site

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=builder /srv/jekyll/_site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
