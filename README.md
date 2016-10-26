
# twilio_sample

## setup

1. install dependencies

  ```bash
$ bundle install --path vendor/bundle
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

or

```
$ foreman start
```
## console

```bash
$ bundle exec pry -e "require './twilio'"
```

## documents

- TwiML https://jp.twilio.com/docs/api/twiml#verbs
