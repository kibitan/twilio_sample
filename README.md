
# twilio_sample

## setup

1. install dependencies

  ```bash
$ bundle install --path vendor/bundle
$ cp .envrc.sample .envrc
  ```

1. set ACCOUNT SID, AUTH TOKEN, PHONE_NUMBER to .envrc

  ```bash
$ brew install direnv
$ cp .envrc.sample .envrc
$ vim .envrc
$ direnv allow
  ```

## boot

```bash
$ brew cask install ngrok
$ bundle exec ruby twilio.rb
$ ngrok http 4567
```

## console

```bash
$ bundle exec pry -e "require './twilio'"
```
