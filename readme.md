# demos

optional: get the [heroku toolbelt](https://toolbelt.heroku.com/)

```
git clone https://github.com/aeosynth/demos.git
cd demos
npm install
node server.js # or `npm start`, or (heroku) `foreman start`
```

push to heroku

```
heroku login
heroku create [MYAPP] #heroku will generate a random name if none given
git push heroku master
heroku open
```
